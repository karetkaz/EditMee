import QtQuick 1.1
//import Qt.labs.folderlistmodel 1.0
import FileModel 1.0;
import com.nokia.meego 1.0
import "script.js" as Script


Page {
	property bool saveMode: false;
	property alias filePath: location.text
	property alias workingDir: folderModel.folder;

	signal fileSelected(string path, bool doSaveOrLoad);
	signal folderChanged(string path);

	function reloadChanges() {
		//TODO: folderModel.refresh();
		folderModel.setFilters(app.browseFoldersFirst, app.browseSortField, app.browseHiddenFiles, []);
	}

	function getFileDir(filename) {
		if (!folderModel.isPathValid(filename)) {
			return folderModel.folder;
		}
		if (folderModel.isPathFolder(filename)) {
			return filename;
		}
		return Script.directoryOf(filename);
	}

	onFolderChanged: {
		//console.log("browserPage.onFolderChanged: " + path);
		workingDir = path;
		location.text = path;
	}

	onFileSelected: {
		//console.log("browserPage.onFileSelected: " + path);
		location.text = path;
		if (saveMode) {
			if (doSaveOrLoad) {
				if (!editPage.saveDocument(path)) {
					errorDialog.open();
				}
				pageStack.pop();
				//folderModel.refresh();
			}
		}
		else {
			if (doSaveOrLoad || app.browserAutoLoad) {
				if (!editPage.loadDocument(path)) {
					errorDialog.open();
				}
				pageStack.pop();
			}
		}
	}

	anchors.fill: parent

	tools: ToolBarLayout {
		ToolIcon {      //show hiddens
			platformIconId: "toolbar-application"; //TODO
			onClicked: {
				//app.setBrowseHiddenFiles(!app.browseHiddenFiles);
				//platformIconId = 'toolbar-pages-all';
				folderModel.setFilters(app.browseFoldersFirst, app.browseSortField, true, []);
			}
		}

		ToolIcon {   // Home
			iconId: "toolbar-home"
			onClicked: {
				folderChanged(folderModel.homeFolder);
			}
		}

		ToolIcon {   // cd ..
			iconId: "toolbar-up"
			onClicked: {
				folderChanged(folderModel.parentFolder);
			}
		}

		ToolIcon {   // refresh
			iconId: "toolbar-refresh"
			onClicked: {
				folderChanged(folderModel.folder);
			}
		}

		ToolIcon {   // back
			iconId: "toolbar-back"
			onClicked: { pageStack.pop(); }
		}
	}

	Column {
		id: mColumn
		width: parent.width
		height: parent.height

		Row {
			width: parent.width;
			TextField {
				id: location
				text: workingDir
				width: parent.width - 80;
				placeholderText: "File to " + (saveMode ? "Save" : "Open");
				focus: false;

				Keys.onReturnPressed: {
					if (folderModel.isPathFolder(location.text)) {
						folderChanged(location.text);
					}
					else {
						fileSelected(location.text, true);
					}
				}

				/*onFocusChanged: {
					var start = location.text.length;
					location.select(start , start);
					location.focus = true;
				}*/

				Item { //WORKAROUND:
					anchors.fill: parent;
					focus: true;
					Keys.onPressed: {
						if (event.key === Qt.Key_Return) {
							folderModel.folder = text;
							event.accepted = true;
						}
					}
				}
			}

			Button {
				width: 80;
				text: saveMode ? "Save" : "Open";
				onClicked: fileSelected(location.text, true);
			}
		}

		ListView {
			id: listView
			clip: true
			height: parent.height - location.height
			width: parent.width

			FileModelItem {
				id: folderModel;
			}

			Component {
				id: fileDelegate
				Rectangle {
					width: parent.width
					height: 60

					MouseArea {
						id: mouseArea
						anchors.fill: parent

						onClicked: {
							if (folderModel.isFolder(index)) {
								folderChanged(filePath);
							}
							else {
								fileSelected(filePath, false);
							}
						}
					}
					color: ( mouseArea.pressed )
						   ? Script.getSetting('browserBgColorPressed')
						   : Script.getSetting('browserBgColorNormal')
					Row {
						id: fileNameView
						anchors.fill: parent
						anchors.margins: 0
						spacing: 2
						Image {
							id: favIcon
							source: folderModel.isFolder(index)
									? "image://theme/icon-m-toolbar-directory-white"
									: "image://theme/icon-m-toolbar-edit-white"
							anchors.verticalCenter: parent.verticalCenter
						}

						Column {
							width: parent.width - favIcon.width - infoArea.width - parent.spacing
							spacing: 2
							Text {
								width: parent.width
								font.pixelSize: 26
								elide: Text.ElideMiddle
								color: theme.inverted ? "white" : "black"
								text: fileName
							}
							Text {
								width: parent.width
								font.pixelSize: 14
								elide: Text.ElideMiddle
								color: "grey"
								text: filePath
							}
						}
						Text {
							id: infoArea
							width: 80
							height: parent.height

							horizontalAlignment: Text.AlignRight;
							verticalAlignment: Text.AlignVCenter;
							font.pixelSize: 18
							color: "grey"
							//text: (folderModel.isFolder(index) ? "Dir" : Script.extensionOf(fileName)) + " ";
							text: (folderModel.isFolder(index) ? "Dir" : Script.formatSize(fileSize)) + " ";
						}
					}
				}
			}

			model: folderModel
			delegate: fileDelegate

		}
	}

	Component.onCompleted: {
		//console.log("Component.onCompleted(PageBrowse): ");
		folderChanged(folderModel.homeFolder);
		//folderModel.setFilters(app.browserDirsFirst, app.browserSortField, app.browserShowHidden, []);
	}
}
