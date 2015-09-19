import QtQuick 2.0
import Sailfish.Silica 1.0
import '../data.js' as DB

// A little easteregg 'hacking'/exploration game
// More or less accurate for better usability

Page {
    id: page
    allowedOrientations: Orientation.All
    property int hours: 12
    property int mins: 12
    property string state: 'snet'
    property int pixsize: (page.width < page.height) ? Math.floor(page.width/image.sourceSize.width) : Math.floor(page.height/image.sourceSize.height) // Make sure image always fits screen

    Component.onCompleted: {
        DB.initialize();
        var currentTime = new Date ( );

        hours = currentTime.getHours();
        mins = currentTime.getMinutes();
    }

    // Emulates some sort of CLI / Shell
    function parse(input){
        input = input.toLowerCase();
        label.text += input + '<br>';

        inputfield.text = '';

        // help
        if(input === 'help'){
            if(state === 'snet'){
                label.text += 'ls<br>ssh &lt;user&gt;@&lt;host&gt;<br>more &lt;file&gt;<br>clear<br>help<br>';
            }
            else if(state === 'post'){
                label.text += 'ls<br>view &lt;file&gt;<br>exit<br>clear<br>help<br>';
            }
            else if(state === 'mail'){
                label.text += 'ls<br>ssh &lt;user&gt;@&lt;host&gt;<br>more &lt;file&gt;<br>exit<br>clear<br>help<br>';
            }
            else if(state === 'server'){
                label.text += 'ls<br>more &lt;file&gt;<br>lynx &lt;url&gt;<br>exit<br>clear<br>help<br>';
            }
        }

        // ls
        else if(input === 'ls'){
            if(state === 'snet'){
                label.text += 'log memdump<br>';
            }
            else if(state === 'post'){
                label.text += 'issue1 issue2 issue3 issue4 issue5 issue6<br>';
            }
            else if(state === 'mail'){
                label.text += 'application devmode hey thepost vacation verification<br>';
            }
            else if(state === 'server'){
                label.text += 'readme<br>';
            }
        }

        // more
        else if(input.substring(0, 5) === 'more ' && state === 'snet')
        {
            var file = input.substring(5);
            if(file === 'log'){
                label.text += '[2107-02-07 07:31:14] [more] memdump<br>[2107-02-07 09:00:56] [remote login]<br>[2107-02-07 16:44:03] [ssh] mtaylor@tolmail.com<br>[2107-02-07 22:12:43] [session ended]<br>';
            }
            else if(file === 'memdump'){
                label.text += 'more: File corrupted or unreadable (Error at 0x74616F).<br>';
            }
            else{
                label.text += 'more: File does not exist.<br>';
            }
        }
        else if(input.substring(0, 5) === 'more ' && state === 'mail')
        {
            file = input.substring(5);
            if(file === 'application'){
                label.text += '[2107-01-05] From: hr@twinex.com<br>Dear Miss Taylor,<br>we are sorry to inform you that the opening you applied for has been filled.<br>Best wishes,<br>Sam Jones, Twinex<br>';
            }
            else if(file === 'devmode'){
                label.text += '[2106-12-17] From: service@tol.com<br>Hello Mary,<br>you have successfully activated developer access for your account. You can now read your mail via an encrypted ssh connection. For more information, please visit tolmail.com<br>Best regards,<br>The TOL Team<br>';
            }
            else if(file === 'hey'){
                label.text += '[2107-02-02] From: kathy86@tolmail.com<br>Hey sis, apparently you dont read IMs anymore? Would you like to join us at Jakes tonight? It\'s gonna be fun. Cheers!<br>';
            }
            else if(file === 'verification'){
                label.text += '[2107-01-12] From: account@tolmail.securepayment.tk<br>Attention! Us have detected dangerous occupation this account. Please vist link to verify: tolmail.securepayment.tk/Hr7kBv9P0<br>';
            }
            else if(file === 'thepost'){
                label.text += '[2107-01-07] From: zhao@tolmail.com<br>Hey Mary,<br>didn\'t see you for quite some time. How are you doing? You did work for The Post some time ago, didn\'t you? Do you still have ssh keys for archive@thepost.net? Would be awesome if you could get me a copy of that issue I have been looking for...<br>David Zhao<br>';
            }
            else if(file === 'vacation'){
                label.text += '[2107-02-01] From: the_luc@tolmail.com<br>Hi Mary,<br>could you do me a favor? I\'m going on vacation tomorrow and you know how my server likes to act up when I\'m not around...<br>Could you just look every now and then if everything is still working? I already set up an account for you. mary@8.44.122.3 is all yours. ;)<br>Thanks a lot,<br>Lucas<br>';
            }
            else{
                label.text += 'more: File does not exist.<br>';
            }
        }
        else if(input.substring(0, 5) === 'more ' && state === 'server')
        {
            file = input.substring(5);
            if(file === 'readme'){
                label.text += 'Hey Mary :)<br>Thanks again for doing this. I owe you!<br>Every once in a while the network adapter goes crazy and the server loses internet connectivity. So just keep an eye out for that and reboot if that should happen. In case things are on fire, call me. <br> --Lucas<br>';
            }
            else{
                label.text += 'more: File does not exist.<br>';
            }
        }
        else if(input === 'more' && (state === 'server' || state === 'mail' || state === 'snet')){
            label.text += 'more: No file given.<br>';
        }

        // ssh
        else if(input.substring(0, 4) === 'ssh ' && state === 'snet'){
            var host =  input.substring(4).split('@');

            if(host[1] === 'tolmail.com' && host[0] === 'mtaylor'){
                label.text += 'TOL mail interface - Mary Taylor<br>';
                page.state = 'mail';
            }
            else if(host[1] === 'thepost.net' || host[1] === 'tolmail.com' || host[1] === 'tol.com' || host[1] === 'twinex.com' || host[1] === '8.44.122.3'){
                label.text += 'ssh: Permission denied (publickey).<br>';
            }
            else{
                label.text += 'ssh: No route to host.<br>';
            }
        }

        else if(input.substring(0, 4) === 'ssh ' && state === 'mail'){
            host =  input.substring(4).split('@');

            if(host[1] === 'thepost.net' && host[0] === 'archive'){
                label.text += 'ThePost employee-only archive<br>';
                page.state = 'post';
            }
            else if(host[1] === '8.44.122.3' && host[0] === 'mary'){
                label.text += 'Linux srv<br>';
                page.state = 'server';
            }
            else if(host[1] === 'thepost.net' || host[1] === 'tolmail.com' || host[1] === 'tol.com' || host[1] === 'twinex.com' || host[1] === '8.44.122.3'){
                label.text += 'ssh: Permission denied (publickey).<br>';
            }
            else{
                label.text += 'ssh: No route to host.<br>';
            }
        }

        else if(input === 'ssh' && (state === 'snet' || state === 'mail')){
            label.text += 'ssh: No host given.<br>';
        }

        // view issue
        else if(input.substring(0, 5) === 'view ' && state === 'post'){
            file = input.substring(5);

            if(file === 'issue1'){
                image.source = '../img/thepost/thepost_1.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else if(file === 'issue2'){
                image.source = '../img/thepost/thepost_2.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else if(file === 'issue3'){
                image.source = '../img/thepost/thepost_3.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else if(file === 'issue4'){
                image.source = '../img/thepost/thepost_4.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else if(file === 'issue5'){
                image.source = '../img/thepost/thepost_5.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else if(file === 'issue6'){
                image.source = '../img/thepost/thepost_6.png';
                image.visible = true;
                label.text += 'Displaying content.<br>';
            }
            else{
                label.text += 'view: File does not exist.<br>';
            }
        }
        else if(input === 'view' && state === 'post'){
            label.text += 'view: No file given.<br>';
        }

        // lynx
        else if(input.substring(0, 5) === 'lynx ' && state === 'server'){
            var url = input.substring(5);

            var pattern = /(https|http|www\.|\:\/\/)/g;
            url = url.replace(pattern, '');
            pattern = /\/.*/g;
            url = url.replace(pattern, '');

            if(url === 'tol.com'){
                label.text += '[https://tol.com]<br>TOL - There for you<br><br>Changing your life - forever<br>What if you could instantly pay for anything, anywhere, without even using your hands? Today, TOL group annouces FPay, allowing you to pay for goods and services using our global facial recognition service. Hardware is already installed in most major business locations and supported by TOLcredit payment solutions. Sign up today!<br>';
            }
            else if(url === 'tolmail.com'){
                label.text += '[https://tolmail.com]<br>TOLmail - your email provider<br><br>Looking for a professional, free &amp; trustworthy personal email provider? TOLmail is your best choice for reliable, secure online communication.<br><br>Your browser does not support javascript. To log in, please enable it or try a modern browser.<br>';
            }
            else if(url === 'thepost.net'){
                label.text += '[http://thepost.net]<br>The Post online<br>Quality journalism since 2072<br><br>Latest articles<br>A week with FPay<br>Only a few weeks ago, the TOL group anncounced a new way to pay - FPay. We sent four of our journalists on a week long journey to check out the new technology that got massive attention from both technology enthusiasts and pro-privacy activists.<br><br>Moose damnages Art<br>During the unconventional art exhibition in the deep forest we reported on earlier, a single moose appeared and collided with several art pieces. A particular work recently aquired by the museum was irreparably destroyed.<br>';
            }
            else if(url === 'twinex.com'){
                label.text += '[https://twinex.com]<br>Twinex Inc.<br><br>Twinex Inc. is the leading provider of special use chemical compounds worldwide. Delivering whatever you need whereever you need it with more than 60 years of business experience. Our clients include multiple nationstates, leading corporations and other global players.<br><br>Press releases: pr.twinex.com<br>';
            }
            else if(url === 'tolmail.securepayment.tk'){
                label.text += '[http://tolmail.securepayment.tk]<br><br>Back from the dead.<br><br>We are awaiting you.<br><br>';
            }
            else if(url === 'pr.twinex.com'){
                label.text += '[https://pr.twinex.com]<br>Twinex Inc. - Press<br><br>05.02.2107<br>We can neither confirm nor deny reports that Twinex Inc. is target of ongoing network attacks.<br><br>21.12.2106<br>We are proud to announce that Twinex Inc. is now supporting multiple local institutions contributing to our common culture. Among these are Independent Weekly, The Post and The Informer.<br><br>04.10.2106<br>Contrary to several accusations in the media, Twinex is not and has never been in any business relation with the Santos regime and condems the use of CW agents and the violations of human rights.<br><br>16.03.2106<br>Twinex Inc. is now a part of the TOL family. We look forward to joining the team and sharing our expertise with them.<br>';
            }
            else{
                label.text += 'lynx: Server not found.<br>';
            }

        }
        else if(input === 'lynx' && state === 'server'){
            label.text += 'lynx: No url specified.<br>';
        }

        // exit
        else if(input === 'exit' && state == 'mail'){
            state = 'snet';
            label.text += 'logout<br>Connection closed.<br>';
        }
        else if(input === 'exit' && (state === 'post' || state === 'server')){
            state = 'mail';
            label.text += 'logout<br>Connection closed.<br>';
        }

        // clear
        else if(input === 'clear'){
            label.text = '';
        }


        else{
            label.text += 'Unknown or blocked command.<br>';
        }

        if(state === 'snet'){
            label.text += '[zero@snet ~]$ ';
        }
        else if(state === 'post'){
            label.text += '[archive@thepost ~]$ ';
        }
        else if(state === 'mail'){
            label.text += '[mtaylor@tolmail Mails]$ ';
        }
        else if(state === 'server'){
            label.text += '[mary@srv docs]$ ';
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: parent.height
        id: flick

        VerticalScrollDecorator{}

        PageHeader {
            title: "Console"
        }

        Label {
            id: label
            text:   'CLI v.07.01, '+page.hours+':'+page.mins+' 2107-02-11<br>Restricted Access<br><br>Enter command. Type \'help\' for a list of commands.<br><br>[zero@snet ~] $ '
            font.pixelSize: Theme.fontSizeExtraSmall
            font.family: 'DejaVu Sans Mono'
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
                bottom: inputfield.top
            }
        }

        Image{
            id: image
            source: '../img/thepost/thepost_1.png'
            smooth: false
            visible: false
            width: Math.floor(page.width/sourceSize.width)*sourceSize.width
            height: Math.floor(page.width/sourceSize.width)*sourceSize.height
            anchors.centerIn: parent
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    parent.visible = false;
                }
            }
        }

        TextField{
            id: inputfield
            width: parent.width
            anchors.bottom: parent.bottom
            placeholderText: "Cmd"
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: parse(text)
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            font.family: 'DejaVu Sans Mono'
        }
    }

}
