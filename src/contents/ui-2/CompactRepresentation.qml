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

import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as Core
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.extras 2.0 as Extras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: compact


//    MouseArea {
//        onClicked: plasmoid.expanded = !plasmoid.expanded
//        anchors.fill: parent
//	}

    states: [
        State {
            name: "horizontalPanel"
            when: plasmoid.formFactor == PlasmaCore.Types.Horizontal

            PropertyChanges {
                target: sizehelper

                /*
                 * The value 0.71 was picked by testing to give the clock the right
                 * size (aligned with tray icons).
                 * Value 0.56 seems to be chosen rather arbitrary as well such that
                 * the time label is slightly larger than the date or timezone label
                 * and still fits well into the panel with all the applied margins.
                 */
//                height: Math.min(main.showDate || timezoneLabel.visible ? main.height * 0.56 : main.height * 0.71,
//                                 3 * theme.defaultFont.pixelSize)
                height: main.height * 0.71

                font.pixelSize: sizehelper.height
            }

            PropertyChanges {
                target: main
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.minimumWidth: contentItem.width
                Layout.maximumWidth: Layout.minimumWidth
            }

            // debug
            PropertyChanges {
                target: timezoneLabel

                text: "Horiz"

                height: main.height
                width: main.width
//
//                font.pixelSize: timezoneLabel.height
            }

        },

        State {
            name: "verticalPanel"
            when: plasmoid.formFactor === PlasmaCore.Types.Vertical

            PropertyChanges {
                target: sizehelper

                width: main.width

                fontSizeMode: Text.HorizontalFit
                font.pixelSize: 3 * theme.defaultFont.pixelSize
            }

            PropertyChanges {
                target: main
                Layout.fillHeight: false
                Layout.fillWidth: true
                Layout.maximumHeight: contentItem.height
                Layout.minimumHeight: Layout.maximumHeight
            }

            // debug
            PropertyChanges {
                target: timezoneLabel

                text: "Vert"

                height: main.height
                width: main.width
//
//                font.pixelSize: timezoneLabel.height
            }

        }
    ]

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Visible elements
    */
    Item {
        id: compactItem
        anchors.verticalCenter: main.verticalCenter

        // Visible elements
        Grid {
            id: compactGrid

            rows: 1
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            flow: Grid.TopToBottom
            columnSpacing: units.smallSpacing

            Components.Label  {
                id: timezoneLabel
                text: "whoa"
            }

            Components.Label  {
                id: timeLabel

                font {
//                    family: plasmoid.configuration.fontFamily || theme.defaultFont.family
//                    weight: plasmoid.configuration.boldText ? Font.Bold : theme.defaultFont.weight
//                    italic: plasmoid.configuration.italicText
                    pixelSize: 1024
                }
                minimumPixelSize: 1

                text: {
//                    // get the time for the given timezone from the dataengine
//                    var now = dataSource.data[plasmoid.configuration.lastSelectedTimezone]["DateTime"];
//                    // get current UTC time
//                    var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
//                    // add the dataengine TZ offset to it
//                    var currentTime = new Date(msUTC + (dataSource.data[plasmoid.configuration.lastSelectedTimezone]["Offset"] * 1000));
//
//                    main.currentTime = currentTime;
//                    return Qt.formatTime(currentTime, main.timeFormat);

                        return "Test me!";
                }

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            } // Label: timeLabel

        } // Grid

    } // Item


    /*
    ** Invisible helpers
    */
    Components.Label {
        id: sizeHelper

        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
        minimumPixelSize: 1

        visible: false
    }

    FontMetrics {
        id: timeMetrics

        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
    }

}
