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
import "../js/utils.js" as Utils

QtObject {
    property var json: null

    // ------------------------------------------------------------------------------------------------------------------------

    property string state: ''
    property string stateDescription: ''

    property string fileName: ''
    property double completion: 0.0

    property int    printTimeSeconds: 0
	property int    printTimeLeftSeconds: 0

    // ------------------------------------------------------------------------------------------------------------------------

    function fromXhr(xhr) {
        // We only care about DONE readyState.
        if (xhr.readyState !== 4) return

        if (xhr.status === 200) {
            try {
                this.fromJson(JSON.parse(xhr.responseText))
            } catch (error) {
//                console.debug(`ResponseText: "${xhr.responseText}"`)
                console.debug('Error handling API job state response.')
                console.debug(error)
            }
        } else {
            console.debug(`Unexpected job response status code (${xhr.status}).`)
        }
    }

    /*
    ** Parses printing job status JSON response object.
    **
    ** Arguments:
    **	json: response JSON object
    **
    ** Returns:
    **	void
    */
    function fromJson(json) {
        this.json = json

        this.state = json.state.split(/[ ,]+/)[0].toLowerCase()
        var stateSplit = json.state.match(/\w+\s+\((.*)\)/)
        this.stateDescription = (stateSplit !== null) ? stateSplit[1] : ''

        this.fileName = Utils.getString(json.job.file.display)
        this.completion = Utils.getFloat(Utils.roundFloat(json.progress.completion))
        this.printTimeSeconds = Utils.getInt(json.progress.printTime)
        this.printTimeLeftSeconds = Utils.getInt(json.progress.printTimeLeft)
    }

    // ------------------------------------------------------------------------------------------------------------------------
}
