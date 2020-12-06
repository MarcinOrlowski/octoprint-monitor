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
    property var json: ''

    // ------------------------------------------------------------------------------------------------------------------------

    // Job related stats (if any in progress)
    property string jobState: "N/A"
//    property string previousJobState: "N/A"
    property string jobStateDescription: ""
    property string jobFileName: ""
    property double jobCompletion: 0
//    property double previousJobCompletion: 0

    property string jobPrintTime: ""
	property string jobPrintStartStamp: ""
	property string jobPrintTimeLeft: ""

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
    **	resp: response JSON object
    **
    ** Returns:
    **	void
    */
    function fromJson(resp) {
        this.json = resp

        var state = resp.state.split(/[ ,]+/)[0]
        this.jobState = state.toLowerCase()

        var stateSplit = resp.state.match(/\w+\s+\((.*)\)/)
        this.jobStateDescription = (stateSplit !== null) ? stateSplit[1] : ''

//        if (state != main.jobState) {
//            main.previousJobState = main.jobState
//            main.jobState = state.toLowerCase()

//            var stateSplit = resp.state.match(/\w+\s+\((.*)\)/)
//            main.jobStateDescription = (stateSplit !== null) ? stateSplit[1] : ''
//            updateOctoStateDescription()
//        }

        this.jobFileName = Utils.getString(resp.job.file.display)

        this.jobCompletion = Utils.isVal(resp.progress.completion) ? Utils.roundFloat(resp.progress.completion) : 0

//        var jobCompletion = Utils.isVal(resp.progress.completion) ? Utils.roundFloat(resp.progress.completion) : 0
//        if (jobCompletion != main.jobCompletion) {
//            main.previousJobCompletion = main.jobCompletion
//            main.jobCompletion = jobCompletion
//        }

        var jobPrintTime = resp.progress.printTime
        this.jobPrintTime = Utils.isVal(jobPrintTime) ? Utils.secondsToString(jobPrintTime) : ''

        var printTimeLeft = resp.progress.printTimeLeft
        this.jobPrintTimeLeft = Utils.isVal(printTimeLeft) ? Utils.secondsToString(printTimeLeft) : ''
    }

}
