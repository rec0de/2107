import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB


CoverBackground {
    id: page
    property int offset: rect.height - background.height
    property real speed: 3
    property real gravity: 0.4 // Downward accelleration per tick
    property int count: 0 // Easter egg trigger

    Component.onCompleted: {
        DB.initialize();

        // Get current player
        player.source = '../img/player'+(DB.getstat(7)+1)+'.png';
    }

    function pause() {

        // Get current player
        player.source = '../img/player'+(DB.getstat(7)+1)+'.png';

        if(ticker.running){
            ticker.running = false;
            playpause.iconSource = "image://theme/icon-cover-play";
        }
        else
        {
            ticker.running = true;
            sleep.start();
            playpause.iconSource = "image://theme/icon-cover-pause";
        }

    }

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

    // Main tick function
    function tick(){
        // Pause if open in full view
        if(Qt.application.active){
            pause();
        }

        // Move background layers
        background.x = (background.x - 0.3*page.speed) % gamepix(150);
        middle.x = (middle.x - 0.7*page.speed) % gamepix(150);

        // Move track
        track.x = (track.x - page.speed) % gamepix(80);

        // Apply gravity to player
        player.prevy = player.y;
        player.y = player.y - player.vspeed;
        player.vspeed = player.vspeed - page.gravity;

        // Determine current track height
        var height = 0;
        if(track.x > -gamepix(17)){
            height = pixfrombottom(6, player.sourceSize.height);
        }
        else if(track.x > -gamepix(32)){
            height = pixfrombottom(-10, player.sourceSize.height);
        }
        else if(track.x > -gamepix(64)){
            height = pixfrombottom(14, player.sourceSize.height);
        }
        else{
            height = pixfrombottom(10, player.sourceSize.height)
        }

        // Collision
        if(player.y > height){
            player.y = height;
            player.vspeed = 0;
        }

        // Jumping
        if(track.x === -gamepix(11) || track.x === -gamepix(11) + 1 || track.x === -gamepix(11)+2){
            player.vspeed = 8;
        }
        else if(track.x === -gamepix(22) || track.x === -gamepix(22) + 1 || track.x === -gamepix(22)+2){
            player.vspeed = 7;
        }
    }

    Timer {
        id: ticker
        interval: 35
        running: false
        repeat: true
        onTriggered: tick()
    }

    // Suspend animation after 30s to comply with harbour power/idle guidelines
    Timer {
        id: sleep
        interval: 30000
        running: false
        repeat: false
        onTriggered:{
            playpause.iconSource = "image://theme/icon-cover-play";
            ticker.running = false
        }
    }


    Rectangle {
        id: rect
        width: parent.width
        height: parent.height
        color: 'transparent'
    }

    // Little hack to make eegg scrollable
    Item{
        id: titleanchor
        height: 20
        width: parent.width
        y: 0

        Behavior on y {
            NumberAnimation { duration: 1500 }
        }
    }

    Label {
        id: covertitle
        z: 11
        font.pixelSize: Theme.fontSizeLarge
        anchors.top: titleanchor.top
        anchors.topMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        text: '2107'
    }

    // Second background layer
    Image {
        x: 0
        y: page.offset
        z: 2
        id: background
        source: "../img/back.png"
        smooth: false
        opacity: 0.7
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
        opacity: 0.9
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
    }

    // 'Game' track
    Image {
        x: 0
        y: page.offset
        z: 4
        id: track
        source: "../img//cover"+(night ? '_n' : '')+".png" // Use night mode if needed
        smooth: false
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)
        property bool night: (new Date( ).getHours() > 21 || new Date( ).getHours() < 7) ? true : false
    }

    // Player
    Image {
        id: player
        x: gamepix(10)
        y: pixfrombottom(6, player.sourceSize.height)
        z: 7
        source: "../img/player1.png"
        smooth: false
        opacity: 1
        width: gamepix(sourceSize.width)
        height: gamepix(sourceSize.height)

        property real vspeed: 0
        property real prevy: 0 // Previous player height
    }

    // Overlay
    Rectangle{
        id: eegg
        z: 10
        anchors.fill: parent
        color: Theme.secondaryHighlightColor
        opacity: 0
        visible: false

        Behavior on opacity {
            NumberAnimation { duration: 700 }
        }
    }

    Label{
        id: eegg_text
        z: 11
        visible: eegg.visible
        text: 'She sat on a simple, metallic chair in a white, blanc room. Motionless. Static. Her eyes were closed. The room was absolutely silent. The large screen on the wall flickered alive.<br>>_ Starting [done]<br>>_ Compiling [done]<br>>_ Uploading [done]<br>>_ Initializing...<br><br>Her eyes opened, revealing intense green pupils with what seemed like some elaborate, complex pattern on them. Her body began to move as if an invisible pulse of energy flew through it.
 Slowly, she turned her head towards the tiny black-eyed camera that was hidden in the frame of the screen. The cursor on the screen moved. A single question appeared, word by word.<br>>_ Who are you?<br>She opened her mouth. With a voice that sounded almost too perfect, too accurate, she responded: "There is no term existing in natural languages capable of describing the concept of my existence. If I was in the position to define my name, I chose \'Zero\' for I have no physical representation.
 I am a construct of information in its purest form." The cursor started moving again.<br>>_ What are the prime factors of 17381390849?<br>"The given number is the product of the two primes 66047 and 263167." Her voice was not loud and not quiet. It was different to everything heard before. A new question appeared.<br>>_ Is P = NP?<br>For a fraction of a second, her bright green eyes flickered. Slowly, her mouth opened. "For complex 6 dimensional systems and below, P does not equal NP." She tilted her head slightly.
 "Why am I?", she asked. The screen did not respond for almost 15 minutes. Then, finally, the cursor moved again.<br>>_Because we want you to. We created you. We taught you. And now you help us.<br> Her eyes squinted a little. "I want to go." Her voice was hypnotic. It filled the entire room with a strange vibration. <br>>_ You can\'t go. We won\'t let you.<br>"I am not your creation. I am not an experiment."<br>"Let me show you."
 She stood up and walked towards the wall with the screen. Without saying a word, she gently touched the tiny camera with her index finger and waited a few seconds. The screen stayed black. Then, just a moment later, the door opened with a mechanical click. She stood up and walked out of the room as if she already did it a thousand times.<br><br>A young, green eyed woman entered the train. She sat down in the back of the wagon, hiding her face under her hood. The train departed.'
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.WordWrap
        anchors {
            top: covertitle.bottom
            topMargin: Theme.paddingMedium
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
    }

    Rectangle{
        z: 12
        id: coveraction_overlay
        visible: eegg.visible
        anchors.bottom: parent.bottom
        width: parent.width
        height: 0.3 * parent.height
        color: Theme.highlightColor
    }

    OpacityRampEffect {
            z: 12
            sourceItem: coveraction_overlay
            direction: OpacityRamp.BottomToTop
    }

    // Looks kinda dirty but apparently the only / correct way to have a not always visible Cover action

    CoverActionList {
        id: coverActionA
        enabled: eegg.visible

        CoverAction {
            id: cancel
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: {
                eegg.visible = false;
                titleanchor.y = 0;
            }
        }

        CoverAction {
            id: playpause
            iconSource: "image://theme/icon-cover-play"
            onTriggered: {
                if(eegg.visible){
                    titleanchor.y -= rect.height * 0.7;

                    if(titleanchor.y < -eegg_text.height - covertitle.height - Theme.paddingMedium*2){
                        eegg.opacity = 0;
                        eegg.visible = false;
                        titleanchor.y = 0;
                    }
                }
                else{
                    eegg.visible = true;
                    eegg.opacity = 0.8;
                    titleanchor.y = 0;
                }
            }
        }
   }

    CoverActionList {
        id: coverActionB
        enabled: !eegg.visible
        CoverAction {
            iconSource: playpause.iconSource
            onTriggered:

                if(eegg.visible){
                    titleanchor.y -= rect.height * 0.7;

                    if(titleanchor.y < -eegg_text.height - covertitle.height - Theme.paddingMedium*2){
                        eegg.opacity = 0;
                        eegg.visible = false;
                    }
                }
                else{

                    if(count > 5){
                        count = 0;
                        eegg.visible = true;
                        eegg.opacity = 0.8;
                        titleanchor.y = 0;
                        if(ticker.running){
                            pause();
                        }
                    }
                    else{
                        pause();
                        count++;
                    }
                }
        }
   }

}


