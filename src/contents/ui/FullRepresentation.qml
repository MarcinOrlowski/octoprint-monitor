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

import QtQuick 2.6
import QtQuick.Layouts 1.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import "./PrinterStateBucket.js" as Bucket
import "../js/utils.js" as Utils

ColumnLayout {
    id: fullContainer

    Layout.fillWidth: true

    // ------------------------------------------------------------------------------------------------------------------------

	property bool isCameraViewEnabled: plasmoid.configuration.cameraViewEnabled && plasmoid.configuration.cameraViewSnapshotUrl != ''
	property string cameraViewTimerState: i18n('Every %1', Utils.secondsToString(plasmoid.configuration.cameraViewUpdateInterval))
	property string cameraView0Stamp: ''
	property var cameraView0StampMillis: 0
	property string cameraView1Stamp: ''
	property var cameraView1StampMillis: 0

    function isSnapshotEnabled() {
         return osm.apiConnected && plasmoid.expanded && isCameraViewEnabled && isCameraViewPollActive()
    }

	function updateSnapshot() {
	    if (!isSnapshotEnabled()) return

        var targetImageView = (cameraViewStack.currentIndex === 0) ? cameraView0 : cameraView1
        targetImageView.source = `${plasmoid.configuration.cameraViewSnapshotUrl}#random` + Math.floor(Math.random() * 1000)

        function finishImage() {
            if (targetImageView.status === Component.Ready) {
                targetImageView.statusChanged.disconnect(finishImage)
                cameraViewStack.currentIndex = (cameraViewStack.currentIndex+1) % 2

                if (cameraViewStack.currentIndex === 0) {
                    cameraView0StampMillis = Date.now()
                } else {
                    cameraView1StampMillis = Date.now()
                }
            }
        }

        if (targetImageView.status === Component.Loading) {
            targetImageView.statusChanged.connect(finishImage)
        } else {
            finishImage()
        }
	}

	Timer {
	    id: cameraViewSnapshotTimeUpdater
        interval: 1000
        repeat: true
        running: plasmoid.expanded
        triggeredOnStart: plasmoid.expanded
        onTriggered: {
            if (!isSnapshotEnabled()) return

            if (plasmoid.configuration.showSnapshotTimestampElapsed) {
                var showSeconds = plasmoid.configuration.showSnapshotTimestampElapsedAlwaysShowSeconds
                var now = Date.now()
                if (cameraView0StampMillis != 0) cameraView0Stamp = i18n('Updated %1 ago', Utils.secondsToString(Math.floor((now-cameraView0StampMillis)/1000), showSeconds))
                if (cameraView1StampMillis != 0) cameraView1Stamp = i18n('Updated %1 ago', Utils.secondsToString(Math.floor((now-cameraView1StampMillis)/1000), showSeconds))
            } else {
                if (cameraView0StampMillis != 0) cameraView0Stamp = new Date(cameraView0StampMillis).toLocaleString(Qt.locale(), Locale.ShortFormat)
                if (cameraView1StampMillis != 0) cameraView1Stamp = new Date(cameraView1StampMillis).toLocaleString(Qt.locale(), Locale.ShortFormat)
            }
        }
	}

    Timer {
        id: cameraViewTimer;
        interval: plasmoid.configuration.cameraViewUpdateInterval * 1000
        repeat: true
        running: plasmoid.expanded
        triggeredOnStart: plasmoid.expanded
        onTriggered: updateSnapshot()
	}

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Determines if we should keep polling camera view or stop,
    ** depeneding of multiple factors, incl. user settings.
    **
    ** Returns:
    **  bool: False if camera view poll should stop.
    */
    function isCameraViewPollActive() {
        if (!plasmoid.configuration.stopCameraPollForBuckets) return true

        var result = true
        switch (osm.octoStateBucket) {
            case Bucket.idle: result = !plasmoid.configuration.stopCameraPollForBucketIdle; break;
            case Bucket.unknown: result = !plasmoid.configuration.stopCameraPollForBucketUnknown; break;
            case Bucket.working: result = !plasmoid.configuration.stopCameraPollForBucketWorking; break;
            case Bucket.cancelling: result = !plasmoid.configuration.stopCameraPollForBucketCancelling; break;
            case Bucket.paused: result = !plasmoid.configuration.stopCameraPollForBucketPaused; break;
            case Bucket.error: result = !plasmoid.configuration.stopCameraPollForBucketError; break;
            case Bucket.disconnected: result = !plasmoid.configuration.stopCameraPollForBucketDisconnected; break;
        }
        return result
    }

    // ------------------------------------------------------------------------------------------------------------------------

    RowLayout {
        id: fullStateContainerTopRow
        Layout.fillWidth: true

        Image {
//            readonly property int iconSize: PlasmaCore.Units.iconSizes.huge
            readonly property int iconSize: 96

            id: fullStateIcon

            Layout.alignment: Qt.AlignCenter
            fillMode: Image.PreserveAspectFit
            source: osm.octoStateIcon
            clip: true
            width: iconSize
            height: iconSize
            Layout.maximumWidth: iconSize
            Layout.maximumHeight: iconSize
            Layout.preferredWidth: iconSize
            Layout.preferredHeight: iconSize
        }

        ColumnLayout {
            id: fullStateTopContainer

            Layout.fillWidth: true
            anchors.right: fullStateContainerTopRow.right

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                text: {
                    var state = osm.octoState;
                    if (osm.jobInProgress) {
                        state += ` ${osm.jobCompletion}%`
                    }
                    return Utils.ucfirst(state);
                }
            }
            PlasmaComponents.ProgressBar {
                id: fullStateProgressBar
                Layout.fillWidth: true
                height: 4
                value: osm.jobCompletion/100
                visible: osm.jobInProgress
            }
            PlasmaComponents.Label {
                id: fullStateElapsedTime
                Layout.alignment: Qt.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                text: i18n('Elapsed: %1', osm.jobPrintTime)
                font.pixelSize: Qt.application.font.pixelSize * 0.8
                visible: osm.jobInProgress && plasmoid.configuration.showJobPrintTime && osm.jobPrintTime != ''
            }
            PlasmaComponents.Label {
                id: fullStateRemainingTime
                Layout.alignment: Qt.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                text: i18n('Left: %1', osm.jobPrintTimeLeft)
                font.pixelSize: Qt.application.font.pixelSize * 0.8
                visible: osm.jobInProgress && plasmoid.configuration.showJobTimeLeft && osm.jobPrintTimeLeft != ''
            }
        } // ColumnLayout
    } // RowLayout

