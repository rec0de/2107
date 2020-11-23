import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB

// Sorry, this got kinda messy...

Page {
    id: page
    allowedOrientations: Orientation.All
    property int charcount: 8

    onWidthChanged: layout()
    onHeightChanged: layout() // I don't know why I need this, but apparently onWidthChanged is not called when changing from landscape to portrait

    Component.onCompleted: {
        DB.initialize();

        // Load current character
        character.num = DB.getstat(7);

        // Activate special moose character if unlocked
        if(DB.getstat(10) === 1){
            charcount = 9;
        }

        // Load mute state
        if(DB.getstat(11) === 1){
            muteswitch.checked = false;
        }

        layout()
    }

    // Changes layout for landscape / portrait switching
    function layout(){
        if(page.height > page.width){
            // Portrait
            portrait.visible = true;
            landscape.visible = false;
        }
        else{
            // Landscape
            portrait.visible = false;
            landscape.visible = true;
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 10
        id: flick

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: "About 2107"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("about.qml"))
                }
            }
        }


        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Settings"
            }

            RemorsePopup {
                id: remorse
                onTriggered: {
                    DB.hardreset();
                    Qt.quit();
                }
            }

            RemorsePopup {
                id: remorse2
                onTriggered: {
                    DB.setstat(6, 0);
                    DB.setstat(9, 0);
                }
            }

            Column{
                id: portrait
                width: page.width

                SectionHeader {
                    text: "Character"
                }

                Row{
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingMedium

                    IconButton{
                        icon.source: 'image://theme/icon-cover-previous'
                        icon.height: icon.sourceSize.height / 2
                        icon.width: icon.sourceSize.width / 2
                        onClicked: character.num = (character.num - 1)%page.charcount
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Image{
                        id: character
                        source: '../img/player'+(Math.abs(num) + 1)+'.png'
                        smooth: false
                        height: sourceSize.height * 20
                        width: sourceSize.width * 20
                        anchors.verticalCenter: parent.verticalCenter
                        property int num: 0

                        onNumChanged: {
                            DB.setstat(7, Math.abs(num)); // Update character selection in DB
                        }
                    }

                    IconButton{
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: 'image://theme/icon-cover-next'
                        icon.height: icon.sourceSize.height / 2
                        icon.width: icon.sourceSize.width / 2
                        onClicked: character.num = (character.num + 1)%page.charcount
                    }
                }

                // Spacer
                Item{
                    width: parent.width
                    height: Theme.paddingSmall
                }

                Label{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: names[Math.abs(character.num)]
                    property var names: new Array('z3r0', 'da3m0n', '0x2A', '0x83B', 'c0r3', 'gh0s7', '0x3e9', '0x29a', 'hirvi')
                }

                SectionHeader {
                    text: "General"
                }

                TextSwitch {
                    id: muteswitch
                    text: "Background music"
                    automaticCheck: false
                    checked: true
                    onClicked:{
                        if(checked){ // Deactivate
                            checked = false;
                            DB.setstat(11, 1);
                        }
                        else{ // Activate
                            checked = true;
                            DB.setstat(11, 0);
                        }
                    }
                }

                SectionHeader {
                    text: "Debug"
                }

                Button {
                    text: "Reset Game"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked:{
                        remorse.execute('Reset Game');
                   }
                }

                Button {
                    text: "Reset Objectives"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked:{
                        remorse2.execute('Reset Objectives');
                   }
                }

                // Spacer
                Item{
                    width: parent.width
                    height: Theme.paddingLarge
                }

                // Easter egg minigame trigger
                Image{
                    source: '../img/console.svg'
                    height: Theme.itemSizeSmall * 0.8
                    width: Theme.itemSizeSmall * 0.8
                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea{
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("console.qml"))
                    }
                }

            }

            Row{
                id: landscape
                anchors.horizontalCenter: parent.horizontalCenter

                Column{
                    width: page.width/2 - Theme.paddingLarge

                    Label{
                        text: "Character"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    // Spacer
                    Item{
                        width: parent.width
                        height: Theme.paddingLarge
                    }

                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingMedium

                        IconButton{
                            icon.source: 'image://theme/icon-cover-previous'
                            icon.height: icon.sourceSize.height / 2
                            icon.width: icon.sourceSize.width / 2
                            onClicked: character.num = (character.num - 1)%page.charcount
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Image{
                            source: '../img/player'+(Math.abs(character.num) + 1)+'.png'
                            smooth: false
                            height: sourceSize.height * 20
                            width: sourceSize.width * 20
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        IconButton{
                            anchors.verticalCenter: parent.verticalCenter
                            icon.source: 'image://theme/icon-cover-next'
                            icon.height: icon.sourceSize.height / 2
                            icon.width: icon.sourceSize.width / 2
                            onClicked: character.num = (character.num + 1)%page.charcount
                        }
                    }

                    // Spacer
                    Item{
                        width: parent.width
                        height: Theme.paddingSmall
                    }

                    Label{
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: names[Math.abs(character.num)]
                        property var names: new Array('z3r0', 'da3m0n', '0x2A', '0x83B', 'c0r3', 'gh0s7', '0x3e9', '0x29a', 'hirvi')
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    width: page.width/2 - Theme.paddingLarge

                    Label{
                        text: "General"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    TextSwitch {
                        text: "Background music"
                        automaticCheck: false
                        checked: muteswitch.checked
                        // horizontalCenter does not work for some reason :(
                        onClicked:{
                            if(checked){ // Deactivate
                                muteswitch.checked = false;
                                DB.setstat(11, 1);
                            }
                            else{ // Activate
                                muteswitch.checked = true;
                                DB.setstat(11, 0);
                            }
                        }
                    }

                    Label{
                        text: "Debug"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Button {
                        text: "Reset Game"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked:{
                            remorse.execute('Reset Game');
                       }
                    }

                    Button {
                        text: "Reset Objectives"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked:{
                            remorse2.execute('Reset Objectives');
                       }
                    }
                }
            }

        }
    }

}
