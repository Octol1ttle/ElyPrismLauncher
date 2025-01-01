#include "MinecraftProfileStepEly.h"

#include "Application.h"
#include "minecraft/auth/Parsers.h"
#include "net/RawHeaderProxy.h"

MinecraftProfileStepEly::MinecraftProfileStepEly(AccountData* data) : MinecraftProfileStep(data) {}

void MinecraftProfileStepEly::perform()
{
    m_data->yggdrasilToken = m_data->msaToken;

    QUrl url("https://account.ely.by/api/mojang/services/minecraft/profile");
    auto headers = QList<Net::HeaderPair>{ { "Content-Type", "application/json" },
                                           { "Accept", "application/json" },
                                           { "Authorization", QString("Bearer %1").arg(m_data->yggdrasilToken.token).toUtf8() } };

    m_response.reset(new QByteArray());
    m_request = Net::Download::makeByteArray(url, m_response);
    m_request->addHeaderProxy(new Net::RawHeaderProxy(headers));

    m_task.reset(new NetJob("MinecraftProfileStepEly", APPLICATION->network()));
    m_task->setAskRetry(false);
    m_task->addNetAction(m_request);

    connect(m_task.get(), &Task::finished, this, &MinecraftProfileStepEly::onRequestDone);

    m_task->start();
}