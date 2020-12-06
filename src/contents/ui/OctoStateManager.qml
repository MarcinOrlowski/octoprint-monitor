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
import "./PrinterStateBucket.js" as Bucket

QtObject {
    property var current: OctoState
    property var states: []
    property var job: JobStateManager {}
    property var printer: PrinterStateManager {}

    // ------------------------------------------------------------------------------------------------------------------------

    property string octoState: 'N/A'
    property string octoStateDescription: ''
    property string octoStateBucket: ''
    property string octoStateBucketName: ''
    property string octoStateIcon: ''

	property string lastOctoStateChangeStamp: ''

    // Indicates if print job is currently in progress.
	property bool jobInProgress: false

    property string jobFileName: ''
    property double jobCompletion: 0
    property string jobStateDescription: ""
    property string jobPrintTime: ""
	property string jobPrintStartStamp: ""
	property string jobPrintTimeLeft: ""

    // ------------------------------------------------------------------------------------------------------------------------

    // Tells if plasmoid API access is already confugred.
    property bool apiAccessConfigured: false;

    property bool apiConnected: false;

	property bool printerConnected: false

    // ------------------------------------------------------------------------------------------------------------------------

    function handleJobState(xhr) {
        // We only care about DONE readyState.
        if (xhr.readyState !== 4) return

        // Ensure we managed to talk to the API
        this.apiConnected = (xhr.status !== 0)

        job.handle(xhr)
        this.updateOctoState()
    }

    function handlePrinterState(xhr) {
        // We only care about DONE readyState.
        if (xhr.readyState !== 4) return

        // Ensure we managed to talk to the API
        this.apiConnected = (xhr.status !== 0)

        printer.handle(xhr)
        this.updateOctoState()
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Returns name of printer state's bucket.
    **
    ** Returns:
    **	string: printer state bucket
    */
    function getPrinterStateBucket() {
        return printer.current.getPrinterStateBucket()
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
            bucket = osm.getPrinterStateBucket()
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
        var state = Qt.createComponent("OctoState.qml").createObject(null)

        var jobInProgress = false
        var currentStateBucket = this.getPrinterStateBucket()
        var currentStateBucketName = this.getPrinterStateBucketName(currentStateBucket);
        var currentState = currentStateBucketName

        this.apiAccessConfigured = (plasmoid.configuration.api_url != '' && plasmoid.configuration.api_key != '')

        if (this.apiConnected) {
            jobInProgress = printer.current.isJobInProgress()
            if (jobInProgress && this.jobState == 'printing') currentState = job.current.jobState
        } else {
            currentState = (!this.apiAccessConfigured) ? 'configuration' : 'unavailable'
        }

        this.jobInProgress = jobInProgress
        this.printerConnected = printer.current.isPrinterConnected()

//        console.debug(`currentState: ${currentState}, previous: ${this.previousOctoState}`);
        if (currentState != this.previousOctoState) {
            state.icon = osm.getOctoStateIcon()
            state.state = currentState
            state.stateBucket = currentStateBucket
            state.stateBucketName = currentStateBucketName

            this.lastOctoStateChangeStamp = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)

            this.states.unshift(states)
            this.current = state

            updateOctoStateDescription()
            exposeCurrentState()


//            postNotification()
        }
    }

    function exposeCurrentState() {
        this.octoState = current.state
        this.octoStateBucket = current.stateBucket
        this.octoStateBucketName = current.stateBucketName
        this.octoStateIcon = current.icon

        this.jobFileName = job.current.jobFileName
        this.jobCompletion = job.current.jobCompletion
        this.jobPrintTime = job.current.jobPrintTime
        this.jobPrintTimeLeft = job.current.jobPrintTimeLeft
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
        var desc = this.jobStateDescription;
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
        this.octoStateDescription = desc;
    }

    // ------------------------------------------------------------------------------------------------------------------------

}
