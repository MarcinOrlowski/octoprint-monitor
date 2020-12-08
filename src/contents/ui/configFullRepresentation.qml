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

ColumnLayout {
    width: childrenRect.width

    property alias cfg_cameraViewEnabled: cameraViewEnabled.checked
    property alias cfg_cameraViewUpdateInterval: cameraViewUpdateInterval.value
    property alias cfg_cameraViewSnapshotUrl: cameraViewSnapshotUrl.text
    property alias cfg_cameraViewControlsEnabled: cameraViewControlsEnabled.checked

    property alias cfg_showJobFileName: showJobFileName.checked
    property alias cfg_showJobPrintTime: showJobPrintTime.checked
    property alias cfg_showJobPrintTimeAlwaysShowSeconds: showJobPrintTimeAlwaysShowSeconds.checked
    property alias cfg_showJobPrintTimeLeft: showJobPrintTimeLeft.checked
    property alias cfg_showJobPrintTimeLeftAlwaysShowSeconds: showJobPrintTimeLeftAlwaysShowSeconds.checked

    property alias cfg_showSnapshotTimestamp: showSnapshotTimestamp.checked
    property alias cfg_showSnapshotTimestampElapsed: showSnapshotTimestampElapsed.checked
    property alias cfg_showSnapshotTimestampElapsedAlwaysShowSeconds: showSnapshotTimestampElapsedAlwaysShowSeconds.checked

    property alias cfg_stopCameraPollForBuckets: stopCameraPollForBuckets.checked
    property alias cfg_stopCameraPollForBucketUnknown: stopCameraPollForBucketUnknown.checked
    property alias cfg_stopCameraPollForBucketWorking: stopCameraPollForBucketWorking.checked
    property alias cfg_stopCameraPollForBucketCancelling: stopCameraPollForBucketCancelling.checked
    property alias cfg_stopCameraPollForBucketPaused: stopCameraPollForBucketPaused.checked
    property alias cfg_stopCameraPollForBucketError: stopCameraPollForBucketError.checked
    property alias cfg_stopCameraPollForBucketIdle: stopCameraPollForBucketIdle.checked
    property alias cfg_stopCameraPollForBucketDisconnected: stopCameraPollForBucketDisconnected.checked

    GroupBox {
        title: i18n("Camera view")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: cameraViewEnabled
                Kirigami.FormData.label: i18n("Enable camera snapshot view")
            }

            TextField {
                id: cameraViewSnapshotUrl
                enabled: cfg_cameraViewEnabled
                validator: RegExpValidator { regExp: /http(s)?:.{5,}/ }
                Kirigami.FormData.label: i18n("Camera snapshot URL")
            }

            PlasmaComponents.SpinBox {
                id: cameraViewUpdateInterval
                enabled: cfg_cameraViewEnabled
                editable: true
                from: 1
                to: 3600
                stepSize: 5

                Kirigami.FormData.label: i18n("Camera update interval (secs)")
            }

            CheckBox {
                id: cameraViewControlsEnabled
                enabled: cfg_cameraViewEnabled
                Kirigami.FormData.label: i18n("Show camera view controls")
            }

        }
    }

    GroupBox {
        title: i18n("Camera view control")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: showSnapshotTimestamp
                enabled: cfg_cameraViewEnabled
                text: i18n("Show snapshot time stamp")
            }
            GridLayout {
                readonly property int indent: 24
                columns: 1
                CheckBox {
                    id: showSnapshotTimestampElapsed
                    enabled: cfg_cameraViewEnabled && cfg_showSnapshotTimestamp
                    Layout.leftMargin: parent.indent
                    text: i18n("Show as elapsed time")
                }
                CheckBox {
                    id: showSnapshotTimestampElapsedAlwaysShowSeconds
                    enabled: cfg_cameraViewEnabled && cfg_showSnapshotTimestamp && cfg_showSnapshotTimestampElapsed
                    Layout.leftMargin: parent.indent * 2
                    text: i18n("Always show seconds")
                }
            }

            CheckBox {
                id: stopCameraPollForBuckets
                enabled: cfg_cameraViewEnabled
                text: i18n("Stop camera pooling for state buckets")
            }
            ColumnLayout {
                id: clsStates

                GridLayout {
                    readonly property int indent: 24
                    columns: 2
                    CheckBox {
                        id: stopCameraPollForBucketUnknown
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Unknown")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketWorking
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Working")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketCancelling
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Cancelling")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketPaused
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Paused")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketError
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Error")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketIdle
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Idle")
                    }
                    CheckBox {
                        id: stopCameraPollForBucketDisconnected
                        enabled: cfg_stopCameraPollForBuckets && cfg_cameraViewEnabled
                        Layout.leftMargin: parent.indent
                        text: i18n("Disconnected")
                    }
                }
            }
        }
    }

    GroupBox {
        title: i18n("Miscelaneous")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            GridLayout {
                readonly property int indent: 24
                columns: 1
                CheckBox {
                    id: showJobPrintTime
                    text: i18n("Show elapsed print time")
                }
                CheckBox {
                    id: showJobPrintTimeAlwaysShowSeconds
                    enabled: cfg_showJobPrintTime
                    Layout.leftMargin: parent.indent
                    text: i18n("Always show seconds")
                }
            }

            GridLayout {
                readonly property int indent: 24
                columns: 1
                CheckBox {
                    id: showJobPrintTimeLeft
                    text: i18n("Show estimated remaining time")
                }
                CheckBox {
                    id: showJobPrintTimeLeftAlwaysShowSeconds
                    enabled: cfg_showJobPrintTimeLeft
                    Layout.leftMargin: parent.indent
                    text: i18n("Always show seconds")
                }
            }

            CheckBox {
                id: showJobFileName
                text: i18n("Show job file name")
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
