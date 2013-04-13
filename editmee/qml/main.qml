import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {

	//#{ settings section
	property bool editorToolBar: Settings.getValue('editor.tool.bar', true);
	function setEditorToolBar(value) {return editorToolBar = Settings.setValue('editor.tool.bar', value);}

	property string editorToolBarChars: Settings.getValue('editor.tool.bar.chars', ";:='\"(){}[]<>_+-*/\\");
	function setEditorToolBarChars(value) {return editorToolBarChars = Settings.setValue('editor.tool.bar.chars', value);}

	property int editorNavRepeatDelay: Settings.getValue('editorNavRepeatDelay', 500);
	property int editorNavRepeatSpeed: Settings.getValue('editorNavRepeatSpeed', 20);

	property int editorFontSize: +Settings.getValue('editor.font.size', 10);
	function setEditorFontSize(value) {return editorFontSize = Settings.setValue('editor.font.size', value);}

	// TODO property int editorFontType: +Settings.getValue('editor.font.type', 'arial');

	property bool editorWordWrap: Settings.getValue('editor.wrap', false);
	function setEditorWordWrap(value) {return editorWordWrap = Settings.setValue('editor.wrap', value);}

	property bool browseHiddenFiles: Settings.getValue('browse.hidden.files', false);
	function setBrowseHiddenFiles(value) {return browseHiddenFiles = Settings.setValue('browse.hidden.files', value);}

	property bool browseFoldersFirst: Settings.getValue('browse.folders.first', true);
	function setBrowseFoldersFirst(value) {return browseFoldersFirst = Settings.setValue('browse.folders.first', value);}

	property bool browseSortField: Settings.getValue('browse.sort.field', 0);
	//property bool browseSortDesc: Settings.getValue('browse.sort.desc', false);

	property bool browserAutoLoad: Settings.getValue('browserAutoLoad', true);
	function setBrowserAutoLoad(value) {return browserAutoLoad = Settings.setValue('browserAutoLoad', value);}

	property bool browserAutoSave: Settings.getValue('browserAutoSave', false);
	function setBrowserAutoSave(value) {return browserAutoSave = Settings.setValue('browserAutoSave', value);}

	property bool searchMatchCase: Settings.getValue('search.match.case', false);
	function setSearchMatchCase(value) {return searchMatchCase;}
	//doNotSave = Settings.setValue('search.match.case', value);}
	property bool searchWholeWords: Settings.getValue('search.whole.words', false);
	function setSearchWholeWords(value) {return searchWholeWords;}
	//doNotSave = Settings.setValue('search.whole.words', value);}
	property bool searchRegexp: Settings.getValue('search.regexp', false);
	function setSearchRegexp(value) {return searchRegexp;}
	//doNotSave = Settings.setValue('search.regexp', value);}
	//#} settings

	id: app;
	initialPage: editPage

	PageSettings {id: settingsPage}
	PageBrowse {id: browsePage}
	PageEdit {id: editPage}

	QueryDialog {
		id: errorDialog
		titleText: "Error"
		acceptButtonText: "Close"
		message: "error"
	}

	MenuMain {
		id: menuMain
		visualParent: pageStack
	}

	Menu { id: menuEdit
		visualParent: pageStack

		MenuLayout {
			/*MenuItem {
				text: "Undo"
				onClicked: editPage.undo();
			}
			MenuItem {
				text: "Redo"
				onClicked: editPage.redo();
			}*/
			MenuItem {
				text: "Cut"
				onClicked: editPage.cut();
			}
			MenuItem {
				text: "Copy"
				onClicked: editPage.copy();
			}
			MenuItem {
				text: "Paste"
				onClicked: editPage.paste();
			}
			MenuItem {
				text: "Select All"
				onClicked: editPage.selectAll();
			}
		}
	}

	ListModel {
		id: listFavorites;
	}

	Menu { id: menuFavorites
		visualParent: pageStack
		MenuLayout {
			id: menuFavoritesLayout
			Repeater {
				model: listFavorites;
				MenuItem {
					parent: menuFavoritesLayout;
					text: model.text.match('.*/([^/]+)$')[1];
					onClicked: {
						editPage.loadDocument(model.text);
					}
				}
			}
		}
	}

}
