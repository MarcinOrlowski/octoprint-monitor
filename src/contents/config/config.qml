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
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Compact layout")
        icon: "view-visible"
        source: "configCompactRepresentation.qml"
    }
    ConfigCategory {
        name: i18n("Full layout")
        icon: "widget-alternatives"
        source: "configFullRepresentation.qml"
    }
    ConfigCategory {
        name: i18n("Notifications")
        icon: "notifications"
        source: "configNotifications.qml"
    }
    ConfigCategory {
        name: i18n("OctoPrint API")
        icon: "configure"
        source: "configApi.qml"
    }
    ConfigCategory {
        name: i18n("About")
        icon: "dialog-information"
        source: "configAbout.qml"
    }
}
