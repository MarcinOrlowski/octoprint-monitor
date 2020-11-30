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

    property alias cfg_api_url: api_url.text
    property alias cfg_api_key: api_key.text
	property alias cfg_status_poll_interval: status_poll_interval.value

	GroupBox {
//		title: i18n("OctoPrint API")
		Layout.fillWidth: true
//		flat: true

	    Kirigami.FormLayout {
    	    anchors.left: parent.left
        	anchors.right: parent.right

            TextField {
                id: api_key
                text: i18n("API key:")
            }

	        TextField {
    	        id: api_url
				focus: true
				validator: RegExpValidator { regExp: /http(s)?:.{5,}/ }
	            Kirigami.FormData.label: i18n("OctoPrint API URL") + ':'
    	    }
		}
    }

    GroupBox {
//		title: i18n("OctoPrint API")
        Layout.fillWidth: true
//		flat: true

	    Kirigami.FormLayout {
    	    anchors.left: parent.left
        	anchors.right: parent.right

            SpinBox {
                    id: status_poll_interval
                    editable: true
                    from: 1
                    to: 600
                    stepSize: 15
                    Kirigami.FormData.label: i18n("Status poll interval (seconds)") + ':'
	        }
        }
    }


    Item {
    		Layout.fillHeight: true
    }
}
