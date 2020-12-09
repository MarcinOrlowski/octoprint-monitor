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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Dialogs 1.3

Dialog {
    property string plasmoidTitle: ''
    property string plasmoidVersion: ''

    readonly property string authorUrl: 'http://MarcinOrlowski.com/'

    visible: false
    title: i18n('Information')
    standardButtons: StandardButton.Ok

    width: 600
    height: 500
    Layout.minimumWidth: 600
    Layout.minimumHeight: 500

    Timer {
        id: debugModeTimeoutTimer
        interval: 2 * 1000
        repeat: true
        running: debugModeClickCount > 0
        triggeredOnStart: false
        onTriggered: debugModeClickCount = 0
    }

    ColumnLayout {
        anchors.centerIn: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        ColumnLayout {
            Layout.margins: 30

            Image {
                Layout.alignment: Qt.AlignHCenter
                fillMode: Image.PreserveAspectFit
                source: plasmoid.file('', 'images/logo.png')

                MouseArea {
                    property int debugModeClickCount: 0

                    anchors.fill: parent
                    onClicked: {
                        if (!debug.enabled) {
                            debugModeClickCount++;
                            if (debugModeClickCount >= 10) {
                                debug.enabled = true;

                                notificationManager.post({
                                    'title': 'Debug Mode',
                                    'icon': osm.octoStateIcon,
                                    'summary': 'Debug mode enabled',
                                    'expireTimeout': 10 * 1000,
                                });
                            }
                        }
                    }
                }
            }

            // metadata access is not available until very recent Plasma
            // so as a work around we have it auto-generated as JS file
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                textFormat: Text.PlainText
                font.bold: true
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                text: `${plasmoidTitle} v${plasmoidVersion}`
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                textFormat: Text.RichText
                text: {
                    var year = '2020'
                    var currentYear = new Date().getFullYear()
                    if (currentYear != year) {
                        year += `-${currentYear}`
                    }
                    return `&copy;${year} by <strong><u>Marcin Orlowski</u></strong>`
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally(authorUrl)
                }
            }

            Item {
                height: 20
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                textFormat: Text.RichText
                text: i18n('Visit <u>project page</u> on Github')
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally(plasmoidUrl)
                    }
                }
            }
        }
    }
} // Dialog
