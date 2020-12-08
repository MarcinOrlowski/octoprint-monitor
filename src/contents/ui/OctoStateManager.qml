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
import "./PrinterStateBucket.js" as Bucket

QtObject {
    property var current: OctoState
	property string lastOctoStateChangeStamp: ''

    property var states: []

    property var job: JobStateManager {}
    property var printer: PrinterStateManager {}

    // ------------------------------------------------------------------------------------------------------------------------

    property string octoState: ''
    property string octoStateDescription: ''
    property string octoStateBucket: ''
    property string octoStateBucketName: ''
    property string octoStateIcon: plasmoid.file("", `images/state-dead.png`)

    // Indicates if print job is currently in progress.
	property bool jobInProgress: false

    property string jobFileName: ''
    property double jobCompletion: 0
    property string jobStateDescription: ''
    property int jobPrintTimeSeconds: 0
    property int jobPrintTimeLeftSeconds: 0

    // ------------------------------------------------------------------------------------------------------------------------

    // Tells if plasmoid API access is already confugred.
    property bool apiAccessConfigured: false

    property bool apiConnected: false

	property bool printerConnected: false

    // ------------------------------------------------------------------------------------------------------------------------

    function handleJobState(xhr) {
        // We only care about DONE readyState.
        if (xhr.readyState !== 4) return

        // Ensure we managed to talk to the API
        this.apiConnected = (xhr.status !== 0)

        if (job.handle(xhr)) {
            this.updateOctoState()
        }
    }

    function handlePrinterState(xhr) {
        // We only care about DONE readyState.
        if (xhr.readyState !== 4) return

        // Ensure we managed to talk to the API
        this.apiConnected = (xhr.status !== 0)

        if (printer.handle(xhr)) {
            this.updateOctoState()
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------

	/*
	** Returns path to icon representing current Octo state (based on
	** printer state bucket)
	**
	** Returns:
	**	string: path to plasmoid's icon file
	*/
	function getOctoStateIcon() {
   	    var bucket = 'dead'
	    if (!this.apiAccessConfigured) {
	        bucket = 'configuration'
	    } else if (this.apiConnected) {
            bucket = osm.octoStateBucket
        }

        return plasmoid.file("", `images/state-${bucket}.png`)
	}


    /*
    ** Calculates current octoState. Updates internal data if state changes.
    **
    ** Returns:
    **  void
    */
    function updateOctoState() {
        // calculate new octoState. If different from previous one, check what happened
        // (i.e. was printing is idle) -> print successful
        var newState = Qt.createComponent("OctoState.qml").createObject(null)

        if (!(printer.current instanceof PrinterState)) return
        if (!(job.current instanceof JobState)) return

        newState.printer = printer.current
        newState.job = job.current

        var currentStateBucket = newState.printer.getPrinterStateBucket()
        var currentStateBucketName = this.getPrinterStateBucketName(currentStateBucket)
        var currentState = currentStateBucketName

        this.apiAccessConfigured = (plasmoid.configuration.api_url != '' && plasmoid.configuration.api_key != '')

        var jobInProgress = false
        if (this.apiConnected) {
            jobInProgress = newState.printer.isJobInProgress()
//            if (jobInProgress && this.jobState == 'printing') currentState = newState.job.state
            if (jobInProgress && newState.job.state == 'printing') currentState = newState.job.state
        } else {
            currentState = (!this.apiAccessConfigured) ? 'configuration' : 'unavailable'
        }

        this.jobInProgress = jobInProgress
        this.printerConnected = newState.printer.isPrinterConnected()


        newState.icon = osm.getOctoStateIcon()
        newState.state = currentState
        newState.stateBucket = currentStateBucket
        newState.stateBucketName = currentStateBucketName

        updateOctoStateDescription()

        newState.jobFileName = job.current.fileName
        newState.jobCompletion = job.current.completion
        newState.jobPrintTimeSeconds = job.current.printTimeSeconds
        newState.jobPrintTimeLeftSeconds = job.current.printTimeLeftSeconds

        this.states.unshift(newState)
        if (this.states.length > 3) this.states.pop()

        this.lastOctoStateChangeStamp = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
        this.current = newState

        exposeCurrentState()

        // do not announce the same state over and over again. We need this check as we still keep
        // recording state changes (i.e. for progress and timers)
        if ((this.states.length == 1) || (current.state != this.states[1].state)) {
            postNotification()
        }
    }

    function exposeCurrentState() {
        this.octoState = current.state
        this.octoStateBucket = current.stateBucket
        this.octoStateBucketName = current.stateBucketName
        this.octoStateIcon = current.icon

        this.jobFileName = current.jobFileName
        this.jobCompletion = current.jobCompletion
        this.jobPrintTimeSeconds = current.jobPrintTimeSeconds
        this.jobPrintTimeLeftSeconds = current.jobPrintTimeLeftSeconds
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Returns name of given state bucket. Checks if custom name for that bucket
    ** is enabled and uses if it's not empty string. In other cases returns
    ** generic bucket name.
    **
    ** Returns
    **  string: printer bucket name
    */
    function getPrinterStateBucketName(bucket) {
        var name = ''
        switch(bucket) {
            case Bucket.unknown:
                if (plasmoid.configuration.printerStateNameForBucketUnknownEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketUnknown
                break
            case Bucket.working:
                if (plasmoid.configuration.printerStateNameForBucketWorkingEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketWorking
                break
            case Bucket.cancelling:
                if (plasmoid.configuration.printerStateNameForBucketCancellingEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketCancelling
                break
            case Bucket.paused:
                if (plasmoid.configuration.printerStateNameForBucketPausedEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketPaused
                break
            case Bucket.error:
                if (plasmoid.configuration.printerStateNameForBucketErrorEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketError
                break
            case Bucket.idle:
                if (plasmoid.configuration.printerStateNameForBucketIdleEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketIdle
                break
            case Bucket.disconnected:
                if (plasmoid.configuration.printerStateNameForBucketDisconnectedEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketDisconnected
                break
        }

        return name != '' ? name : bucket
    }

    function updateOctoStateDescription() {
        var desc = this.jobStateDescription
        if (desc == '') {
            switch(this.octoStateBucket) {
                case Bucket.unknown: desc = 'Unable to determine root cause.'; break;
                case Bucket.paused: desc = 'Print job is PAUSED now.'; break;
                case Bucket.idle: desc = 'Printer is operational and idle.'; break;
                case Bucket.disconnected: desc = 'OctoPrint is not connected to the printer.'; break;
                case Bucket.cancelling: desc = 'OctoPrint is cancelling current job.'; break;
//              case Bucket.working: ""
//              case Bucket.error: "error"
                case 'unavailable': desc = 'Unable to connect to OctoPrint API.'; break;
                case Bucket.connecting: desc = 'Connecting to OctoPrint API.'; break;

                case 'configuration': desc = 'Widget is not configured!'; break;
            }
        }
        this.octoStateDescription = desc
    }

    // ------------------------------------------------------------------------------------------------------------------------

    function tick() {
        if (this.jobPrintTimeSeconds != 0) this.jobPrintTimeSeconds++
        if (this.jobPrintTimeLeftSeconds != 0) this.jobPrintTimeLeftSeconds--
//        console.debug(`tick(): printTime ${this.jobPrintTimeSeconds} ` + Utils.secondsToString(this.jobPrintTimeSeconds)
//            + `, TimeLeft: ${jobPrintTimeLeftSeconds} ` + Utils.secondsToString(jobPrintTimeLeftSeconds))
    }

    // ------------------------------------------------------------------------------------------------------------------------

}
