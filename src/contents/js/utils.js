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

function isVal(value) {
    return (typeof value !== 'undefined') && value != null && value != "";
}

function getInt(value, def) {
    if (def === undefined) def = 0;
    return isVal(value) ? value : def;
}

function getString(value, def) {
    if (def === undefined) def = '';
    return isVal(value) ? value : def;
}

function getFloat(value, def) {
    if (def === undefined) def = 0.0;
    return isVal(value) ? value : def;
}

function isValidJsonString(jsonString) {
    if (!(typeof jsonString === "string")) return false;
    if (jsonString === '') return false;

    try {
        JSON.parse(jsonString);
        return true;
    } catch (error) {
        return false;
    }
}

function roundFloat(num, decimals) {
    if (decimals === undefined) decimals = 1;

    if (num == null || num == "") {
        num = 0;
    }
    num = +num.toFixed(decimals);
    return num;
}

function secondsToString(seconds, always_include_seconds) {
    if (always_include_seconds === undefined) always_include_seconds = false
    if (seconds == null || seconds == '') seconds = 0;
    var result = '';

    var d = Math.floor(seconds / (3600 * 24));
    var h = Math.floor(seconds / 3600);
    var m = Math.floor((seconds % 3600) / 60);
    var s = Math.floor(seconds % 60);

    if (d > 0) {
        if (result != '') result += ' ';
        result += `${d}d`;
    }
    if (h > 0) {
        if (result != '') result += ' ';
        result += `${h}h`;
    }
    if (m > 0) {
        if (result != '') result += ' ';
        result += `${m}m`;
    }

    // do not show seconds until last minute (unless enforced)
    if (result == '' || (always_include_seconds && (s > 0))) {
        if (result != '') result += ' ';
        result += `${s}s`;
    }

    return result;
}

function ucfirst(string) {
    return (string.length > 1) ? string.substr(0, 1).toUpperCase() + string.substr(1) : string.toUpperCase();
}
