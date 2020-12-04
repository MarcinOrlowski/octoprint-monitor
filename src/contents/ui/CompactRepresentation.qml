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
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as Extras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kquickcontrolsaddons 2.0
import QtQuick.Controls.Styles 1.4

GridLayout {
    id: compactContainer

    Plasmoid.toolTipItem: Loader {
        id: tooltipLoader
        source: "Tooltip.qml"
    }

    // ------------------------------------------------------------------------------------------------------------------------

    property int compactStateIconSize: 0

    states: [
        State {
            name: "horizontalPanel"
            when: plasmoid.formFactor == PlasmaCore.Types.Horizontal

            PropertyChanges {
                target: compactContainer
                columns: 2
                rows: 1
            }
        }, // State: horizontalPanel
        State {
            name: "verticalPanel"
            when: plasmoid.formFactor == PlasmaCore.Types.Vertical

            PropertyChanges {
                target: compactContainer
                columns: 1
                rows: 4
            }
        } // State: verticalPanel
    ] // states

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Determines if current state icon should be visible or not,
    ** depeneding of multiple factors, incl. user settings.
    **
    ** Returns:
    **  bool: False if icon for current state bucket should not be shown
    */
    function isStateBucketIconShown() {
        if (!plasmoid.configuration.compactLayoutStateIconEnabled) return false
        if (!plasmoid.configuration.compactLayoutHideIconForBuckets) return true

        var result = true
        switch (getPrinterStateBucket()) {
            case main.bucket_idle: result = !plasmoid.configuration.compactLayoutHideIconForBucketIdle; break;
            case main.bucket_unknown: result = !plasmoid.configuration.compactLayoutHideIconForBucketUnknown; break;
            case main.bucket_cancelling: result = !plasmoid.configuration.compactLayoutHideIconForBucketCancelling; break;
            case main.bucket_working: result = !plasmoid.configuration.compactLayoutHideIconForBucketWorking; break;
            case main.bucket_paused: result = !plasmoid.configuration.compactLayoutHideIconForBucketPaused; break;
            case main.bucket_error: result = !plasmoid.configuration.compactLayoutHideIconForBucketError; break;
            case main.bucket_disconnected: result = !plasmoid.configuration.compactLayoutHideIconForBucketDisconnected; break;
        }
        return result
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Determines if current state bucket should be visible or not,
    ** depeneding of multiple factors, incl. user settings.
    **
    ** Returns:
    **  bool: False if current state bucket should not be shown
    */
    function isStateBucketNameShown() {
        if (!plasmoid.configuration.compactLayoutShowBucketName) return false
        if (!plasmoid.configuration.compactLayoutHideBuckets) return true

        var result = true
        switch (getPrinterStateBucket()) {
            case main.bucket_idle: result = !plasmoid.configuration.compactLayoutHideBucketIdle; break;
            case main.bucket_unknown: result = !plasmoid.configuration.compactLayoutHideBucketUnknown; break;
            case main.bucket_working: result = !plasmoid.configuration.compactLayoutHideBucketWorking; break;
            case main.bucket_cancelling: result = !plasmoid.configuration.compactLayoutHideBucketCancelling; break;
            case main.bucket_paused: result = !plasmoid.configuration.compactLayoutHideBucketPaused; break;
            case main.bucket_error: result = !plasmoid.configuration.compactLayoutHideBucketError; break;
            case main.bucket_disconnected: result = !plasmoid.configuration.compactLayoutHideBucketDisconnected; break;
        }
        return result
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Visible elements
    */
    Image {
        id: compactStateIcon
        Layout.alignment: Qt.AlignCenter
        fillMode: Image.PreserveAspectFit
        source: main.octoStateIcon
        clip: true
        visible: {
            // If all is set hidden we will force icon display anyway.
            var visibility = isStateBucketIconShown()
            if (!visibility) {
                visibility =
                    (!isStateBucketNameShown()
                        && !(main.jobInProgress && (
                            plasmoid.configuration.compactLayoutPercentageEnabled
                            || plasmoid.configuration.compactLayoutVerticalProgressBarEnabled
                            || plasmoid.configuration.compactLayoutShowPrintTime
                            || plasmoid.configuration.compactLayoutShowPrintTimeLeft
                        )
                    ))
            }
            return visibility;
        }
        Layout.maximumWidth: {
            var threshold = (plasmoid.formFactor == PlasmaCore.Types.Horizontal) ? compactContainer.height : compactContainer.width;
            var size = threshold;
            if (plasmoid.configuration.compactLayoutCustomIconSizeEnabled && (compactContainer.width !== undefined)) {
                size = Math.min(plasmoid.configuration.compactLayoutCustomIconSize, threshold)
            }
            return size
        }
        Layout.maximumHeight: {
            var threshold = (plasmoid.formFactor == PlasmaCore.Types.Vertical) ? compactContainer.width : compactContainer.height;
            var size = threshold;
            if (plasmoid.configuration.compactLayoutCustomIconSizeEnabled && (compactContainer.height !== undefined)) {
                size = Math.min(plasmoid.configuration.compactLayoutCustomIconSize, threshold)
            }
            return size
        }
    } // Image

    PlasmaComponents.Label {
        id: compactOctoStateLine
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        Layout.alignment: Qt.AlignHCenter
        font.capitalization: Font.Capitalize
        text: {
            var state = "";
            if(isStateBucketNameShown()) state += main.octoState
            if (main.jobInProgress && plasmoid.configuration.compactLayoutPercentageEnabled) {
                if (state != '') state += ' '
                state += `${main.jobCompletion}%`
            }
            return state;
        }
        visible: plasmoid.configuration.compactLayoutStateTextLineEnabled && compactOctoStateLine.text != ''
    }

    PlasmaComponents.ProgressBar {
        visible: {
            return plasmoid.formFactor == PlasmaCore.Types.Vertical
                && plasmoid.configuration.compactLayoutVerticalProgressBarEnabled && main.jobInProgress
        }
        Layout.maximumWidth: compactContainer.width
        height: 4
        value: main.jobCompletion/100
    }

    PlasmaComponents.Label {
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        Layout.alignment: Qt.AlignHCenter
        font.capitalization: Font.Capitalize
        text: i18n('Elapsed') + ': ' + main.jobPrintTime
        visible: main.jobInProgress && plasmoid.configuration.compactLayoutShowPrintTime && main.jobPrintTime != ''
    }

    PlasmaComponents.Label {
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        Layout.alignment: Qt.AlignHCenter
        font.capitalization: Font.Capitalize
        text: i18n('Left') + ': ' + main.jobPrintTimeLeft
        visible: main.jobInProgress && plasmoid.configuration.compactLayoutShowPrintTimeLeft && main.jobPrintTimeLeft != ''
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
