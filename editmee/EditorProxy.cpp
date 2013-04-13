#include "EditorProxy.h"

#include <QApplication>

#include <QDir>
#include <QFile>
#include <QTextStream>

//#include <QFileInfo>

#include <QStyle>
#include <QScrollBar>
#include <QTouchEvent>

#include <QSwipeGesture>
#include <QPanGesture>
#include <QPinchGesture>

#include <QGraphicsProxyWidget>

#include <QDebug>
#include <QLabel>

#define useScite 1

EditorProxy::EditorProxy(QDeclarativeItem *parent)
	: QDeclarativeItem(parent)
	, sciEditor(new ScintillaEditBase()) {


	setAcceptTouchEvents(true);
	grabGesture(Qt::PinchGesture);
	setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton | Qt::MiddleButton);

	proxyWidget = new QGraphicsProxyWidget(this);
	proxyWidget->setWidget(sciEditor);

	sciEditor->send(SCI_SETVSCROLLBAR, 0);
	sciEditor->send(SCI_SETHSCROLLBAR, 0);
	sciEditor->send(SCI_SETMARGINWIDTHN, 0, 60);

	sciEditor->send(SCI_SETCARETLINEVISIBLE, 1);
	sciEditor->send(SCI_SETCARETLINEBACK, 0xA0FFFF);
}

EditorProxy::~EditorProxy() {
	delete sciEditor;
}

void EditorProxy::requestEditorFocus() {
	sciEditor->setFocus();
}

void EditorProxy::requestSoftwareInputPanel() {
	sciEditor->setFocus();
	QEvent event2(QEvent::RequestSoftwareInputPanel);
	QApplication::sendEvent(sciEditor, &event2);
}

bool EditorProxy::load(const QString &filename) {
	QFile file(filename);
	if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
		sciEditor->sends(SCI_SETTEXT, 0, file.readAll());
		file.close();
		return true;
	}
	return false;
}

bool EditorProxy::save(const QString &filename) {
	QFile file(filename);
	if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
		int textLen = sciEditor->sends(SCI_GETTEXTLENGTH) + 1;
		char* text = new char[textLen];
		sciEditor->sends(SCI_GETTEXT, textLen, text);
		file.write(text);
		file.close();
		delete text;
		return true;
	}
	return false;
}

void EditorProxy::gotoLine(const QString &text) {
	bool isLine;
	int lineNr = text.toInt(&isLine);
	if (isLine) {
		sciEditor->send(SCI_GOTOLINE, lineNr - 1);
	}
	sciEditor->send(SCI_SCROLLCARET);
}

bool EditorProxy::findPrev(const QString &text) {
	int selectionStart = sciEditor->send(SCI_GETSELECTIONSTART);
	int selectionEnd = sciEditor->send(SCI_GETSELECTIONEND);

	sciEditor->send(SCI_GOTOPOS, selectionStart);
	sciEditor->send(SCI_SEARCHANCHOR, selectionStart);

	int found = sciEditor->sends(SCI_SEARCHPREV, 0, text.toAscii().data());
	if (found < 0) {
		sciEditor->send(SCI_SETSEL, selectionEnd, selectionStart);
		return false;
	}
	selectionStart = sciEditor->send(SCI_GETSELECTIONSTART);
	selectionEnd = sciEditor->send(SCI_GETSELECTIONEND);
	sciEditor->send(SCI_SETSEL, selectionEnd, selectionStart);
	sciEditor->send(SCI_SCROLLCARET);
	return true;
}

bool EditorProxy::findNext(const QString &text) {
	int selectionStart = sciEditor->send(SCI_GETSELECTIONSTART);
	int selectionEnd = sciEditor->send(SCI_GETSELECTIONEND);

	sciEditor->send(SCI_GOTOPOS, selectionEnd);
	sciEditor->send(SCI_SEARCHANCHOR, selectionEnd);
	int found = sciEditor->sends(SCI_SEARCHNEXT, 0, text.toAscii().data());
	if (found < 0) {
		sciEditor->send(SCI_SETSEL, selectionStart, selectionEnd);
		return false;
	}
	selectionStart = sciEditor->send(SCI_GETSELECTIONSTART);
	selectionEnd = sciEditor->send(SCI_GETSELECTIONEND);
	sciEditor->send(SCI_SETSEL, selectionStart, selectionEnd);
	sciEditor->send(SCI_SCROLLCARET);
	return true;
}

