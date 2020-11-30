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
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls.Styles 1.4
import org.kde.plasma.plasmoid 2.0 //needed to give the Plasmoid attached properties

Item {
	// CompactROOT
	id: compact

//    width: units.gridUnit * 35
//    height: units.gridUnit * 35
//
//    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
//
//    Rectangle {
//        anchors.fill: parent
//        color: "red"
//    }

//	Layout.fillWidth: true
//	Layout.fillHeight: true
//	Layout.minimumWidth: imageSize
//	Layout.minimumHeight: imageSize

//	Layout.minimumWidth: 200 * units.devicePixelRatio
//	Layout.minimumHeight: 200 * units.devicePixelRatio

//	spacing: units.smallSpacing

	Plasmoid.status: PlasmaCore.Types.ActiveStatus
//	Plasmoid.toolTipMainText: ""
//	Plasmoid.toolTipSubText: ""

	Plasmoid.toolTipItem: Loader {
		id: tooltipLoader

		Layout.minimumWidth: compact ? compact.width : 0
		Layout.maximumWidth: compact ? compact.width : 0
		Layout.minimumHeight: compact ? compact.height : 0
		Layout.maximumHeight: compact ? compact.height : 0

		source: "Tooltip.qml"
	}

    MouseArea {
        onClicked: plasmoid.expanded = !plasmoid.expanded
        anchors.fill: parent
	}

    // ------------------------------------------------------------------------------------------------------------------------

    Plasmoid.onFormFactorChanged: {
        if (plasmoid.formFactor == PlasmaCore.Types.Horizontal) {
            console.debug("formFactor: Horizontal");
        } else {
            console.debug("formFactor: Vertical");
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------

	property bool layoutVertical: plasmoid.configuration.compactLayoutVerticalMode
	property int imageSize: layoutVertical ? plasmoid.configuration.compactLayoutVerticalIconSize : plasmoid.configuration.compactLayoutHorizontalIconSize

	property bool displayState: main.compactLayoutProgressEnabled || main.compactLayoutStateEnabled

//    Rectangle {
//        anchors.fill: parent
//        color: "red"
//    }

//    Item {
//        anchors.verticalCenter: compact.verticalCenter

        Grid {
            rows: 1

            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            flow: Grid.TopToBottom
            columnSpacing: units.smallSpacing

            Rectangle {
                anchors.fill: parent
                color: "red"
            }

        }


//        ColumnLayout {
//            id: compactLayoutVertical
//            visible: compact.layoutVertical
////            Layout.alignment: Qt.AlignCenter
////            width: parent.width
//            spacing: units.smallSpacing
//
////            Layout.fillWidth: true
////            Layout.fillHeight: true
//
//            Image {
//                Layout.alignment: Qt.AlignCenter
//                width: compact.imageSize
//                height: compact.imageSize
//                Layout.minimumWidth: compact.imageSize
//                Layout.minimumHeight: compact.imageSize
//                Layout.preferredWidth: compact.imageSize
//                Layout.preferredHeight: compact.imageSize
//                fillMode: Image.PreserveAspectFit
//                source: main.octoStateIcon
//            }
//
//            PlasmaComponents.Label {
//                Layout.alignment: Qt.AlignCenter
//                Layout.maximumWidth: parent.width
//    //			elide: Text.ElideRight
//                textFormat: Text.PlainText
//                maximumLineCount: 1
//                wrapMode: Text.NoWrap
//                text: main.compactOctoState
//                font.capitalization: Font.Capitalize
//                visible: main.compactLayoutStateEnabled
//            }
//
//            PlasmaComponents.ProgressBar {
//                Layout.fillWidth: true
//                visible: main.showPrintingProgressBar && main.compactLayoutcompactLayoutVerticalProgressBarEnabled
//
//                value: main.job_completion/100
//                style: ProgressBarStyle {
//                    background: Rectangle {
//                        radius: 4
//                        color: "#3f4159"
//                        border.color: "#262841"
//                        border.width: 1
//    //                    implicitWidth: 200
//                        implicitHeight: 12
//                    }
//                    progress: Rectangle {
//                        radius: 4
//                        // octoprint's octopus dark green
//                        color: "#219c18"
//                        // octoprint's octopus light green
//                        border.color: "#25c622"
//                    }
//                }
//            }
//        }
//
//        RowLayout {
//            id: compactLayoutHorizontal
//
//            visible: compact.layoutVertical === false
////            Layout.alignment: Qt.AlignCenter
////            width: parent.width
//            spacing: units.smallSpacing
//
//            Image {
//                Layout.alignment: Qt.AlignCenter
//                width: compact.imageSize
//                height: compact.imageSize
//                Layout.minimumWidth: compact.imageSize
//                Layout.minimumHeight: compact.imageSize
//                Layout.preferredWidth: compact.imageSize
//                Layout.preferredHeight: compact.imageSize
//                fillMode: Image.PreserveAspectFit
//                source: main.octoStateIcon
//            }
//
//            PlasmaComponents.Label {
//                Layout.alignment: Qt.AlignCenter
//                Layout.maximumWidth: parent.width
//    //			elide: Text.ElideRight
//                textFormat: Text.PlainText
//                maximumLineCount: 1
//                wrapMode: Text.NoWrap
//                text: main.compactOctoState
//                visible: main.compactLayoutStateEnabled
//            }
//        }

    // ------------------------------------------------------------------------------------------------------------------------

//    }

}
