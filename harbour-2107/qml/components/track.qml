import QtQuick 2.0

Image {
    source: "../img/tracks/track_"+id+(night ? '_n' : '')+".png" // Use night image if needed
    mirror: false
    id: animal
    opacity: 1
    smooth: false
    width: (height / 50) * sourceSize.width
    x: 30
    y: 30
    z: 5
    property int id: 0
    property bool night: false


    // End tick function

    function despawn(){
        destroy(0);
    }

}
