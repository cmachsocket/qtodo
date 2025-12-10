import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
//import org.kde.plasma.plasmoid
ListView {
    id: todoList

    property bool itemDropped: false
    property var parentModelList: []
    property var parentModelTitleList: []
    property var thisModel

    //readonly property int transparency: Plasmoid.configuration.transparency
    function getCheckedItemCount(model) {
        var count = 0
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).checked) {
                count++;
            }
        }
        return count;
    }

    // fix the scrolling issue
    anchors.bottom: parent.bottom
    anchors.top: inputItem.bottom + 10
    anchors.topMargin: 10
    clip: true
    spacing: 10

    delegate: Item {
        id: itemWrapper

        property int dragItemIndex: index
        property double originalY: itemWrapper.y

        Drag.active: itemMouseArea.drag.active
        Drag.hotSpot: Qt.point(itemWrapper.width / 2, itemWrapper.height / 2)
        anchors.horizontalCenter: parent.horizontalCenter
        height: todoText.contentHeight + 20
        width: parent.width * 0.95

        MouseArea {
            id: itemMouseArea

            anchors.fill: parent
            drag.target: itemWrapper

            drag.onActiveChanged: {
                if (itemMouseArea.drag.active) {
                    itemWrapper.dragItemIndex = index;
                    itemWrapper.originalY = itemWrapper.y;
                }
            }
            onReleased: {
                itemWrapper.Drag.drop();
                if (!itemDropped) {
                    itemWrapper.y = itemWrapper.originalY;
                }
                itemDropped = false;
            }
        }
        DropArea {
            id: itemDropArea

            anchors.fill: parent

            onDropped: {
                itemWrapper.dragItemIndex = index;
                thisModel.move(drag.source.dragItemIndex, itemWrapper.dragItemIndex, 1);
                saveModelToJson("todoListModel", todoListModel);
                itemDropped = true;
            }
        }
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: (1-config_transparency/100)
            radius: 10
        }
        Item {
            anchors.fill: parent
            anchors.margins: 10
            height: parent.height * 0.9

            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    spacing: 10

                    Text {
                        id: remainingText

                        anchors.verticalCenter: parent.verticalCenter
                        // anchors.horizontalCenter: parent.left
                        color: config_text_color
                        font: config_text_font
                        text: getCheckedItemCount(thisModel.get(index).sublist) + "/" + thisModel.get(index).sublist.count
                        visible: thisModel.get(index).sublist.count != 0
                        width: 30
                    }
                    Button {
                        id: detailButton

                        text: "details"
                        width: 10

                        background: Kirigami.Icon {
                            id: detailIcon

                            anchors.verticalCenter: parent.verticalCenter
                            color: "blue"
                            height: width
                            opacity: 0.7
                            source: "application-menu-symbolic"
                            width: Kirigami.Units.iconSizes.small

                            states: [
                                State {
                                    when: detailButtonHoverHandler.hovered

                                    PropertyChanges {
                                        opacity: 0.4
                                        target: detailIcon
                                    }
                                }
                            ]

                            HoverHandler {
                                id: detailButtonHoverHandler

                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onClicked: {
                            root.subModelTitle = model.text;
                            todoList.parentModelList.push(fullRep.currentModel);
                            todoList.parentModelTitleList.push(model.text);
                            fullRep.currentModel = thisModel.get(index).sublist;
                        }
                    }
                    Button {
                        id: editButton

                        text: "edit"
                        width: 10

                        background: Kirigami.Icon {
                            id: editIcon

                            anchors.verticalCenter: parent.verticalCenter
                            color: "green"
                            height: width
                            opacity: 0.7
                            source: "document-edit-symbolic"
                            width: Kirigami.Units.iconSizes.small

                            states: [
                                State {
                                    when: editButtonHoverHandler.hovered

                                    PropertyChanges {
                                        opacity: 0.4
                                        target: editIcon
                                    }
                                }
                            ]

                            HoverHandler {
                                id: editButtonHoverHandler

                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onClicked: {
                            editPopup.open();
                        }
                    }
                    Button {
                        id: deleteButton

                        text: "remove"
                        width: 10

                        background: Kirigami.Icon {
                            id: deleteIcon

                            anchors.verticalCenter: parent.verticalCenter
                            color: "red"
                            height: width
                            opacity: 0.7
                            source: "edit-delete-symbolic"
                            width: Kirigami.Units.iconSizes.small

                            states: [
                                State {
                                    when: deleteButtonHoverHandler.hovered

                                    PropertyChanges {
                                        opacity: 0.4
                                        target: deleteIcon
                                    }
                                }
                            ]

                            HoverHandler {
                                id: deleteButtonHoverHandler

                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onClicked: {
                            thisModel.remove(index);
                            saveModelToJson("todoListModel", todoListModel);
                        }
                    }
                }
            }

            // just use two buttons instead of a dropdown menu

            Popup {
                id: editPopup
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnEnter
                focus: true
                height: editTextArea.contentHeight + 35
                modal: true
                width: fullRep.width

                TextArea {
                    id: editTextArea

                    anchors.fill: parent
                    color: config_text_color
                    font: config_text_font
                    horizontalAlignment: TextArea.AlignHCenter
                    text: model.text
                    verticalAlignment: TextArea.AlignVCenter
                    wrapMode: TextArea.Wrap

                    // background: Rectangle {
                    //     anchors.fill: parent
                    //     color: config_background_color
                    //     height: parent.height + 30
                    //     opacity: (1 - config_transparency / 100)
                    //     radius: 10
                    // }

                    Keys.onReturnPressed: {
                        model.text = editTextArea.text;
                        model.checked = false;
                        thisModel.move(index, 0, 1);
                        saveModelToJson("todoListModel", todoListModel);
                        editPopup.close();
                    }
                }
            }
            Text {
                id: todoText

                anchors.left: checkbox.right
                anchors.verticalCenter: parent.verticalCenter
                color: config_text_color
                font: config_text_font
                text: model.text
                width: parent.width * 0.75
                wrapMode: Text.Wrap
            }
            CheckBox {
                id: checkbox

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                checked: model.checked

                // use onClicked instead of onCheckedChanged to avoid binding loop
                onClicked: {
                    model.checked = checked;
                    // move the checked item to the bottom of the list
                    if (thisModel.get(index).checked) {
                        thisModel.move(index, thisModel.count - 1, 1);
                    } else {
                        thisModel.move(index, 0, 1);
                    }
                    saveModelToJson("todoListModel", todoListModel);
                }
            }
        }
    }
    displaced: Transition {
        NumberAnimation {
            duration: 200
            properties: "y"
        }
    }
}
