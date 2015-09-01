import QtQuick 2.0

Image {
    source: "../img/dove1.png"
    mirror: false
    id: animal
    opacity: 1
    smooth: false
    x: 30
    y: 30
    z: 4
    width: 30
    height: 30
    property bool alive: true
    property bool flying: false
    property int speed: 5
    property real direction: 0 // Flying direction
    property int viewarea: 9 + Math.floor(Math.random()*12) // Player distance for triggering flying

    function tick(){
        // Check for despawn
        if(y < -height || y > rect.height || x < -width){
            despawn();
        }

        // Check for nearby player
        var dx = x - (player.x + gamepix(2)); // Use center of player for distance
        var dy = y - (player.y + gamepix(3));
        var dist = Math.sqrt(dx*dx + dy*dy);
        // If player is near, fly away
        if(!flying && dist < gamepix(viewarea)){
            flying = true;
            source = "../img/dove2.png";
            direction = (Math.random()*2) - 1; // Between -1 and 1
            flapper.run = true;

            // Increment birds_scared stats
            stats.birds_scared++;
        }

        // Fly
        if(flying){
            y = y - speed;
            x = x - speed*direction;
        }
    }

    // End tick function

    function despawn(){
        alive = false;
        flapper.run = false;
        destroy(0);
    }

    // Manually start flying
    function startfly(){
        flying = true;
        source = "../img/dove2.png";
        direction = (Math.random()*2) - 1; // Between -1 and 1
        flapper.run = true;
    }

    Timer{
        id: flapper
        running: run && Qt.application.active
        repeat: true
        interval: 250
        property bool even: false
        property bool run: false
        onTriggered: {
            even = !even;

            if(even){
                parent.source = "../img/dove3.png";
            }
            else{
                parent.source = "../img/dove2.png";
            }

        }
    }

    Timer{
        id: positionfixer
        running: true
        interval: 300
        repeat: false
        onTriggered: {
            // Check that bird is not hovering above ground
            if(!flying){
                var expheight = pixfrombottom(page.terrain[page.terrainindex + Math.ceil(realpix(x))], 3);
                if(expheight !== y){
                    y = expheight;
                }
            }
        }
    }

}
