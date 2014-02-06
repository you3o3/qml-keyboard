import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    id: root

    property string source
    property int keyWidth: 75
    property int keyHeight: 100
    property alias font: proxyTextItem.font
    property alias fontColor: proxyTextItem.color
    property color keyColor: "#34495E"
    property color keyPressedColor: "#1ABC9C"

    property int xmlIndex: 1

    property bool allUpperCase: false

    signal keyClicked(string key)
    signal switchSource(string source)

    Text {
        id: proxyTextItem
        color: "#F2F2F2"
        font.pointSize: 36
        font.weight: Font.Light
        font.family: "Roboto"
        font.capitalization: root.allUpperCase ? Font.AllUppercase :
                                                 Font.MixedCase
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Column {
        id: column
        anchors.centerIn: parent

        Repeater {
            id: rowRepeater
            model: XmlListModel {
                source: root.source
                query: "/Keyboard/Row"
            }

            Row {
                id: keyRow
                anchors.horizontalCenter: if(parent) parent.horizontalCenter

                Repeater {
                    id: keyRepeater
                    model: XmlListModel {
                        source: root.source
                        query: "/Keyboard/Row[" + (index + 1) + "]/Key"

                        XmlRole { name: "labels"; query: "@labels/string()" }
                        XmlRole { name: "ratio"; query: "@ratio/number()" }
                        XmlRole { name: "icon"; query: "@icon/string()" }
                    }

                    Key {
                        id: key
                        width: keyWidth * ratio
                        height: keyHeight
                        iconSource: icon
                        font: proxyTextItem.font
                        fontColor: proxyTextItem.color
                        keyColor: root.keyColor
                        keyPressedColor: root.keyPressedColor

                        property var command
                        property var params: labels

                        onParamsChanged: {
                            var labelSplit = params.split(/[|]+/)

                            text = params.split(/[!|]+/)[0].toString();
                            if (labelSplit[1]) alternates = labelSplit[1];
                            command = params.split(/[!]+/)[1];
                        }

                        onClicked: {
                            if (command)
                            {
                                var commandList = command.split(":");

                                switch(commandList[0])
                                {
                                    case "source":
                                        root.switchSource(commandList[1])
                                        return;
                                    case "shift":
                                        root.allUpperCase = !root.allUpperCase
                                        return;
                                    default: return;
                                }
                            }
                            if(text.length === 1) root.emitKeyClicked(text);
                        }

                        onAlternatesClicked: root.emitKeyClicked(symbol);
                    }
                }
            }
        }
    }
    function emitKeyClicked(text)
    {
        keyClicked( allUpperCase ? text.toUpperCase() : text);
    }
}
