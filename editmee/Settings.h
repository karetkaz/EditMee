#ifndef SETTINGSPROXY_H
#define SETTINGSPROXY_H

#include <QObject>
#include <QVariant>

class Settings: public QObject
{
	Q_OBJECT
public:
	explicit Settings(QString, QString, QObject *parent = 0);

	Q_INVOKABLE QVariant setValue(const QString &key, const QVariant &value);
	Q_INVOKABLE QVariant getValue(const QString &key, const QVariant &defaultValue = QVariant()) const;

	Q_INVOKABLE QVariant getArray(const QString &key);
	Q_INVOKABLE QVariant setArray(const QString &key, const QVariant &value);
	Q_INVOKABLE QVariant addArray(const QString &key, const QVariant &value);

private:
	QString m_confFile;

signals:

public slots:
};

#endif // SETTINGSPROXY_H
