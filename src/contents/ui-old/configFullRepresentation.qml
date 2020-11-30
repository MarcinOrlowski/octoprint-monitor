/**
 * OctoPrint Monitor
 *
 * Plasmoid to monitor OctoPrint instance and print job progress.
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2020 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/octoprint-monitor
 */

import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    width: childrenRect.width
//    height: childrenRect.height

    property alias cfg_cameraViewEnabled: cameraViewEnabled.checked
    property alias cfg_cameraViewUpdateInterval: cameraViewUpdateInterval.value

    property alias cfg_showJobFileName: showJobFileName.checked

    GroupBox {
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: cameraViewEnabled
                Kirigami.FormData.label: i18n("Enable camera snapshot view") + ':'
            }
            SpinBox {
                id: cameraViewUpdateInterval
                editable: true
                from: 1
                to: 3600
                stepSize: 5
                Kirigami.FormData.label: i18n("Camera update interval (seconds)") + ':'
            }
        }
    }

    GroupBox {
        title: i18n("Camera Image View")
        Layout.fillWidth: true
//		flat: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            SpinBox {
                id: cameraViewImageWidth
                editable: true
                from: 256
                to: 3840
//                stepSize: 256
                Kirigami.FormData.label: i18n("Snapshot image width (px)") + ':'
            }
            SpinBox {
                id: cameraViewImageHeight
                editable: true
                from: 256
                to: 2160
                stepSize: 64
                inputMethodHints: Qt.ImhDigitsOnly
                Kirigami.FormData.label: i18n("Snapshot image height (px)") + ':'
//                textFromValue: function(value, locale) {
//                    return Number(value).toLocaleString(locale, 'f', 0);
//                }
            }

            SpinBox {
                id: cameraViewImageScaleFactor
                editable: true
                from: 1
                to: 20
                Kirigami.FormData.label: i18n("Scale factor") + ':'
            }

        }
    }

    Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
    }


}
