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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    width: childrenRect.width

	property alias cfg_notificationsEnabled:	notificationsEnabled.checked
//	property alias cfg_useNotifySend:		    notificationsUseNotifySend.checked

    property alias cfg_notificationsTimeoutPrintJobStarted: notificationsTimeoutPrintJobStarted.value
    property alias cfg_notificationsTimeoutPrintJobSuccessful: notificationsTimeoutPrintJobSuccessful.value
    property alias cfg_notificationsTimeoutPrintJobFailed: notificationsTimeoutPrintJobFailed.value

    GroupBox {
        title: i18n("Desktop notifications")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            CheckBox {
                id: notificationsEnabled
                text: i18n("Post desktop notifications")
            }
//            CheckBox {
//                id: notificationsUseNotifySend
//                enabled: cfg_notificationsEnabled
//                text: i18n("Use notify-send instead")
//            }
        }
    } // GroupBox

    GroupBox {
        title: i18n("Notification timeouts")
        Layout.fillWidth: true

	    Kirigami.FormLayout {
    	    anchors.left: parent.left
        	anchors.right: parent.right

            PlasmaComponents.SpinBox {
                id: notificationsTimeoutPrintJobStarted
                editable: true
                enabled: cfg_notificationsEnabled
                from: 0
                to: 60
                Kirigami.FormData.label: i18n("Print job started (secs)")
	        }

            PlasmaComponents.SpinBox {
                id: notificationsTimeoutPrintJobSuccessful
                editable: true
                enabled: cfg_notificationsEnabled
                from: 0
                to: 60
                Kirigami.FormData.label: i18n("Print job successful (secs)")
	        }

            PlasmaComponents.SpinBox {
                id: notificationsTimeoutPrintJobFailed
                editable: true
                enabled: cfg_notificationsEnabled
                from: 0
                to: 60
                Kirigami.FormData.label: i18n("Print job failed (secs)")
	        }

        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
