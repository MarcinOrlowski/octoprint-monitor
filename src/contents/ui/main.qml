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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import "../js/utils.js" as Utils
import "../js/version.js" as Version

Item {
    id: main

    // Debug switch to mimic API access using hardcded JSONs
    readonly property bool fakeApiAccess: false

    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}

    // ------------------------------------------------------------------------------------------------------------------------

    property string plasmoidTitle: ''
    readonly property string plasmoidVersion: Version.version
    readonly property string plasmoidUrl: 'https://github.com/marcinorlowski/octoprint-monitor'

    Component.onCompleted: {
        plasmoidTitle = Plasmoid.title
        plasmoid.setAction("showAboutDialog", i18n('About ') + plasmoidTitle + '…');
    }

    // ------------------------------------------------------------------------------------------------------------------------

    // Printer state flags
    property bool pf_cancelling: false		// working
    property bool pf_closedOrError: false	// error
    property bool pf_error: false			// error
    property bool pf_finishing: false		// working
    property bool pf_operational: false		// idle
    property bool pf_paused: false			// paused
    property bool pf_pausing: false			// working
    property bool pf_printing: false		// working
    property bool pf_ready: false			// idle
    property bool pf_resuming: false		// working

    // printer state
    property string printer_state: ""

    // Bed temperature
    property double p_bed_actual: 0
    property double p_bed_offset: 0
    property double p_bed_target: 0

    // Hotend temperature
    property double extruder0TemperatureActual: 0
    property double extruder0TemperatureOffset: 0
    property double extruder0TemperatureTarget: 0

    // True if printer is connected to OctoPrint
    property bool printerConnected: false

    // ------------------------------------------------------------------------------------------------------------------------

    // Job related stats (if any in progress)
    property string jobState: "N/A"
    property string previousJobState: "N/A"
    property string jobStateDescription: ""
    property string jobFileName: ""
    property double jobCompletion: 0
    property double previousJobCompletion: 0

    property string jobPrintTime: ""
	property string jobPrintStartStamp: ""
	property string jobPrintTimeLeft: ""

    // Indicates if print job is currently in progress.
	property bool jobInProgress: false

    // ------------------------------------------------------------------------------------------------------------------------

    // Indicates we were able to successfuly connect to OctoPrint API
    property bool apiConnected: false

    // Tells if plasmoid API access is already confugred.
    property bool apiAccessConfigured: false;

    // ------------------------------------------------------------------------------------------------------------------------

    property bool firstApiRequest: true

    /*
    ** State fetching timer. We fetch printer state first and job state only
    ** if there's any ongoing.
    */
	Timer {
		id: mainTimer

        interval: plasmoid.configuration.statusPollInterval * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            getPrinterStateFromApi();

            // First time we need to fire both requests unconditionally, otherwise
            // job state request will neede to wait for another timer trigger, causing
            // odd delay in widget update.
            if (main.firstApiRequest) {
                main.firstApiRequest = false;
                getJobStateFromApi();
            } else {
                // Do not query Job state if we can tell there's no running job
                var buckets = [ main.bucket_error, main.bucket_idle, main.bucket_disconnected ];
                if (buckets.includes(getPrinterStateBucket()) === false) {
                    getJobStateFromApi()
                }
            }
        }
	}

	NotificationManager {
	    id: notificationManager
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: {
            var stdout = data["stdout"]

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd, onNewDataCallback) {
            if (onNewDataCallback !== undefined){
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)
    }

    // ------------------------------------------------------------------------------------------------------------------------

    // Printer status buckets
    readonly property string bucket_unknown: "unknown"
    readonly property string bucket_working: "working"
    readonly property string bucket_cancelling: "cancelling"
    readonly property string bucket_paused: "paused"
    readonly property string bucket_error: "error"
    readonly property string bucket_idle: "idle"
    readonly property string bucket_disconnected: "disconnected"
    readonly property string bucket_connecting: "connecting"

    /*
    ** Returns name of printer state's bucket.
    **
    ** Returns:
    **	string: printer state bucket
    */
    function getPrinterStateBucket() {
        var bucket = undefined;

        if ( main.pf_finishing || main.pf_printing || main.pf_pausing ) {
            bucket = main.bucket_working
        } else if ( main.pf_cancelling ) {
            bucket = main.bucket_cancelling
        } else if ( main.pf_closedOrError || main.pf_error ) {
            bucket = main.bucket_error
        } else if ( main.pf_operational || main.pf_ready ) {
            bucket = main.bucket_idle
        } else if ( main.pf_paused ) {
            bucket = main.bucket_paused;
        }

        if (bucket == undefined) {
            bucket = main.bucket_disconnected
        }

        return bucket;
    }

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
            case bucket_unknown:
                if (plasmoid.configuration.printerStateNameForBucketUnknownEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketUnknown
                break
            case bucket_working:
                if (plasmoid.configuration.printerStateNameForBucketWorkingEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketWorking
                break
            case bucket_cancelling:
                if (plasmoid.configuration.printerStateNameForBucketCancellingEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketCancelling
                break
            case bucket_paused:
                if (plasmoid.configuration.printerStateNameForBucketPausedEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketPaused
                break
            case bucket_error:
                if (plasmoid.configuration.printerStateNameForBucketErrorEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketError
                break
            case bucket_idle:
                if (plasmoid.configuration.printerStateNameForBucketIdleEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketIdle
                break
            case bucket_disconnected:
                if (plasmoid.configuration.printerStateNameForBucketDisconnectedEnabled)
                    name = plasmoid.configuration.printerStateNameForBucketDisconnected
                break
        }

        return name != '' ? name : bucket
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Checks if current printer status flags indicate there's actually print in progress.
    **
    ** Returns:
    **	bool
    */
    function isJobInProgress() {
        var result = main.pf_printing || main.pf_paused || main.pf_resuming;
        return result;
    }

    /*
    ** Checks if current printer status flags indicate device is offline or not.
    **
    ** Returns:
    **	bool
    */
    function isPrinterConnected() {
        return  main.pf_cancelling
             || main.pf_error
             || main.pf_finishing
             || main.pf_operational
             || main.pf_paused
             || main.pf_pausing
             || main.pf_printing
             || main.pf_ready
             || main.pf_resuming
//           || main.pf_closedOrError
        ;
    }

    // ------------------------------------------------------------------------------------------------------------------------

    property string octoState: bucket_connecting
    property string octoStateBucket: bucket_connecting
    property string octoStateBucketName: bucket_connecting
    // FIXME we should have SVG icons here
    property string octoStateIcon: plasmoid.file("", "images/state-unknown.png")
    property string octoStateDescription: 'Connecting to OctoPrint API.'
    property string lastOctoStateChangeStamp: ""

    property string previousOctoState: ""
    property string previousOctoStateBucket: ""

    function updateOctoStateDescription() {
        var desc = main.jobStateDescription;
        if (desc == '') {
            switch(main.octoStateBucket) {
                case bucket_unknown: desc = 'Unable to determine root cause.'; break;
                case bucket_paused: desc = 'Print job is PAUSED now.'; break;
                case bucket_idle: desc = 'Printer is operational and idle.'; break;
                case bucket_disconnected: desc = 'OctoPrint is not connected to the printer.'; break;
                case bucket_cancelling: desc = 'OctoPrint is cancelling current job.'; break;
//              case bucket_working: ""
//              case bucket_error: "error"
                case 'unavailable': desc = 'Unable to connect to OctoPrint API.'; break;
                case bucket_connecting: desc = 'Connecting to OctoPrint API.'; break;

                case 'configuration': desc = 'Widget is not configured!'; break;
            }
        }

        main.octoStateDescription = desc;
    }

    /*
    ** Constructs and posts desktop notification reflecting curent state.
    ** NOTE: This method must be called AFTER the state changed as it uses
    ** octoStateBucket and previousOctoStateBuckets for its logic
    **
    ** Returns:
    **  void
    */
    function postNotification() {
        var current = main.octoStateBucket
        var previous = main.previousOctoStateBucket
        var post = false
        var expireTimeout = 0
        var summary = ''
        var body = ''

        if (!plasmoid.configuration.notificationsEnabled) return

        var body = main.octoStateDescription
        if (current != previous) {
            // switching back from "Working"
            if (!post && (previous == bucket_working)) {
                post = true
                switch (current) {
                    case bucket_cancelling:
                        summary = `Cancelling job '${main.jobFileName}'.`
                        break;

                    case bucket_paused:
                        summary = `Print job '${main.jobFileName}' paused.`
                        break

                    default:
                        if (main.jobCompletion == 100) {
                            summary = `Print '${main.jobFileName}' completed.`
                            expireTimeout = plasmoid.configuration.notificationsTimeoutBucketPrintJobSuccessful
                        } else {
                            summary = 'Print stopped.'
                            expireTimeout = plasmoid.configuration.notificationsTimeoutBucketPrintJobFailed
                            var percentage = main.jobCompletion > 0 ? main.jobCompletion : main.previousJobCompletion
                            if (percentage > 0) {
                                body = `File '${main.jobFileName}' stopped at ${percentage}%.`
                            } else {
                               body = `File '${main.jobFileName}'.`
                            }
                        }
                        if (main.jobPrintTime != '') {
                            if (body != '') body += ' '
                            body += `Print time ${main.jobPrintTime}.`
                        }
                        break
                }
            }

            // switching from anything (but connecting) to bucket "Working"
            if (!post && (current == bucket_working) && (previous != bucket_connecting)) {
                post = true
                expireTimeout = plasmoid.configuration.notificationsTimeoutPrintJobStarted
                summary = 'Printing started.'
                body = `File '${main.jobFileName}'.`
                if (main.jobPrintTimeLeft != '') {
                    body += ` Est. print time ${main.jobPrintTimeLeft}.`
                }
            }
        }

//        console.debug(`post: ${post}, state: ${previous}=>${current}, timeout: ${expireTimeout}, body: "${body}"`)
        if (post) {
            var title = main.plasmoidTitle
            // there's system timer shown (xx ago) shown for non expiring notifications
            if (expireTimeout == 0) {
                title += ' ' + new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
            }
            if (summary == '') {
                summary = "Printer new state: '" + Utils.ucfirst(main.octoState) + "'."
            }
            notificationManager.post({
                'title': title,
                'icon': main.octoStateIcon,
                'summary': summary,
                'body': body,
                'expireTimeout': expireTimeout * 1000,
            });
        }
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

        var jobInProgress = false
        var printerConnected = isPrinterConnected()
        var currentStateBucket = getPrinterStateBucket()
        var currentStateBucketName = getPrinterStateBucketName(currentStateBucket);
        var currentState = currentStateBucketName

        main.apiAccessConfigured = (plasmoid.configuration.api_url != '' && plasmoid.configuration.api_key != '')

        if (main.apiConnected) {
            jobInProgress = isJobInProgress()
            if (jobInProgress && main.jobState == "printing") currentState = main.jobState
        } else {
            currentState = (!main.apiAccessConfigured) ? 'configuration' : 'unavailable'
        }

        main.jobInProgress = jobInProgress
        main.printerConnected = printerConnected

//        console.debug(`currentState: ${currentState}, previous: ${main.previousOctoState}`);
        if (currentState != main.previousOctoState) {
            main.previousOctoState = main.octoState
            main.previousOctoStateBucket = main.octoStateBucket

            main.octoState = currentState
            main.octoStateBucket = currentStateBucket
            main.octoStateBucketName = currentStateBucketName
            updateOctoStateDescription()

            main.lastOctoStateChangeStamp = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
            main.octoStateIcon = getOctoStateIcon()

            postNotification()
        }
    }

	/*
	** Returns path to icon representing current Octo state (based on
	** printer state bucket)
	**
	** Returns:
	**	string: path to plasmoid's icon file
	*/
	function getOctoStateIcon() {
   	    var bucket = 'dead'
	    if (!main.apiAccessConfigured) {
	        bucket = 'configuration'
	    } else if (main.apiConnected) {
            bucket = getPrinterStateBucket()
        }

        return plasmoid.file("", `images/state-${bucket}.png`)
	}

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Returns instance of XMLHttpRequest, configured for OctoPrint doing Api request.
    ** Throws Error if API URL or access key is not configured.
    **
    ** Returns:
    **  Configured instance of XMLHttpRequest.
    */
    function getXhr(req) {
        var apiUrl = plasmoid.configuration.api_url
        var apiKey = plasmoid.configuration.api_key

		if ( apiUrl + apiKey == "" ) return null;

        var xhr = new XMLHttpRequest()
        var url = `${apiUrl}/${req}`
        xhr.open('GET', url)
        xhr.setRequestHeader("Host", apiUrl)
        xhr.setRequestHeader("X-Api-Key", apiKey)

        return xhr
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests job status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
	function getJobStateFromApi() {
	    if (!main.fakeApiAccess) {
	        getJobStateFromApiReal()
        } else {
            getJobStateFromApiFake()
        }
	}

    function getJobStateFromApiFake() {
        main.apiConnected = true
        var json='{"job":{"averagePrintTime":null,"estimatedPrintTime":19637.457560140414,"filament":{"tool0":{"length":9744.308959960938,"volume":68.87846124657558}},"file":{"date":1607166777,"display":"deercraft-stick.gcode","name":"deercraft-stick.gcode","origin":"local","path":"deercraft-stick.gcode","size":17025823},"lastPrintTime":null,"user":"_api"},"progress":{"completion":15.966200282946675,"filepos":2718377,"printTime":2582,"printTimeLeft":16499,"printTimeLeftOrigin":"genius"},"state":"Printing"}'
        parseJobStatusResponse(JSON.parse(json))
        updateOctoState()
    }

	function getJobStateFromApiReal() {
	    var xhr = getXhr('job')

        if (xhr === null) {
            updateOctoState()
            return
        }

        xhr.onreadystatechange = (function () {
            // We only care about DONE readyState.
            if (xhr.readyState !== 4) return

            // Ensure we managed to talk to the API
            main.apiConnected = (xhr.status !== 0)

            if (xhr.status === 200) {
//                console.debug(`ResponseText: "${xhr.responseText}"`)
                try {
                    parseJobStatusResponse(JSON.parse(xhr.responseText))
                } catch (error) {
                    console.debug('Error handling API job state response.')
                    console.debug(error)
                }
                updateOctoState()
            } else {
                console.debug(`Unexpected job response status code (${xhr.status}).`)
            }
        });
        xhr.send()
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

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests printer status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
    function getPrinterStateFromApi() {
        if (!main.fakeApiAccess) {
            getPrinterStateFromApiReal()
        } else {
            getPrinterStateFromApiFake()
        }
    }

    function getPrinterStateFromApiFake() {
        var json = '{"state":{"flags":{"cancelling":false,"closedOrError":false,"error":false,"finishing":false,"operational":true,"paused":false,"pausing":false,"printing":true,"ready":false,"resuming":false,"sdReady":false},"text":"Printing"},"temperature":{"bed":{"actual":65.0,"offset":0,"target":65.0},"tool0":{"actual":200.0,"offset":0,"target":200.0}}}';
        parsePrinterStateResponse(JSON.parse(json))
        updateOctoState();
    }

    function getPrinterStateFromApiReal() {
        var xhr = getXhr('printer')

        if (xhr === null) {
            updateOctoState()
            return
        }

        xhr.onreadystatechange = (function () {
            // We only care about DONE readyState.
            if (xhr.readyState !== 4) return

            // Ensure we managed to talk to the API
            main.apiConnected = (xhr.status !== 0)

            switch (xhr.status) {
                case 200:
//                  console.debug(`ResponseText: "'${xhr.responseText}'"`)
                    try {
                        parsePrinterStateResponse(JSON.parse(xhr.responseText))
                    } catch (error) {
                        setPrinterFlags(false)
                        main.pf_error = true
                    }
                    break
                case 409:
                    // Printer is not operational
                    setPrinterFlags(false)
                    break
                default:
                    console.debug(`Unexpected printer response status code (${xhr.status}).`)
                    main.pf_error = true
                    break
            }
            updateOctoState();
        });
        xhr.send()
    }

    /**
    ** Sets pf_* flags to given bool value. Just for DRY.
    **
    ** Arguments:
    **  state: true/false to set all flags to.
    **
    ** Returns:
    **  void
    */
    function setPrinterFlags(state) {
        main.pf_cancelling = state
        main.pf_closedOrError = state
        main.pf_finishing = state
        main.pf_operational = state
        main.pf_paused = state
        main.pf_pausing = state
        main.pf_printing = state
        main.pf_ready = state
        main.pf_resuming = state
        main.pf_error = state
    }

	/*
	** Parses printer status JSON response object.
	**
	** Arguments:
	**	resp: response JSON object
	**
	** Returns:
	**	void
	*/
	function parsePrinterStateResponse(resp) {
		main.pf_cancelling = resp.state.flags.cancelling
		main.pf_closedOrError = resp.state.flags.closedOrError
		main.pf_error = resp.state.flags.error
		main.pf_finishing = resp.state.flags.finishing
		main.pf_operational = resp.state.flags.operational
		main.pf_paused = resp.state.flags.paused
		main.pf_pausing = resp.state.flags.pausing
		main.pf_printing = resp.state.flags.printing
		main.pf_ready = resp.state.flags.ready
		main.pf_resuming = resp.state.flags.resuming

		// Textural representation of printer state as returned by API
		main.printer_state = resp.state.text

		// temepratures
		main.p_bed_actual = Utils.getFloat(resp.temperature.bed.actual)
		main.p_bed_offset = Utils.getFloat(resp.temperature.bed.offset)
		main.p_bed_target = Utils.getFloat(resp.temperature.bed.target)

		// hot-ends
		// FIXME: check for more than one
		main.extruder0TemperatureActual = Utils.getFloat(resp.temperature.tool0.actual)
		main.extruder0TemperatureOffset = Utils.getFloat(resp.temperature.tool0.offset)
		main.extruder0TemperatureTarget = Utils.getFloat(resp.temperature.tool0.target)
	}

    // ------------------------------------------------------------------------------------------------------------------------

    UpdateChecker {
        id: updateChecker
        plasmoidUMetaDataUrl: 'https://raw.githubusercontent.com/MarcinOrlowski/octoprint-monitor/master/src/metadata.desktop'
        plasmoidTitle: main.plasmoidTitle
        plasmoidVersion: main.plasmoidVersion
    }

    // ------------------------------------------------------------------------------------------------------------------------

    function action_showAboutDialog() {
        aboutDialog.visible = true
    }

    AboutDialog {
        id: aboutDialog
        plasmoidTitle: main.plasmoidTitle
        plasmoidVersion: main.plasmoidVersion
    }

    // ------------------------------------------------------------------------------------------------------------------------

}
