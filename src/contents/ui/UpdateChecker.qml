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
import Qt.labs.settings 1.0
import "../js/meta.js" as Meta

Item {
	// URL to metadata.desktop file of recent stable public release
    property string plasmoidUMetaDataUrl: ''

	Timer {
        interval: 3 * 60 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: checkVersion()
	}

    Settings {
        id: updateCheckerSettings
        category: "UpdateChecker"
        property string lastVersionCheckDate: ''
    }

    function checkVersion() {
        var d = new Date()
        var today = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate()
        if (today != updateCheckerSettings.lastVersionCheckDate) {
            var xhr = new XMLHttpRequest()
            xhr.open('GET', plasmoidUMetaDataUrl)
            xhr.onreadystatechange = (function () {
                // We only care about DONE readyState.
                if (xhr.readyState !== 4) return
                if (xhr.status === 200) {
                    updateCheckerSettings.lastVersionCheckDate = today

                    var remoteVersion = xhr.responseText.match(/X\-KDE\-PluginInfo\-Version=(.*)/)[1]
//                    console.debug(`remoteVersion: ${remoteVersion}, currentVersion: ${Meta.version}`)
                    if (remoteVersion != Meta.version) {
                        notificationManager.post({
                            'title': Meta.title,
//                            'icon': main.octoStateIcon,
                            'summary': `OctoPrint Monitor ${remoteVersion} available!`,
                            'body': `You are currently using version ${Meta.version}. See project page for more information.`,
                            'expireTimeout': 0,
                        });
                    }
                }
            });
            xhr.send()
        }
    }
}
