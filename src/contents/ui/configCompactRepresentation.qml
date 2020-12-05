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
import org.kde.kirigami 2.13 as Kirigami

Kirigami.FormLayout {
    property alias cfg_compactLayoutShowBucketName: compactLayoutShowBucketName.checked
    property alias cfg_compactLayoutStateIconEnabled: compactLayoutStateIconEnabled.checked
    property alias cfg_compactLayoutPercentageEnabled: compactLayoutPercentageEnabled.checked

    property alias cfg_compactLayoutCustomIconSizeEnabled: compactLayoutCustomIconSizeEnabled.checked
    property alias cfg_compactLayoutCustomIconSize: compactLayoutCustomIconSize.value
    property alias cfg_compactLayoutVerticalProgressBarEnabled: compactLayoutVerticalProgressBarEnabled.checked

    property alias cfg_compactLayoutStateTextLineEnabled: compactLayoutStateTextLineEnabled.checked

    property alias cfg_compactLayoutHideBuckets: compactLayoutHideBuckets.checked
    property alias cfg_compactLayoutHideBucketUnknown: compactLayoutHideBucketUnknown.checked
    property alias cfg_compactLayoutHideBucketWorking: compactLayoutHideBucketWorking.checked
    property alias cfg_compactLayoutHideBucketPaused: compactLayoutHideBucketPaused.checked
    property alias cfg_compactLayoutHideBucketError: compactLayoutHideBucketError.checked
    property alias cfg_compactLayoutHideBucketIdle: compactLayoutHideBucketIdle.checked
    property alias cfg_compactLayoutHideBucketDisconnected: compactLayoutHideBucketDisconnected.checked

    Layout.fillHeight: true
    Layout.fillWidth: true

    Item {
        Kirigami.FormData.label: i18n("State icon")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: compactLayoutStateIconEnabled
        text: i18n("Display state icon")
    }

    CheckBox {
        id: compactLayoutCustomIconSizeEnabled
        text: i18n("Override maximum state icon size (if fits)")
        enabled: cfg_compactLayoutStateIconEnabled
    }

    SpinBox {
        Kirigami.FormData.label: i18n("State icon size:")
        id: compactLayoutCustomIconSize
        enabled: cfg_compactLayoutCustomIconSizeEnabled && cfg_compactLayoutStateIconEnabled
        editable: true
        from: 32
        to: 512
        stepSize: 16
    }

    Item {
        Kirigami.FormData.label: i18n("State text")
        Kirigami.FormData.isSection: true
    }

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
        id: clsStates
        readonly property int indent: 24

        GridLayout {
            columns: 2
            CheckBox {
                id: compactLayoutHideBucketUnknown
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Unknown")
            }
            CheckBox {
                id: compactLayoutHideBucketWorking
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Working")
            }
            CheckBox {
                id: compactLayoutHideBucketPaused
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Paused")
            }
            CheckBox {
                id: compactLayoutHideBucketError
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Error")
            }
            CheckBox {
                id: compactLayoutHideBucketIdle
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Idle")
            }
            CheckBox {
                id: compactLayoutHideBucketDisconnected
                enabled: cfg_compactLayoutHideBuckets && cfg_compactLayoutShowBucketName && cfg_compactLayoutStateTextLineEnabled
                Layout.leftMargin: clsStates.indent
                text: i18n("Disconnected")
            }
        }
    }

    CheckBox {
        id: compactLayoutPercentageEnabled
        enabled: cfg_compactLayoutStateTextLineEnabled
        text: i18n("Display print progress percentage")
    }

    Item {
        Kirigami.FormData.label:  i18n("Job progress")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: compactLayoutVerticalProgressBarEnabled
        text: i18n("Show print job progress bar")
    }
}
