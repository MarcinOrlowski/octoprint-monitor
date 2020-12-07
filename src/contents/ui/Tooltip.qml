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

import QtQuick 2.7
import QtQuick.Layouts 1.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import "../js/utils.js" as Utils

Item {
	id: tooltipRoot

	width: units.gridUnit * 15
	height: units.gridUnit * 8

	// ------------------------------------------------------------------------------------------------------------------------

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

		spacing: units.smallSpacing

		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			textFormat: Text.PlainText
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			font.bold: true
            text: Utils.ucfirst(!osm.jobInProgress ? osm.octoState : `${osm.octoState} ${osm.jobCompletion}%`)
		}
		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			elide: Text.ElideRight
			textFormat: Text.PlainText
			maximumLineCount: 2
			wrapMode: Text.Wrap
			font.italic: true
			text: osm.octoStateDescription
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: osm.octoStateDescription != ''
		}
		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			textFormat: Text.RichText
            text: '<b>' + i18n('State changed') + `:</b> ${osm.lastOctoStateChangeStamp}`
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            visible: osm.lastOctoStateChangeStamp != ''
		}

		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			maximumLineCount: 1
			textFormat: Text.RichText
			wrapMode: Text.NoWrap
			text: {
			    var msg = ''
			    if (osm.jobPrintTime != '')
			        msg += '<b>' + i18n('Print time') + `:</b> ${osm.jobPrintTime}`
                if (osm.jobPrintTimeLeft != '') {
                    if (msg != '') msg += ', '
                    msg += '<b>' + i18n('Time left') + `:</b> ${osm.jobPrintTimeLeft}`
                }
                return msg
            }
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: osm.jobPrintTime != '' || osm.jobPrintTimeLeft != ''
		}

		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			elide: Text.ElideMiddle
			textFormat: Text.RichText
			text: '<b>' + i18n('File') + `:</b> ${osm.jobFileName}`
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: osm.jobFileName != ''
		}

        GridLayout {
		    id: tooltipTemperatures
			width: parent.width
			Layout.fillWidth: true
			columns: 2
			visible: osm.printerConnected && osm.apiConnected

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				textFormat: Text.RichText
				text: '<b>' + i18n("Hot bed") + ':</b> '
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}

			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				textFormat: Text.RichText
				wrapMode: Text.NoWrap
				text: {
				    var msg = `${osm.bedTemperatureActual}°`
				    if (osm.bedTemperatureTarget > 0) msg += ` of ${osm.bedTemperatureTarget}°`
				    return msg
                }
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
                textFormat: Text.RichText
				text: '<b> ' + i18n("Extruder #1") + ':</b> '
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
                textFormat: Text.RichText
				wrapMode: Text.NoWrap
				text: {
				    var msg = `${osm.extruder0TemperatureActual}°`
				    if (osm.extruder0TemperatureTarget > 0) msg += ` of ${osm.extruder0TemperatureTarget}°`
				    return msg
                }
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}
		} // GridLayout
	} // ColumnLayout

    // ------------------------------------------------------------------------------------------------------------------------
}
