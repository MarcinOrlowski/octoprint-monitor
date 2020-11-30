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

ColumnLayout {
    id: full

	Layout.fillWidth: true
	Layout.fillHeight: true

	spacing: units.smallSpacing

	property int snapshotWidth: 256
	property int snapshotHeight: 256

    // ------------------------------------------------------------------------------------------------------------------------

	property bool isCameraViewEnabled: plasmoid.configuration.cameraViewEnabled && plasmoid.configuration.cameraViewSnapshotUrl != ""
    Timer {
        interval: plasmoid.configuration.cameraViewUpdateInterval * 1000
        repeat: true
        running: plasmoid.expanded
        triggeredOnStart: plasmoid.expanded

        onTriggered: {
            if (!main.apiConnected || plasmoid.expanded == false || !isCameraViewEnabled) {
                return;
            }

			var oldImageView = stack.currentIndex === 0 ? cameraView1 : cameraView0;
			var newImageView = stack.currentIndex === 1 ? cameraView1 : cameraView0;

			newImageView.source = plasmoid.configuration.cameraViewSnapshotUrl;

			function finishImage() {
				if (newImageView.status === Component.Ready) {
					newImageView.statusChanged.disconnect(finishImage);

                    cameraUpdateStamp.text = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat);

					stack.currentIndex = stack.currentIndex++ % 2;
				}
			}

			if (newImageView.status === Component.Loading) {
				newImageView.statusChanged.connect(finishImage);
			} else {
				finishImage();
			}
		}
	}

    // ------------------------------------------------------------------------------------------------------------------------

    // FIXME - wrong settng used
    property int imageSize: plasmoid.configuration.compactLayoutVerticalIconSize

	ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true

	    RowLayout {
            Layout.fillWidth: true
            Image {
                id: stateIcon
                Layout.alignment: Qt.AlignCenter
                width: full.imageSize
                height: full.imageSize
                Layout.minimumWidth: full.imageSize
                Layout.minimumHeight: full.imageSize
                Layout.preferredWidth: full.imageSize
                Layout.preferredHeight: full.imageSize
                fillMode: Image.PreserveAspectFit
                source: main.octoStateIcon
            }
            PlasmaComponents.Label {
                id: stateText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                text: main.octoState
                font.capitalization: Font.Capitalize
            }
        }

        ColumnLayout {
            visible: main.printingInProgress
            Layout.fillWidth: true
            PlasmaComponents.Label {
                id: jobProgress
                text: {
                    var state;
                    if (isPrintInProgress()) {
                        state = main.job_state;
                        if (main.job_completion < 100) {
                            state += ' (' + main.job_completion + '%)';
                        }
                    } else {
                        state = i18n('Completed');
                    }
                    return state;
                }
                font {
                    pixelSize: Qt.application.font.pixelSize * 0.8
                    capitalization: Font.Capitalize
                }
            }
        }

        PlasmaComponents.ProgressBar {
            id: jobProgressBar
//                width: parent.width
//                height: 1 * units.devicePixelRatio
            Layout.fillWidth: true
            value: main.job_completion/100
            visible: main.showPrintingProgressBar
        }

        ColumnLayout {
            visible: main.printingInProgress
            Layout.fillWidth: true

            PlasmaComponents.Label {
                id: jobPrintTime
                Layout.fillWidth: true
                text: i18n('Print time') + ': ' + main.job_print_time_str
                font.pixelSize: Qt.application.font.pixelSize * 0.8
            }
            PlasmaComponents.Label {
                id: jobFileName
                Layout.fillWidth: true
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                elide: Text.ElideMiddle
                text: main.job_file_name
                font.pixelSize: Qt.application.font.pixelSize * 0.8
            }
        } // ColumnLayout

        StackLayout {
            id: stack

            property int cameraViewWidth: 1280
            property int cameraViewHeight: 720
            property int cameraViewScaleFactor: 4

            width: cameraViewWidth / cameraViewScaleFactor
            height: cameraViewHeight / cameraViewScaleFactor

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: isCameraViewEnabled

            // We init to 2 to display "Loading" text
            // unless first frame is loaded.
            currentIndex: 2

            Image {
                id: cameraView0
                width: parent.width
                height: parent.height
                Layout.minimumWidth: parent.width
                Layout.minimumHeight: parent.height
                Layout.maximumWidth: parent.width
                Layout.maximumHeight: parent.height
                sourceSize.width: cameraView0.width
                sourceSize.height: cameraView0.height
                fillMode: Image.PreserveAspectFit;
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                cache: false
                asynchronous: true
                Layout.alignment: Qt.AlignCenter
            }

            Image {
                id: cameraView1
                width: parent.width
                height: parent.height
                Layout.minimumWidth: parent.width
                Layout.minimumHeight: parent.height
                Layout.maximumWidth: parent.width
                Layout.maximumHeight: parent.height
                sourceSize.width: cameraView1.width
                sourceSize.height: cameraView1.height
                fillMode: Image.PreserveAspectFit;
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                cache: false
                asynchronous: true
                Layout.alignment: Qt.AlignCenter
            }

            PlasmaComponents.ProgressBar {
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                indeterminate: true
                Layout.fillWidth: true
            }

        } // StackLayout

        PlasmaComponents.Label {
            id: cameraUpdateStamp
            maximumLineCount: 1
            Layout.maximumWidth: parent.width
            wrapMode: Text.NoWrap
            text: ""
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            visible: isCameraViewEnabled
        }

    }

    // ------------------------------------------------------------------------------------------------------------------------

}
