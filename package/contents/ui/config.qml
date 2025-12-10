import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import QtQuick.Dialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: config_page
    property alias cfg_text_font: text_font.selectedFont
    property alias cfg_background_color: background_color.selectedColor
    property alias cfg_text_color: text_color.selectedColor
    property alias cfg_transparency: transparency.value

    height: childrenRect.height
    width: childrenRect.width

    QtLayouts.GridLayout {
        anchors.fill: parent
        columns: 2

        /* row 1 */
        QtControls.Label {
            anchors.right: parent.center
            text: i18n("transparency: ")
        }
        QtLayouts.RowLayout {
            QtControls.SpinBox {
                id: transparency

                from: 10
                stepSize: 10
                to: 100
                value: cfg_transparency
            }
            QtControls.Label {
                text: i18n("%")
            }
        }
        QtControls.Label {
            id: font_layout

            text: i18n("font: ")
        }
        QtLayouts.RowLayout {
            QtControls.Button {
                id: font_button

                text: cfg_text_font || i18n("default")

                onClicked: text_font.open()
            }
            FontDialog {
                id: text_font

                selectedFont: cfg_text_font

                onAccepted: {
                    font_button.text = text_font.selectedFont;
                    cfg_text_font = text_font.selectedFont;
                    text_font.close();
                }
                onRejected: {
                    text_font.close();
                }
            }
        }
        /* row 2 */
        QtControls.Label {
            text: i18n("text color: ")
        }
        QtLayouts.RowLayout {
            Rectangle {
                border.color: "black"
                color: text_color.selectedColor
                height: 20
                radius: 5
                width: 20

                MouseArea {
                    anchors.fill: parent

                    onClicked: text_color.open()
                }
            }
            ColorDialog {
                id: text_color

                title: "set text color"
            }
        }
        QtControls.Label {
            text: i18n("background color: ")
        }
        QtLayouts.RowLayout {
            Rectangle {
                border.color: "black"
                color: background_color.selectedColor
                height: 20
                radius: 5
                width: 20

                MouseArea {
                    anchors.fill: parent

                    onClicked: background_color.open()
                }
            }
            ColorDialog {
                id: background_color

                title: "set background color"
            }
        }
        /* row 4 */

    }
}