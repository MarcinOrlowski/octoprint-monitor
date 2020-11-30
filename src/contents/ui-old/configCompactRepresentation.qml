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

	property alias cfg_compactLayoutVerticalMode:       compactLayoutVerticalMode.checked
	property alias cfg_compactLayoutVerticalIconSize:   compactLayoutVerticalIconSize.value
	property alias cfg_compactLayoutHorizontalIconSize: compactLayoutHorizontalIconSize.value
	property alias cfg_compactLayoutStateEnabled:		compactLayoutStateEnabled.checked
	property alias cfg_compactLayoutProgressEnabled:	compactLayoutProgressEnabled.checked
	property alias cfg_compactLayoutVerticalProgressBarEnabled: compactLayoutVerticalProgressBarEnabled

    GroupBox {
        title: i18n("General settings")
        Layout.fillWidth: true
//	    	flat: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: compactLayoutVerticalMode
                Kirigami.FormData.label: i18n("Use vertical layout") + ':'
            }

            CheckBox {
                id: compactLayoutStateEnabled
                Kirigami.FormData.label: i18n("Display current printer state") + ':'
            }

            CheckBox {
                id: compactLayoutProgressEnabled
                Kirigami.FormData.label: i18n("Display print progress percentage") + ':'
            }

        }
    }

    GroupBox {
        title: i18n("Horizontal layout")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            SpinBox {
                id: compactLayoutHorizontalIconSize
                editable: true
                from: 32
                to: 512
                stepSize: 32
    //			suffix: px
                Kirigami.FormData.label: i18n("Printer state icon size") + ':'
            }
        }
    }


    GroupBox {
        title: i18n("Vertical layout")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            SpinBox {
                id: compactLayoutVerticalIconSize
                editable: true
                from: 32
                to: 512
                stepSize: 32
    //			suffix: "px"
                Kirigami.FormData.label: i18n("Printer state icon size") + ':'
            }

            CheckBox {
                id: compactLayoutVerticalProgressBarEnabled
                Kirigami.FormData.label: i18n("Show print job progress bar") + ':'
            }
        }
    }

    Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
    }


}
