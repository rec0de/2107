import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB

Page {
    id: page
    allowedOrientations: Orientation.All
    property int realpix: 1
    property string bestdistance: 'Error :('
    property string bestjumps: 'Error :('
    property string bestbirds: 'Error :('
    property string totaldistance: 'Error :('
    property string totaljumps: 'Error :('
    property string totalbirds: 'Error :('
    property string gamesplayed: 'Error :('

    onWidthChanged: layout()
    onHeightChanged: layout() // I don't know why I need this, but apparently onWidthChanged is not called when changing from landscape to portrait

    Component.onCompleted: {
        DB.initialize();

        // Get realpix conversion rate
        realpix = DB.getstat(8);
        if(realpix === 0){
            realpix = 1; // Avoid division by 0
        }

        // Load stats
        bestdistance = numconvert(Math.round(DB.getstat(3)/realpix));
        bestjumps = numconvert(DB.getstat(5));
        bestbirds = numconvert(DB.getstat(1));

        totaldistance = numconvert(Math.round(DB.getstat(2)/realpix));
        totaljumps = numconvert(DB.getstat(4));
        totalbirds = numconvert(DB.getstat(0));

        gamesplayed = numconvert(DB.getstat(12));

        layout();
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

    // Changes layout for landscape / portrait switching
    function layout(){
        if(page.height > page.width){
            // Portrait
            portrait1.visible = true;
            portrait2.visible = true;
            landscape1.visible = false;
            landscape2.visible = false;
        }
        else{
            // Landscape
            portrait1.visible = false;
            portrait2.visible = false;
            landscape1.visible = true;
            landscape2.visible = true;
        }
    }


    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 10
        id: flick

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge

            PageHeader {
                title: "Stats"
            }

            SectionHeader {
                text: "Best"
            }

            Column {
                id: portrait1
                width: parent.width
                anchors.margins: Theme.paddingLarge

                Label{
                    text: "Distance"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: bestdistance
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

                // Spacer
                Item{
                    height: Theme.paddingLarge
                    width: parent.width
                }

                Label{
                    text: "Jumps"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: bestjumps
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

                // Spacer
                Item{
                    height: Theme.paddingLarge
                    width: parent.width
                }

                Label{
                    text: "Birds scared"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: bestbirds
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

            }

            Row{
                id: landscape1
                anchors.margins: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Column{
                    Label{
                        text: "Distance"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: bestdistance
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Jumps"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: bestjumps
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Birds scared"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: bestbirds
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }
            }

            SectionHeader {
                text: "Total"
            }

            Column {
                id: portrait2
                width: parent.width
                anchors.margins: Theme.paddingLarge

                Label{
                    text: "Distance"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: totaldistance
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

                // Spacer
                Item{
                    height: Theme.paddingLarge
                    width: parent.width
                }

                Label{
                    text: "Jumps"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: totaljumps
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

                // Spacer
                Item{
                    height: Theme.paddingLarge
                    width: parent.width
                }

                Label{
                    text: "Birds scared"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: totalbirds
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

                // Spacer
                Item{
                    height: Theme.paddingLarge
                    width: parent.width
                }

                Label{
                    text: "Games played"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }

                Label{
                    text: gamesplayed
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                }

            }

            Row{
                id: landscape2
                anchors.margins: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Column{
                    Label{
                        text: "Distance"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: totaldistance
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Jumps"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: totaljumps
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Birds scared"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: totalbirds
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }

                // Spacer
                Item{
                    height: parent.height
                    width: Theme.paddingLarge
                }

                Column{
                    Label{
                        text: "Games played"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }

                    Label{
                        text: gamesplayed
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeHuge
                    }
                }
            }
        }
    }

}
