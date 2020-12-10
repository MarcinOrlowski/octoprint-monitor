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

QtObject {
    property bool enabled: false

    property bool layoutOverlaysEnabled: enabled && layoutOverlaysEnabledFlag
    property bool layoutOverlaysEnabledFlag: false

    property bool fakeApiCalls: enabled && fakeApiCallsFlag
    property bool fakeApiCallsFlag: false

    property bool logsEnabled: enabled && logsEnabledFlag
    property bool logsEnabledFlag: false

    function log(msg) {
        if (logsEnabled) console.debug(msg)
    }
    function time(msg) {
        if (logsEnabled) console.time(msg)
    }
    function timeEnd(msg) {
        if (logsEnabled) console.timeEnd(msg)
    }

}

