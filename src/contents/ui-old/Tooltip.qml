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

	width: childrenRect.width * units.gridUnit
	height: childrenRect.height * units.gridUnit

//    Layout.fillWidth: true
//    Layout.fillHeight: true

    ColumnLayout {
//		id: tooltip

        anchors {
            left: parent.left
            top: parent.top
            margins: units.gridUnit / 2
        }

		spacing: units.smallSpacing

//        width: parent.width

//        Layout.fillWidth: true
//        Layout.fillHeight: true


		PlasmaComponents.Label {
//			Layout.maximumWidth: parent.width
//			elide: Text.ElideRight
			textFormat: Text.PlainText
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			text: main.octoState
			font.capitalization: Font.Capitalize
		}

		PlasmaComponents.Label {
//			Layout.maximumWidth: parent.width
//			elide: Text.ElideRight
			textFormat: Text.PlainText
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			text: main.octoStateDescription
//			font.capitalization: Font.Capitalize
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: main.octoStateDescription != ""
		}

		PlasmaComponents.Label {
			maximumLineCount: 1
			wrapMode: Text.NoWrap
			font.bold: true
			text: main.job_file_name
			font.pixelSize: Qt.application.font.pixelSize * 0.8
			visible: main.job_file_name != ""
		}

//        PlasmaComponents.ProgressBar {
////                width: parent.width
////                height: 1 * units.devicePixelRatio
//            Layout.fillWidth: true
//            value: main.job_completion/100
//        }

//        PlasmaComponents.ProgressBar {
////            visible: main.printingInProgress
//            Layout.fillWidth: true
////            Layout.fillHeight: true
////    		width: parent.width
//
//            value: main.job_completion/100
//            style: ProgressBarStyle {
//                background: Rectangle {
//                    radius: 4
//                    color: "#3f4159"
//                    border.color: "#262841"
//                    border.width: 1
////                    implicitWidth: 200
//                    implicitHeight: 12
//                }
//                progress: Rectangle {
//                    radius: 4
//                    // octoprint's octopus dark green
//                    color: "#219c18"
//                    // octoprint's octopus light green
//                    border.color: "#25c622"
//                }
//            }
//        }

		GridLayout {
		    id: tooltipTemperatures

			width: parent.width
			Layout.fillWidth: true
			columns: 2

			visible: main.printerConnected

			PlasmaComponents.Label {
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: i18n("Hot bed") + ': '
			}

			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: main.p_bed_actual + '°'
				visible: main.p_bed_target == 0 || main.p_bed_actual == main.p_bed_target
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: main.p_bed_actual + '° of ' + main.p_bed_target + '°'
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
				text: main.p_he0_actual + '°'
				visible: main.p_he0_target == 0 || main.p_he0_actual == main.p_he0_target
			}
			PlasmaComponents.Label {
				Layout.alignment: Qt.AlignRight
				maximumLineCount: 1
				wrapMode: Text.NoWrap
				text: main.p_he0_actual + '° of ' + main.p_he0_target + '°'
//				text: main.p_he0_actual + '° of ' + main.p_he0_target + '°'
				visible: main.p_he0_target > 0 && main.p_he0_actual != main.p_he0_target
			}
		} // GridLayout
	} // ColumnLayout

} // ColumnLayout
