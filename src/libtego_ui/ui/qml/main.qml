import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import Qt.labs.platform 1.1
import im.ricochet 1.0
import "ContactWindow.js" as ContactWindow

// Root non-graphical object providing window management and other logic.
QtObject {
    id: root

    property MainWindow mainWindow: MainWindow {
        //onVisibleChanged: if (!visible) Qt.quit()
    }

    function createDialog(component, properties, parent) {
        if (typeof(component) === "string")
            component = Qt.createComponent(component)
        if (component.status !== Component.Ready)
            console.log("openDialog:", component.errorString())
        var object = component.createObject(parent ? parent : null, (properties !== undefined) ? properties : { })
        if (!object)
            console.log("openDialog:", component.errorString())
        object.closed.connect(function() {
            object.destroy();
        })
        return object
    }

    function createDialogRequest(component, properties, parent) {
        if (typeof(component) === "string")
            component = Qt.createComponent(component)
        if (component.status !== Component.Ready)
            console.log("openDialog:", component.errorString())
        var object = component.createObject(parent ? parent : null, (properties !== undefined) ? properties : { })
        if (!object)
            console.log("openDialog:", component.errorString())
        object.closed.connect(function() {
            mainWindow.contactRequestDialogs.splice(mainWindow.contactRequestDialogs.indexOf(object), 1);

            if(mainWindow.appNotificationsModel.indexOf(object) != -1){
                mainWindow.appNotificationsModel.splice(mainWindow.appNotificationsModel.indexOf(object), 1);
                mainWindow.appNotifications.model = mainWindow.appNotificationsModel
            }

            object.destroy();

            mainWindow.contactRequestDialogsLength = mainWindow.contactRequestDialogs.length;
            if(typeof(mainWindow.contactRequestSelectionDialog) != "undefined" && mainWindow.contactRequestSelectionDialog != null)
                mainWindow.contactRequestSelectionDialog.contactRequestDialogsChanged();
        })
        return object
    }

    property QtObject preferencesDialog
    function openPreferences(page, properties) {
        if (preferencesDialog == null) {
            preferencesDialog = createDialog("PreferencesDialog.qml",
                {
                    'initialPage': page,
                    'initialPageProperties': properties
                }
            )
            preferencesDialog.closed.connect(function() { preferencesDialog = null })
        }

        preferencesDialog.visible = true
        preferencesDialog.raise()
        preferencesDialog.requestActivate()
    }

    property QtObject audioNotifications: audioNotificationLoader.item

    Component.onCompleted: {
        ContactWindow.createWindow = function(user) {
            var re = createDialog("ChatWindow.qml", { 'contact': user })
            re.x = mainWindow.x + mainWindow.width + 10
            re.y = mainWindow.y + (mainWindow.height / 2) - (re.height / 2)

            var screens = uiMain.screens
            if ((mainWindow.Screen !== undefined) && (mainWindow.Screen.name in screens)) {
                var currentScreen = screens[mainWindow.Screen.name]
                var offsetX = currentScreen.left
                var offsetY = currentScreen.top
                re.x = re.x - offsetX + re.width <= currentScreen.width ? re.x : mainWindow.x - re.width - 10
                re.y = re.y - offsetY + re.height <= currentScreen.height ? re.y : currentScreen.height + offsetY - re.height - 10
            }

            re.visible = true
            return re
        }

        if (torInstance.configurationNeeded) {
            var object = createDialog("NetworkSetupWizard.qml")
            object.networkReady.connect(function() {
                mainWindow.visible = true
                object.visible = false
            })
            object.visible = true
        } else {
            mainWindow.visible = true
        }
    }

    property list<QtObject> data: [
        Connections {
            target: userIdentity
            function onRequestAdded(request) {
                if(mainWindow.contactRequestDialogs.length > 300){
                    return;
                }
                var object = createDialogRequest("ContactRequestDialog.qml", { 'request': request })
                mainWindow.contactRequestDialogs.push(object)
                mainWindow.contactRequestDialogsLength = mainWindow.contactRequestDialogs.length

                if(request.message.length > 0 && mainWindow.appNotificationsModel.length <= 3){
                    mainWindow.appNotificationsModel.push(object)
                    mainWindow.appNotifications.model = mainWindow.appNotificationsModel
                }

                if(!mainWindow.visible && uiSettings.data.showNotificationSystemtray){
                    mainWindow.systray.showMessage(qsTr("New Contact Request"), ("You just received a new contact request"),SystemTrayIcon.Information, 3000)
                }
            }
        },

        Connections {
            target: torInstance
            function onConfigurationNeededChanged() {
                if (torInstance.configurationNeeded) {
                    var object = createDialog("NetworkSetupWizard.qml", { 'modality': Qt.ApplicationModal }, mainWindow)
                    object.networkReady.connect(function() { object.visible = false })
                    object.visible = true
                }
            }
        },

        Settings {
            id: uiSettings
            path: "ui"
        },

        SystemPalette {
            id: palette
        },

        FontLoader {
            id: iconFont
            source: "qrc:/icons/speek-icons.ttf"
        },

        FontLoader {
            id: notoFont
            source: "qrc:/fonts/NotoSans-Regular.ttf"
        },

        FontLoader {
            id: notoBoldFont
            source: "qrc:/fonts/NotoSans-Bold.ttf"
        },

        Item {
            id: styleHelper
            visible: false
            Label { id: fakeLabel }
            Label { id: fakeLabelSized; font.pointSize: styleHelper.pointSize > 0 ? styleHelper.pointSize : 1 }

            property int pointSize: (Qt.platform.os === "windows") ? 10 : (Qt.platform.os === "osx") ? 14 : 12
            property int textHeight: fakeLabelSized.height
            property int dialogWindowFlags: Qt.Dialog | Qt.WindowSystemMenuHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
            property string fontFamily: "Noto Sans"
            property bool darkMode: uiMain.themeColor.darkMode == "true" ? true : false
            property var borderColor: uiMain.themeColor.borderColor
            property var chatIconColor: uiMain.themeColor.chatIconColor
            property var borderColor2: uiMain.themeColor.borderColor2
            property var emojiPickerBackground: uiMain.themeColor.emojiPickerBackground
            property var outgoingMessageColor: uiMain.themeColor.outgoingMessageColor
            property var incomingMessageColor: uiMain.themeColor.incomingMessageColor
            property var chatIconColorHover: uiMain.themeColor.chatIconColorHover
            property var unreadCountBadge: uiMain.themeColor.unreadCountBadge
            property var scrollBar: uiMain.themeColor.scrollBar
            property var searchBoxText: uiMain.themeColor.searchBoxText
            property var messageBoxText: uiMain.themeColor.messageBoxText
            property var chatBoxBorderColor: uiMain.themeColor.chatBoxBorderColor
            property var chatBoxBorderColorLeft: uiMain.themeColor.chatBoxBorderColorLeft
            property var notificationBackground: uiMain.themeColor.notificationBackground
            property var contactListHover: uiMain.themeColor.contactListHover
        },

        Loader {
            id: audioNotificationLoader
            active: uiSettings.data.playAudioNotification || false
            source: "AudioNotifications.qml"
        }
    ]
}
