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
	property alias cfg_useNotifySend:		    notificationsUseNotifySend.checked

    GroupBox {
        title: i18n("Desktop notifications")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            PlasmaComponents.CheckBox {
                id: notificationsEnabled
                text: i18n("Post desktop notifications")
            }
//            PlasmaComponents.CheckBox {
//                id: notificationsUseNotifySend
//                enabled: cfg_notificationsEnabled
//                text: i18n("Use notify-send instead")
//            }
        }
    } // GroupBox

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
