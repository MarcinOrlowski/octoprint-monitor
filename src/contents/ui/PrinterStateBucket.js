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
  const unknown = "unknown";
  const working = "working";
  const cancelling = "cancelling";
  const paused = "paused";
  const error = "error";
  const idle = "idle";
  const disconnected = "disconnected";
  const connecting = "connecting";
