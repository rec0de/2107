import QtQuick 2.0
import QtQuick.Particles 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import '../data.js' as DB
import '../files.js' as Files
import '../components'

Page {
    id: page
    allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted
    clip: true

    property bool running: false // True if game is running
    property real speed: 3.5 // Movement speed
    property int offset: rect.height - background.height
    property real gravity: 0.04 // Downward accelleration per tick
    property var birds: [] // Contains spawned doves
    property var track: [] // Contains game track
    property int trackcount: 23 // Number of available tracks
    property int glitch: 0 // O: No glitch 1: Lines Glitch 2: Overlay Glitch
    property var terrain: Array() // Parcour height for each gamepixel
    property int terrainindex: 0 // Height of gamepixel at x = 0
    property real realindex: 0
    property real gametime: 0 // Ingame time
    property bool mute: false // Mute music
    property bool tutorial: false // Show tutorial
    property int tut_index: 0 // Position in tutorial
    property bool altsoundtrack: false // Use alternative soundtrack
    property real skycolor: 306/360


    Item{
        id: stats
        property int birds_scared: 0
        property int distance: 0
        property int jumps: 0

        property int birds_scared_total: 0
        property int distance_total: 0
        property int jumps_total: 0

        property int games_played: 0

        property int objective_type: 0 // 0: birds scared (one game) 1: birds scared (total) 2: distance (one game) 3: distance (total) 4: jumps (one game) 5: jumps (total) 6: No more objectives 7: games played
        property int objective_count: 1
        property int objective_basecount: 0
        property int level: 0

        property var lvl_type:  [3,   7,  4, 2,   1,  7, 5,   0,  2,    1,   4,  7,  3,     0,  5,    2,    3,     1,   4,   5,    3,     0,  6]
        property var lvl_count: [100, 2, 10, 750, 40, 5, 100, 25, 1000, 150, 50, 10, 20000, 50, 1000, 2500, 50000, 750, 150, 2000, 75000, 80, 0]

        property int highscore: 0
        property bool highscore_muted: false // Disables high score messages
    }


    Component.onCompleted: {
        DB.initialize();

        // Load stats
        stats.birds_scared_total = DB.getstat(0);
        stats.distance_total = DB.getstat(2);
        stats.jumps_total = DB.getstat(4);
        stats.highscore = DB.getstat(3);
        stats.games_played = DB.getstat(12);

        // Load settings
        updatesettings();

        // Update objective message
        objective.text = getobjstring();

        if(stats.objective_type !== 6){
            objective.visible = true;
        }
        else{
            objective.visible = false;
        }

        // Disable highscore message if highscore = 0
        if(stats.highscore === 0){
            stats.highscore_muted = true;
        }

        // Set backgound color
        timecycle();

        // Save realpix conversion rate on first start & show tutorial
        if(DB.getstat(8) === 0){
            DB.setstat(8, Math.floor(rect.height/background.sourceSize.height));
            message.text = 'Welcome to 2107! Tap anywhere to jump.';
            tutorial = true;

            // Load track 0 for tutorial
            addtrack(0, 0);

            // Reset player position
            player.x = gamepix(10);
            player.y = pixfrombottom(terrain[(terrainindex + Math.round(realpix(player.x))) % terrain.length], player.sourceSize.height);

            // Background 'parallax' effect based on player.y
            background.y = page.offset - gamepix(0.05 * (realpix(player.y) - 20));
            middle.y = page.offset - gamepix(0.08 * (realpix(player.y) - 20));
        }
        else{
            // Load first track
            resetterrain();
        }
    }

    // Touch function
    function touch(){

        // Do tutorial if needed
        if(tutorial){
            if(tut_index === 0){
                // First jump
                resume();
                player.vspeed = gamepix(1);
                tut_timer_djump.start();
                return;
            }
            else if(tut_index === 1){
                // Double jump
                resume();
                player.djump = false;
                player.vspeed = gamepix(0.9);
                tut_timer_slam.start();
                return;
            }
            else{
                return; // Wait for completition
            }
        }

        // Resume game if paused
        if(!page.running){
            resume();
            return;
        }

        if(player.onground){// Player is on ground
            player.vspeed = gamepix(1);
            stats.jumps++; // Increment jump stats
        }
        else if(player.djump){ // Player is midair but still has doublejump
            player.djump = false;
            player.vspeed = gamepix(0.9);
            stats.jumps++; // Increment jump stats
        }

    }


    // Main function
    function tick(){

        // Increase distance
        stats.distance += page.speed;

        // Move doves & trigger tick
        for (var i = 0; i < birds.length; i++){
            if(birds[i].alive){
                birds[i].tick();
                birds[i].x = birds[i].x - speed;
            }
            else{ // Remove despawned birds
                birds.splice(i, 1);
                i--;
            }
        }

        // Move background layers
        background.x = (background.x - 0.3*page.speed) % gamepix(150);
        middle.x = (middle.x - 0.7*page.speed) % gamepix(150);

        // Move messages
        movemsgs();

        // Apply gravity to player
        player.prevy = player.y;
        player.y = player.y - player.vspeed;
        player.vspeed = player.vspeed - gamepix(page.gravity);

        // Terrain management
        realindex += realpix(page.speed);
        terrainindex = Math.round(realindex) - 1;

        // Move track images
        var highestx = -100000;
        var highestx_width = page.width;
        for (i = 0; i < track.length; i++){

            if(track[i].x > 0 - track[i].width){
                track[i].x = track[i].x - speed;

                // Get last track element
                if(track[i].x > highestx){
                    highestx = track[i].x;
                    highestx_width = track[i].width;
                }
            }
            else{
                track[i].despawn();
                track.splice(i, 1);
                i--;
            }
        }

        // Add new track

        if(highestx + highestx_width < (page.width + gamepix(12))){ // add gamepix(12) to have some space for dove spawning
            var rantrack = Math.floor(Math.random()*page.trackcount);
            addtrack(rantrack, highestx_width + highestx - gamepix(1)); // Subtracting 1 gamepix for overlap
        }

        // Collision detection
        var playerground;
        var groundpix1 = pixfrombottom(terrain[terrainindex + Math.round(realpix(player.x))], player.sourceSize.height);
        var groundpix5 = pixfrombottom(terrain[terrainindex + Math.round(realpix(player.x)) + 4], player.sourceSize.height);

        // Get highest pixel player is standing on
        if(groundpix1 <= groundpix5){
            playerground = groundpix1;
        }
        else{
            playerground = groundpix5;
        }

        var sidecol = false;
        if(player.y > playerground && player.prevy <= playerground){ // Top collision
            player.y = playerground;
            player.vspeed = 0;
            player.djump = true;
        }
        else if(player.y > playerground){ // Sideways collision
            player.x -= page.speed;
            sidecol = true;
            // Do top collision to avoid falling
            if(player.y > groundpix1){
                player.y = groundpix1;
                player.vspeed = 0;
            }

        }

        // Set player.onground
        if((player.y <= playerground && player.y >= playerground - 5) || (sidecol && player.y <= groundpix1 && player.y >= groundpix1 - 5)){
            player.onground = true;
        }
        else{
            player.onground = false;
        }

        // Move player towards x = gamepix(10) if not there
        if(player.x < gamepix(10) && ! sidecol){
            player.x += page.speed * 0.25;
        }

        // Die if out of screen
        if(player.x < -player.width * 1.5 || player.y > page.height){
            page.glitch = 3;
            glitch_transition.start();
        }

        // Background 'parallax' effect based on player.y
        background.y = page.offset - gamepix(0.05 * (realpix(player.y) - 20));
        middle.y = page.offset - gamepix(0.08 * (realpix(player.y) - 20));

        slowtick(); // Ehh let's just do one tick function - I don't think the separation changed much anyway
        timecycle();
    }


    // Triggers stuff unrelated to graphic output with lower frequency
    function slowtick(){

        // Pause if closed
        if(Qt.application.state !== Qt.ApplicationActive){
            message.text = 'Tap to continue.'
            pause();
        }

        // Check objectives
        objectivecheck();

        // Check highscore
        if(!stats.highscore_muted && stats.distance > stats.highscore){
            stats.highscore_muted = true;
            newhighscore.visible = true;

            // Avoid label overlap
            if(objective.visible && (objective.x + objective.width) > page.width){
                newhighscore.x = objective.x + objective.width * 1.5;
            }
            else if(completed.visible && (completed.x + completed.width) > page.width){
                newhighscore.x = completed.x + completed.width * 1.5;
            }
            else{
                newhighscore.x = page.width;
            }
        }

        // Increase speed
        page.speed = gamepix((3.2 + Math.sqrt(realpix(stats.distance)/70))/8);

        // Randomly spawn doves
        if(Math.floor(Math.random()*30)===1){
            autospawn();
        }

        // Height limit for player
        if(player.y < - player.height * 3){
            player.y = - player.height * 3;
        }


        // Glitching
        if(page.glitch === 1){

            // End glitching 1/20
            if(chance(20)){
                page.glitch = 0;
                background.source = '../img/back.png';
                middle.source = '../img/middle.png';
            }

            // Change glitch image 1/2
            else if(chance(2)){
                // Line offset effect
                background.source = '../img/glitch/back_lines_'+(Math.floor(Math.random()*3)+1)+'.png';
                middle.source = '../img/glitch/middle_lines_'+(Math.floor(Math.random()*3)+1)+'.png';
            }
        }
        else if(page.glitch === 2){

            // Show overlay image
            if(!overlay.visible){
                overlay.visible = true;
                overlay.source = '../img/glitch/overlay_'+Math.ceil(Math.random()*3)+'.png';
            }

            // End glitching 1/10
            if(chance(10)){
                page.glitch = 0;
                overlay.visible = false;
            }

            // Change glitch position 1/2
            else if(chance(2)){
                overlay.x = - Math.floor(Math.random()*(gamepix(150)-page.width));
                overlay.y = - Math.floor(Math.random()*gamepix(20));
            }
        }
        // Heavy glitching as transition
        else if(page.glitch === 3){
            if(chance(4)){ // Change overlay position
                overlay.x = - Math.floor(Math.random()*(gamepix(150)-page.width));
                overlay.y = - Math.floor(Math.random()*gamepix(20));
            }
            if(chance(2)){ // Change background glitch
                background.source = '../img/glitch/back_lines_'+(Math.floor(Math.random()*3)+1)+'.png';
                middle.source = '../img/glitch/middle_lines_'+(Math.floor(Math.random()*3)+1)+'.png';
            }
            if(chance(2)){  // Change sky hue
                page.skycolor = Math.random();
            }
        }
        else {

            // Start glitching
            var mult = Math.round(60/(realpix(stats.distance)/1000)) + 10;
            if(chance(mult)){
                page.glitch = Math.floor(Math.random()*3);
            }
        }

    }


    // Spawns some flying doves when game paused but active
    function pausetick(){

        // Spawn doves
        if(chance(70)){
            var dovex = Math.round(Math.random()*page.width);
            spawndove(dovex, page.height);
            birds[birds.length - 1].startfly(); // Trigger flying for spawned dove
        }

        // Tick doves
        for (var i = 0; i < birds.length; i++){
            if(birds[i].alive){
                birds[i].tick();
            }
            else{ // Remove despawned birds
                birds.splice(i, 1);
                i--;
            }
        }

        timecycle();
    }

    // Prepares new game start
    function reset(){
        pause();
        message.text = 'Tap to restart. Score: '+numconvert(Math.round(realpix(stats.distance)));

        // Set new track & reset player position
        resetterrain();

        // Reset stats & update highscore
        resetstats();

        // Reset music
        if(!page.mute){
            backgroundloop.stop();
        }

        // End glitching
        page.glitch = 0;
        background.source = '../img/back.png';
        middle.source = '../img/middle.png';
        overlay.visible = false;

        // Display objective
        if(stats.objective_type !== 6){
            objective.visible = true;
        }
        else{
            objective.visible = false;
        }

        newhighscore.visible = false;
        completed.visible = false;

        objective.x = page.width;
        objective.text = getobjstring();
    }

    // Shows pause UI
    function pausescreen(){
        pause();

        menu.show(rect.color);
        datamenu.hide();
        filelist.hide();
        fileview.hide();
        shop.hide();

        hidemsgs();
    }

    // Selects a random file & shows data UI
    function datascreen(){

        // List of all files that have not been sold or owned
        var impossible = DB.listseen();
        var count = Files.names().length;
        var possible = Array();

        for(var i = 0; i < count; i++){
            if(!contains(impossible, i)){
                possible.push(i);
            }
        }

        // If there are unseen files left
        if(possible.length > 0){
            // Choose possible file
            var id = possible[Math.floor(Math.random() * possible.length)];

            // Show data UI
            pause();

            menu.hide();
            datamenu.show(rect.color, id);
            filelist.hide();
            fileview.hide();
            shop.hide();

            hidemsgs();
        }
    }

    // Shows data UI
    function filelistscreen(){
        pause();

        menu.hide();
        datamenu.hide();
        filelist.show(rect.color);
        fileview.hide();
        shop.hide();

        hidemsgs();
    }

    // Shows file viewer UI
    function fileviewscreen(id){
        pause();

        menu.hide();
        datamenu.hide();
        filelist.hide();
        fileview.show(rect.color, id);
        shop.hide();

        hidemsgs();
    }

    // Shows shop UI
    function shopmenuscreen(id){
        pause();

        menu.hide();
        datamenu.hide();
        filelist.hide();
        fileview.hide();
        shop.show(rect.color);

        hidemsgs();
    }

    // Hides onscreen messages and pause button
    function hidemsgs(){
        pausebutton.visible = false;
        message.visible = false;
        completed.visible = false;
        newhighscore.visible = false;
    }



    // Spawns doves intelligently
    function autospawn(){
        var count = Math.floor(Math.random()*2)+1; // Spawn 1 - 2 doves
        for(var i = 0; i < count; i++){
            var spawnpos = terrainindex + Math.floor(realpix(page.width)) + 4*i;
            if(terrain[spawnpos] > 0 && terrain[spawnpos] === terrain[spawnpos + 1] && terrain[spawnpos] === terrain[spawnpos + 2]){
                spawndove(gamepix(Math.floor(realpix(page.width)) + 4*i), pixfrombottom(terrain[spawnpos], 3));
            }
        }
    }

    // Spawns a dove at given location
    function spawndove(x, y){
        var dove_comp = Qt.createComponent("../components/dove.qml");
        var mirror = false; // Determines if dove is mirrored

        if(Math.floor(Math.random()*2) === 1){
            mirror = true;
        }
        var temp = dove_comp.createObject(page, {x: x, y: y, height: gamepix(3), width: gamepix(3), mirror: mirror});
        page.birds.push(temp);
    }

    // Spawns a parcour element
    function addtrack(id, x){
        var track_comp = Qt.createComponent("../components/track.qml");
        var currentTime = new Date ( );

        var night = (page.gametime > 190 || page.gametime < 45) ? true : false;
        var temp = track_comp.createObject(page, {x: x, y: page.offset, height: gamepix(50), id: id, night: night});
        page.track.push(temp);

        // Push terrain profile
        var comp_val;
        var comp_num;
        if(id === 0){
            comp_val = Array(10,  4, 13, -10, 18, 10);
            comp_num = Array(21, 10, 31,   6, 26, 6);
        }
        else if(id === 1){
            comp_val = Array(10,  4, -10,  8, 18, 14, -10, 12, -10, 10);
            comp_num = Array( 9, 24,  24, 19, 37, 17,  17, 24,  18, 11);
        }
        else if(id === 2){
            comp_val = Array(10, 4, -10, 9, 14, 12, -10, 19, 25,  6, -10, 11, 18, 24, 20, 15, 9, 4, 5, 4, 3, 2, 1, -10, 25, 1, 2, 3, 4, 6, 7, 9, 10, 14, 10);
            comp_num = Array(8, 17, 15, 12, 13,  9,  10, 17, 24, 16,   6, 24, 15, 16,  1,  1, 1, 1, 1, 1, 2, 1, 1,   6, 20, 4, 1, 1, 1, 1, 1, 1, 22, 21,  9);
        }
        else if(id === 3){
            comp_val = Array(10, 16, -10, 21, 20, 19, 18, 17, 16, 15, 14, 13, 3, 4, 5,  6, -10,  6, 14, 9, 18,  4, 11, -10, 10);
            comp_num = Array(17,  9,  10,  8,  2,  2,  2,  2,  2,  2,  2,  1, 2, 2, 2, 14,  20, 16, 19, 9, 14, 13, 14,  12,  4);
        }
        else if(id === 4){
            comp_val = Array(10,  4, 16, 12, 24, 18, -10, 10);
            comp_num = Array( 9, 25, 17, 20, 35, 21,  14,  9);
        }
        else if(id === 5){
            comp_val = Array(10, 14,  7, -10,  4, 14, 21, 11, 32, 22, -10, 23, 16, 10);
            comp_num = Array( 8, 16, 13,  19, 12, 14, 21,  7, 20,  8,  16, 22, 18,  6);
        }
        else if(id === 6){
            comp_val = Array(10, 16, -10,  7, -10, 15,  5, 8, 11, 14, 17, 22, 12,  8, 16, 10);
            comp_num = Array( 9, 12,  14, 15,   8, 28, 19, 9,  9,  9,  9, 12, 16, 10, 16,  5);
        }
        else if(id === 7){
            comp_val = Array(10, 9, 6, 4, 3, -10, 13, -10, 21, 14,  7, 11,  4, -10, 12, 19, 26, 27, 26, -10, 18, -10, 10);
            comp_num = Array(11, 1, 1, 2, 1,   6, 16,   2, 10, 14, 12, 16, 14,   8, 12, 16,  1, 13,  1,   7, 16,   8, 12);
        }
        else if(id === 8){
            comp_val = Array(10, 16,  4, -10,  6, 13, 22, 15, 5, 11, -10, 17, 8, -10, 16, 10);
            comp_num = Array( 7, 18, 14,  16, 17, 11, 31, 12, 8, 13,  11, 14, 7,   8,  9,  4);
        }
        else if(id === 9){
            comp_val = Array(10, 16,  6, 23, 17, -10, 29,  8, 16, 24, 10, 14, 10);
            comp_num = Array( 8, 23, 19, 18,  6,  11, 28, 15, 18, 26, 10, 12,  6);
        }
        else if(id === 10){
            comp_val = Array(10,  5, -10, 16, 4, 11, -10,  4, 10, 16, -10, 12,  4, -10, 10);
            comp_num = Array( 9, 15,   7, 14, 7, 19,   6, 12, 14, 20,  17, 19, 15,  14, 12);
        }
        else if(id === 11){
            comp_val = Array(10, 14,  4, 11, 17, 6, 10, 14, 18, 22, 23, 22, 18, 14, 10, 9, 6, 2, -10,  5, 11, -10, 10);
            comp_num = Array( 7, 21, 20, 12, 25, 1,  1,  1,  1,  1, 12,  1,  1,  1, 18, 1, 1, 1,  20, 12, 11,  18, 13);
        }
        else if(id === 12){
            comp_val = Array(10,  4, 16, 21, 25, -10, 16, 20, 6, 14, 13, 12, 11, 10, -10, 12, -10, 10);
            comp_num = Array( 8, 16, 11, 15, 19,  21, 17, 17, 9,  4,  3,  3,  3,  3,  14, 18,  11,  8);
        }
        else if(id === 13){
            comp_val = Array(10, 16, -10, 22, 17, -10,  7, -10, 16, 10, 21, 15, -10, 10);
            comp_num = Array( 6,  9,  11, 21, 18,  26, 19,  12, 15,  7, 15, 13,  17, 11);
        }
        else if(id === 14){
            comp_val = Array(10, -10, 10);
            comp_num = Array(15,  22, 13);
        }
        else if(id === 15){
            comp_val = Array(10, 9, 8, 5, -10, 2, 4, 5, 6, 8, 9, 10);
            comp_num = Array( 8, 1, 1, 1,   7, 1, 1, 1, 2, 1, 1,  5);
        }
        else if(id === 16){
            comp_val = Array(10,  4, 12, 11, 10, 9, -10, 16, 25,  8, -10, 13, -10,  4, 11, 16, 10);
            comp_num = Array( 8, 11,  3,  3,  3, 3,   9, 20, 31, 13,  14, 15,  20, 12, 10, 17,  8);
        }
        else if(id === 17){
            comp_val = Array(10,  4, -10,  8, 14, 15, 16, -10, 20, 21, 20, -10, 15, 17, 19, 20, 19, 17, 15, 10, 9, 7, -10,  6, 12, 17, 10);
            comp_num = Array( 7, 13,  15, 10,  4,  4,  4,   5,  1, 16,  1,   5,  1,  1,  1, 18,  1,  1,  1, 17, 1, 1,  11, 10, 12, 28, 11);
        }
        else if(id === 18){
            comp_val = Array(10, -10,  7, 14, -10, 21, 28, 21, 18, 15, 22, 15, -10, 11,  7, 4, 10);
            comp_num = Array(15,   7, 12, 15,   7, 13, 15, 10, 16, 12, 22,  9,   8, 12, 12, 5, 10);
        }
        else if(id === 19){
            comp_val = Array(10, 5, 13, -10, 7, 9, 11, 12, 26, 25, 23, 21, 19, 21, 23, 25, 26, 12, 11, 9, 7, 4,  8, 15, -10,  4, 10);
            comp_num = Array(9, 12, 17,  20, 1, 1,  1, 15,  7,  1,  1,  1,  9,  1,  1,  1,  7, 15,  1, 1, 1, 9, 14, 14,  18, 12, 10);
        }
        else if(id === 20){
            comp_val = Array(10, 5, 16, -10, 20,  6, 11, -10, 21, 22, 21, 12, 11, -10, 17, 22, 10);
            comp_num = Array( 9, 7, 13,  14, 20, 10, 15,  10,  1, 27,  1, 16,  1,   8, 11, 22, 15);
        }
        else if(id === 21){
            comp_val = Array(10, 14, 10, 21, -10, 24,  9, 14, -10, 16, 17, 23, 24, 23,  4, -10,  7, 11, 10, 9, 8, 7, -10, 10);
            comp_num = Array( 6,  9,  3, 18,  11, 13, 17,  9,   8,  1, 15,  1, 16,  1, 16,   9, 11, 13,  2, 2, 2, 1,   7,  9);
        }
        else if(id === 22){
            comp_val = Array(10, 4, -10, 8, 13, 16, -10, 20,  8, 7, -10, 10, 11, 16, 21, 26, 21, 16, -10,  4, 10);
            comp_num = Array(19, 9,  10, 9, 12, 10,  13, 18, 11, 1,  10,  1,  7,  5,  5,  8,  5,  5,  23, 11,  8);
        }


        for (var i = 0; i < comp_val.length; i++){
            for(var j = 0; j < comp_num[i]; j++){
                terrain.push(comp_val[i]);
            }
        }
    }

    // Calculates grey shade of background depending on current time
    function timecycle(){
        // Get seconds from midnight
        const ct = new Date();
        var midnight = ct.getHours()*60*60 + ct.getMinutes()*60 + ct.getSeconds() + ct.getMilliseconds()/1000; // Between 0 and 86400

        // Each day-night cycle lasts 4 mins
        var gametime = midnight % (60*4);
        page.gametime = gametime;

        // Change background color
        const mult = -0.35 * Math.cos(gametime * (Math.PI / 120)) + 0.45;

        // Calculate color shade
        const lightness = Math.round(mult*1000)/10; //Math.floor(132 * mult);
        rect.color = Qt.hsla(page.skycolor, 0.85, mult, 1);

        // Move moon
        const baseX = page.width / 2;
        const baseY = page.height * 0.8;
        const radius = page.height * 0.8;
        var angle = gametime <= 45 ? Math.PI * (gametime / 90 + 0.5) : Math.PI * (gametime / 100 - 1.9);
        moon.x = baseX + Math.cos(angle) * radius;
        moon.y = baseY - Math.sin(angle) * radius;
    }

    // Checks for completed objectives
    function objectivecheck(){
        switch(stats.objective_type){
        case 0:
            if(stats.birds_scared >= stats.objective_count){
                obj_completed(stats.level);
            }
            break
        case 1:
            if(stats.birds_scared_total + stats.birds_scared >= stats.objective_count + stats.objective_basecount){
                obj_completed(stats.level);
            }
            else if(stats.birds_scared_total + stats.birds_scared < stats.objective_basecount){
                DB.setstat(9, stats.birds_scared_total); // Database fucked up somehow, reset basecount to birds_scared_total
                stats.objective_basecount = stats.birds_scared_total;
                pause();
                message.text = 'Sorry, 2107 encountered a problem. It should be fixed now.';
            }
            break
        case 2:
            if(realpix(stats.distance) >= stats.objective_count){
                obj_completed(stats.level);
            }
            break
        case 3:
            if(realpix(stats.distance_total + stats.distance - stats.objective_basecount) >= stats.objective_count){
                obj_completed(stats.level);
            }
            else if(realpix(stats.distance_total + stats.distance) < realpix(stats.objective_basecount)){
                DB.setstat(9, stats.distance_total); // Database fucked up somehow, reset basecount to distance_total
                stats.objective_basecount = stats.distance_total;
                pause();
                message.text = 'Sorry, 2107 encountered a problem. It should be fixed now.';
            }

            break
        case 4:
            if(stats.jumps >= stats.objective_count){
                obj_completed(stats.level);
            }
            break
        case 5:
            if(stats.jumps_total + stats.jumps >= stats.objective_count + stats.objective_basecount){
                obj_completed(stats.level);
            }
            else if(stats.jumps_total + stats.jumps < stats.objective_basecount){
                DB.setstat(9, stats.jumps_total); // Database fucked up somehow, reset basecount to jumps_total
                stats.objective_basecount = stats.jumps_total;
                pause();
                message.text = 'Sorry, 2107 encountered a problem. It should be fixed now.';
            }
            break
        case 6: // Unfulfillable
            break
        case 7:
            if(stats.games_played >= stats.objective_count + stats.objective_basecount){
                obj_completed(stats.level);
            }
            else if(stats.games_played < stats.objective_basecount){
                DB.setstat(9, stats.games_played); // Database fucked up somehow, reset basecount to games_played
                stats.objective_basecount = stats.games_played;
                pause();
                message.text = 'Sorry, 2107 encountered a problem. It should be fixed now.';
            }
            break
        }
    }

    ////////////////////////////////////
    // Smallish function collection   //
    ////////////////////////////////////

    // Converts game/graphic pixels to display pixels
    function gamepix(num){
        return Math.floor(rect.height/background.sourceSize.height)*num;
    }

    // Converts real pixels to game pixels
    function realpix(num){
        return num/Math.floor(rect.height/background.sourceSize.height);
    }

    // Returns y value for an object n game pixels from the bottom given the source height
    function pixfrombottom(n, sheight){
        return rect.height- gamepix(n) - gamepix(sheight);
    }

    // Returns true with 1/prob probability, else false
    function chance(prob){
        if(Math.floor(Math.random()*prob) === 0){
            return true;
        }
        else{
            return false;
        }
    }

    // Deletes past terrain data
    function memclean(){
        for(var i = 0; i < (realindex - 10); i++){
            terrain.splice(i, 1);
            i--;
            realindex--;
        }
    }

    // Pauses game
    function pause(){
        if(!page.mute){
            backgroundloop.pause();
        }
        page.running = false;
        message.visible = true;
    }

    // Resumes game
    function resume(){

        // Reload all settings from DB
        updatesettings();

        if(!page.mute){
            backgroundloop.play();
        }
        datamenu.hide();
        filelist.hide();
        fileview.hide();
        menu.hide();
        shop.hide();

        page.running = true;
        message.visible = false;
        pausebutton.visible = true;
        menu_back.color = 'transparent';
    }

    // Coverts numbers to easily readable format
    function numconvert(num){
        if(num < 1000){
            return num;
        }
        else if(num < 1000000){
            return Math.round(num/10)/100 + 'k';
        }
        else{
            return Math.round(num/10000)/100 + 'm';
        }
    }

    // Checks if array of gadgets contains value
    function contains(array, value) {
        for (var i = 0; i < array.length; i++) {
            if (array[i]['uid'] === value) {
                return true;
            }
        }
        return false;
    }

    ////////////////////////////////////
    // Longer function collection     //
    ////////////////////////////////////

    // Shows objective completed message
    function obj_completed(lvl){

        // Stats & Level changes are only written to DB on reset to avoid lag
        // -> Per-game progress is lost on crash or exit while game is running

        // Avoid label overlap
        if(newhighscore.visible && (newhighscore.x + newhighscore.width) > page.width){
            completed.x = newhighscore.x + newhighscore.width * 1.5;
        }
        else{
            completed.x = page.width;
        }

        completed.text = 'Level '+(lvl+1)+' completed!';
        completed.visible = true;

        // Load & display new objective
        stats.level = lvl + 1;
        stats.objective_count = stats.lvl_count[lvl + 1];
        stats.objective_type = stats.lvl_type[lvl + 1];

        // Set base count for objectives on total stats
        if(stats.objective_type === 1){ // Total birds
            stats.objective_basecount = stats.birds_scared + stats.birds_scared_total;
        }
        else if(stats.objective_type === 3){ // Total distance
            stats.objective_basecount = stats.distance + stats.distance_total;
        }
        else if(stats.objective_type === 5){ // Total jumps
            stats.objective_basecount = stats.jumps + stats.jumps_total;
        }
        else if(stats.objective_type === 7){ // Games played
            stats.objective_basecount = stats.games_played;
        }

        objective.visible = true;
        objective.x = page.width + completed.width * 1.5;
        objective.text = getobjstring();
    }

    // Builds objective string
    function getobjstring(){
        var objstring = '';
        switch(stats.objective_type){
        case 0:
            objstring = 'Scare '+stats.objective_count+' birds in one run '+stats.birds_scared+'/'+stats.objective_count;
            break
        case 1:
            objstring = 'Scare '+stats.objective_count+' birds '+(stats.birds_scared_total + stats.birds_scared -stats.objective_basecount)+'/'+stats.objective_count;
            break
        case 2:
            objstring = 'Travel '+stats.objective_count+'m in one run '+Math.round((realpix(stats.distance)/stats.objective_count)*100)+'%';
            break
        case 3:
            objstring = 'Travel '+stats.objective_count+'m '+Math.round((realpix(stats.distance_total + stats.distance-stats.objective_basecount)/stats.objective_count)*100)+'%';
            break
        case 4:
            objstring = 'Jump '+stats.objective_count+' times in one run '+stats.jumps+'/'+stats.objective_count;
            break
        case 5:
            objstring = 'Jump '+stats.objective_count+' times '+(stats.jumps_total + stats.jumps -stats.objective_basecount)+'/'+stats.objective_count;
            break
        case 6:
            objstring = 'Well done! No more objectives for now.';
            break
        case 7:
            objstring = 'Play  '+stats.objective_count+' games '+(stats.games_played - stats.objective_basecount)+'/'+stats.objective_count;
            break
        }
        return 'Level '+(stats.level+1)+': '+objstring;
    }

    // Resets terrain & doves
    function resetterrain(){
        // Delete Track items
        for (var i = 0; i < page.track.length; i++){
            track[i].despawn();
        }
        page.track = Array();

        // Delete spawned doves
        for (i = 0; i < page.birds.length; i++){
            birds[i].despawn();
        }
        page.birds = Array();

        // Reset terrain
        page.terrain = Array();
        page.terrainindex = 0;
        page.realindex = 0;
        var trackid = Math.floor(Math.random()*page.trackcount);
        if(trackid === 14 || trackid === 15){
            trackid = trackid - Math.floor(Math.random()*7) - 2; // Avoid starting with small tracks
        }

        addtrack(trackid, 0);

        // Reset player position
        player.x = gamepix(10);
        player.y = pixfrombottom(terrain[(terrainindex + Math.round(realpix(player.x))) % terrain.length], player.sourceSize.height);

        // Background 'parallax' effect based on player.y
        background.y = page.offset - gamepix(0.05 * (realpix(player.y) - 20));
        middle.y = page.offset - gamepix(0.08 * (realpix(player.y) - 20));
    }

    // Resets per-game stats & saves new totals, updates highscores if needed
    function resetstats(){
        // Update highscore
        if(stats.distance > stats.highscore){
            DB.setstat(3, stats.distance); // Update highscore
            stats.highscore = stats.distance;
        }

        // Update best jumps
        if(stats.jumps > DB.getstat(5)){
            DB.setstat(5, stats.jumps);
        }

        // Update best birds_scared
        if(stats.birds_scared > DB.getstat(1)){
            DB.setstat(1, stats.birds_scared);
        }

        // Increment games_played
        stats.games_played++;
        DB.setstat(12, stats.games_played);

        // Reset stats
        stats.birds_scared_total += stats.birds_scared;
        stats.birds_scared = 0;
        stats.distance_total += stats.distance;
        stats.distance = 0;
        stats.jumps_total += stats.jumps;
        stats.jumps = 0;

        if(stats.highscore !== 0){
            stats.highscore_muted = false;
        }

        // Save stats to DB
        DB.setstat(0, stats.birds_scared_total);
        DB.setstat(2, stats.distance_total);
        DB.setstat(4, stats.jumps_total);
        DB.setstat(9, stats.objective_basecount);
        DB.setstat(6, stats.level);
    }

    // Moves messages (highscore, objective, objective completed) along screen
    function movemsgs(){
        // Move objective text if on screen
        if(objective.visible){
            objective.x -= page.speed * 1.5;
            objective.text = getobjstring();
            if(objective.x < -objective.width){
                objective.visible = false;
            }
        }

        // Move completed message if on screen
        if(completed.visible){
            completed.x -= page.speed * 1.5;
            if(completed.x < -completed.width){
                completed.visible = false;
            }
        }

        // Move highscore message if on screen
        if(newhighscore.visible){
            newhighscore.x -= page.speed * 1.5;
            if(newhighscore.x < -newhighscore.width){
                newhighscore.visible = false;
            }
        }
    }

    // Loads settings from DB, called on load & resume
    function updatesettings(){

        // Update character image
        player.source = '../img/player'+(DB.getstat(7)+1)+'.png';

        // Update mute setting
        if(DB.getstat(11) === 1){
            page.mute = true;
        }
        else{
            page.mute = false;
        }

        // Load objective
        stats.level = DB.getstat(6);
        stats.objective_basecount = DB.getstat(9);
        stats.objective_count = stats.lvl_count[stats.level];
        stats.objective_type = stats.lvl_type[stats.level];

        // Load all total stats to avoid anomalies
        stats.birds_scared_total = DB.getstat(0);
        stats.jumps_total = DB.getstat(4);
        stats.distance_total = DB.getstat(2);
        stats.games_played = DB.getstat(12);

        // Get OLED gadget status
        if(DB.getgadget(0) === 1){
            player.indicator = true;
        }
        else{
            player.indicator = false;
        }

        // Get Mp3 gadget status
        if(DB.getgadget(3) === 1){
            page.altsoundtrack = true;
        }
        else{
            page.altsoundtrack = false;
        }
    }

    Audio{
        id: backgroundloop
        source: page.altsoundtrack ? '../aud/alternate.wav' : '../aud/background_looped.mp3'
        loops: Audio.Infinite
        muted: page.mute
        // Auido is looped in file a few times already because there is an ugly cut when looping here.
    }

    // Main ticker
    Timer {
        id: ticker
        interval: 35
        running: page.running
        repeat: true
        onTriggered: tick()
    }

    // Runs when game paused but open
    Timer {
        id: pauseticker
        interval: 35
        running: !page.running && Qt.application.active && pageStack.currentPage == page
        repeat: true
        onTriggered: pausetick()
    }

    // Deletes past terrain data
    Timer {
        id: memcleaner
        interval: 5000
        running: page.running
        repeat: true
        onTriggered: memclean()
    }

    // Heavy glitching on death
    Timer {
        id: glitch_transition
        interval: 300
        running: false
        repeat: false
        onTriggered: reset()
    }

    // Shows double jump tutorial
    Timer {
        id: tut_timer_djump
        interval: 1100
        running: false
        repeat: false
        onTriggered: {
            page.tut_index = 1;
            pause();
            message.text = 'Nice! Tap again to doublejump.';
        }
    }

    // Shows slam tutorial
    Timer {
        id: tut_timer_slam
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            page.tut_index = 2;
            pause();
            message.text = 'Great! Now swipe down to slam.';
        }
    }

    // Shows tutorial completition message
    Timer {
        id: tut_timer_done
        interval: 600
        running: false
        repeat: false
        onTriggered: {
            page.tutorial = false;
            pause();
            message.text = 'That\'s it, have fun!';
        }
    }

    // Solid color background
    Rectangle {
        id: rect
        z: 0
        width: parent.width
        height: parent.height
        color: '#bbbbbb'
        MouseArea {
            // based on Swipe recognition by Gianluca from https://forum.qt.io/topic/39641/swipe-gesture-with-qt-quick-2-0-and-qt-5-2/4  - Thanks!
            anchors.fill: parent
            preventStealing: true
            property real yvelocity: 0.0
            property int yStart: 0
            property int yPrev: 0
            property bool tracing: false
            property bool swiped: false
            onPressed: {
                yStart = mouse.y
                yPrev = mouse.y
                yvelocity = 0
                tracing = true
            }

            // Abort jump on swipe down
            onPositionChanged: {
                if (tracing){
                    var ycurrVel = (mouse.y-yPrev);
                    yvelocity = (yvelocity + ycurrVel)/2.0;
                    yPrev = mouse.y;
                    if(yvelocity > 12 && Math.abs(yStart - mouse.y) > parent.width * 0.1){

                        // Slam tutorial
                        if(tutorial && tut_index === 2){
                            resume();
                            tut_timer_done.start();
                        }

                        tracing = false
                        player.vspeed = -gamepix(1); // Slam down
                        swiped = true;
                    }
                }
            }

            onReleased: {
                tracing = false
            }
            onClicked:{
                if(swiped){
                    swiped = false;
                }
                else{
                    touch();
                }
            }
        }
    }

    // Moon
    Image {
        x: 0
        y: 0
        z: 1
        id: moon
        source: "../img/moon.png"
        smooth: false
        opacity: 1
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
    }

    // Second background layer
    Image {
        x: 0
        y: page.offset
        z: 2
        id: background
        source: "../img/back.png"
        smooth: false
        opacity: 1
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
    }

    // First background layer
    Image {
        x: 0
        y: page.offset
        z: 3
        id: middle
        source: "../img/middle.png"
        smooth: false
        opacity: 1
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
    }

    // Objective Text
    Label{
        visible: true
        id: objective
        text: 'Something went wrong...';
        y: gamepix(5)
        x: page.width
        z: 6
    }

    // Objective completed message
    Label{
        visible: false
        id: completed
        text: 'Objective completed!'
        y: gamepix(5)
        x: page.width
        z: 6
    }

    // Highscore message
    Label{
        visible: false
        id: newhighscore
        text: 'New highscore!'
        y: gamepix(5)
        x: page.width
        z: 6
    }

    Rectangle{
        color: 'transparent'
        width: gamepix(7)
        height: gamepix(7)
        x: page.width - gamepix(7)
        y: 0
        z: 6
        id: pausebutton

        Image {
            anchors.centerIn: parent
            z: 6
            source: "../img/pause.png"
            smooth: false
            width: gamepix(sourceSize.width)
            height: gamepix(sourceSize.height)
        }

        MouseArea{
            anchors.fill: parent
            onClicked: pausescreen()
        }
    }

    // Main menu

    Rectangle{
        id: menu
        visible: false;
        height: parent.height
        width: parent.width
        color: 'transparent'
        z: 10

        function show(color){
            visible = true;
            menu_back.color = "black";
            menu_obj.text = getobjstring();
        }

        function hide(){
            visible = false;
        }

        // Block touch events to prevent game from resuming
        MouseArea{
            anchors.fill: parent
        }

        Rectangle{
            id: menu_back
            anchors.fill: parent
            z: 10
            color: 'transparent'
            opacity: 0.4

            Behavior on color {
                ColorAnimation {duration: 400 }
            }
        }

        Rectangle{
            id: settingsbutton
            height: gamepix(6)
            width: parent.width / 4
            anchors.left: parent.left
            z: 11
            color: 'transparent'

            Label{
                anchors.centerIn: parent
                text: 'Settings'
                font.pixelSize: Theme.fontSizeLarge
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    pageStack.push(Qt.resolvedUrl("settings.qml"))
                }
            }
        }

        Rectangle{
            id: statsbutton
            height: gamepix(6)
            width: parent.width / 4
            anchors.left: settingsbutton.right
            z: 11
            color: 'transparent'

            Label{
                anchors.centerIn: parent
                text: 'Stats'
                font.pixelSize: Theme.fontSizeLarge
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    pageStack.push(Qt.resolvedUrl("stats.qml"))
                }
            }
        }

        Rectangle{
            id: filesbutton
            height: gamepix(6)
            width: parent.width / 4
            anchors.right: shopbutton.left
            z: 11
            color: 'transparent'

            Label{
                anchors.centerIn: parent
                text: 'Files'
                font.pixelSize: Theme.fontSizeLarge
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    filelistscreen()
                }
            }
        }

        Rectangle{
            id: shopbutton
            height: gamepix(6)
            width: parent.width / 4
            anchors.right: parent.right
            z: 11
            color: 'transparent'

            Label{
                anchors.centerIn: parent
                text: 'Shop'
                font.pixelSize: Theme.fontSizeLarge
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    shopmenuscreen()
                }
            }
        }

        Rectangle{
            id: menuline
            height: gamepix(1)
            width: page.width
            opacity: 1
            x: 0
            y: gamepix(6)
            z: 11
            color: '#e7e7e7'
        }

        Column{
            opacity: 1
            y: gamepix(7) + Theme.paddingLarge
            z: 11
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.width * 0.6
            spacing: Theme.paddingSmall

            Label{
                text: 'Stats'
                font.pixelSize: Theme.fontSizeLarge
            }
            Label{
                text: 'Distance: '+numconvert(Math.round(realpix(stats.distance)))
                font.pixelSize: Theme.fontSizeMedium
            }
            Label{
                text: 'Highscore: '+numconvert(Math.round(realpix(stats.highscore)))
                font.pixelSize: Theme.fontSizeMedium
            }
            Label{
                text: 'Jumps: '+numconvert(stats.jumps)
                font.pixelSize: Theme.fontSizeMedium
            }
            Label{
                text: 'Birds scared: '+numconvert(stats.birds_scared)
                font.pixelSize: Theme.fontSizeMedium
            }
            Label{
                id: menu_obj
                text: 'Something went wrong...'
                font.pixelSize: Theme.fontSizeMedium
            }

            // Spacer
            Item{
                height: Theme.paddingMedium
                width: parent.width
            }

            Label{
                anchors.horizontalCenter: parent.horizontalCenter
                text: 'Tap to continue'
                font.pixelSize: Theme.fontSizeMedium

                MouseArea{
                    anchors.fill: parent
                    onClicked: resume()
                }
            }
        }
    }

    // Data menu
    DataScreen{
        id: datamenu
    }

    // File list
    FileListScreen{
        id: filelist
    }

    // File viewer
    ViewScreen{
        id: fileview
    }

    // Shop
    ShopScreen{
        id: shop
    }

    ParticleSystem{
        anchors.fill: parent
        z: 6
        running: page.running

        ImageParticle{
            source: '../img/particle.png'
            alphaVariation: 0.4
            entryEffect: ImageParticle.None
        }

        Gravity{
            anchors.fill: parent
            angle: 90
            magnitude: 70
        }

        Emitter{
            id: emitter
            enabled: player.onground
            height: gamepix(1)
            width: gamepix(1)
            y: player.y + gamepix(player.sourceSize.height)
            x: player.x
            size: gamepix(1)
            lifeSpan: 2000
            velocity: AngleDirection{
                angle: 215
                angleVariation: 15
                magnitude: 100 + page.speed * 10
            }

        }
    }

    // Playable character
    Image {
        id: player
        x: 0
        y: 0
        z: 7
        source: "../img/player1.png"
        smooth: false
        opacity: 1
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)

        property real vspeed: 0
        property real prevy: 0 // Previous player height
        property bool djump: true // Able to doublejump
        property bool onground: true // Player is standing on ground
        property bool indicator: false

        // Jumpstate gadget
        Rectangle{
            visible: parent.indicator && parent.source !== '../img/player9.png' // Do not display for moose eegg
            height: gamepix(1)
            width: gamepix(1)
            color: parent.djump ? '#e7e7e7' : '#3a3a3a'
            x: gamepix(2)
            y: gamepix(4)
        }
    }

    Label{
        id: message
        z: 6
        anchors.centerIn: parent
        text: 'Tap to start.';
    }

    // Tutorial skip button
    Label{
        z: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.paddingLarge

        visible: page.tutorial

        font.pixelSize: Theme.fontSizeMedium
        text: 'Skip tutorial'

        MouseArea{
            anchors.fill: parent
            onClicked: {
                message.text = 'Tap to start.';
                tutorial = false
            }
        }
    }

    // Overlay glitch
    Image {
        id: overlay
        visible: false
        x: 0
        y: 0
        z: 8
        source: "../img/glitch/overlay_1.png"
        smooth: false
        opacity: 0.6
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
    }
}
