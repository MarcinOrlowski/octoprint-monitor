import QtQuick 2.0
import Qt.labs.settings 1.0

Item {
    property string plasmoidTitle: ''
    property string plasmoidUMetaDataUrl: ''
    property string plasmoidVersion: ''

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
        if (plasmoidUMetaDataUrl == '') {
            console.debug('plasmoidUMetaDataUrl is empty');
            return
        }
        if (plasmoidVersion == '') {
            console.debug('plasmoidVersion not specified');
            return
        }

        var d = new Date()
        var today = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate()
//        console.debug(`today: ${today}, lastCheck: ${updateCheckerSettings.lastVersionCheckDate}`)
        if (today != updateCheckerSettings.lastVersionCheckDate) {
            var xhr = new XMLHttpRequest()
            xhr.open('GET', plasmoidUMetaDataUrl)
            xhr.onreadystatechange = (function () {
                // We only care about DONE readyState.
                if (xhr.readyState !== 4) return
                if (xhr.status === 200) {
                    updateCheckerSettings.lastVersionCheckDate = today

                    var remoteVersion = xhr.responseText.match(/X\-KDE\-PluginInfo\-Version=(.*)/)[1]
//                    console.debug(`remoteVersion: ${remoteVersion}, currentVersion: ${plasmoidVersion}`)
                    if (remoteVersion != plasmoidVersion) {
                        notificationManager.post({
                            'title': plasmoidTitle,
//                            'icon': main.octoStateIcon,
                            'summary': `OctoPrint Monitor ${remoteVersion} available!`,
                            'body': `You are currently using version ${plasmoidVersion}. See project page for more information.`,
                            'expireTimeout': 0,
                        });
                    }
                }
            });
            xhr.send()
        }
    }
}
