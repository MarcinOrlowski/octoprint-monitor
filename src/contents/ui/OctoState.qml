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
    property string state: 'N/A'
    property string stateBucket: ''
    property string stateBucketName: ''
    property string icon: ''

    property string jobFileName: ''
    property double jobCompletion: 0
    property int jobPrintTime: 0
    property int jobPrintTimeLeft: 0

    property var printer: undefined
    property var job: undefined
}

