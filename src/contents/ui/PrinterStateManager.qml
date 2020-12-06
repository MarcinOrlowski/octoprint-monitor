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

    // ------------------------------------------------------------------------------------------------------------------------

    function handle(xhr) {
        // We only care about DONE readyState and HTTP OK 200
        if (xhr.readyState !== 4) return

        if (xhr.status !== 200) {
            console.debug(`Unexpected job response status code (${xhr.status}).`)
            return
        }

        var state = Qt.createComponent("PrinterState.qml").createObject(null)
        state.fromXhr(xhr)

        // check HASH and add if different

        this.states.unshift(states)
        this.current = state

        if (this.states.length > 3) this.states.pop()
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
