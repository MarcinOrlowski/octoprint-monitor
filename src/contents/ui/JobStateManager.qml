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
    property var current: null
    property var states: []

    Component.onCompleted: {
        current = Qt.createComponent("JobState.qml").createObject(null)
    }

    // ------------------------------------------------------------------------------------------------------------------------

    function handle(xhr) {
        var newState = Qt.createComponent("JobState.qml").createObject(null)
        newState.fromXhr(xhr)

        // check HASH and add if different from last one
//        console.debug(`job handle: new: '${newState.state}', current '${current.state}'`)
        if (newState.state != current.state) {
            this.states.unshift(newState)
            this.current = newState
        }

        if (this.states.length > 3) this.states.pop()
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
