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
import QtQuick.Dialogs 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import "../js/utils.js" as Utils
import "../js/version.js" as Version
import "./PrinterStateBucket.js" as Bucket

Item {
    id: main

    // ------------------------------------------------------------------------------------------------------------------------

    OctoStateManager {
        id: osm
    }

    Timer {
        id: octoStateTimer
        interval: 1000
        repeat: true
        running: osm.jobInProgress
        triggeredOnStart: true
        onTriggered: osm.tick()
    }

    // Debug switch to mimic API access using hardcded JSONs
    readonly property bool fakeApiAccess: false

    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}

    // ------------------------------------------------------------------------------------------------------------------------

    JobState {
    }

    property string plasmoidTitle: ''
    readonly property string plasmoidVersion: Version.version
    readonly property string plasmoidUrl: 'https://github.com/marcinorlowski/octoprint-monitor'

    Component.onCompleted: {
        plasmoidTitle = Plasmoid.title
        plasmoid.setAction("showAboutDialog", i18n('About %1…', plasmoidTitle));
    }

    // ------------------------------------------------------------------------------------------------------------------------

    // Indicates we were able to successfuly connect to OctoPrint API
    property bool apiConnected: false

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** State fetching timer. We fetch printer state first and job state only
    ** if there's any ongoing.
    */
	Timer {
		id: mainTimer

        property bool firstApiRequest: true

        interval: plasmoid.configuration.statusPollInterval * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            getPrinterStateFromApi();

            // First time we need to fire both requests unconditionally, otherwise
            // job state request will neede to wait for another timer trigger, causing
            // odd delay in widget update.
            if (this.firstApiRequest) {
                this.firstApiRequest = false;
                getJobStateFromApi();
            } else {
                // Do not query Job state if we can tell there's no running job
                var buckets = [ Bucket.error, Bucket.idle, Bucket.disconnected ];
                if (buckets.includes(osm.octoStateBucket) === false) {
                    getJobStateFromApi()
                }
            }
        }
	}

	NotificationManager {
	    id: notificationManager
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: {
            var stdout = data["stdout"]

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd, onNewDataCallback) {
            if (onNewDataCallback !== undefined){
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)
    }

    // ------------------------------------------------------------------------------------------------------------------------

    property string octoState: Bucket.connecting
    property string octoStateBucket: Bucket.connecting
    property string octoStateBucketName: Bucket.connecting
    // FIXME we should have SVG icons here
    property string octoStateIcon: plasmoid.file("", "images/state-unknown.png")
    property string octoStateDescription: 'Connecting to OctoPrint API.'
    property string lastOctoStateChangeStamp: ""

    property string previousOctoState: ""
    property string previousOctoStateBucket: ""

    /*
    ** Constructs and posts desktop notification reflecting curent state.
    ** NOTE: This method must be called AFTER the state changed as it uses
    ** octoStateBucket and previousOctoStateBuckets for its logic
    **
    ** Returns:
    **  void
    */
    function postNotification() {
        var current = osm.octoStateBucket
        // carlos
        var previous = osm.previousOctoStateBucket
        var post = false
        var expireTimeout = 0
        var summary = ''
        var body = ''

        if (!plasmoid.configuration.notificationsEnabled) return

        var body = osm.octoStateDescription
        if (current != previous) {
            // switching back from "Working"
            if (!post && (previous == Bucket.working)) {
                post = true
                switch (current) {
                    case Bucket.cancelling:
                        summary = i18n('Cancelling job "%1".', osm.jobFileName)
                        break;

                    case Bucket.paused:
                        summary = i18n('Print job "%1" paused.', osm.jobFileName)
                        break

                    default:
                        if (osm.jobCompletion == 100) {
                            summary = i18n('Print "%s" completed.', osm.jobFileName)
                            expireTimeout = plasmoid.configuration.notificationsTimeoutBucketPrintJobSuccessful
                        } else {
                            summary = i18n('Print stopped.')
                            expireTimeout = plasmoid.configuration.notificationsTimeoutBucketPrintJobFailed
                            var percentage = osm.jobCompletion > 0 ? osm.jobCompletion : osm.previousJobCompletion
                            if (percentage > 0) {
                                body = i18n('File "%1" stopped at %1%%.', osm.jobFileName, percentage)
                            } else {
                               body = i18n('File "%1".', osm.jobFileName)
                            }
                        }
                        if (osm.jobPrintTimeSeconds != 0) {
                            if (body != '') body += ' '
                            body += i18n('Print time %1.', Utils.secondsToString(osm.jobPrintTimeSeconds))
                        }
                        break
                }
            }

            // switching from anything (but connecting) to bucket "Working"
            if (!post && (current == Bucket.working) && (previous != Bucket.connecting)) {
                post = true
                expireTimeout = plasmoid.configuration.notificationsTimeoutPrintJobStarted
                summary = i18n('New printing started.')

                if (osm.jobFileName != '') {
                    if (osm.jobPrintTimeLeftSeconds == 0) {
                        body = i18n('File "%1".', osm.jobFileName)
                    } else {
                        body = i18n('File "%1". Est. print time %2.', osm.jobFileName, Utils.secondsToString(osm.jobPrintTimeLeftSeconds))
                    }
                }
            }
        }

//        console.debug(`post: ${post}, state: ${previous}=>${current}, timeout: ${expireTimeout}, body: "${body}"`)
        if (post) {
            var title = main.plasmoidTitle
            // there's system timer shown (xx ago) shown for non expiring notifications
            if (expireTimeout == 0) {
                title += ' ' + new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
            }
            if (summary == '') {
                summary = "Printer new state: '" + Utils.ucfirst(osm.octoState) + "'."
            }
            notificationManager.post({
                'title': title,
                'icon': osm.octoStateIcon,
                'summary': summary,
                'body': body,
                'expireTimeout': expireTimeout * 1000,
            });
        }
    }


    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Returns instance of XMLHttpRequest, configured for OctoPrint doing Api request.
    ** Throws Error if API URL or access key is not configured.
    **
    ** Returns:
    **  Configured instance of XMLHttpRequest.
    */
    function getXhr(req) {
        var apiUrl = plasmoid.configuration.api_url
        var apiKey = plasmoid.configuration.api_key

		if ( apiUrl != '' && apiKey != '' ) {
            var xhr = null
            xhr = new XMLHttpRequest()
            var url = `${apiUrl}/${req}`
            xhr.open('GET', url)
            xhr.setRequestHeader("Host", apiUrl)
            xhr.setRequestHeader("X-Api-Key", apiKey)
        }
        return xhr
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests job status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
//	function getJobStateFromApi() {
//	    if (!main.fakeApiAccess) {
//	        getJobStateFromApiReal()
//        } else {
//            getJobStateFromApiFake()
//        }
//	}
//
//    function getJobStateFromApiFake() {
//        main.apiConnected = true
//        var json='{"job":{"averagePrintTime":null,"estimatedPrintTime":19637.457560140414,"filament":{"tool0":{"length":9744.308959960938,"volume":68.87846124657558}},"file":{"date":1607166777,"display":"deercraft-stick.gcode","name":"deercraft-stick.gcode","origin":"local","path":"deercraft-stick.gcode","size":17025823},"lastPrintTime":null,"user":"_api"},"progress":{"completion":15.966200282946675,"filepos":2718377,"printTime":2582,"printTimeLeft":16499,"printTimeLeftOrigin":"genius"},"state":"Printing"}'
//        printerStateManager.handle(JSON.parse(json))
//        updateOctoState()
//    }

	function getJobStateFromApi() {
//	function getJobStateFromApiReal() {
	    var xhr = getXhr('job')
        if (xhr !== null) {
            xhr.onreadystatechange = (function () {
                // We only care about DONE readyState.
                if (xhr.readyState !== 4) return

////                 Ensure we managed to talk to the API
//                main.apiConnected = (xhr.status !== 0)

//              console.debug(`ResponseText: "${xhr.responseText}"`)
                osm.handleJobState(xhr)
            });
            xhr.send()
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------

    /*
    ** Requests printer status from OctoPrint and process the response.
	**
	** Returns:
	**	void
    */
//    function getPrinterStateFromApi() {
//        if (!main.fakeApiAccess) {
//            getPrinterStateFromApiReal()
//        } else {
//            getPrinterStateFromApiFake()
//        }
//    }

//    function getPrinterStateFromApiFake() {
//        var json = '{"state":{"flags":{"cancelling":false,"closedOrError":false,"error":false,"finishing":false,"operational":true,"paused":false,"pausing":false,"printing":true,"ready":false,"resuming":false,"sdReady":false},"text":"Printing"},"temperature":{"bed":{"actual":65.0,"offset":0,"target":65.0},"tool0":{"actual":200.0,"offset":0,"target":200.0}}}';
//        parsePrinterStateResponse(JSON.parse(json))
//        updateOctoState();
//    }

    function getPrinterStateFromApi() {
//    function getPrinterStateFromApiReal() {
        var xhr = getXhr('printer')

        if (xhr !== null) {
            xhr.onreadystatechange = (function () {
                osm.handlePrinterState(xhr)
            });
            xhr.send()
        }
    }


    // ------------------------------------------------------------------------------------------------------------------------

    UpdateChecker {
        id: updateChecker
        plasmoidUMetaDataUrl: 'https://raw.githubusercontent.com/MarcinOrlowski/octoprint-monitor/master/src/metadata.desktop'
        plasmoidTitle: main.plasmoidTitle
        plasmoidVersion: main.plasmoidVersion
    }

    // ------------------------------------------------------------------------------------------------------------------------

    function action_showAboutDialog() {
        aboutDialog.visible = true
    }

    AboutDialog {
        id: aboutDialog
        plasmoidTitle: main.plasmoidTitle
        plasmoidVersion: main.plasmoidVersion
    }

    // ------------------------------------------------------------------------------------------------------------------------

}
