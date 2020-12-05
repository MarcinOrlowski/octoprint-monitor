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
import org.kde.plasma.components 3.0 as PlasmaComponents

Kirigami.FormLayout {
    property alias cfg_cameraViewEnabled: cameraViewEnabled.checked
    property alias cfg_cameraViewUpdateInterval: cameraViewUpdateInterval.value
    property alias cfg_cameraViewSnapshotUrl: cameraViewSnapshotUrl.text
    property alias cfg_showJobFileName: showJobFileName.checked
    property alias cfg_showJobPrintTime: showJobPrintTime.checked
    property alias cfg_showJobTimeLeft: showJobTimeLeft.checked

    property alias cfg_stopCameraPollForBuckets: stopCameraPollForBuckets.checked
    property alias cfg_stopCameraPollForBucketUnknown: stopCameraPollForBucketUnknown.checked
    property alias cfg_stopCameraPollForBucketWorking: stopCameraPollForBucketWorking.checked
    property alias cfg_stopCameraPollForBucketPaused: stopCameraPollForBucketPaused.checked
    property alias cfg_stopCameraPollForBucketError: stopCameraPollForBucketError.checked
    property alias cfg_stopCameraPollForBucketIdle: stopCameraPollForBucketIdle.checked
    property alias cfg_stopCameraPollForBucketDisconnected: stopCameraPollForBucketDisconnected.checked


    Item {
        Kirigami.FormData.label: i18n("Camera view")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: cameraViewEnabled
        Kirigami.FormData.label: i18n("Enable camera snapshot view:")
    }

    TextField {
        id: cameraViewSnapshotUrl
        enabled: cfg_cameraViewEnabled
        validator: RegExpValidator { regExp: /http(s)?:.{5,}/ }
        Kirigami.FormData.label: i18n("Camera snapshot URL:")
    }

    SpinBox {
        id: cameraViewUpdateInterval
        enabled: cfg_cameraViewEnabled
        editable: true
        from: 1
        to: 3600
        stepSize: 5

        Kirigami.FormData.label: i18n("Camera update interval (seconds):")
    }

    Item {
        Kirigami.FormData.label: i18n("Camera view control")
        Kirigami.FormData.isSection: true
    }
    CheckBox {
        id: stopCameraPollForBuckets
        enabled: cfg_cameraViewEnabled
        text: i18n("Stop camera pooling for state buckets")
    }
    ColumnLayout {
        id: clsStates
        readonly property int indent: 24

        GridLayout {
            columns: 2
            CheckBox {
                id: stopCameraPollForBucketUnknown
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Unknown")
            }
            CheckBox {
                id: stopCameraPollForBucketWorking
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Working")
            }
            CheckBox {
                id: stopCameraPollForBucketPaused
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Paused")
            }
            CheckBox {
                id: stopCameraPollForBucketError
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Error")
            }
            CheckBox {
                id: stopCameraPollForBucketIdle
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Idle")
            }
            CheckBox {
                id: stopCameraPollForBucketDisconnected
                enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Disconnected")
            }
        }
    }
    Item {
        Kirigami.FormData.label: i18n("Miscelaneous")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: showJobPrintTime
        text: i18n("Show elapsed print time:")
    }
    CheckBox {
        id: showJobTimeLeft
        text: i18n("Show estimated job time left")
    }
    CheckBox {
        id: showJobFileName
        text: i18n("Show job file name")
    }
}
