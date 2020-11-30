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
import QtQuick.Dialogs 1.0

ColumnLayout {
    width: childrenRect.width
//    height: childrenRect.height

    property alias cfg_notificationJobStartSoundEnabled: notificationJobStartSoundEnabled.checked
    property alias cfg_notificationJobStartSoundFilePath: notificationJobStartSoundFilePath.text

    GroupBox {
    //    		title: i18n("Camera Image View")
        Layout.fillWidth: true
    //		flat: true

        RowLayout {
            CheckBox {
                id: notificationJobStartSoundEnabled
                text: i18n("Print Job Started") + ':'
            }
            Button {
                text: i18n("Choose")
                onClicked: notificationJobStartSoundFileDialog.visible = true
                enabled: notificationJobStartSoundEnabled
            }
            TextField {
                id: notificationJobStartSoundFilePath
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width
                enabled: notificationJobStartSoundEnabled
                placeholderText: "/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
            }
        }
    }

    Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
    }

    FileDialog {
        id: notificationJobStartSoundFileDialog
        title: i18n("Choose a sound effect")
        folder: '/usr/share/sounds'
        nameFilters: [ "Sound files (*.wav *.mp3 *.oga *.ogg)", "All files (*)" ]
        onAccepted: {
            console.debug("Selected file: " + fileUrls)
            cfg_notificationJobStartSoundFilePath = fileUrl
        }
        onRejected: {
            console.debug("Canceled")
        }
    }


}
