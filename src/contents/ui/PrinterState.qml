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
import "PrinterStateBucket.js" as Bucket

QtObject {
    property var json: null

    // ------------------------------------------------------------------------------------------------------------------------

    // Printer state flags
    property bool flagCancelling: false		// working
    property bool flagClosedOrError: false	// error
    property bool flagError: false			// error
    property bool flagFinishing: false		// working
    property bool flagOperational: false	// idle
    property bool flagPaused: false			// paused
    property bool flagPausing: false		// working
    property bool flagPrinting: false		// working
    property bool flagReady: false			// idle
    property bool flagResuming: false		// working

    // printer state
    property string printer_state: ''

    // Bed temperature
    property double bedTemperatureActual: 0
    property double bedTemperatureOffset: 0
    property double bedTemperatureTarget: 0

    // Hotend temperature
    property double extruder0TemperatureActual: 0
    property double extruder0TemperatureOffset: 0
    property double extruder0TemperatureTarget: 0

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Checks if current printer status flags indicate there's actually print in progress.
    **
    ** Returns:
    **	bool
    */
    function isJobInProgress() {
        return flagPrinting || flagPaused || flagResuming
    }

    /*
    ** Checks if current printer status flags indicate device is offline or not.
    **
    ** Returns:
    **	bool
    */
    function isPrinterConnected() {
        return  flagCancelling
             || flagError
             || flagFinishing
             || flagOperational
             || flagPaused
             || flagPausing
             || flagPrinting
             || flagReady
             || flagResuming
//           || flagClosedOrError
        ;
    }

    /*
    ** Returns name of printer state's bucket.
    **
    ** Returns:
    **	string: printer state bucket
    */
    function getPrinterStateBucket() {
        var bucket = undefined;

        if ( flagFinishing || flagPrinting || flagPausing ) {
            bucket = Bucket.working
        } else if ( flagCancelling ) {
            bucket = Bucket.cancelling
        } else if ( flagClosedOrError || flagError ) {
            bucket = Bucket.error
        } else if ( flagOperational || flagReady ) {
            bucket = Bucket.idle
        } else if ( flagPaused ) {
            bucket = Bucket.paused;
        }

        if (bucket == undefined) {
            bucket = Bucket.disconnected
        }

        return bucket;
    }


    // ------------------------------------------------------------------------------------------------------------------------

    /**
    ** Sets pri ter flags to given bool value. Just for DRY.
    **
    ** Arguments:
    **  state: true/false to set all flags to.
    **
    ** Returns:
    **  void
    */
    function setPrinterFlags(state) {
        flagCancelling = state
        flagClosedOrError = state
        flagFinishing = state
        flagOperational = state
        flagPaused = state
        flagPausing = state
        flagPrinting = state
        flagReady = state
        flagResuming = state
        flagError = state
    }

    function fromXhr(xhr) {
        switch (xhr.status) {
            case 200:
                debug.log(`ResponseText: "'${xhr.responseText}'"`)
                try {
                    this.fromJson(JSON.parse(xhr.responseText))
                } catch (error) {
                    console.debug('Error handling API printer state response.')
                    console.debug(error)

                    setPrinterFlags(false)
                    flagError = true
                }
                break
            case 409:
                // Printer is not operational
                this.setPrinterFlags(false)
                break
            case 0:
                flagError = true
                break;
            default:
                console.debug(`Unexpected printer response status code (${xhr.status}).`)
                flagError = true
                break
        }
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
    function fromJson(resp) {
        this.json = resp;

        flagCancelling = resp.state.flags.cancelling
        flagClosedOrError = resp.state.flags.closedOrError
        flagError = resp.state.flags.error
        flagFinishing = resp.state.flags.finishing
        flagOperational = resp.state.flags.operational
        flagPaused = resp.state.flags.paused
        flagPausing = resp.state.flags.pausing
        flagPrinting = resp.state.flags.printing
        flagReady = resp.state.flags.ready
        flagResuming = resp.state.flags.resuming

        // Textural representation of printer state as returned by API
        this.printer_state = resp.state.text

        // temepratures
        bedTemperatureActual = Utils.getFloat(resp.temperature.bed.actual)
        bedTemperatureOffset = Utils.getFloat(resp.temperature.bed.offset)
        bedTemperatureTarget = Utils.getFloat(resp.temperature.bed.target)

        // FIXME: check for more than one extruder
        extruder0TemperatureActual = Utils.getFloat(resp.temperature.tool0.actual)
        extruder0TemperatureOffset = Utils.getFloat(resp.temperature.tool0.offset)
        extruder0TemperatureTarget = Utils.getFloat(resp.temperature.tool0.target)
    }

}
