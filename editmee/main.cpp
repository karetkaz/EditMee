#include <QtGui/QApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeView>
#include <QDeclarativeContext>
#include <qdeclarative.h>

#include "FileSystemModel.h"
#include "EditorProxy.h"
#include "Settings.h"

int main(int argc, char *argv[]) {

	QApplication app(argc, argv);
	QDeclarativeView window;
	QDeclarativeContext *ctxt = window.rootContext();

	Settings settings(".EditMee", "settings.config");

	qmlRegisterType<EditorProxy>("TextEditor", 1, 0, "SciEditor");
	qmlRegisterType<FileSystemModel>("FileModel", 1, 0, "FileModelItem");

	ctxt->setContextProperty("Settings", &settings);

	window.setSource(QUrl("qrc:/qml/main.qml"));
	window.showFullScreen();

	return app.exec();
}

// see: /home/kmz/Applications/QtSDK/QtSources/4.8.1/src/imports/folderlistmodel/qdeclarativefolderlistmodel.cpp
