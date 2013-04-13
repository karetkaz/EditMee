#ifndef FileSystemModel_H
#define FileSystemModel_H

#include <QString>
#include <QDirModel>
#include <QtCore/QObject>
#include <QDeclarativeParserStatus>

class FileSystemModel: public QAbstractListModel, public QDeclarativeParserStatus {
	Q_OBJECT
	Q_INTERFACES(QDeclarativeParserStatus)

	Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)
	Q_PROPERTY(QString parentFolder READ parentFolder NOTIFY folderChanged)
	Q_PROPERTY(QString homeFolder READ homeFolder NOTIFY folderChanged)
	Q_PROPERTY(int count READ count)

	public:
		explicit FileSystemModel(QObject *parent = 0);
		//virtual ~FileSystemModel() {}

		enum Roles {
			FileNameRole = Qt::UserRole+1,
			FilePathRole = Qt::UserRole+2,
			FileSizeRole = Qt::UserRole+3
		};

		int rowCount(const QModelIndex &parent) const { Q_UNUSED(parent); return m_count; }
		QVariant data(const QModelIndex &index, int role) const;

		int count() const { return m_count; } //{ return rowCount(QModelIndex()); }

		QString folder() const { return m_folder; }
		void setFolder(const QString &folder);

		QString parentFolder() const;

		QString homeFolder() const;

		Q_INVOKABLE void setFilters(bool foldersFirst, int sortBy, bool showHidden, QStringList filters);

		Q_INVOKABLE bool isFolder(int index) const;

		// utils
		Q_INVOKABLE bool isPathFolder(const QString &filePath) const;
		Q_INVOKABLE bool isPathValid(const QString &filePath) const;

	//![parserstatus]
		virtual void classBegin() {}
		virtual void componentComplete();
	//![parserstatus]

	//![notifier]
	Q_SIGNALS:
		void folderChanged();
	//![notifier]

	//![class end]
	private Q_SLOTS:
		void refresh();
		void inserted(const QModelIndex &index, int start, int end);
		void removed(const QModelIndex &index, int start, int end);
		void handleDataChanged(const QModelIndex &start, const QModelIndex &end);

	private:
		//Q_DISABLE_COPY(QDeclarativeFolderListModel)
		QDirModel model;
		int m_count;
		QString m_folder;
		QModelIndex m_folderIndex;
};

#endif // FileSystemModel_H
