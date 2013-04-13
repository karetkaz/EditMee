import QtQuick 1.1
import com.nokia.meego 1.0
import TextEditor 1.0

Page {
	property string fileName: "";

	function loadDocument(file) {
		if (textArea.load(file)) {
			var favorites = Settings.getArray('favorites');
			btnFavorite.setStatus(favorites.indexOf(file) >= 0);
			fileName = file;
			return true;
		}
		return false;
	}

	function saveDocument(file) {
		if (textArea.save(file)) {
			fileName = file;
			return true;
		}
		return false;
	}

	function newDocument() {
		editPage.fileName = "";
		textArea.clear();
	}

	function undo() {textArea.undo();}
	function redo() {textArea.redo();}
	function cut() {textArea.cut();}
	function copy() {textArea.copy();}
	function paste() {textArea.paste();}
	function selectAll() {textArea.selectAll();}

	property int sciLineDown: 2300;
	//property int sciLineDownExtend: 2301;
	property int sciLineUp: 2302;
	//property int sciLineUpExtend: 2303;
	property int sciCharLeft: 2304;
	//property int sciCharLeftExtend: 2305;
	property int sciCharRight: 2306;
	//property int sciCharRightExtend: 2307;
	property int sciWordLeft: 2308;
	//property int sciWordLeftExtend: 2309;
	property int sciWordRight: 2310;
	//property int sciWordRightExtend: 2311;
	property int sciHome: 2312;
	//property int sciHomeExtend: 2313;
	property int sciLineEnd: 2314;
	//property int sciLineEndExtend: 2315;
	property int sciDocumentStart: 2316;
	//property int sciDocumentStartExtend: 2317;
	property int sciDocumentEnd: 2318;
	//property int sciDocumentEndExtend: 2319;
	property int sciPageUp: 2320;
	//property int sciPageUpExtend: 2321;
	property int sciPageDown: 2322;
	//property int sciPageDownExtend: 2323

	function refreshSettings() {
		textArea.wrap(app.editorWordWrap);
		textArea.zoom(app.editorFontSize);

		listModel.clear();
		var chars = app.editorToolBarChars;
		for (var i = 0; i < chars.length; ++i) {
			listModel.append({text: chars[i], send: chars[i]});
		}
		if (charsRow.visible !== app.editorToolBar) {
			setVisibleRow(charsRow, app.editorToolBar);
		}
	}

	function setVisibleRow(row, visible) {
		if (visible) {
			navigateRow.visible = false;
			searchRow.visible = false;
			charsRow.visible = false;
		}
		row.visible = visible;
		if (!visible && row !== charsRow) {
			charsRow.visible = app.editorToolBar;
		}
	}

	tools: ToolBarLayout {

		ToolIcon {
			id: btnFavorite;
			platformIconId: "toolbar-favorite-unmark";
			function setStatus(isFav) {
				platformIconId = (isFav ? "toolbar-favorite-mark" : "toolbar-favorite-unmark");
			}
			onClicked: if (fileName !== "") {
				var favorites = Settings.getArray('favorites');
				var favIndex = favorites.indexOf(fileName);

				if (favIndex < 0) {
					favorites.push(fileName);
					setStatus(true);
				}
				else {
					favorites.splice(favIndex, 1);
					setStatus(false);
				}
				Settings.setArray('favorites', favorites);
			}
		}

		ToolIcon {
			platformIconId: "toolbar-undo";
			onClicked: textArea.undo();
		}

		ToolIcon {
			platformIconId: "toolbar-redo";
			onClicked: textArea.redo();
		}

		ToolIcon {
			platformIconId: "toolbar-cut-paste";
			onClicked: {
				if (menuMain.status !== DialogStatus.Closed) {
					menuMain.close();
				}
				if (menuFavorites.status !== DialogStatus.Closed) {
					menuFavorites.close();
				}
				if (menuEdit.status !== DialogStatus.Closed) {
					menuEdit.close();
				}
				else {
					menuEdit.open();
				}
			}
		}

		ToolIcon {  // edit
			platformIconId: "toolbar-edit"
			onClicked: {
				textArea.requestSoftwareInputPanel();
			}
		}

		ToolIcon {  // toggle find
			platformIconId: "toolbar-search"
			onClicked: setVisibleRow(searchRow, !searchRow.visible);
		}

		ToolIcon {  // toggle goto
			platformIconId: "toolbar-jump-to"
			onClicked: {
				textArea.requestEditorFocus();
				setVisibleRow(navigateRow, !navigateRow.visible);
			}
		}

		ToolIcon {  // menu
			platformIconId: "toolbar-view-menu"
			onClicked: {
				if (menuEdit.status !== DialogStatus.Closed) {
					menuEdit.close();
				}
				if (menuFavorites.status !== DialogStatus.Closed) {
					menuFavorites.close();
				}
				if (menuMain.status !== DialogStatus.Closed) {
					menuMain.close();
				}
				else {
					menuMain.open();
				}
			}
		}
	}

	SciEditor {
		id: textArea
		anchors {
			top: parent.top
			bottom: searchBar.top
			left: parent.left
			right: parent.right
			margins: 0
		}

		Component.onCompleted: {
			/*textArea.undoAvailable.connect(function(available) {
				console.debug('undoAvailable: ' + available);
				//btnUndo.enabled = available;
			});
			textArea.redoAvailable.connect(function(available) {
				console.debug('redoAvailable: ' + available);
				//btnRedo.enabled = available;
			});;*/
		}
	}

	Rectangle {
		id: searchBar;
		visible: true;
		height: barColumn.height;
		color: theme.inverted ? '#212121' : '#f0f0f0'

		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			margins: 0
		}

		Column {
			id: barColumn;
			width: parent.width;
			Row { id: navigateRow;
				visible: false;
				width: parent.width;

				Timer {
					id: repeatedSend
					triggeredOnStart: true;
					interval: 1200;
					running: false;
					repeat: true;
					onTriggered: {
						if (key > 0) {
							textArea.requestEditorFocus();
							textArea.sciSend(key);
							switch (cnt) {
								case 0:
									interval = app.editorNavRepeatDelay;
									break;
								case 1:
									interval = app.editorNavRepeatSpeed;
									break;
							}
							cnt += 1;
						}
					}
					property int key: 0;
					property int cnt: 0;

					function set(run, key) {
						repeatedSend.key = key;
						repeatedSend.cnt = 0;
						running = run;
					}
				}

				TextField {
					width: parent.width - 7 * height;
					placeholderText: "Line";
					inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoAutoUppercase;
					Keys.onReturnPressed: {
						textArea.requestEditorFocus();
						textArea.gotoLine(text);
					}
				}

				Button {
					id: btnAltNav;
					text: 'Alt';
					width: height;
					checkable: true;
				}

				Button { // Left / WordLeft
					text: '↤';	//"\u2B05";	// 2190: ← / 21A4: ↤
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciWordLeft : sciCharLeft);
				}
				Button { // Right / WordRight
					text: '↦';	//"\u27A1";	// 2192: → / 21A6: ↦
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciWordRight : sciCharRight);
				}
				Button { // Up / PageUp
					text: '↥';	//"\u2B06";	// 2191: ↑ / 21A5: ↥
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciPageUp : sciLineUp);
				}
				Button { // Down / PageDown
					text: '↧';	//"\u2B07";	// 2193: ↓ / 21A7: ↧
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciPageDown : sciLineDown);
				}
				Button { // Home / DocumentStart
					text: '⇤';	//"\u2B06"	// ? / 21E4 ⇤
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciDocumentStart : sciHome);
				}
				Button { // End / DocumentEnd
					text: '⇥';	//"\u2B06"	// ? / 21E5 ⇥
					width: height;
					onPressedChanged: repeatedSend.set(pressed, btnAltNav.checked ? sciDocumentEnd : sciLineEnd);
				}
			}

			Row { id: searchRow;
				visible: !true;
				width: parent.width;
				TextField {
					id: searchEdit
					width: searchRow.width - 2 * height;
					inputMethodHints: Qt.ImhNoPredictiveText  | Qt.ImhNoAutoUppercase;
					placeholderText: 'Search text';
					Keys.onReturnPressed: {
						textArea.requestEditorFocus();
						textArea.find(searchEdit.text, false, app.searchMatchCase, app.searchWholeWords, app.searchRegexp);
					}
					onVisibleChanged: {
						if (visible)
							selectAll();
					}
				}

				Button {
					id: btnFindPrev
					iconSource: "image://theme/icon-m-toolbar-previous" + (theme.inverted ? "-white" : "")
					width: height
					onClicked: {
						textArea.requestEditorFocus();
						if (searchEdit.text !== "") {
							textArea.find(searchEdit.text, true, app.searchMatchCase, app.searchWholeWords, app.searchRegexp);
						}
					}
				}

				Button {
					id: btnFindNext
					iconSource: "image://theme/icon-m-toolbar-next" + (theme.inverted ? "-white" : "")
					width: height
					onClicked: {
						textArea.requestEditorFocus();
						if (searchEdit.text !== "") {
							textArea.find(searchEdit.text, false, app.searchMatchCase, app.searchWholeWords, app.searchRegexp);
						}
					}
				}
			}

			Row { id: charsRow;
				visible: true;
				width: parent.width

				Flickable {
					clip: true;
					interactive: true;
					width: parent.width;
					height: charsRow2.height;
					contentWidth: charsRow2.width;
					contentHeight: charsRow2.height;
					flickableDirection: Flickable.HorizontalFlick;

					Row {
						id: charsRow2;
						Button {
							text: "↹"; // ↹
							width: height;
							onClicked: {
								textArea.requestEditorFocus();
								textArea.addText("\t");
							}
						}

						ListModel {
							id: listModel
						}

						Repeater {
							model: listModel;
							delegate: Button {
								text: model.text
								width: height;
								onClicked: {
									textArea.requestEditorFocus();
									textArea.addText(model.send);
								}
							}
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		//console.log("Component.onCompleted(PageEdit): ");
		fileName = "";
		refreshSettings();
	}
}
