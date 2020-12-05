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
    property var json: ''

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

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Checks if current printer status flags indicate there's actually print in progress.
    **
    ** Returns:
    **	bool
    */
    function isJobInProgress() {
        var result = pf_printing || pf_paused || pf_resuming
        return result
    }

    /*
    ** Checks if current printer status flags indicate device is offline or not.
    **
    ** Returns:
    **	bool
    */
    function isPrinterConnected() {
        return  pf_cancelling
             || pf_error
             || pf_finishing
             || pf_operational
             || pf_paused
             || pf_pausing
             || pf_printing
             || pf_ready
             || pf_resuming
//           || pf_closedOrError
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

        if ( this.pf_finishing || this.pf_printing || this.pf_pausing ) {
            bucket = this.bucket_working
        } else if ( this.pf_cancelling ) {
            bucket = this.bucket_cancelling
        } else if ( this.pf_closedOrError || this.pf_error ) {
            bucket = this.bucket_error
        } else if ( this.pf_operational || this.pf_ready ) {
            bucket = this.bucket_idle
        } else if ( this.pf_paused ) {
            bucket = this.bucket_paused;
        }

        if (bucket == undefined) {
            bucket = this.bucket_disconnected
        }

        return bucket;
    }


    // ------------------------------------------------------------------------------------------------------------------------

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
        this.pf_cancelling = state
        this.pf_closedOrError = state
        this.pf_finishing = state
        this.pf_operational = state
        this.pf_paused = state
        this.pf_pausing = state
        this.pf_printing = state
        this.pf_ready = state
        this.pf_resuming = state
        this.pf_error = state
    }

    function parseXhr(xhr) {
        switch (xhr.status) {
            case 200:
//                  console.debug(`ResponseText: "'${xhr.responseText}'"`)
                try {
                    var json = JSON.parse(xhr.responseText);
                    this.parsePrinterStateResponse(json)

                } catch (error) {
                    this.setPrinterFlags(false)
                    this.pf_error = true
                }
                break
            case 409:
                // Printer is not operational
                this.setPrinterFlags(false)
                break
            default:
                console.debug(`Unexpected printer response status code (${xhr.status}).`)
                this.pf_error = true
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
    function parsePrinterStateResponse(resp) {
        this.json = resp;

        this.pf_cancelling = resp.state.flags.cancelling
        this.pf_closedOrError = resp.state.flags.closedOrError
        this.pf_error = resp.state.flags.error
        this.pf_finishing = resp.state.flags.finishing
        this.pf_operational = resp.state.flags.operational
        this.pf_paused = resp.state.flags.paused
        this.pf_pausing = resp.state.flags.pausing
        this.pf_printing = resp.state.flags.printing
        this.pf_ready = resp.state.flags.ready
        this.pf_resuming = resp.state.flags.resuming

        // Textural representation of printer state as returned by API
        this.printer_state = resp.state.text

        // temepratures
        this.p_bed_actual = Utils.getFloat(resp.temperature.bed.actual)
        this.p_bed_offset = Utils.getFloat(resp.temperature.bed.offset)
        this.p_bed_target = Utils.getFloat(resp.temperature.bed.target)

        // hot-ends
        // FIXME: check for more than one
        this.extruder0TemperatureActual = Utils.getFloat(resp.temperature.tool0.actual)
        this.extruder0TemperatureOffset = Utils.getFloat(resp.temperature.tool0.offset)
        this.extruder0TemperatureTarget = Utils.getFloat(resp.temperature.tool0.target)
    }

}
