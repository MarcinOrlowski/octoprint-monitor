import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtMultimedia 5.4
import org.kde.plasma.plasmoid 2.0

QtObject {
    id: notificationManager

    property var dataSource: PlasmaCore.DataSource {
        id: dataSource
        engine: "notifications"
        connectedSources: ["org.freedesktop.Notifications"]
    }

    function post(args) {
        var useNotifySend = plasmoid.configuration.notificationsUseNotifySend

        console.debug(`useNotifySend: ${useNotifySend}`);
        if (useNotifySend) {
            var params = [`--app-name="${args.title}"`]
            if (args.icon) params.push(`--icon="${args.icon}"`);
            if (args.expireTimeout) params.push(`--expire-time=${args.expireTimeout}`);
            // FIXME we need to shell escape these two!
            if (args.summary) params.push('"' + args.summary.replace(/\"/g, '') + '"');
            if (args.body) params.push('"' + args.body.replace(/\"/g, '') + '"');

//            console.debug(JSON.stringify(args))
            var cmd='notify-send ' + params.join(' ')
            console.debug(`cmd: ${cmd}`);
            executable.exec(cmd);
        } else {
            // https://github.com/KDE/plasma-workspace/blob/master/dataengines/notifications/notifications.operations
            var service = dataSource.serviceForSource("notification")
            var operation = service.operationDescription("createNotification")
            operation.appName = args.title
            operation.appIcon = args.icon || ""
            operation.summary = args.summary || ""
            operation.body = args.body || ""
            if (typeof args.expireTimeout !== undefined) {
                operation.expireTimeout = args.expireTimeout
            }
            service.startOperationCall(operation)
}
//        if (args.soundFile) {
//            sfx.source = args.soundFile
//            sfx.play()
//        }
    }

    property Audio sfx: Audio {
    }
}
