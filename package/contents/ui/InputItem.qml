import QtQuick
import QtQuick.Controls

Item {
    id: inputItem
    property var thisModel

    anchors.horizontalCenter: parent.horizontalCenter
    height: inputTextArea.contentHeight + 8
    width: fullRep.width * 0.9

    TextArea {
        id: inputTextArea

        anchors.fill: parent
        color: config_text_color
        horizontalAlignment: TextArea.AlignHCenter
        verticalAlignment: TextArea.AlignVCenter
        wrapMode: TextArea.Wrap+
        font: config_text_font
        background: Rectangle {
            anchors.fill: parent
            color: config_background_color
            height: parent.height + 30
            opacity: (1 - config_transparency / 100)
            radius: 10
        }

        Keys.onReturnPressed: {
            var input = {};
            input.text = inputTextArea.text;
            input.color = config_text_color;
            input.checked = false;
            input.sublist = [];
            thisModel.insert(0, input);
            saveModelToJson("todoListModel", todoListModel);
            inputTextArea.text = "";
        }
    }
}
