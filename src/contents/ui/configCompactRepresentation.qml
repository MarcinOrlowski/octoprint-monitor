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
    id: ccRoot

    width: childrenRect.width

    readonly property int indent: 24

    property alias cfg_compactLayoutStateIconEnabled:   compactLayoutStateIconEnabled.checked

    property alias cfg_compactLayoutHideIconForBuckets: compactLayoutHideIconForBuckets.checked
    property alias cfg_compactLayoutHideIconForBucketUnknown: compactLayoutHideIconForBucketUnknown.checked
    property alias cfg_compactLayoutHideIconForBucketWorking: compactLayoutHideIconForBucketWorking.checked
    property alias cfg_compactLayoutHideIconForBucketCancelling: compactLayoutHideIconForBucketCancelling.checked
    property alias cfg_compactLayoutHideIconForBucketPaused: compactLayoutHideIconForBucketPaused.checked
    property alias cfg_compactLayoutHideIconForBucketError: compactLayoutHideIconForBucketError.checked
    property alias cfg_compactLayoutHideIconForBucketIdle: compactLayoutHideIconForBucketIdle.checked
    property alias cfg_compactLayoutHideIconForBucketDisconnected: compactLayoutHideIconForBucketDisconnected.checked


	property alias cfg_compactLayoutShowBucketName:		compactLayoutShowBucketName.checked
    property alias cfg_compactLayoutPercentageEnabled:	compactLayoutPercentageEnabled.checked

    property alias cfg_compactLayoutCustomIconSizeEnabled: compactLayoutCustomIconSizeEnabled.checked
	property alias cfg_compactLayoutCustomIconSize:   compactLayoutCustomIconSize.value

	property alias cfg_compactLayoutVerticalProgressBarEnabled: compactLayoutVerticalProgressBarEnabled.checked
	property alias cfg_compactLayoutShowPrintTime: compactLayoutShowPrintTime.checked
	property alias cfg_compactLayoutShowPrintTimeLeft: compactLayoutShowPrintTimeLeft.checked

	property alias cfg_compactLayoutStateTextLineEnabled: compactLayoutStateTextLineEnabled.checked

    property alias cfg_compactLayoutHideBuckets: compactLayoutHideBuckets.checked
    property alias cfg_compactLayoutHideBucketUnknown: compactLayoutHideBucketUnknown.checked
    property alias cfg_compactLayoutHideBucketWorking: compactLayoutHideBucketWorking.checked
    property alias cfg_compactLayoutHideBucketCancelling: compactLayoutHideBucketCancelling.checked
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

            CheckBox {
                id: compactLayoutStateIconEnabled
                text: i18n("Display state icon")
            }

            CheckBox {
                id: compactLayoutCustomIconSizeEnabled
                text: i18n("Override maximum state icon size (if fits)")
                enabled: cfg_compactLayoutStateIconEnabled
            }

            RowLayout {
                Label {
                    text: i18n("State icon size")
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

            CheckBox {
                id: compactLayoutHideIconForBuckets
                enabled: cfg_compactLayoutStateIconEnabled
                text: i18n("Hide state icon for specific buckets")
            }
            ColumnLayout {
                GridLayout {
                    columns: 2
                    CheckBox {
                        id: compactLayoutHideIconForBucketUnknown
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Unknown")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketWorking
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Working")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketCancelling
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Cancelling")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketPaused
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Paused")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketError
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Error")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketIdle
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Idle")
                    }
                    CheckBox {
                        id: compactLayoutHideIconForBucketDisconnected
                        enabled: cfg_compactLayoutHideIconForBuckets && cfg_compactLayoutStateIconEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Disconnected")
                    }
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

            CheckBox {
                id: compactLayoutStateTextLineEnabled
                text: i18n("Display text state line")
            }

            CheckBox {
                id: compactLayoutShowBucketName
                enabled: cfg_compactLayoutStateTextLineEnabled
                text: i18n("Show state bucket name")
            }

            CheckBox {
                id: compactLayoutHideBuckets
                enabled: cfg_compactLayoutStateTextLineEnabled && cfg_compactLayoutShowBucketName
                text: i18n("Hide state text for specific buckets")
            }
            ColumnLayout {
                readonly property int indent: 24

                GridLayout {
                    columns: 2
                    CheckBox {
                        id: compactLayoutHideBucketUnknown
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Unknown")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketWorking
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Working")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketCancelling
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Cancelling")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketPaused
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Paused")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketError
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Error")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketIdle
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Idle")
                    }
                    CheckBox {
                        id: compactLayoutHideBucketDisconnected
                        enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                        Layout.leftMargin: ccRoot.indent
                        text: i18n("Disconnected")
                    }
                }
            }

            CheckBox {
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

            CheckBox {
                id: compactLayoutVerticalProgressBarEnabled
                text: i18n("Show print job progress bar")
            }

            CheckBox {
                id: compactLayoutShowPrintTime
                text: i18n("Show print elapsed time")
            }
            CheckBox {
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
