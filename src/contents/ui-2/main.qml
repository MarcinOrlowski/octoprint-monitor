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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import "../js/utils.js" as Util

Item {
    id: main

    width: units.gridUnit * 10
    height: units.gridUnit * 4

    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

    Plasmoid.compactRepresentation: CompactRepresentation {}
//    Plasmoid.fullRepresentation: FullRepresentation {}
//    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    // ------------------------------------------------------------------------------------------------------------------------

    property bool compactLayoutStateEnabled: plasmoid.configuration.compactLayoutStateEnabled
    property bool compactLayoutProgressEnabled: plasmoid.configuration.compactLayoutProgressEnabled
//    property bool compactLayoutVerticalTemperatureEnabled: plasmoid.configuration.compactLayoutVerticalTemperatureEnabled
    property bool compactLayoutcompactLayoutVerticalProgressBarEnabled: plasmoid.configuration.compactLayoutVerticalProgressBarEnabled

    // True if printer is actually printing
    property bool printingInProgress: false

    // This is small "hack". We keep the progress bar hidden unless first print is
    // started and then we never hide it again (as for now). This is intentional,
    // because when print is completed, state switches back to Idle and there's no
    // other indication that the printe was completed. So progress bar stays here
    // to remind user about that, unless we will have this done better.
    property bool showPrintingProgressBar: false

    // True if printer is connected to OctoPrint
    property bool printerConnected: false

    // Indicates we were able to successfuly connect to OctoPrint API
    property bool apiConnected: false

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
    property double p_he0_actual: 0
    property double p_he0_offset: 0
    property double p_he0_target: 0

    // ------------------------------------------------------------------------------------------------------------------------

	// This is generic combined state shown to the user
	property string octoState: "Connecting"
	property string octoStateDescription: ""
    // Combined state formatted for Compact representation
	property string compactOctoState: "Connecting"
    // Octo state icon
    property string octoStateIcon: plasmoid.file("", "icons/state-unknown.png")

    /*
    ** calculated Octo state, based on current printer and job states.
    **
    ** Returns:
    **  string: text representation of the state
    */
    function getOctoState() {
        var state = '';
        if (main.apiConnected) {
            if (main.job_state == "Printing") {
                state = main.job_state;
            } else {
                state = getPrinterStateBucket();
            }
        } else {
            state = 'unavailable';
        }
        return state;
    }

	/*
	** Returns path to icon representing current Octo state (based on
	** printer state bucket)
	**
	** Returns:
	**	string: path to plasmoid's icon file
	*/
	function getOctoStateIcon() {
	    var bucket = 'dead';
	    if (main.apiConnected) {
            bucket = getPrinterStateBucket();
        }
        return plasmoid.file("", "icons/state-" + bucket + ".png");
	}

    // ------------------------------------------------------------------------------------------------------------------------

    // Job related stats (if any in progress)
    property string job_state: "N/A"
    property string job_file_name: ""
    property double job_completion: 0
	property string job_completion_str: ""

    property string job_print_time_str: ""
	property string job_print_start_stamp_str: ""
	property string job_print_time_left_str: ""

    // ------------------------------------------------------------------------------------------------------------------------

    property bool firstApiRequest: true

    /*
    ** State fetching timer. We fetch printer state first and job state only
    ** if there's any ongoing.
    */
	Timer {
		id: statusTimer

        interval: plasmoid.configuration.status_poll_interval * 1000
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
                    getJobStateFromApi();
                }
            }
        }
	}

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Updates values of combined Octo state to reflect current printer/job state
	**
	** Returns:
	**	void
    */
	function updateOctoState() {
        var printInProgress = isPrintInProgress();
        var printerConnected = isPrinterConnected();

		main.printingInProgress = printInProgress;
		main.printerConnected = printerConnected;

		// Shows job state for while print is in progress, otherwise returns printer state.
		var state = getOctoState();
        // FIXME: some job states (can have more info returned)
		var stateDescription = "";
        if (main.apiConnected) {
            if (printInProgress) {
                main.showPrintingProgressBar = true;

                state = main.job_state;
                // FIXME hardcoded state string
                if (main.job_state == "Printing") {
                    state += ': ' + main.job_completion + '%';
                }
            }
		} else {
		    stateDescription = i18n("Failed connecting to OctoPrint API");
		}

		main.octoState = state;
		main.octoStateDescription = stateDescription;
		// FIXME :Icon is currently always based on printer state
		main.octoStateIcon = getOctoStateIcon();

		// Compact representation needs data formatted bit different though
		// FIXME do not call it if we know we display FullRepresentation
		updateCompactOctoState();
	}

    /*
    ** Update combied Octo state used by plasmoid in Compact form.
    ** Some fields are formatted slightly different to save space
    ** and user can switch some stuff on/off in that representation.
	**
	** Returns:
	**	void
    */
    function updateCompactOctoState() {
        var state = '';

        if (main.compactLayoutStateEnabled) {
            state = getOctoState();
        }
        if (main.apiConnected) {
            if (main.compactLayoutProgressEnabled) {
                // Shows job state for while print is in progress,
                // otherwise returns printer state.
                if (isPrintInProgress()) {
                    // FIXME hardcoded state string
                    if (main.job_state == "Printing") {
                        if (state != "") {
                            state += ': ';
                        }
                        state += main.job_completion + '%';
                    }
                }
            }
        }

        main.compactOctoState = state;
    }

    // ------------------------------------------------------------------------------------------------------------------------

	// Printer status buckets
	property string bucket_unknown: "unknown"
	property string bucket_working: "working"
	property string bucket_paused: "paused"
	property string bucket_error: "error"
	property string bucket_idle: "idle"
	property string bucket_disconnected: "disconnected"

	/*
	** Returns name of printer state's bucket.
	**
	** Returns:
	**	string: printer state bucket name
	*/
	function getPrinterStateBucket() {
		var bucket = main.bucket_disconnected;

		if ( main.pf_cancelling || main.pf_finishing || main.pf_printing || main.pf_pausing ) {
			bucket = main.bucket_working;
		} else
		if ( main.pf_closedOrError || main.pf_error ) {
			bucket = main.bucket_error;
		} else
		if ( main.pf_operational || main.pf_ready ) {
			bucket = main.bucket_idle;
		} else
		if ( main.pf_paused ) {
			bucket = main.bucket_paused;
		}

		return bucket;
	}

	/*
	** Checks if current printer status flags indicate there's actually print in progress.
	**
	** Returns:
	**	bool
	*/
    function isPrintInProgress() {
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

    /*
    ** Returns instance of XMLHttpRequest, configured for OctoPrint doing Api request.
    ** Throws Error if API URL or access key is not configured.
    **
    ** Returns:
    **  Configured instance of XMLHttpRequest.
    */
    function getXhr(req) {
        var apiUrl = plasmoid.configuration.api_url;
        var apiKey = plasmoid.configuration.api_key;

		if ( apiUrl + apiKey == "" ) {
		    throw new Error('Error: API access is not configured.');
		}

        var xhr = new XMLHttpRequest();
        var url = apiUrl + "/" + req;
        xhr.open('GET', url);
        xhr.setRequestHeader("Host", apiUrl);
        xhr.setRequestHeader("X-Api-Key", apiKey);

        return xhr;
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests job status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
	function getJobStateFromApi() {
//	    console.debug('getJobStateFromApi()');

	    var xhr = getXhr('job');

        xhr.onreadystatechange = (function () {
//            console.debug("Job response: status: " + xhr.status + ", readyState: " + xhr.readyState + ", responseText: '" + xhr.responseText + "'");

            // Ensure we managed to talk to the API
            main.apiConnected = (xhr.status !== 0);

            if (xhr.status !== 0) {
                try {
                    parseJobStatusResponse(JSON.parse(xhr.responseText));
                } catch (error) {
//                    console.debug("Error handling API job state response.");
//                    console.debug(error);
                }
            }
            updateOctoState();
        });
        xhr.send();
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
		var state = resp.state.split(/[ ,]+/)[0];

		main.job_state = state;
		main.job_file_name = Util.getString(resp.job.file.name);

		if (Util.isVal(resp.progress.completion)) {
        	main.job_completion = Util.roundFloat(resp.progress.completion);
			main.job_completion_str = main.job_completion + '%';
		} else {
			main,job_completion = 0;
			main.job_completion_str = "";
		}

		var job_print_time = resp.progress.printTime
		if (Util.isVal(job_print_time)) {
			main.job_print_time_str = Util.secondsToString(job_print_time)
		} else {
			main.job_print_time_str = ""
		}

		var print_time_left = resp.progress.printTimeLeft
		if (Util.isVal(print_time_left)) {
			main.job_print_time_left_str = Util.secondsToString(print_time_left)
		} else {
			main.job_print_time_left_str = ""
		}

//		main.estimated_print_time = secondsToString(resp.job.estimatedPrintTime);
	}

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests printer status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
    function getPrinterStateFromApi() {
//        console.debug('getPrinterStateFromApi()');

        var xhr = getXhr('printer');

        xhr.onreadystatechange = (function () {
//            console.debug("Printer response: status: " + xhr.status + ", readyState: " + xhr.readyState + ", responseText: '" + xhr.responseText + "'");

            // Ensure we managed to talk to the API
            main.apiConnected = (xhr.status !== 0);

            if (xhr.status !== 0) {
                try {
                    parsePrinterStateResponse(JSON.parse(xhr.responseText));
                } catch (error) {
//                  console.debug("Error handling API printer state response.");
//                  console.debug('Error caught: ' + error);

                    main.pf_cancelling = false;
                    main.pf_closedOrError = false;
                    main.pf_error = false;
                    main.pf_finishing = false;
                    main.pf_operational = false;
                    main.pf_paused = false;
                    main.pf_pausing = false;
                    main.pf_printing = false
                    main.pf_ready = false;
                    main.pf_resuming = false;

                    // This is nasty hack for lame OctoPrint API that returns plain string
                    // when printer is disconnected instead of proper JSON based response.
                    if (xhr.responseText !== 'Printer is not operational') {
                        main.pf_error = true;
                    }
                }
            }
            updateOctoState();
        });
        xhr.send();
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
		main.pf_cancelling = resp.state.flags.cancelling;
		main.pf_closedOrError = resp.state.flags.closedOrError;
		main.pf_error = resp.state.flags.error;
		main.pf_finishing = resp.state.flags.finishing;
		main.pf_operational = resp.state.flags.operational;
		main.pf_paused = resp.state.flags.paused;
		main.pf_pausing = resp.state.flags.pausing;
		main.pf_printing = resp.state.flags.printing;
		main.pf_ready = resp.state.flags.ready;
		main.pf_resuming = resp.state.flags.resuming;

		// Textural representation of printer state as returned by API
		main.printer_state = resp.state.text;

		// temepratures
		main.p_bed_actual = Util.getFloat(resp.temperature.bed.actual);
		main.p_bed_offset = Util.getFloat(resp.temperature.bed.offset);
		main.p_bed_target = Util.getFloat(resp.temperature.bed.target);

		// hot-ends
		main.p_he0_actual = Util.getFloat(resp.temperature.tool0.actual);
		main.p_he0_offset = Util.getFloat(resp.temperature.tool0.offset);
		main.p_he0_target = Util.getFloat(resp.temperature.tool0.target);
	}

    // ------------------------------------------------------------------------------------------------------------------------

}
