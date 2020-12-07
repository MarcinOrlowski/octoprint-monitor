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

    /*
    ** Handles XmlHtmlREquest object with API response
    **
    ** Returns:
    **  bool: true if handled xhr object successfuly, false otherwise.
    */
    function handle(xhr) {
        // We only care about DONE readyState and HTTP OK 200
        if (xhr.readyState !== 4) return

        try {
            var state = Qt.createComponent("PrinterState.qml").createObject(null)
            state.fromXhr(xhr)

            // check HASH and add if different

            this.states.unshift(state)
            this.current = state

            if (this.states.length > 3) this.states.pop()

            return true
        } catch (error) {
            console.debug(error)
        }

        return false
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
