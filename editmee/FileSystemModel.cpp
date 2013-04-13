#include "FileSystemModel.h"

FileSystemModel::FileSystemModel(QObject *parent): QAbstractListModel(parent) {
	QHash<int, QByteArray> roles;
	roles[FileNameRole] = "fileName";
	roles[FilePathRole] = "filePath";
	roles[FileSizeRole] = "fileSize";
	//roles[FileTypeRole] = "fileType";
	setRoleNames(roles);

	model.setFilter(QDir::AllDirs | QDir::AllEntries | QDir::Hidden | QDir::NoDotAndDotDot);
	model.setSorting(QDir::DirsFirst | QDir::IgnoreCase | QDir::Name);

	connect(&model, SIGNAL(rowsInserted(const QModelIndex&,int,int))
			, this, SLOT(inserted(const QModelIndex&,int,int)));
	connect(&model, SIGNAL(rowsRemoved(const QModelIndex&,int,int))
			, this, SLOT(removed(const QModelIndex&,int,int)));
	connect(&model, SIGNAL(dataChanged(const QModelIndex&,const QModelIndex&))
			, this, SLOT(handleDataChanged(const QModelIndex&,const QModelIndex&)));
	connect(&model, SIGNAL(modelReset()), this, SLOT(refresh()));
	connect(&model, SIGNAL(layoutChanged()), this, SLOT(refresh()));
}

QVariant FileSystemModel::data(const QModelIndex &index, int role) const {
	QModelIndex modelIndex = model.index(index.row(), 0, m_folderIndex);
	if (modelIndex.isValid()) {
		switch(role) {
		case FileNameRole:
			return model.data(modelIndex, QDirModel::FileNameRole).toString();
		case FilePathRole:
			return model.data(modelIndex, QDirModel::FilePathRole).toString();
		case FileSizeRole: {
			QFileInfo info(model.data(modelIndex, QDirModel::FilePathRole).toString());
			return QVariant(info.size());
		}
		}
	}
	return QVariant();
}

bool FileSystemModel::isFolder(int index) const {
	if (index != -1) {
		QModelIndex idx = model.index(index, 0, m_folderIndex);
		if (idx.isValid())
			return model.isDir(idx);
	}
	return false;
}


void FileSystemModel::componentComplete() {
	if (!QDir().exists(m_folder)) {
		setFolder(QDir::currentPath());
	}

	if (!m_folderIndex.isValid())
		QMetaObject::invokeMethod(this, "refresh", Qt::QueuedConnection);
}



void FileSystemModel::refresh() {
	m_folderIndex = QModelIndex();
	if (m_count) {
		emit beginRemoveRows(QModelIndex(), 0, m_count - 1);
		m_count = 0;
		emit endRemoveRows();
	}
	m_folderIndex = model.index(m_folder);
	int newcount = model.rowCount(m_folderIndex);
	if (newcount) {
		emit beginInsertRows(QModelIndex(), 0, newcount - 1);
		m_count = newcount;
		emit endInsertRows();
	}
}

void FileSystemModel::inserted(const QModelIndex &index, int start, int end) {
	if (index == m_folderIndex) {
		emit beginInsertRows(QModelIndex(), start, end);
		m_count = model.rowCount(m_folderIndex);
		emit endInsertRows();
	}
}

void FileSystemModel::removed(const QModelIndex &index, int start, int end) {
	if (index == m_folderIndex) {
		emit beginRemoveRows(QModelIndex(), start, end);
		m_count = model.rowCount(m_folderIndex);
		emit endRemoveRows();
	}
}

void FileSystemModel::handleDataChanged(const QModelIndex &start, const QModelIndex &end) {
	if (start.parent() == m_folderIndex)
		emit dataChanged(index(start.row(),0), index(end.row(),0));
}



void FileSystemModel::setFolder(const QString &folder) {

	if (folder == m_folder)
		return;

	QModelIndex index = model.index(folder);

	if (index.isValid() && model.isDir(index)) {
		m_folder = folder;
		QMetaObject::invokeMethod(this, "refresh", Qt::QueuedConnection);
		emit folderChanged();
	}
}

QString FileSystemModel::parentFolder() const {
	QString localFile = m_folder;
	if (!localFile.isEmpty()) {
		QDir dir(localFile);
#if defined(Q_OS_SYMBIAN) || defined(Q_OS_WIN)
		if (dir.isRoot())
			dir.setPath("");
		else
#endif
			dir.cdUp();
		localFile = dir.path();
	} else {
		int pos = m_folder.lastIndexOf(QLatin1Char('/'));
		if (pos == -1)
			return QString();
		localFile = m_folder.left(pos);
	}
	return localFile;
}

QString FileSystemModel::homeFolder() const {
	return QDir::homePath();
}

void FileSystemModel::setFilters(bool foldersFirst, int sortBy, bool showHidden, QStringList filters) {
	QDir::Filters filter = QDir::AllEntries | QDir::NoDotAndDotDot;
	QDir::SortFlags sort = QDir::IgnoreCase | QDir::Name;

	if (foldersFirst)
		sort |= QDir::DirsFirst;

	if (showHidden)
		filter |= QDir::Hidden;

	model.setFilter(filter);
	model.setSorting(sort);
	model.setNameFilters(filters);

}

bool FileSystemModel::isPathFolder(const QString &filePath) const {
	QFileInfo info(filePath);
	return info.exists() && info.isDir();
}

bool FileSystemModel::isPathValid(const QString &filePath) const {
	QFileInfo info(filePath);
	return info.exists();
}
