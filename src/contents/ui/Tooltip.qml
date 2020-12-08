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
            text: i18n('<b>State changed:</b> %1', osm.lastOctoStateChangeStamp)
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
			    if (osm.jobPrintTimeSeconds != 0)
			        msg += i18n('<b>Print time:</b> %1', Utils.secondsToString(osm.jobPrintTimeSeconds))
                if (osm.jobPrintTimeLeftSeconds != 0) {
                    if (msg != '') msg += ', '
                    msg += i18n('<b>Time left:</b> %1', Utils.secondsToString(osm.jobPrintTimeLeftSeconds))
                }
                return msg
            }
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: osm.jobPrintTimeSeconds != 0 || osm.jobPrintTimeLeftSeconds != 0
		}

		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			elide: Text.ElideMiddle
			textFormat: Text.RichText
			text: i18n('<b>File:</b> %1', osm.jobFileName)
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: osm.jobFileName != ''
		}

        GridLayout {
		    id: tooltipTemperatures
			width: parent.width
			Layout.fillWidth: true
			columns: 2
			visible: osm.printerConnected && osm.apiConnected && osm.current.printer !== undefined

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				textFormat: Text.RichText
				text: i18n('<b>Hot bed:</b>')
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}

			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				textFormat: Text.RichText
				wrapMode: Text.NoWrap
				text: {
				    var msg = `${osm.current.printer.bedTemperatureActual}°`
				    if (osm.current.printer.bedTemperatureTarget > 0) msg += ` of ${osm.current.printer.bedTemperatureTarget}°`
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
				    var msg = `${osm.current.printer.extruder0TemperatureActual}°`
				    if (osm.current.printer.extruder0TemperatureTarget > 0) msg += ` of ${osm.current.printer.extruder0TemperatureTarget}°`
				    return msg
                }
				font.pixelSize: Qt.application.font.pixelSize * 0.8
			}
		} // GridLayout
	} // ColumnLayout

    // ------------------------------------------------------------------------------------------------------------------------
}
