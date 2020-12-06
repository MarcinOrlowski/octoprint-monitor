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

    property var jobStateManager: JobStateManager {}
    property var printerStateManager: PrinterStateManager {}

    // ------------------------------------------------------------------------------------------------------------------------

    function handleJobState(xhr) {
        jobStateManager.handle(xhr)
    }

    function handlePrinterState(xhr) {
        printerStateManager.handle(xhr)
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Checks if current printer status flags indicate device is offline or not.
    **
    ** Returns:
    **	bool
    */
    function isPrinterConnected() {
        return printerStateManager.current.isPrinterConnected()
    }

    /*
    ** Returns name of printer state's bucket.
    **
    ** Returns:
    **	string: printer state bucket
    */
    function getPrinterStateBucket() {
        return printerStateManager.current.getPrinterStateBucket()
    }

    /*
    ** Checks if current printer status flags indicate there's actually print in progress.
    **
    ** Returns:
    **	bool
    */
    function isJobInProgress() {
        return printerStateManager.current.isJobInProgress()
    }

}
