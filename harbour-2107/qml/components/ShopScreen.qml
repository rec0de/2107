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
    property var names: Array('OLED Implant', 'TDx 3', 'Plush animal', 'MP3 Player');
    property var prices: Array(24, 126, 214, 78);
    property var descriptions: Array('Not the most trustworthy implant, but it gets the job done. Changes color according to douple jump status.', 'Highly experimental time dilation drugs. Might mess with the fourth dimension. Slows down stuff.', 'A slightly used plush moose. Looks cute.', 'Comes with a totally new tune. Groovy!');
    property var stati: Array();

    property int active: -1
    property int credits: 0

    function show(color){
        visible = true;
        back.color = color;

        credits = DB.getstat(14);
        if(! credits > 0){
            credits = 0;
        }

        refresh();
    }

    function hide(){
        visible = false;
    }

    // Reloads gadget status from DB
    function refresh(){
        listmodel.clear();
        var status;

        for(var i = 0; i < names.length; i++){
            status = DB.getgadget(i);
            if(status !== 1 && status !== 2){
                status = 0;
            }

            stati[i] = status;
            listmodel.append({"id": i});
        }
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
                datascreen()
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
                source: (active === -1) ? '../img/cybershed.png': '../img/gadgets/'+active+'.png';
                smooth: false
                width: gamepix(sourceSize.width)
                height: gamepix(sourceSize.height)
            }

            Label{
                id: producttext
                width: row.width / 2 - Theme.paddingLarge
                wrapMode: Text.WordWrap
                text: (active === -1) ? 'Welcome to the CyberShed.': descriptions[active]
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        Column{
            width: parent.width / 2
            spacing: Theme.paddingMedium

            Label{
                id: listheader
                text: 'The CyberShed'
                font.pixelSize: Theme.fontSizeLarge
            }

            ListView {
                id: listview
                clip: true
                width: parent.width
                height: row.height - listheader.height - balance.height -buybutton.height - Theme.paddingLarge - Theme.paddingMedium * 3
                snapMode: ListView.SnapToItem
                model: listmodel

                delegate: Row{
                    width: parent.width

                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        source: '../img/gadgets/'+id+'.png'
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
                        font.pixelSize: Theme.fontSizeMedium
                        text: names[id] + ' - ' + ((stati[id] === 0) ? (prices[id] +'c') : ((stati[id] === 1) ? 'active' : 'inactive'));
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

            Label{
                id: balance
                font.pixelSize: Theme.fontSizeMedium
                text: 'Current balance: '+credits+'c'
            }
            Label{
                id: buybutton
                visible: (active !== -1)
                font.pixelSize: Theme.fontSizeMedium
                text: (active === -1) ? 'This should be invisible' : ((stati[active] === 0) ? ('Buy '+names[active]) : ((stati[active] === 1) ? ('Disable '+names[active]) : ('Enable '+names[active])))

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(stati[active] === 0 && credits + 100000 >= prices[active]){ //DEBUG!
                            credits -= prices[active];

                            // Save new balance
                            DB.setstat(14, credits);

                            // Unlock gadget
                            stati[active] = 1;
                            DB.setgadget(active, 1);

                            // Refresh UI
                            refresh();
                        }
                        else if(stati[active] === 1){
                            // Disable gadget
                            stati[active] = 2;
                            DB.setgadget(active, 2);
                            refresh();
                        }
                        else if(stati[active] === 2){
                            // Enable gadget
                            stati[active] = 1;
                            DB.setgadget(active, 1);
                            refresh();
                        }
                        else{
                            console.log('Not enough c');
                        }
                    }
                }
            }
        }
    }
}
