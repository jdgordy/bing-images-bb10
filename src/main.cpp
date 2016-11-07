#include <bb/cascades/Application>

#include "ApplicationUI.hpp"
#include "HttpDataSource.hpp"
#include <QLocale>
#include <QTranslator>
#include <Qt/qdeclarativedebug.h>

using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    // Register our custom types with QML, so that they can be used as property types
    qmlRegisterType<HttpDataSource>("my.library", 1, 0, "HttpDataSource");

    Application app(argc, argv);

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    new ApplicationUI(&app);

    // Enter the application main event loop.
    return Application::exec();
}
