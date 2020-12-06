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
    // Job related stats (if any in progress)
    property string jobState: 'N/A'
    property string jobStateDescription: ''
    property string jobFileName: ''
    property double jobCompletion: 0

    property string jobPrintTime: ''
	property string jobPrintStartStamp: ''
	property string jobPrintTimeLeft: ''

}
