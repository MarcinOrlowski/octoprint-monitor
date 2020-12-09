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

    // ------------------------------------------------------------------------------------------------------------------------

	property bool isCameraViewEnabled: plasmoid.configuration.cameraViewEnabled && plasmoid.configuration.cameraViewSnapshotUrl != ''
	property string cameraViewTimerState: i18n('Every %1', Utils.secondsToString(plasmoid.configuration.cameraViewUpdateInterval))
	property string cameraView0Stamp: ''
	property var cameraView0StampMillis: 0
	property string cameraView1Stamp: ''
	property var cameraView1StampMillis: 0

	property var cameraViewUpdateStampMillis: 0
	property string cameraViewUpdateStamp: ''

    function isSnapshotEnabled() {
         return osm.apiConnected && plasmoid.expanded && isCameraViewEnabled && isCameraViewPollActive()
    }

    property bool frontImageVisible: true
    property bool cameraViewInitialized: true
    readonly property string imageSourceUrl: plasmoid.configuration.cameraViewSnapshotUrl + '#'

    function updateSnapshot() {
	    if (!isSnapshotEnabled()) return

        var url = imageSourceUrl + Date.now()
        if (!cameraViewInitialized) {
//            cameraImageViewFront.source = url
            cameraImageViewBack.source = url
            cameraViewInitialized = true
            return
        }

        if (frontImageVisible) {
//            cameraImageViewBack.visible = true
            showBackImageViewAnimation.start()
        } else {
//            cameraImageViewFront.visible = true
            showFrontImageViewAnimation.start()
        }
        cameraViewUpdateStampMillis = Date.now()
        frontImageVisible = !frontImageVisible
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
                if (cameraViewUpdateStampMillis != 0) cameraViewUpdateStamp = i18n('Updated %1 ago', Utils.secondsToString(Math.floor((now-cameraViewUpdateStampMillis)/1000), showSeconds))
            } else {
                if (cameraViewUpdateStampMillis != 0) cameraViewUpdateStamp = new Date(cameraViewUpdateStampMillis).toLocaleString(Qt.locale(), Locale.ShortFormat)
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

    readonly property int xfadeDuration: 300
    ParallelAnimation {
        id: showBackImageViewAnimation
        onStarted: cameraImageViewBack.opacity = 0
        onStopped: cameraImageViewFront.source = imageSourceUrl + Date.now()
        PropertyAnimation {
            target: cameraImageViewBack
            property: "opacity"
            from: 0
            to: 1
            duration: xfadeDuration
            alwaysRunToEnd: true
        }
        PropertyAnimation {
            target: cameraImageViewFront
            property: "opacity"
            from: 1
            to: 0
            duration: xfadeDuration
            alwaysRunToEnd: true
        }
    }

    ParallelAnimation {
        id: showFrontImageViewAnimation
        onStarted: cameraImageViewFront.opacity = 0
        onStopped: cameraImageViewBack.source = imageSourceUrl + Date.now()
        PropertyAnimation {
            target: cameraImageViewBack
            property: "opacity"
            from: 1
            to: 0
            duration: xfadeDuration
            alwaysRunToEnd: true
        }
        PropertyAnimation {
            target: cameraImageViewFront
            property: "opacity"
            from: 0
            to: 1
            duration: xfadeDuration
            alwaysRunToEnd: true
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------

    RowLayout {
        id: fullStateContainerTopRow
        Layout.fillWidth: true

        anchors.left: fullContainer.left
        anchors.right: fullContainer.right
        anchors.top: fullContainer.top

        Image {
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
            anchors.left: fullStateIcon.right
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
                font.pixelSize: Qt.application.font.pixelSize * 0.8
                text: i18n('Elapsed: %1', Utils.secondsToString(osm.jobPrintTimeSeconds, plasmoid.configuration.showJobPrintTimeAlwaysShowSeconds))
                visible: osm.jobInProgress && plasmoid.configuration.showJobPrintTime && osm.jobPrintTime != ''
            }
            PlasmaComponents.Label {
                id: fullStateRemainingTime
                Layout.alignment: Qt.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.pixelSize: Qt.application.font.pixelSize * 0.8
                text: i18n('Left: %1', Utils.secondsToString(osm.jobPrintTimeLeftSeconds, plasmoid.configuration.showJobPrintTimeLeftAlwaysShowSeconds))
                visible: osm.jobInProgress && plasmoid.configuration.showJobPrintTimeLeft && osm.jobPrintTimeLeft != ''
            }
            PlasmaComponents.Label {
                id: fullStateJobFileName
                Layout.alignment: Qt.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                elide: Text.ElideMiddle
                text: osm.jobFileName
                font.pixelSize: Qt.application.font.pixelSize * 0.8
                visible: osm.jobInProgress && plasmoid.configuration.showJobFileName && osm.jobInProgress != ''
            }
        } // ColumnLayout
    } // RowLayout (fullStateContainerTopRow)

    ColumnLayout {
        id: cameraViewContainer
        anchors.top: fullStateContainerTopRow.bottom
        anchors.left: fullContainer.left
        anchors.right: fullContainer.right
        anchors.bottom: fullContainer.bottom

        visible: isCameraViewEnabled

        Rectangle {
            anchors.fill: parent
            color: "#ff0000"
            opacity: 0.5
        }

        ColumnLayout {
            id: cameraViewExtrasContainer

            anchors.left: fullContainer.left
            anchors.right: fullContainer.right
            anchors.bottom: fullContainer.bottom

            Rectangle {
                anchors.fill: parent
                color: "#00ff00"
                opacity: 0.5
            }

            RowLayout {
                id: cameraViewTimestampContainer

                anchors.left: cameraViewExtrasContainer.left
                anchors.right: cameraViewExtrasContainer.right

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    font.pixelSize: Qt.application.font.pixelSize * 0.8
                    text: cameraViewUpdateStamp
                }
            } // cameraViewTimestampContainer

            RowLayout {
                id: cameraViewControlButtonsContainer

                anchors.left: cameraViewExtrasContainer.left
                anchors.right: cameraViewExtrasContainer.right
                anchors.bottom: cameraViewContainer.bottom

                visible: plasmoid.configuration.cameraViewControlsEnabled
                Layout.fillWidth: true

                PlasmaComponents.Button {
                    id: buttonStartPause
                    text: i18n("Pause")
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
                    implicitWidth: units.gridUnit * 2
                    icon.name: "view-refresh"
                    onClicked: updateSnapshot()
                }
            } // cameraViewControlButtonsContainer
        } // cameraViewExtrasContainer

        ColumnLayout {
            id: cameraViewImageContainer

            anchors.top: cameraViewContainer.top
            anchors.left: cameraViewContainer.left
            anchors.right: cameraViewContainer.right
//            anchors.bottom: cameraViewExtrasContainer.top

            Rectangle {
                anchors.fill: parent
                color: "#0000ff"
                opacity: 0.5
            }

            Image {
                id: cameraImageViewBack
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
//                anchors.fill: parent
                Layout.minimumWidth: parent.width
                Layout.maximumWidth: parent.width
                Layout.minimumHeight: 200
                fillMode: Image.PreserveAspectFit;
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                cache: false
                asynchronous: true
                opacity: 0
            }
            Image {
                id: cameraImageViewFront
                // we need them overlapping
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
//                anchors.fill: parent
//                Layout.minimumWidth: 320
//                Layout.maximumWidth: 200
                Layout.minimumWidth: parent.width
                Layout.maximumWidth: parent.width
                Layout.minimumHeight: 200
                fillMode: Image.PreserveAspectFit;
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                cache: false
                asynchronous: true
                opacity: 1
                source: plasmoid.file("", `images/logo.png`)
            }
        } // cameraViewImageContainer

    } // cameraViewContainer

    // ------------------------------------------------------------------------------------------------------------------------
}
