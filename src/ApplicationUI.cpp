#include "ApplicationUI.hpp"
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/system/Clipboard>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeTargetReply>
#include <iostream>

// Declare namespaces
using namespace bb::cascades;
using namespace bb::system;
using namespace std;

// Constants
static const QString g_strDefaultEnableStartupRefresh = "true";
static const QString g_strDefaultMarket = "en-US";
static const QString g_strDefaultOrientation = "768_1280";

// Constructor
ApplicationUI::ApplicationUI(bb::cascades::Application* app) :
    QObject(app),
    m_pInvokeManager(new InvokeManager(this)),
    m_pTranslator(new QTranslator(this)),
    m_pLocaleHandler(new LocaleHandler(this))
{
    // We set up the application Organization and name, this is used by QSettings
    // when saving values to the persistent store.
    QCoreApplication::setOrganizationName("JamesGordy");
    QCoreApplication::setApplicationName("BingImage");

    // Set default parameters
    QSettings settings;
    if( settings.value("EnableStartupRefresh").isNull() )
    {
        settings.setValue("EnableStartupRefresh", g_strDefaultEnableStartupRefresh);
    }
    if( settings.value("Market").isNull() )
    {
        settings.setValue("Market", g_strDefaultMarket);
    }
    if( settings.value("Orientation").isNull() )
    {
        settings.setValue("Orientation", g_strDefaultOrientation);
    }

	// Connect us to receive localization change signal
    if( !QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged())) )
    {
        // This is an abnormal situation! Something went wrong!
        // Add own code to recover here
        qWarning() << "Recovering from a failed connect()";
    }

    // initial load
    onSystemLanguageChanged();

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument* qml = QmlDocument::create("asset:///main.qml").parent(this);
    if( !qml->hasErrors() )
    {
        // Register us
        qml->setContextProperty("mainApp", this);

        // Create root object for the UI
        AbstractPane* root = qml->createRootObject<AbstractPane>();

        // Set created root object as the application scene
        app->setScene(root);
    }
}

ApplicationUI::~ApplicationUI()
{
}

// Set or retrieve configuration parameter
void ApplicationUI::setParameter(const QString& parameter, const QString& value)
{
    // Persist the parameter
    QSettings settings;
    settings.setValue(parameter, QVariant(value));
}

// Set or retrieve configuration parameter
QString ApplicationUI::getParameter(const QString& parameter, const QString& defaultValue)
{
    QSettings settings;

    // First check if the parameter exists
    if( settings.value(parameter).isNull() )
    {
        return defaultValue;
    }

    // Retrieve the parameter from the persistent store
    QString result = settings.value(parameter).toString();
    return result;
}

// Helper function to copy URL to clipboard
void ApplicationUI::copyUrl(const QUrl& url, const QString& mimeType)
{
	// Create a clipboard instance and add URL
	Clipboard clipboard;
	clipboard.clear();
	clipboard.insert(mimeType, url.toString().toUtf8());
}

// Helper function to trigger picture editor and set wallpaper
void ApplicationUI::setWallpaper(const QUrl& url)
{
    // Create an invocation request
    InvokeRequest request;
    request.setTarget("sys.pictureeditor.setaswallpaper");
    request.setAction("bb.action.SET");
    request.setFileTransferMode(bb::system::FileTransferMode::CopyReadOnly);
    request.setUri(url);
    request.setData(QByteArray("upScale:b:false\n"));

    // Send the invocation request
    InvokeTargetReply* pReply = m_pInvokeManager->invoke(request);
    pReply->deleteLater();
}

void ApplicationUI::onSystemLanguageChanged()
{
	// Remove existing translation files
    QCoreApplication::instance()->removeTranslator(m_pTranslator);

    // Initiate, load and install the application translation files
    QString locale_string = QLocale().name();
    QString file_name = QString("BingImage_%1").arg(locale_string);
    if( m_pTranslator->load(file_name, "app/native/qm") )
    {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}
