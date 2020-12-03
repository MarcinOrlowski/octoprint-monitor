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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami
import "../js/version.js" as Version

ColumnLayout {
    width: childrenRect.width
    Layout.fillWidth: true

    ColumnLayout {
        anchors.centerIn: parent
        Layout.fillWidth: true

        Image {
            Layout.alignment: Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
            source: plasmoid.file("", "images/logo.png")
        }

        // metadata access is not available until very recent Plasma
        // so as a work around we have it auto-generated as JS file
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            textFormat: Text.RichText
            text: `<center>
<h2>OctoPrint Monitor v${Version.version}</h2><br />
&copy;2020 by Marcin Orlowski<br />
<br />
<a href=\"https://github/com/marcinorlowski/octoprint-monitor\">https://github/com/marcinorlowski/octoprint-monitor</a>
</center>`
            }
        }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
