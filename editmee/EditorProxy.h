#ifndef EDITORPROXY_H
#define EDITORPROXY_H

#include <QDeclarativeItem>
#include "ScintillaEditBase.h"
//#include <QTextEdit>

class QGraphicsProxyWidget;
class EditorWidget;

class EditorProxy : public QDeclarativeItem {
	Q_OBJECT

public:
	explicit EditorProxy(QDeclarativeItem *parent = NULL);
	virtual ~EditorProxy();

public slots:

	void undo() {sciEditor->send(SCI_UNDO);}
	void redo() {sciEditor->send(SCI_REDO);}

	void cut() {sciEditor->send(SCI_CUT);}
	void copy() {sciEditor->send(SCI_COPY);}
	void paste() {sciEditor->send(SCI_PASTE);}
	void selectAll() {sciEditor->send(SCI_SELECTALL);}

	void clear() {sciEditor->sends(SCI_SETTEXT, 0, "");}

	void zoom(int value) {sciEditor->send(SCI_SETZOOM, editorZoom = value);}
	void wrap(bool mode) {sciEditor->send(SCI_SETWRAPMODE, mode ? SC_WRAP_WORD : SC_WRAP_NONE);}

	void addText(const QString &text) {sciEditor->sends(SCI_REPLACESEL, 0, text.toAscii().data());}

	void sciSend(const int thing) {sciEditor->send(thing);}

	bool load(const QString &file);
	bool save(const QString &file);

	bool find(const QString &text, bool prev, bool matchCase, bool wholeWords, bool regexp);

	void gotoLine(const QString &text);
	bool findNext(const QString &text);
	bool findPrev(const QString &text);

	void requestEditorFocus();
	void requestSoftwareInputPanel();

signals:

protected:
	virtual void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry);
	virtual bool sceneEvent(QEvent *event);

private:
	QGraphicsProxyWidget *proxyWidget;
	ScintillaEditBase *sciEditor;
	qreal editorZoom;
};

#endif // EditorProxy_H
