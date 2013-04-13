# Add more folders to ship with the application, here
folder_qml.source = qml
folder_qml.target =
DEPLOYMENTFOLDERS = folder_qml

CONFIG += mobility

QT += declarative
MOBILITY += feedback

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# Define QMLJSDEBUGGER to allow debugging of QML in debug builds
# (This might significantly increase build time)
# DEFINES += QMLJSDEBUGGER

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable. 
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES +=\
	main.cpp \
	EditorProxy.cpp \
	Settings.cpp \
	FileSystemModel.cpp

HEADERS+=\
	EditorProxy.h \
	FileSystemModel.h \
	Settings.h \
	../scintilla/qt/ScintillaEditBase/ScintillaQt.h \
	../scintilla/qt/ScintillaEditBase/ScintillaEditBase.h \
	../scintilla/qt/ScintillaEditBase/PlatQt.h

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/script.js \
    qml/PageSettings.qml \
    qml/PageEdit.qml \
    qml/PageBrowse.qml \
    qml/MenuMain.qml \
    qml/main.qml

contains(MEEGO_EDITION,harmattan) {
	icon.files = editmee.png
	icon.path = /usr/share/icons/hicolor/80x80/apps
	INSTALLS += icon
}

contains(MEEGO_EDITION,harmattan) {
	desktopfile.files = editmee.desktop
	desktopfile.path = /usr/share/applications
	INSTALLS += desktopfile
}

contains(MEEGO_EDITION,harmattan) {
	target.path = /opt/EditMee/bin
	INSTALLS += target
}

RESOURCES += \
	resources.qrc

INCLUDEPATH += $$PWD/../scintilla/qt/ScintillaEditBase $$PWD/../scintilla/include/ $$PWD/../scintilla/src/
#LIBS += $$PWD/../../scintilla/bin/libScintillaEditBase.a
LIBS += $$PWD/../scintilla/bin/libScintillaEditBase.a
