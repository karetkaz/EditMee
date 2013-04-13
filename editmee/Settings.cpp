#include "Settings.h"

#include <QDesktopServices>
#include <QCoreApplication>
#include <QSettings>
#include <QDebug>

Settings::Settings(QString appName, QString fileName, QObject *parent) : QObject(parent) {
	// Initialize the settings path
	m_confFile = QDesktopServices::storageLocation( QDesktopServices::DataLocation ) + "/" + appName + "/" + fileName;
}

/*QString Settings::filePath() const {
	return m_confFile;
}

void Settings::setFilePath(const QString &data) {
	m_confFile.clear();
	m_confFile.append(data);
}*/

QVariant Settings::setValue(const QString &key, const QVariant & value) {
	QSettings settings(m_confFile, QSettings::IniFormat);
	//qDebug() << "setValue(" << key << " = " << value;
	settings.setValue(key, value);
	return value;
}

QVariant Settings::getValue( const QString &key, const QVariant & defaultValue) const {
	QSettings settings(m_confFile, QSettings::IniFormat);
	//qDebug() << "getValue(" << key << " = " << settings.value(key, defaultValue);
	return settings.value(key, defaultValue);
}

QVariant Settings::getArray( const QString &key) {
	QSettings settings(m_confFile, QSettings::IniFormat);
	QList<QVariant> list;
	int size = settings.beginReadArray(key);
	for (int i = 0; i < size; ++i) {
		settings.setArrayIndex(i);
		list.append(settings.value("value"));
	}
	settings.endArray();
	return QVariant(list);
}

QVariant Settings::setArray(const QString &key, const QVariant &value) {
	QSettings settings(m_confFile, QSettings::IniFormat);
	QList<QVariant> list = value.toList();
	settings.beginWriteArray(key);
	for (int i = 0; i < list.size(); ++i) {
		settings.setArrayIndex(i);
		settings.setValue("value", list.at(i));
	}
	settings.endArray();
	return QVariant(list);
}

QVariant Settings::addArray(const QString &key, const QVariant &value) {
	QList<QVariant> list = getArray(key).toList();
	list.append(value);
	setArray(key, QVariant(list));
	return QVariant(list);
}
