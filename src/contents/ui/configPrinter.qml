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
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

ColumnLayout {
    width: childrenRect.width

    property alias cfg_printerStateNameForBucketUnknownEnabled: printerStateNameForBucketUnknownEnabled.checked
    property alias cfg_printerStateNameForBucketUnknown: printerStateNameForBucketUnknown.text
    property alias cfg_printerStateNameForBucketWorkingEnabled: printerStateNameForBucketWorkingEnabled.checked
    property alias cfg_printerStateNameForBucketWorking: printerStateNameForBucketWorking.text
    property alias cfg_printerStateNameForBucketCancellingEnabled: printerStateNameForBucketCancellingEnabled.checked
    property alias cfg_printerStateNameForBucketCancelling: printerStateNameForBucketCancelling.text
    property alias cfg_printerStateNameForBucketPausedEnabled: printerStateNameForBucketPausedEnabled.checked
    property alias cfg_printerStateNameForBucketPaused: printerStateNameForBucketPaused.text
    property alias cfg_printerStateNameForBucketErrorEnabled: printerStateNameForBucketErrorEnabled.checked
    property alias cfg_printerStateNameForBucketError: printerStateNameForBucketError.text
    property alias cfg_printerStateNameForBucketIdleEnabled: printerStateNameForBucketIdleEnabled.checked
    property alias cfg_printerStateNameForBucketIdle: printerStateNameForBucketIdle.text
    property alias cfg_printerStateNameForBucketDisconnectedEnabled: printerStateNameForBucketDisconnectedEnabled.checked
    property alias cfg_printerStateNameForBucketDisconnected: printerStateNameForBucketDisconnected.text

	GroupBox {
        title: i18n("Custom printer state names")
		Layout.fillWidth: true

	    Kirigami.FormLayout {
            Layout.fillWidth: true
    	    anchors.left: parent.left
        	anchors.right: parent.right

        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Unknown")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketUnknownEnabled
                }

                TextField {
                    id: printerStateNameForBucketUnknown
                    Layout.fillWidth: true
                    enabled: cfg_printerStateNameForBucketUnknownEnabled
                }
        	}

        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Working")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketWorkingEnabled
                }

                TextField {
                    id: printerStateNameForBucketWorking
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketWorkingEnabled
                }
        	}

        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Cancelling")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketCancellingEnabled
                }

                TextField {
                    id: printerStateNameForBucketCancelling
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketCancellingEnabled
                }
        	}

        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Paused")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketPausedEnabled
                }

                TextField {
                    id: printerStateNameForBucketPaused
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketPausedEnabled
                }
        	}

        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Error")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketErrorEnabled
                }

                TextField {
                    id: printerStateNameForBucketError
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketErrorEnabled
                }
        	}


        	RowLayout {
                Layout.fillWidth: true
        	    Kirigami.FormData.label: i18n("Idle")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketIdleEnabled
                }

                TextField {
                    id: printerStateNameForBucketIdle
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketIdleEnabled
                }
        	}

            RowLayout {
                Layout.fillWidth: true
                Kirigami.FormData.label: i18n("Disconnected")

                PlasmaComponents.CheckBox {
                    id: printerStateNameForBucketDisconnectedEnabled
                }

                TextField {
                    id: printerStateNameForBucketDisconnected
                    Layout.fillWidth: true
                    enabled: printerStateNameForBucketDisconnectedEnabled
                }
            }

        }
    }

    Item {
        Layout.fillHeight: true
    }
}
