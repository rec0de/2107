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
    property int id: 0
    property int value: 0
    property string name: 'Error'
    property bool firsttime: false

    function show(color, loadid){

        var names = Files.names();
        var values = Files.values();

        if(DB.getstat(13) !== 1){
            firsttime = true;
        }
        else{
            firsttime = false;
        }

        visible = true;
        datamenu_back.color = color;
        id = loadid;
        value = values[id];
        name = names[id];
    }

    function hide(){
        visible = false;
    }

    // Block touch events to prevent game from resuming
    MouseArea{
        anchors.fill: parent
    }

    Rectangle{
        id: firsttime_info
        visible: firsttime
        z: 13
        anchors.centerIn: parent
        width: parent.width - Theme.paddingLarge * 2
        height: firsttime_info_label.height + Theme.paddingMedium * 2 + gamepix(2)
        color: 'transparent'
        border.color: '#e7e7e7'
        border.width: gamepix(1)

        Row{
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.paddingSmall * 2 - gamepix(2)
            z: 13
            spacing: Theme.paddingMedium

            Image{
                id: infoicon
                smooth: false
                source: '../img/info.png'
                height: gamepix(sourceSize.height)
                width: gamepix(sourceSize.width)
            }

            Label {
                id: firsttime_info_label
                text:   'Cool, you just found some data! Now you have two options:<br>1. Sell the file for credits on the black market<br>2. Keep the file and add it to your collection<br>If you choose to sell, you\'ll never know the contents of the file. If you keep it, you can\'t sell it anymore. Choose wisely.'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                z: 14
                width: parent.width - infoicon.width - Theme.paddingMedium
            }
        }

        // Background for infobox, colors border gray for some reason, therefore smaller height and width
        Rectangle{
            height: parent.height - gamepix(2)
            width: parent.width - gamepix(2)
            anchors.centerIn: parent
            opacity: 0.9
            color: datamenu_back.color
            z: 12
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                parent.visible = false;
                // Do not display message again
                DB.setstat(13, 1);
            }
        }
    }

    Rectangle{
        id: datamenu_back
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
            text: 'Keep'
            font.pixelSize: Theme.fontSizeLarge
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{
                // Mark file as owned
                DB.setval(id, 2);

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
            text: 'Sell'
            font.pixelSize: Theme.fontSizeLarge
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{
                // Get player credits
                var credits = DB.getstat(14);
                if(credits < 0){credits = 0;}

                // Add value of file to credits, mark file as sold
                DB.setstat(14, credits + value);
                DB.setval(id, 1);

                // Show pause screen
                pausescreen();
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
        opacity: 1
        z: 11
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: page.width * 0.8
        spacing: Theme.paddingSmall

        Image {
            z: 11
            source: "../img/data"+((id % 4)+1)+".png"
            smooth: false
            width: gamepix(sourceSize.width)
            height: gamepix(sourceSize.height)
        }

        Column{
            Label{
                text: 'Data found'
                font.pixelSize: Theme.fontSizeLarge
            }

            Item{
                // Spacer
                height: Theme.paddingMedium
                width: parent.width
            }

            Label{
                text: 'Filename'
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Label{
                text: name
                font.pixelSize: Theme.fontSizeMedium
            }

            Item{
                // Spacer
                height: Theme.paddingMedium
                width: parent.width
            }

            Label{
                text: 'Worth'
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Label{
                text: value + 'c'
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
