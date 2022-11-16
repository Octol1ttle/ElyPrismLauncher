#include "ClaimAccount.h"
#include <launch/LaunchTask.h>

#include "Application.h"
#include "minecraft/auth/AccountList.h"

bool ClaimAccount::isMSA = false;

ClaimAccount::ClaimAccount(LaunchTask* parent, AuthSessionPtr session): LaunchStep(parent)
{
    if(session->status == AuthSession::Status::PlayableOnline && !session->demo)
    {
        auto accounts = APPLICATION->accounts();
        m_account = accounts->getAccountByProfileName(session->player_name);
		ClaimAccount::isMSA = m_account->isMSA();
    }
}

QString ClaimAccount::m_injectorPath = QString("");
void ClaimAccount::executeTask()
{
	auto entry = APPLICATION->metacache()->resolveEntry("general", "authlib-injector.jar");
	entry->setStale(true);
	ClaimAccount::m_injectorPath = entry->getFullPath();
	
	auto netJob = new NetJob("Injector download", APPLICATION->network());
	netJob->addNetAction(Net::Download::makeCached(QUrl("https://github.com/yushijinhun/authlib-injector/releases/download/v1.2.1/authlib-injector-1.2.1.jar"), entry));
	netJob->start();
    if(m_account)
    {
        lock.reset(new UseLock(m_account));
        emitSucceeded();
    }
}

void ClaimAccount::finalize()
{
    lock.reset();
}
