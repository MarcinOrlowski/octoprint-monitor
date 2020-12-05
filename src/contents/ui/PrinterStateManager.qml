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
    property var current: PrinterState
    property var states: []

//    Component.onCompleted: {
//        states.push(new PrinterState())
//    }

    function update(xhr) {
        var state = Qt.createComponent("PrinterState.qml").createObject(null)
        state.parseXhr(xhr)

        // check HASH and add if different

        states.unshift(current)
        current = state

        if (states.length > 3) states.pop()
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