bool EditorProxy::find(const QString &text, bool prev, bool matchCase, bool wholeWords, bool regexp) {
	int selectionStart = sciEditor->send(prev ? SCI_GETSELECTIONEND : SCI_GETSELECTIONSTART);
	int selectionEnd = sciEditor->send(prev ? SCI_GETSELECTIONSTART : SCI_GETSELECTIONEND);

	sciEditor->send(SCI_GOTOPOS, selectionEnd);
	sciEditor->send(SCI_SEARCHANCHOR, selectionEnd);

	// SCFIND_MATCHCASE	A match only occurs with text that matches the case of the search string.
	// SCFIND_WHOLEWORD	A match only occurs if the characters before and after are not word characters.
	// SCFIND_WORDSTART	A match only occurs if the character before is not a word character.
	// SCFIND_REGEXP	The search string should be interpreted as a regular expression.
	// SCFIND_POSIX		Treat regular expression in a more POSIX compatible manner by interpreting bare ( and ) for tagged sections rather than \( and \).

	int flags = (matchCase ? SCFIND_MATCHCASE : 0) | (wholeWords ? SCFIND_WHOLEWORD : 0) | (regexp ? SCFIND_REGEXP : 0);
	if (sciEditor->sends(prev ? SCI_SEARCHPREV : SCI_SEARCHNEXT, flags, text.toAscii().data()) < 0) {
		sciEditor->send(SCI_SETSEL, selectionStart, selectionEnd);
		return false;
	}

	selectionStart = sciEditor->send(prev ? SCI_GETSELECTIONEND : SCI_GETSELECTIONSTART);
	selectionEnd = sciEditor->send(prev ? SCI_GETSELECTIONSTART : SCI_GETSELECTIONEND);
	sciEditor->send(SCI_SETSEL, selectionStart, selectionEnd);
	sciEditor->send(SCI_SCROLLCARET);
	return true;
}

// protected event handling

void EditorProxy::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) {
	Q_UNUSED(oldGeometry)
	proxyWidget->setGeometry(newGeometry);
}

bool EditorProxy::sceneEvent(QEvent *event) {
	if (sciEditor->hasFocus()) {
		switch (event->type()) {
			default:
				qDebug() << "QEvent::" << event->type();
				break;

			case QEvent::TouchEnd:
			case QEvent::TouchBegin:
			case QEvent::TouchUpdate:
				return true;

			case QEvent::Gesture: {
				QGestureEvent *gestureEvent = static_cast<QGestureEvent *>(event);

				if (QGesture *gesture = gestureEvent->gesture(Qt::SwipeGesture)) {
					QSwipeGesture *swipeGesture = static_cast<QSwipeGesture *>(gesture);
					qDebug() << "SwipeGesture: { angle: " << swipeGesture->swipeAngle() << "}";
				}

				else if (QGesture *gesture = gestureEvent->gesture(Qt::PanGesture)) {
					QPanGesture *panGesture = static_cast<QPanGesture *>(gesture);
					qDebug() << "PanGesture: { delta: " << panGesture->delta() << "}";
				}

				else if (QGesture *gesture = gestureEvent->gesture(Qt::PinchGesture)) {
					QPinchGesture *pinchGesture = static_cast<QPinchGesture *>(gesture);
					//qDebug() << "QPinchGesture: { scale: " << pinchGesture->scaleFactor() << ", angle: " << pinchGesture->rotationAngle() << "}";
					editorZoom *= pinchGesture->scaleFactor();

					if (editorZoom < 1)
						editorZoom = 1;

					if (editorZoom > 90)
						editorZoom = 90;

					sciEditor->send(SCI_SETZOOM, editorZoom);
					return true;
				}
				else {
					qDebug() << "QEvent::Gesture";
				}
				return true;
			}
		}
	}
	return QDeclarativeItem::sceneEvent(event);
}

