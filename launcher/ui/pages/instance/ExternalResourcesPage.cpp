#include "ExternalResourcesPage.h"
#include "ui/dialogs/CustomMessageBox.h"
#include "ui_ExternalResourcesPage.h"

#include "DesktopServices.h"
#include "Version.h"
#include "minecraft/mod/ResourceFolderModel.h"
#include "ui/GuiUtil.h"

#include <QKeyEvent>
#include <QMenu>

ExternalResourcesPage::ExternalResourcesPage(BaseInstance* instance, std::shared_ptr<ResourceFolderModel> model, QWidget* parent)
    : QMainWindow(parent), m_instance(instance), ui(new Ui::ExternalResourcesPage), m_model(model)
{
    ui->setupUi(this);

    ui->actionsToolbar->insertSpacer(ui->actionViewConfigs);

    m_filterModel = model->createFilterProxyModel(this);
    m_filterModel->setDynamicSortFilter(true);
    m_filterModel->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_filterModel->setSortCaseSensitivity(Qt::CaseInsensitive);
    m_filterModel->setSourceModel(m_model.get());
    m_filterModel->setFilterKeyColumn(-1);
    ui->treeView->setModel(m_filterModel);

    ui->treeView->installEventFilter(this);
    ui->treeView->sortByColumn(1, Qt::AscendingOrder);
    ui->treeView->setContextMenuPolicy(Qt::CustomContextMenu);

    // The default function names by Qt are pretty ugly, so let's just connect the actions manually,
    // to make it easier to read :)
    connect(ui->actionAddItem, &QAction::triggered, this, &ExternalResourcesPage::addItem);
    connect(ui->actionRemoveItem, &QAction::triggered, this, &ExternalResourcesPage::removeItem);
    connect(ui->actionEnableItem, &QAction::triggered, this, &ExternalResourcesPage::enableItem);
    connect(ui->actionDisableItem, &QAction::triggered, this, &ExternalResourcesPage::disableItem);
    connect(ui->actionViewConfigs, &QAction::triggered, this, &ExternalResourcesPage::viewConfigs);
    connect(ui->actionViewFolder, &QAction::triggered, this, &ExternalResourcesPage::viewFolder);

    connect(ui->treeView, &ModListView::customContextMenuRequested, this, &ExternalResourcesPage::ShowContextMenu);
    connect(ui->treeView, &ModListView::activated, this, &ExternalResourcesPage::itemActivated);

    auto selection_model = ui->treeView->selectionModel();
    connect(selection_model, &QItemSelectionModel::currentChanged, this, &ExternalResourcesPage::current);
    connect(ui->filterEdit, &QLineEdit::textChanged, this, &ExternalResourcesPage::filterTextChanged);
}

ExternalResourcesPage::~ExternalResourcesPage()
{
    delete ui;
}

QMenu* ExternalResourcesPage::createPopupMenu()
{
    QMenu* filteredMenu = QMainWindow::createPopupMenu();
    filteredMenu->removeAction(ui->actionsToolbar->toggleViewAction());
    return filteredMenu;
}

void ExternalResourcesPage::ShowContextMenu(const QPoint& pos)
{
    auto menu = ui->actionsToolbar->createContextMenu(this, tr("Context menu"));
    menu->exec(ui->treeView->mapToGlobal(pos));
    delete menu;
}

void ExternalResourcesPage::openedImpl()
{
    m_model->startWatching();

    auto const setting_name = QString("WideBarVisibility_%1").arg(id());
    if (!APPLICATION->settings()->contains(setting_name))
        m_wide_bar_setting = APPLICATION->settings()->registerSetting(setting_name);
    else
        m_wide_bar_setting = APPLICATION->settings()->getSetting(setting_name);

    ui->actionsToolbar->setVisibilityState(m_wide_bar_setting->get().toByteArray());
}

void ExternalResourcesPage::closedImpl()
{
    m_model->stopWatching();

    m_wide_bar_setting->set(ui->actionsToolbar->getVisibilityState());
}

void ExternalResourcesPage::retranslate()
{
    ui->retranslateUi(this);
}

void ExternalResourcesPage::itemActivated(const QModelIndex&)
{
    if (!m_controlsEnabled)
        return;

    auto selection = m_filterModel->mapSelectionToSource(ui->treeView->selectionModel()->selection());
    m_model->setResourceEnabled(selection.indexes(), EnableAction::TOGGLE);
}

