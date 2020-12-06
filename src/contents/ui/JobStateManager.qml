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
    property var current: JobState
    property var states: []

    // ------------------------------------------------------------------------------------------------------------------------

    function handle(xhr) {
        var state = Qt.createComponent("JobState.qml").createObject(null)
        state.fromXhr(xhr)

        // check HASH and add if different from last one
        if (state.jobState != current.jobState) {
            this.states.unshift(states)
            this.current = state
        }

        if (this.states.length > 3) this.states.pop()
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