//    MouseArea {
//        width: fullContainer.width
//        Layout.minimumWidth: fullContainer.width
//        Layout.maximumWidth: fullContainer.width

    ColumnLayout {
        id: cameraViewContainer

        StackLayout {
            id: cameraViewStack

            width: fullContainer.width
            Layout.minimumWidth: fullContainer.width
            Layout.maximumWidth: fullContainer.width

            visible: isCameraViewEnabled
            currentIndex: 0

            ColumnLayout {
                id: cameraViewContainer0
                width: fullContainer.width
                Layout.minimumWidth: fullContainer.width

                Image {
                    id: cameraView0
                    Layout.minimumWidth: parent.width
                    Layout.maximumWidth: parent.width

                    sourceSize.width: cameraView0.width
                    sourceSize.height: cameraView0.height
                    fillMode: Image.PreserveAspectFit;
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    cache: false
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: plasmoid.configuration.showSnapshotTimestamp
                    PlasmaComponents.Label {
                        maximumLineCount: 1
                        Layout.maximumWidth: parent.width
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        elide: Text.ElideRight
                        font.pixelSize: Qt.application.font.pixelSize * 0.8
                        text: cameraView0Stamp
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        maximumLineCount: 1
                        Layout.maximumWidth: parent.width
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        elide: Text.ElideRight
                        font.pixelSize: Qt.application.font.pixelSize * 0.8
                        text: (cameraView0Stamp != '') ? cameraViewTimerState : ''
                    }
                }
            }

            ColumnLayout {
                id: cameraViewContainer1
                width: parent.width
                Layout.minimumWidth: parent.width
                Layout.maximumWidth: parent.width
                Image {
                    id: cameraView1
                    Layout.minimumWidth: parent.width
                    Layout.maximumWidth: parent.width

                    sourceSize.width: cameraView1.width
                    sourceSize.height: cameraView1.height
                    fillMode: Image.PreserveAspectFit;
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    cache: false
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: plasmoid.configuration.showSnapshotTimestamp
                    PlasmaComponents.Label {
                        maximumLineCount: 1
                        Layout.maximumWidth: parent.width
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        elide: Text.ElideRight
                        font.pixelSize: Qt.application.font.pixelSize * 0.8
                        text: cameraView1Stamp
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        maximumLineCount: 1
                        Layout.maximumWidth: parent.width
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        elide: Text.ElideRight
                        font.pixelSize: Qt.application.font.pixelSize * 0.8
                        text: (cameraView1Stamp != '') ? cameraViewTimerState : ''
                    }
                }
            }
        } // StackLayout

        Rectangle {
            anchors.top: cameraViewContainer.top
            anchors.left: cameraViewContainer.left
            anchors.right: cameraViewContainer.right
            height: fullStateJobFileName.height
            color: "#aa222222"
            visible: osm.jobInProgress && plasmoid.configuration.showJobFileName
            Layout.fillWidth: true

            PlasmaComponents.Label {
                id: fullStateJobFileName

                padding: 8

                anchors.top: parent.top
                anchors.left: parent.left
                Layout.fillWidth: true
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                elide: Text.ElideMiddle
                text: osm.jobFileName
            }
        }

    } // ColumnLayout (cameraViewContainer)

    RowLayout {
        id: cameraViewControButtons

        visible: plasmoid.configuration.cameraViewControlsEnabled && isCameraViewEnabled
        Layout.fillWidth: true

        PlasmaComponents.Button {
            id: buttonStartPause
            text: i18n("Pause")
//            implicitWidth: minimumWidth
            icon.name: "media-playback-pause"
            onClicked: {
                if (cameraViewTimer.running) {
                    cameraViewTimer.stop()
                    cameraViewTimerState = i18n('PAUSED')
                    buttonStartPause.text = i18n('Start')
                    buttonStartPause.icon.name = "media-playback-start"
                } else {
                    cameraViewTimerState = i18n('Every %1', Utils.secondsToString(plasmoid.configuration.cameraViewUpdateInterval))
                    cameraViewTimer.start()
                    buttonStartPause.text = i18n('Pause')
                    buttonStartPause.icon.name = "media-playback-pause"
                }
            }
        }

        PlasmaComponents.Button {
            text: "Stop"
//            implicitWidth: minimumWidth
            icon.name: "media-playback-stop"
            onClicked: {
                cameraViewTimer.stop()
                cameraViewTimerState = i18n('STOPPED')
                buttonStartPause.text = i18n('Start')
                buttonStartPause.icon.name = "media-playback-start"
            }
        }

        Item {
            Layout.fillWidth: true
        }

        PlasmaComponents.Button {
            text: ''
            implicitWidth: units.gridUnit * 2
            icon.name: "view-refresh"
            onClicked: {
                if (cameraViewTimer.running) {
                    cameraViewTimer.restart()
                }
                updateSnapshot()
            }
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
