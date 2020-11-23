.import QtQuick.LocalStorage 2.0 as LS

// Code derived from 'Noto' by leszek -- Thanks :)

// Structure of stats table
// 0: Birds scared (total)
// 1: Birds scared (best)
// 2: Distance traveled (total)
// 3: Distance traveled (best)
// 4: Jumps (total)
// 5: Jumps (best)
// 6: Current Level (starting at 0)
// 7: Current Character (0-3)
// 8: Realpix conversion rate
// 9: Objective basecount
// 10: Moose character eegg unlocked (default 0)
// 11: Backround music mute (0: music on 1: music muted)
// 12: # of games played
// 13: Player has already found a file (default 0)
// 14: Current wealth of player in c


// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("2107", "1.0", "StorageDatabase", 1000);
}


// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS stats (uid INTEGER UNIQUE, value INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS data (uid INTEGER UNIQUE, status INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS gadgets (uid INTEGER UNIQUE, status INTEGER)');
                });
    sanitize();
}

// This function is used to update stats
function setstat(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO stats VALUES (?,?);', [uid,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}


// This function is used to retrieve stats
function getstat(uid) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM stats WHERE uid=?;', [uid]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value
        } else {
            res = 0;
        }
    })
    return res;
}

// This function is used to retrieve a list of 'owned' files
function listowned() {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT uid FROM data WHERE status=2;');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = 0;
        }
    })
    return res;
}

// This function is used to retrieve a list of all files that have already appeared
function listseen() {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT uid FROM data WHERE status=2 OR status=1;');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = Array();
        }
    })
    return res;
}

// This function is used to set the status of a file
function setval(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO data VALUES (?,?);', [uid,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}

// This function is used to retrieve a list of purchased gadgets
function listownedgadgets() {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT uid FROM gadgets WHERE status=1 OR status=2;');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = 0;
        }
    })
    return res;
}

// This function is used to set the status of a gadget (0: not purchased 1: purchased, active 2: purchased, not active)
function setgadget(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO gadgets VALUES (?,?);', [uid,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}

// This function is used to retrieve a gadget status
function getgadget(uid) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT status FROM gadgets WHERE uid=?;', [uid]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).status
        } else {
            res = 0;
        }
    })
    return res;
}

// Attempts to fix data anomalies
function sanitize(){
    for(var i = 0; i <= 12; i++){
        if(getstat(i) < 0){
            setstat(i, 0);
        }
    }
}


// This function resets all stats
function hardreset(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE stats;');
        tx.executeSql('DROP TABLE data;');
        tx.executeSql('DROP TABLE gadgets;');
    })
}

