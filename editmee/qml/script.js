//initialize();

var settingCache = {
    appThemeInverted: false,

    //browserAutoLoad: true,
    //browserAutoSave: false,
    browserBgColorNormal: "#00000000",
    browserBgColorPressed: "steelblue",

    // editorFontSize: 26,
    // editorTextWrap: false


    logVerbose: true,
    _:undefined
};

theme.inverted = getSetting('appThemeInverted', true);

function log(value) {
    if (settingCache.logVerbose) {
        if (value.constructor !== String) {
            value = JSON.stringify(value);
        }
        console.log("QLM: " + value);
    }
}

function extensionOf(fileName) {
	var idx = fileName.lastIndexOf(".");

	// hidden files are not extensions
	if (idx > 0) {
		return fileName.substr(idx);
	}

	return ""
}

function directoryOf(fileName) {
	var idx = fileName.lastIndexOf("/");

	// hidden files are not extensions
	if (idx > 0) {
		return fileName.substr(0, idx);
	}

	return ""
}

function formatSize(size) {
	var precision = 1;
	if (size > (1 << 30)) {
		return (size / (1 << 30)).toFixed(precision) + "GB";
	}
	if (size > (1 << 20)) {
		return (size / (1 << 20)).toFixed(precision) + "MB";
	}
	if (size > (1 << 10)) {
		return (size / (1 << 10)).toFixed(precision) + "KB";
	}
	return size + " B";
}

/*/ storage.js

function getDatabase() {
    return openDatabaseSync("EditMee", "1.0", "StorageDatabase", 100000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
    });
}*/

function setSetting(setting, value) {
    settingCache[setting] = value;
    /*var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting, value]);
        if (!rs.rowsAffected > 0) {
            value = null;
        }
	});// */
    return value;
}

function getSetting(setting, value) {
    /*var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            value = rs.rows.item(0).value;
        }
        else {
            //setSetting(setting, value);
        }
	});*/
    if (settingCache.hasOwnProperty(setting)) {
        value = settingCache[setting];
    }
    return value;
}
