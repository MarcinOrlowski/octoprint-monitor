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
        var result = flagPrinting || flagPaused || flagResuming
        return result
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

        if ( this.flagFinishing || this.flagPrinting || this.flagPausing ) {
            bucket = Bucket.working
        } else if ( this.flagCancelling ) {
            bucket = Bucket.cancelling
        } else if ( this.flagClosedOrError || this.flagError ) {
            bucket = Bucket.error
        } else if ( this.flagOperational || this.flagReady ) {
            bucket = Bucket.idle
        } else if ( this.flagPaused ) {
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
        this.flagCancelling = state
        this.flagClosedOrError = state
        this.flagFinishing = state
        this.flagOperational = state
        this.flagPaused = state
        this.flagPausing = state
        this.flagPrinting = state
        this.flagReady = state
        this.flagResuming = state
        this.flagError = state
    }

    function fromXhr(xhr) {
        switch (xhr.status) {
            case 200:
//              console.debug(`ResponseText: "'${xhr.responseText}'"`)
                try {
                    this.fromJson(JSON.parse(xhr.responseText))
                } catch (error) {
                    console.debug('Error handling API printer state response.')
                    console.debug(error)

                    this.setPrinterFlags(false)
                    this.flagError = true
                }
                break
            case 409:
                // Printer is not operational
                this.setPrinterFlags(false)
                break
            default:
                console.debug(`Unexpected printer response status code (${xhr.status}).`)
                this.flagError = true
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

        this.flagCancelling = resp.state.flags.cancelling
        this.flagClosedOrError = resp.state.flags.closedOrError
        this.flagError = resp.state.flags.error
        this.flagFinishing = resp.state.flags.finishing
        this.flagOperational = resp.state.flags.operational
        this.flagPaused = resp.state.flags.paused
        this.flagPausing = resp.state.flags.pausing
        this.flagPrinting = resp.state.flags.printing
        this.flagReady = resp.state.flags.ready
        this.flagResuming = resp.state.flags.resuming

        // Textural representation of printer state as returned by API
        this.printer_state = resp.state.text

        // temepratures
        this.bedTemperatureActual = Utils.getFloat(resp.temperature.bed.actual)
        this.bedTemperatureOffset = Utils.getFloat(resp.temperature.bed.offset)
        this.bedTemperatureTarget = Utils.getFloat(resp.temperature.bed.target)

        // hot-ends
        // FIXME: check for more than one
        this.extruder0TemperatureActual = Utils.getFloat(resp.temperature.tool0.actual)
        this.extruder0TemperatureOffset = Utils.getFloat(resp.temperature.tool0.offset)
        this.extruder0TemperatureTarget = Utils.getFloat(resp.temperature.tool0.target)
    }

}