void ExternalResourcesPage::filterTextChanged(const QString& newContents)
{
    m_viewFilter = newContents;
    m_filterModel->setFilterRegularExpression(m_viewFilter);
}

bool ExternalResourcesPage::shouldDisplay() const
{
    return true;
}

bool ExternalResourcesPage::listFilter(QKeyEvent* keyEvent)
{
    switch (keyEvent->key()) {
        case Qt::Key_Delete:
            removeItem();
            return true;
        case Qt::Key_Plus:
            addItem();
            return true;
        default:
            break;
    }
    return QWidget::eventFilter(ui->treeView, keyEvent);
}

bool ExternalResourcesPage::eventFilter(QObject* obj, QEvent* ev)
{
    if (ev->type() != QEvent::KeyPress)
        return QWidget::eventFilter(obj, ev);

    QKeyEvent* keyEvent = static_cast<QKeyEvent*>(ev);
    if (obj == ui->treeView)
        return listFilter(keyEvent);

    return QWidget::eventFilter(obj, ev);
}

void ExternalResourcesPage::addItem()
{
    if (!m_controlsEnabled)
        return;

    auto list = GuiUtil::BrowseForFiles(
        helpPage(), tr("Select %1", "Select whatever type of files the page contains. Example: 'Loader Mods'").arg(displayName()),
        m_fileSelectionFilter.arg(displayName()), APPLICATION->settings()->get("CentralModsDir").toString(), this->parentWidget());

    if (!list.isEmpty()) {
        for (auto filename : list) {
            m_model->installResource(filename);
        }
    }
}

void ExternalResourcesPage::removeItem()
{
    if (!m_controlsEnabled)
        return;

    auto selection = m_filterModel->mapSelectionToSource(ui->treeView->selectionModel()->selection());

    int count = 0;
    bool folder = false;
    for (auto& i : selection.indexes()) {
        if (i.column() == 0) {
            count++;

            // if a folder is selected, show the confirmation dialog
            if (m_model->at(i.row()).fileinfo().isDir())
                folder = true;
        }
    }

    QString text;
    bool multiple = count > 1;

    if (multiple) {
        text = tr("You are about to remove %1 items.\n"
                  "This may be permanent and they will be gone from the folder.\n\n"
                  "Are you sure?")
                   .arg(count);
    } else if (folder) {
        text = tr("You are about to remove the folder \"%1\".\n"
                  "This may be permanent and it will be gone from the parent folder.\n\n"
                  "Are you sure?")
                   .arg(m_model->at(selection.indexes().at(0).row()).fileinfo().fileName());
    }

    if (!text.isEmpty()) {
        auto response = CustomMessageBox::selectable(this, tr("Confirm Removal"), text, QMessageBox::Warning,
                                                     QMessageBox::Yes | QMessageBox::No, QMessageBox::No)
                            ->exec();

        if (response != QMessageBox::Yes)
            return;
    }

    removeItems(selection);
}

void ExternalResourcesPage::removeItems(const QItemSelection& selection)
{
    m_model->deleteResources(selection.indexes());
}

void ExternalResourcesPage::enableItem()
{
    if (!m_controlsEnabled)
        return;

    auto selection = m_filterModel->mapSelectionToSource(ui->treeView->selectionModel()->selection());
    m_model->setResourceEnabled(selection.indexes(), EnableAction::ENABLE);
}

void ExternalResourcesPage::disableItem()
{
    if (!m_controlsEnabled)
        return;

    auto selection = m_filterModel->mapSelectionToSource(ui->treeView->selectionModel()->selection());
    m_model->setResourceEnabled(selection.indexes(), EnableAction::DISABLE);
}

void ExternalResourcesPage::viewConfigs()
{
    DesktopServices::openDirectory(m_instance->instanceConfigFolder(), true);
}

void ExternalResourcesPage::viewFolder()
{
    DesktopServices::openDirectory(m_model->dir().absolutePath(), true);
}

bool ExternalResourcesPage::current(const QModelIndex& current, const QModelIndex& previous)
{
    if (!current.isValid()) {
        ui->frame->clear();
        return false;
    }

    return onSelectionChanged(current, previous);
}

bool ExternalResourcesPage::onSelectionChanged(const QModelIndex& current, const QModelIndex& previous)
{
    auto sourceCurrent = m_filterModel->mapToSource(current);
    int row = sourceCurrent.row();
    Resource const& resource = m_model->at(row);
    ui->frame->updateWithResource(resource);

    return true;
}
