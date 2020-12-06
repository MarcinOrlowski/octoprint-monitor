/**
 * OctoPrint Monitor
 *
 * Plasmoid to monitor OctoPrint instance and print job progress.
 *
 * @author  Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2020 Marcin Orlowski
 * @license  http = //www.opensource.org/licenses/mit-license.php MIT
 * @link   https = //github.com/MarcinOrlowski/octoprint-monitor
 */

  // Printer status buckets
  var unknown = "unknown";
  var working = "working";
  var cancelling = "cancelling";
  var paused = "paused";
  var error = "error";
  var idle = "idle";
  var disconnected = "disconnected";
  var connecting = "connecting";
