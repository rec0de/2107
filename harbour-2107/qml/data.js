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
                });
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


// This function resets all stats
function hardreset(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE stats;');
    })
}

