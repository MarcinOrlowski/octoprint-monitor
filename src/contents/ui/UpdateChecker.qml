import QtQuick 2.0
//import org.kde.plasma.core 2.0 as PlasmaCore
//import QtMultimedia 5.4
//import org.kde.plasma.plasmoid 2.0
import Qt.labs.settings 1.0

Item {
    id: updateChecker

    property string title: ''
    property string url: ''
    property string currentVersion: ''

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
        if (updateChecker.url == '') {
            console.debug('UpdateChecker URL is empty');
            return
        }
        if (updateChecker.currentVersion == '') {
            console.debug('currentVersion not specified');
            return
        }

        var d = new Date()
        var today = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate()
//        console.debug(`today: ${today}, lastCheck: ${updateCheckerSettings.lastVersionCheckDate}`)
        if (today != updateCheckerSettings.lastVersionCheckDate) {
            var xhr = new XMLHttpRequest()
            xhr.open('GET', updateChecker.url)
            xhr.onreadystatechange = (function () {
                // We only care about DONE readyState.
                if (xhr.readyState !== 4) return
                if (xhr.status === 200) {
                    updateCheckerSettings.lastVersionCheckDate = today

                    var remoteVersion = xhr.responseText.match(/X\-KDE\-PluginInfo\-Version=(.*)/)[1]
//                    console.debug(`remoteVersion: ${remoteVersion}, currentVersion: ${currentVersion}`)
                    if (remoteVersion != currentVersion) {
                        notificationManager.post({
                            'title': updateChecker.title,
//                            'icon': main.octoStateIcon,
                            'summary': `OctoPrint Monitor ${remoteVersion} available!`,
                            'body': `You are currently using version ${updateChecker.currentVersion}. See project page for more information.`,
                            'expireTimeout': 0,
                        });
                    }
                }
            });
            xhr.send()
        }
    }
}
