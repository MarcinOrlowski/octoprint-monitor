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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    width: childrenRect.width

	property alias cfg_compactLayoutShowBucketName:		compactLayoutShowBucketName.checked
    property alias cfg_compactLayoutStateIconEnabled:   compactLayoutStateIconEnabled.checked
    property alias cfg_compactLayoutPercentageEnabled:	compactLayoutPercentageEnabled.checked

    property alias cfg_compactLayoutCustomIconSizeEnabled: compactLayoutCustomIconSizeEnabled.checked
	property alias cfg_compactLayoutCustomIconSize:   compactLayoutCustomIconSize.value

	property alias cfg_compactLayoutVerticalProgressBarEnabled: compactLayoutVerticalProgressBarEnabled.checked
	property alias cfg_compactLayoutShowPrintTime: compactLayoutShowPrintTime
	property alias cfg_compactLayoutShowPrintTimeLeft: compactLayoutShowPrintTimeLeft

	property alias cfg_compactLayoutStateTextLineEnabled: compactLayoutStateTextLineEnabled.checked

    property alias cfg_compactLayoutHideBuckets: compactLayoutHideBuckets.checked
    property alias cfg_compactLayoutHideBucketUnknown: compactLayoutHideBucketUnknown.checked
    property alias cfg_compactLayoutHideBucketWorking: compactLayoutHideBucketWorking.checked
    property alias cfg_compactLayoutHideBucketPaused: compactLayoutHideBucketPaused.checked
    property alias cfg_compactLayoutHideBucketError: compactLayoutHideBucketError.checked
    property alias cfg_compactLayoutHideBucketIdle: compactLayoutHideBucketIdle.checked
    property alias cfg_compactLayoutHideBucketDisconnected: compactLayoutHideBucketDisconnected.checked

    GroupBox {
        title: i18n("State icon")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            PlasmaComponents.CheckBox {
                id: compactLayoutStateIconEnabled
                text: i18n("Display state icon")
            }

            PlasmaComponents.CheckBox {
                id: compactLayoutCustomIconSizeEnabled
                text: i18n("Override maximum state icon size (if fits)")
                enabled: cfg_compactLayoutStateIconEnabled
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("State icon size") + ':'
                }
                PlasmaComponents.SpinBox {
                    id: compactLayoutCustomIconSize
                    enabled: cfg_compactLayoutCustomIconSizeEnabled && cfg_compactLayoutStateIconEnabled
                    editable: true
                    from: 32
                    to: 512
                    stepSize: 16
                }
            }
        }
    } // GroupBox

    GroupBox {
        title: i18n("State text")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            PlasmaComponents.CheckBox {
                id: compactLayoutStateTextLineEnabled
                text: i18n("Display text state line")
            }

            PlasmaComponents.CheckBox {
                id: compactLayoutShowBucketName
                enabled: cfg_compactLayoutStateTextLineEnabled
                text: i18n("Show state bucket name")
            }

            PlasmaComponents.CheckBox {
                id: compactLayoutHideBuckets
                enabled: cfg_compactLayoutStateTextLineEnabled && cfg_compactLayoutShowBucketName
                text: i18n("Hide state text for specific buckets")
            }
            ColumnLayout {
                id: clsStates
                readonly property int indent: 24

                GridLayout {
                    columns: 2
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketUnknown
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Unknown")
                    }
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketWorking
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Working")
                    }
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketPaused
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Paused")
                    }
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketError
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Error")
                    }
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketIdle
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Idle")
                    }
                    PlasmaComponents.CheckBox {
                        id: compactLayoutHideBucketDisconnected
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: clsStates.indent
                        text: i18n("Disconnected")
                    }
                }
            }

            PlasmaComponents.CheckBox {
                id: compactLayoutPercentageEnabled
                enabled: cfg_compactLayoutStateTextLineEnabled
                text: i18n("Display print progress percentage")
            }

        }
    } // GroupBox

    GroupBox {
        title: i18n("Job progress")
        Layout.fillWidth: true

        Kirigami.FormLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            PlasmaComponents.CheckBox {
                id: compactLayoutVerticalProgressBarEnabled
                text: i18n("Show print job progress bar")
            }

            PlasmaComponents.CheckBox {
                id: compactLayoutShowPrintTime
                text: i18n("Show print elapsed time")
            }
            PlasmaComponents.CheckBox {
                id: compactLayoutShowPrintTimeLeft
                text: i18n("Show estimated remaining time")
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
