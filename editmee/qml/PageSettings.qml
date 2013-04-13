import QtQuick 1.1
import com.nokia.meego 1.0

/*TODO:
Appearance
	K Full screen
	K Dark theme
	K Orientation (sensor/portrait/landscape)

Editor:
	Line higlight color
	Line margin width

	Background color
	Text color

	Font family
	k Font size
	k Text wrap

	k Edit bar

Search:
	k Case sensitive
	k Whole words
	k Regexp

Misc:
	K Auto save files (menu -> save: save the opened file, or browse if new file)
	K Auto load files (in browser delecting a file will load, no need to press the Load button.)
	K Show hidden files
	K Show folders first

*/

Page {
	property color textColor: theme.inverted ? "white" : "black"

	//property int separatorHeight: 0;
	property int rowMarginTop: 20;
	property int rowMarginLeft: 14;
	property int rowMarginRight: 14;
	property int rowFontPointSize: 20;

	width: parent.width
	height: parent.height

	tools: ToolBarLayout {
		ToolIcon {   // about
			iconId: "toolbar-home"
		}
		ToolIcon {   // back
			iconId: "toolbar-back"
			onClicked: {
				pageStack.pop();
				editPage.refreshSettings();
			}
		}
	}
	Flickable {
		id: flick;
		width: parent.width;
		height: parent.height;

		interactive: true;
		contentWidth: parent.width
		contentHeight: settingsColumn.height + 2 * rowMarginTop
		clip: true

		Column {
			id: settingsColumn
			anchors {
				top: parent.top;
				topMargin: rowMarginTop;
				//bottom: parent.bottom;
				//bottomMargin: rowMarginTop;
				left: parent.left;
				leftMargin: rowMarginLeft;
				right:  parent.right
				rightMargin: rowMarginRight;
			}
			spacing: rowMarginTop;

			Row {// ------------- Appearance
				width: parent.width;
				height: lblAppearance.height;
				Label { text: "Appearance";
					id: lblAppearance;
					color: "gray";
					font.pointSize: 10;
					anchors {
						right: parent.right;
					}
				}
				Rectangle {
					height: 1;
					color: lblAppearance.color;
					anchors {
						left: parent.left;
						right: lblAppearance.left;
						rightMargin: rowMarginRight;
						verticalCenter: lblAppearance.verticalCenter;
					}
				}
			}

			Label { text: "Full screen";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					id: chkFullScreen;
					anchors.right: parent.right;
					checked: Settings.getValue('theme.fullscreen', true);
					onCheckedChanged: {
						app.showStatusBar = !checked;
						Settings.setValue('theme.fullscreen', checked);
						//appWindow.showToolBar = appWindow.showStatusBar;
					}
				}
			}

			Label { text: "Dark theme";
				width: parent.width;
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter;
				Switch {
					anchors.right: parent.right;
					checked: Settings.getValue('theme.darktheme', false);
					onCheckedChanged: {
						theme.inverted = checked;
						Settings.setValue('theme.darktheme', theme.inverted);
					}
				}
			}

			Label { text: "Orientation";
				width: parent.width;
				font.pointSize: rowFontPointSize;
				color: textColor;
			}
			ButtonRow {
				id: btnOrientations
				anchors {
					left: parent.left;
					leftMargin: rowMarginLeft;
					right:  parent.right
					rightMargin: rowMarginRight;
				}
				//width: parent.width;
				function setValue() {
					var text = Settings.getValue("orientation", "");
					for (var i = 0; i < children.length; ++i) {
						if (children[i].text === text) {
							children[i].checked = true;
							children[i].clicked();
						}
					}
				}

				Button {
					text: "Sensor";
					onClicked: {
						Settings.setValue("orientation", text);
						editPage.orientationLock = PageOrientation.Automatic;
						browsePage.orientationLock = PageOrientation.Automatic;
						settingsPage.orientationLock = PageOrientation.Automatic;
					}
				}
				Button {
					text: "Portrait";
					onClicked: {
						Settings.setValue("orientation", text);
						editPage.orientationLock = PageOrientation.LockPortrait;
						browsePage.orientationLock = PageOrientation.LockPortrait;
						settingsPage.orientationLock = PageOrientation.LockPortrait;
					}
				}
				Button {
					text: "Landscape";
					onClicked: {
						Settings.setValue("orientation", text);
						editPage.orientationLock = PageOrientation.LockLandscape;
						browsePage.orientationLock = PageOrientation.LockLandscape;
						settingsPage.orientationLock = PageOrientation.LockLandscape;
					}
				}
			}

			Row {// ------------- Editor
				width: parent.width;
				height: lblEditor.height;
				Label { text: "Editor";
					id: lblEditor;
					color: "gray";
					font.pointSize: 10;
					anchors{
						//top: parent.top;
						right: parent.right;
						rightMargin: rowMarginRight;
					}
				}
				Rectangle {
					height: 1;
					color: lblEditor.color;
					anchors{
						left: parent.left;
						right: lblEditor.left;
						rightMargin: 15
						leftMargin: rowMarginLeft
						verticalCenter: lblEditor.verticalCenter;
					}
				}
			}

			Label { text: "Wrap text";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					//id: chkWrapText;
					anchors.right: parent.right;
					checked: app.editorWordWrap;
					onCheckedChanged: app.setEditorWordWrap(checked);
				}
			}

			Label { text: "Font size";
				width: parent.width
				//color: textColor;
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				TextField {
					id: txtFontSize;
					placeholderText: "Font size"
					//width: 70;
					enabled: false;
					width: chkFullScreen.width;
					height: chkFullScreen.height;
					anchors.right: parent.right;
				}
			}
			Slider {
				id: barFontSize
				width: parent.width;
				stepSize: 1
				minimumValue: 1;
				maximumValue: 90;
				onValueChanged: {
					txtFontSize.text = value;
				}
				onPressedChanged: if (!pressed) {
					app.setEditorFontSize(value);
				}
			}

			Label { text: "Tool bar";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.editorToolBar;
					onCheckedChanged: app.setEditorToolBar(checked);
				}
			}
			TextField {
				//id: txtCharsBar;
				text: app.editorToolBarChars;
				anchors {
					left: parent.left;
					leftMargin: rowMarginLeft;
					right:  parent.right
					rightMargin: rowMarginRight;
				}
				onTextChanged: app.setEditorToolBarChars(text);
			}

			Row {// ------------- Search
				width: parent.width;
				height: lblSearch.height;
				Label { text: "Search";
					id: lblSearch;
					color: "gray";
					font.pointSize: 10;
					anchors{
						//top: parent.top;
						right: parent.right;
						rightMargin: rowMarginRight;
					}
				}
				Rectangle {
					height: 1;
					color: lblSearch.color;
					anchors{
						left: parent.left;
						right: lblSearch.left;
						rightMargin: 15
						leftMargin: rowMarginLeft
						verticalCenter: lblSearch.verticalCenter;
					}
				}
			}

			Label { text: "Case sensitive";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.searchMatchCase;
					onCheckedChanged: app.setSearchMatchCase(checked);
				}
			}

			Label { text: "Whole words";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.searchWholeWords;
					onCheckedChanged: app.setSearchWholeWords(checked);
				}
			}

			Label { text: "Regexp";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.searchRegexp;
					onCheckedChanged: app.setSearchRegexp(checked);
				}
			}

			Row {// ------------- Misc
				width: parent.width;
				height: lblMisc.height;
				Label { text: "Misc";
					id: lblMisc;
					color: "gray";
					font.pointSize: 10;
					anchors {
						//top: parent.top;
						right: parent.right;
						rightMargin: rowMarginRight;
					}
				}
				Rectangle {
					height: 1;
					color: lblMisc.color;
					anchors{
						left: parent.left;
						right: lblMisc.left;
						rightMargin: 15
						leftMargin: rowMarginLeft
						verticalCenter: lblMisc.verticalCenter;
					}
				}
			}

			Label { text: "Auto Load";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.browserAutoLoad;
					onCheckedChanged: app.setBrowserAutoLoad(checked);
				}
			}

			Label { text: "Auto Save";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.browserAutoSave;
					onCheckedChanged: app.setBrowserAutoSave(checked);
				}
			}

			Label { text: "Hidden files";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.browseHiddenFiles;
					onCheckedChanged: app.setBrowseHiddenFiles(checked);
				}
			}

			Label { text: "Folders first";
				width: parent.width
				font.pointSize: rowFontPointSize;
				verticalAlignment: Text.AlignVCenter
				Switch {
					anchors.right: parent.right;
					checked: app.browseFoldersFirst;
					onCheckedChanged: app.setBrowseFoldersFirst(checked);
				}
			}
		}
	}

	ScrollDecorator {
			flickableItem: flick
			platformStyle: ScrollDecoratorStyle {}
	}

	Component.onCompleted: {
		//console.log("Component.onCompleted(PageSettings): ");
		btnOrientations.setValue();
		barFontSize.value = app.editorFontSize;
	}
}
