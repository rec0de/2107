import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB
import '../files.js' as Files

Rectangle{
    visible: false;
    height: parent.height
    width: parent.width
    color: 'transparent'
    z: 10
    property var doctypes:  Files.doctypes()
    property var names: Files.names()
    property int active: 0

    function show(color){
        visible = true;
        back.color = color;

        var data = DB.listowned();

        listmodel.clear();

        for(var i = 0; i < data.length; i++){
            listmodel.append({"id": data[i].uid});
        }

        if(data.length > 0){
            active = data[0].uid;
            listview.visible = true;
            placeholder.visible = false;
        }
        else{
            listview.visible = false;
            placeholder.visible = true;
        }
    }

    function hide(){
        visible = false;
    }

    // Block touch events to prevent game from resuming
    MouseArea{
        anchors.fill: parent
    }

    Rectangle{
        id: back
        anchors.fill: parent
        z: 10
        color: 'transparent'
        opacity: 0.6

        Behavior on color {
            ColorAnimation {duration: 700 }
        }
    }

    Rectangle{
        height: gamepix(6)
        width: parent.width / 2
        anchors.left: parent.left
        z: 11
        color: 'transparent'

        Label{
            anchors.centerIn: parent
            text: 'Back'
            font.pixelSize: Theme.fontSizeLarge
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{
                // Show pause screen
                pausescreen();
            }
        }
    }

    Rectangle{
        height: gamepix(6)
        width: parent.width / 2
        anchors.right: parent.right
        z: 11
        color: 'transparent'

        Label{
            anchors.centerIn: parent
            text: 'View'
            font.pixelSize: Theme.fontSizeLarge
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{
                if(! placeholder.visible){
                    fileviewscreen(active)
                }
            }
        }
    }

    Rectangle{
        height: gamepix(1)
        width: page.width
        opacity: 1
        x: 0
        y: gamepix(6)
        z: 11
        color: '#e7e7e7'
    }

    Row{
        id: row
        opacity: 1
        z: 11
        y: gamepix(7) + Theme.paddingLarge;
        anchors.horizontalCenter: parent.horizontalCenter
        width: back.width * 0.8
        height: parent.height - gamepix(7) - Theme.paddingLarge * 2;
        spacing: Theme.paddingLarge

        Column{
            Image {
                z: 11
                source: "../img/doctype"+doctypes[active]+".png"
                smooth: false
                width: gamepix(sourceSize.width)
                height: gamepix(sourceSize.height)

                MouseArea{
                    anchors.fill: parent

                    onClicked:{
                        if(! placeholder.visible){
                            fileviewscreen(active)
                        }
                    }
                }
            }

            Label{
                visible: ! placeholder.visible
                text: 'tap to view'
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea{
                    anchors.fill: parent

                    onClicked:{
                        if(! placeholder.visible){
                            fileviewscreen(active)
                        }
                    }
                }
            }
        }

        Column{
            width: parent.width / 2
            spacing: Theme.paddingMedium

            Label{
                id: listheader
                text: 'File List'
                font.pixelSize: Theme.fontSizeLarge
            }

            Label{
                id: placeholder
                visible: false
                text: 'No files yet :('
                font.pixelSize: Theme.fontSizeMedium
            }

            ListView {
                id: listview
                clip: true
                width: parent.width
                height: row.height - listheader.height - Theme.paddingLarge - Theme.paddingMedium
                snapMode: ListView.SnapToItem
                model: listmodel

                delegate: Row{
                    width: parent.width

                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        source: '../img/doctype'+doctypes[id]+'.png'
                        smooth: false
                        height: 27
                        width: 27
                    }

                    Rectangle{
                        // Spacer
                        height: parent.height
                        width: Theme.paddingMedium
                        color: 'transparent'
                    }

                    Label {
                        text: names[id]
                        font.pixelSize: Theme.fontSizeMedium
                        anchors.verticalCenter: parent.verticalCenter
                        color: (active === id) ? '#ffffff' : '#cccccc'

                        MouseArea{
                            anchors.fill: parent

                            onClicked:{
                                active = id;
                            }
                        }
                    }
                }
            }

            ListModel {
                id: listmodel
            }
        }
    }
}
