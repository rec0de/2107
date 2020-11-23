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
    property var content: Files.content()
    property int id: 0

    function show(color, loadid){
        visible = true;
        back.color = color;

        id = loadid;
        if(doctypes[id] === 3){
            row_image.visible = true;
            row_text.visible = false;
        }
        else{
            row_image.visible = false;
            row_text.visible = true;
            flick.contentY = 0;
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
        width: parent.width
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
                // Show file list screen
                filelistscreen();
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
        id: row_text
        opacity: 1
        z: 11
        y: gamepix(7) + Theme.paddingLarge;
        anchors.horizontalCenter: parent.horizontalCenter
        width: back.width - Theme.paddingLarge * 2
        height: parent.height - gamepix(7) - Theme.paddingLarge * 2;
        spacing: Theme.paddingMedium

        Image {
            id: fileicon
            z: 11
            source: "../img/doctype"+doctypes[id]+".png"
            smooth: false
            width: gamepix(sourceSize.width)
            height: gamepix(sourceSize.height)
        }


        Column{
            width: parent.width - fileicon.width - Theme.paddingMedium
            height: parent.height
            spacing: Theme.paddingMedium

            Label{
                id: title
                text: names[id]
                font.pixelSize: Theme.fontSizeLarge
            }

            Flickable{
                id: flick
                width: parent.width
                height: parent.height - title.height - Theme.paddingMedium
                clip: true

                contentHeight: contentlabel.height
                contentWidth: parent.width

                Label{
                    id: contentlabel
                    text: content[id]
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
    }

    Row{
        id: row_image
        visible: false
        opacity: 1
        z: 11
        y: gamepix(7) + Theme.paddingLarge;
        anchors.horizontalCenter: parent.horizontalCenter
        width: back.width * 0.7
        height: parent.height - gamepix(7) - Theme.paddingLarge * 2;
        spacing: Theme.paddingLarge

        Column{
            width: parent.width
            spacing: Theme.paddingMedium

            Label{
                anchors.left: image.left
                id: label
                text: names[id]
                font.pixelSize: Theme.fontSizeLarge
            }

            Image {
                id: image
                z: 11
                anchors.horizontalCenter: parent.horizontalCenter
                source: (doctypes[id] === 3) ? "../img/"+content[id] : "../img/data1.png"
                smooth: false
                width: (parent.width * (sourceSize.height / sourceSize.width) < row_image.height - label.height) ? parent.width : (row_image.height - label.height)*(sourceSize.width / sourceSize.height)
                height: (parent.width * (sourceSize.height / sourceSize.width) < row_image.height - label.height) ? parent.width * (sourceSize.height / sourceSize.width) : row_image.height - label.height
            }
        }
    }
}
