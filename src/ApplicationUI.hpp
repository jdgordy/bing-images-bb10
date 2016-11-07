#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QtCore/QObject>
#include <QtCore/QUrl>

// Forward class declarations
namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
    }
    namespace system
    {
        class InvokeManager;
    }
}

class QTranslator;

/*!
 * @brief Application object
 *
 *
 */

class ApplicationUI : public QObject
{
    Q_OBJECT

public:

    // Constructor / destructor
    ApplicationUI(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    // Set or retrieve configuration parameters
    Q_INVOKABLE void setParameter(const QString& parameter, const QString& value);
    Q_INVOKABLE QString getParameter(const QString& parameter, const QString& defaultValue);

    // Helper function to copy URL to clipboard
    Q_INVOKABLE void copyUrl(const QUrl& url, const QString& mimeType);

    // Helper function to trigger picture editor and set wallpaper
    Q_INVOKABLE void setWallpaper(const QUrl& url);

private slots:

    // Handler for system language change
    void onSystemLanguageChanged();

protected:

    // Invocation manager
    bb::system::InvokeManager*  m_pInvokeManager;

    // Localization objects
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
};

#endif /* ApplicationUI_HPP_ */
