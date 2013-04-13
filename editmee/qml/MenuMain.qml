import QtQuick 1.1
import com.nokia.meego 1.0

Menu {
	id: fileMenu
	visualParent: pageStack

	MenuLayout {

		MenuItem {
			text: qsTr("New")
			onClicked: {
				editPage.newDocument();
			}
		}

		MenuItem {
			text: qsTr("Open")
			onClicked: {
				var fileDir = browsePage.getFileDir(editPage.fileName);
				browsePage.reloadChanges();
				pageStack.push(browsePage, {
					workingDir: fileDir,
					filePath: fileDir,
					saveMode: false
				});
			}
		}

		MenuItem {
			text: qsTr("Save")
			onClicked: {
				var fileName = editPage.fileName;
				browsePage.reloadChanges();
				if (fileName.length > 0 && app.browserAutoSave) {
					if (!editPage.saveDocument(fileName)) {
						errorDialog.open();
					}
				}
				else {
					var fileDir = browsePage.getFileDir(fileName);
					pageStack.push(browsePage, {
						workingDir: fileDir,
						filePath: fileName || fileDir,
						saveMode: true
					});
				}
			}
		}

		MenuItem {
			text: qsTr("Settings")
			onClicked: {
				pageStack.push(settingsPage);
			}
		}

		MenuItem {
			text: qsTr("Favorites")
			onClicked: {
				var favorites = Settings.getArray('favorites');
				listFavorites.clear();
				if (favorites.length > 0) {
					for (var i = 0; i < favorites.length; ++i) {
						listFavorites.append({text: favorites[i]});
					}
					if (menuMain.status !== DialogStatus.Closed) {
						menuMain.close();
					}
					if (menuEdit.status !== DialogStatus.Closed) {
						menuEdit.close();
					}
					menuFavorites.open();
				}
			}
		}
	}
}
