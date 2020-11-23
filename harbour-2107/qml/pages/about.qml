import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB

Page {
    id: page
    allowedOrientations: Orientation.All
    property int realpix: 1
    property bool unlocked: false
    onWidthChanged: layout()
    onHeightChanged: layout() // I don't know why I need this, but apparently onWidthChanged is not called when changing from landscape to portrait

    Component.onCompleted: {
        DB.initialize();

        // Get realpix conversion rate
        realpix = DB.getstat(8);
        if(realpix === 0){
            realpix = 1; // Avoid division by 0
        }

        // Check if eegg character is unlocked
        if(DB.getstat(10) === 1){
            unlocked = true;
        }

        layout();
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

    // Easter Egg
    Rectangle {
        id: eegg
        visible: thanks.clickcount > 7
        anchors.centerIn: parent
        width: page.width
        height: eeggcol.height
        color: '#878787'
        z: 1000

        Column{
            id: eeggcol
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            // Spacer
            Item{
                width: parent.width
                height: Theme.paddingMedium
            }

            Label{
                text: 'New character unlocked'
                visible: !unlocked
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Image{
                source: '../img/eegg_moose.png'
                smooth: false
                height: sourceSize.height * realpix
                width: sourceSize.width * realpix
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        MouseArea {
            anchors.fill : parent
            onClicked: thanks.clickcount = 0
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 20
        id: flick

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "About"
            }

            Column{
                id: portrait
                width: parent.width

                SectionHeader {
                    text: "License"
                }

                Label {
                    text: "GPL v3"
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("http://choosealicense.com/licenses/gpl-v3/")
                    }
                }

                SectionHeader {
                    text: "Made by"
                }

                Label {
                    text: "@rec0denet"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SectionHeader {
                    text: "Source"
                }

                Label {
                    text: "github.com/rec0de/2107"
                    font.underline: true;
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("https://github.com/rec0de/2107")
                    }
                }


                SectionHeader {
                    text: "Contact"
                }

                Label {
                    text: "mail@rec0de.net"
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        id : contactMouseArea
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("mailto:mail@rec0de.net")
                    }
                }
            }

            Row{
                id: landscape
                anchors.horizontalCenter: parent.horizontalCenter


                Column{
                    Label{
                        text: "License"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label {
                        text: "GPL v3"
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill : parent
                            onClicked: Qt.openUrlExternally("http://choosealicense.com/licenses/gpl-v3/")
                        }
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Made by"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label {
                        text: "@rec0denet"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Source"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label {
                        text: "github.com/rec0de/2107"
                        font.underline: true;
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill : parent
                            onClicked: Qt.openUrlExternally("https://github.com/rec0de/2107")
                        }
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Contact"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label {
                        text: "mail@rec0de.net"
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill : parent
                            onClicked: Qt.openUrlExternally("mailto:mail@rec0de.net")
                        }
                    }
                }
            }

            SectionHeader {
                text: 'General Info'
            }

            Label {
                text:   'Hey there! Thanks for playing 2107. Despite being just a simple endless jump & run game, you\'ll discover that 2107 has quite some back story and hidden stuff for you to discover. So have fun playing & exploring the game!'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            SectionHeader {
                text: 'Music'
            }

            Label {
                text:   '<i>Arcade Music Loop</i> - Joshuaempyre (CC BY)<br><i>Music Loop - Modern 1</i> - Blockfighter298 (CC 0)'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                MouseArea {
                    anchors.fill : parent
                    onClicked: Qt.openUrlExternally("http://freesound.org/people/joshuaempyre/sounds/251461/")
                }
            }

            SectionHeader {
                text: "About me"
            }

            Label {
                text:   'I develop these apps as a hobby. Therefore, please don\'t expect them to work perfectly. If you like what I\'m doing, consider liking / commenting the app, following me on twitter or supporting me on flattr. For a developer, knowing that people out there use & like your app is one of the greatest feelings ever.'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            SectionHeader {
                text: "Thanks"
            }

            Label {
                id: thanks
                text: 'Database derived from \'noto\' by leszek. Thanks to wellef &amp; strayobject for helping me with some bugs and gukke for lots of great ideas.<br>Inspired by \'Canabalt\', \'Alto\'s Adventure\' and \'Papers Please\'.<br> Thanks to all of you!'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                property int clickcount: 0

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        parent.clickcount = parent.clickcount + 1;
                        if(parent.clickcount > 5){
                            DB.setstat(10, 1); // Unlock moose character
                        }
                    }
                }
            }
        }
    }

}
