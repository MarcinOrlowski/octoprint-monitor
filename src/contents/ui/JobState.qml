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
    property string json: ''

    /*
    ** Parses printing job status JSON response object.
    **
    ** Arguments:
    **	resp: response JSON object
    **
    ** Returns:
    **	void
    */
    function parseJobStatusResponse(resp) {
        var state = resp.state.split(/[ ,]+/)[0]

        if (state != main.jobState) {
            main.previousJobState = main.jobState
            main.jobState = state.toLowerCase()

            var stateSplit = resp.state.match(/\w+\s+\((.*)\)/)
            main.jobStateDescription = (stateSplit !== null) ? stateSplit[1] : ''
            updateOctoStateDescription()
        }

        main.jobFileName = Utils.getString(resp.job.file.display)

        var jobCompletion = Utils.isVal(resp.progress.completion) ? Utils.roundFloat(resp.progress.completion) : 0
        if (jobCompletion != main.jobCompletion) {
            main.previousJobCompletion = main.jobCompletion
            main.jobCompletion = jobCompletion
        }

        var jobPrintTime = resp.progress.printTime
        main.jobPrintTime = Utils.isVal(jobPrintTime) ? Utils.secondsToString(jobPrintTime) : ''

        var printTimeLeft = resp.progress.printTimeLeft
        main.jobPrintTimeLeft = Utils.isVal(printTimeLeft) ? Utils.secondsToString(printTimeLeft) : ''
    }

}
