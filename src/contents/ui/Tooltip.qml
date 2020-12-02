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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

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
            text: {
                var state = main.octoState;
                if (main.jobInProgress) {
                    state += ` ${main.jobCompletion}%`
                }
                return state;
            }
			font.capitalization: Font.Capitalize
		}
		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			elide: Text.ElideRight
			textFormat: Text.PlainText
			maximumLineCount: 2
			wrapMode: Text.Wrap
			font.italic: true
			text: main.octoStateDescription
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: main.octoStateDescription != ""
		}
		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			textFormat: Text.PlainText
			maximumLineCount: 1
			wrapMode: Text.NoWrap
            text: i18n('State changed') + `: ${lastOctoStateChangeStamp}`
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            visible: lastOctoStateChangeStamp != ''
		}


		PlasmaComponents.Label {
		    Layout.maximumWidth: tooltipRoot.width
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			font.bold: true
			elide: Text.ElideMiddle
			text: main.jobFileName
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: main.jobFileName != ""
		}

        GridLayout {
		    id: tooltipTemperatures
			width: parent.width
			Layout.fillWidth: true
			columns: 2
			visible: main.printerConnected && main.apiConnected

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: i18n("Hot bed") + ': '
			}

			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: `${main.p_bed_actual}°'
				visible: main.p_bed_target == 0 || main.p_bed_actual == main.p_bed_target
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: `${main.p_bed_actual}° of ${main.p_bed_target}°`
				visible: main.p_bed_target > 0 && main.p_bed_actual != main.p_bed_target
			}

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: i18n("Hotend #1") + ': '
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: `${main.p_he0_actual}°`
				visible: main.p_he0_target == 0 || main.p_he0_actual == main.p_he0_target
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: `${main.p_he0_actual}° of ${main.p_he0_target}°`
				visible: main.p_he0_target > 0 && main.p_he0_actual != main.p_he0_target
			}
		} // GridLayout
	} // ColumnLayout

    // ------------------------------------------------------------------------------------------------------------------------
}
