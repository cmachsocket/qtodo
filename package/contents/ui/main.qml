import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import QtQuick.Controls
import QtQuick.LocalStorage
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

PlasmoidItem {
    id: root

    readonly property string config_background_color: Plasmoid.configuration.background_color
    readonly property string config_text_color: Plasmoid.configuration.text_color
    readonly property string config_text_font: Plasmoid.configuration.text_font
    readonly property int config_transparency: Plasmoid.configuration.transparency
    property var currentModel: null
    property var mainModel: null
    property bool subModel: !(mainModel == currentModel)
    property var subModelTitle

    Component.onCompleted: {
        mainModel = todoListModel
        currentModel = todoListModel
    }

    function loadModelFromJson(fileName, listModel) {
        let file = LocalStorage.openDatabaseSync("qtodo", "1.0", "StorageDatabase", 5000000);
        let jsonString = "";
        file.transaction(function (tx) {
            let rs = tx.executeSql('SELECT data FROM ListData WHERE id=?', [fileName]);
            if (rs.rows.length > 0) {
                jsonString = rs.rows.item(0).data;
            }
        });

        if (jsonString !== "") {
            let jsonArray = JSON.parse(jsonString);
            listModel.clear();
            for (let i = 0; i < jsonArray.length; i++) {
                listModel.append(jsonArray[i]);
            }
            // move the checked items to the end of the list
            listModel.sort(function (a, b) {
                return a.checked - b.checked;
            });
        }
    }
    function saveModelToJson(fileName, listModel) {
        let jsonArray = [];
        // move the checked items to the end of the list
        for (let i = 0; i < listModel.count; i++) {
            jsonArray.push(listModel.get(i));
        }
        let jsonString = JSON.stringify(jsonArray);
        let file = LocalStorage.openDatabaseSync("qtodo", "1.0", "StorageDatabase", 5000000);
        file.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS ListData (id TEXT UNIQUE, data TEXT)');
            tx.executeSql('INSERT OR REPLACE INTO ListData VALUES(?, ?)', [fileName, jsonString]);
        });
    }

    compactRepresentation: MouseArea {
        property bool wasExpanded

        Accessible.name: Plasmoid.title
        Accessible.role: Accessible.Button
        Layout.minimumHeight: Kirigami.Units.gridUnit * 3
        Layout.minimumWidth: Kirigami.Units.gridUnit * 3

        onClicked: root.expanded = !wasExpanded
        onPressed: wasExpanded = root.expanded

        PlasmaComponents.Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Click me")
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
    fullRepresentation: PlasmaExtras.Representation {
        Item {
            id: mainViewWrapper

            Layout.minimumHeight: 200
            Layout.minimumWidth: 200
            // transparent background
            Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
            anchors.fill: parent
            clip: true
            height: 400
            width: 300

            TodoList {
                id: mainTodoList

                anchors.top: mainInputItem.bottom
                height: parent.height
                model: currentModel
                thisModel: currentModel
                width: parent.width
            }
            InputItem {
                id: mainInputItem

                anchors.top: topBarRectangle.bottom
                anchors.topMargin: 10
                thisModel: currentModel
            }
            Rectangle {
                id: topBarRectangle

                anchors.top: parent.top
                //anchors.left: backButton.right
                //anchors.leftMargin: 15
                //anchors.verticalCenter: parent.verticalCenter
                // anchors.horizontalCenter: parent.horizontalCenter
                color: config_background_color
                height: subModel ? Math.max(title.contentHeight + 10, 40) : 0
                opacity: (1 - config_transparency / 100)
                radius: 10
                visible: subModel
                width: parent.width
            }
            Text {
                id: title

                anchors.horizontalCenter: topBarRectangle.horizontalCenter
                //anchors.left: backButton.right
                //anchors.leftMargin: 15
                anchors.verticalCenter: topBarRectangle.verticalCenter
                color: config_text_color
                font: config_text_font
                horizontalAlignment: Text.AlignHCenter
                text: root.subModelTitle
                verticalAlignment: Text.AlignVCenter
                visible: subModel
                width: parent.width * 0.75
                wrapMode: Text.Wrap
            }
            Button {
                id: backButton

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.verticalCenter: topBarRectangle.verticalCenter
                visible: subModel

                background: Kirigami.Icon {
                    id: backIcon

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "blue"
                    height: width
                    source: "draw-arrow-back"
                    width: Kirigami.Units.iconSizes.medium

                    states: [
                        State {
                            when: backButtonHoverHandler.hovered

                            PropertyChanges {
                                opacity: 0.4
                                target: backIcon
                            }
                        }
                    ]

                    HoverHandler {
                        id: backButtonHoverHandler

                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                onClicked: {
                    var parentModel = mainTodoList.parentModelList[(mainTodoList.parentModelList.length - 1)];
                    var parentModelTitle = mainTodoList.parentModelTitleList[(mainTodoList.parentModelTitleList.length - 2)];

                    root.currentModel = parentModel;
                    root.subModelTitle = parentModelTitle;
                    mainTodoList.parentModelList.pop();
                    mainTodoList.parentModelTitleList.pop();
                }
            }
            ListModel {
                id: todoListModel

                Component.onCompleted: {
                    loadModelFromJson("todoListModel", todoListModel);
                }
            }
        }
    }
}