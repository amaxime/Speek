import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.2

ApplicationWindow {
    id: window
    width: minimumWidth
    height: minimumHeight
    minimumWidth: 600
    maximumWidth: minimumWidth
    minimumHeight: visibleItem.height + 16
    maximumHeight: minimumHeight
    title: "Speek.Chat"

    signal networkReady
    signal closed

    onVisibleChanged: if (!visible) closed()

    property Item visibleItem: configPage.visible ? configPage : pageLoader.item

    function back() {
        if (pageLoader.visible) {
            pageLoader.visible = false
            configPage.visible = true
        } else {
            openBeginning()
        }
    }

    function openBeginning() {
        configPage.visible = false
        configPage.reset()
        pageLoader.sourceComponent = firstPage
        pageLoader.visible = true
    }

    function openConfig() {
        pageLoader.visible = false
        configPage.visible = true
    }

    function openBootstrap() {
        configPage.visible = false
        pageLoader.source = Qt.resolvedUrl("TorBootstrapStatus.qml")
        pageLoader.visible = true
    }

    Loader {
        id: pageLoader
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        sourceComponent: firstPage
    }

    TorConfigurationPage {
        id: configPage
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        visible: false
    }

    StartupStatusPage {
        id: statusPage
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        visible: false

        onHasErrorChanged: {
            if (hasError) {
                if (visibleItem)
                    visibleItem.visible = false
                pageLoader.visible = false
                statusPage.visible = true
                visibleItem = statusPage
            }
        }
    }

    Component {
        id: firstPage

        Column {
            spacing: 8
            Rectangle{
                visible: !uiMain.appstore_compliant
                width: 150
                height: 150
                radius: 20
                color: palette.base
                anchors.horizontalCenter: parent.horizontalCenter
                Image{
                    source: "qrc:/icons/speeklogo2.png"
                    width: 110
                    height: 110
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextArea {
                visible: uiMain.appstore_compliant
                Layout.fillWidth: true
                Layout.fillHeight: true
                width: parent.width

                readOnly: true
                text: uiMain.eulaText
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.Wrap

                Accessible.description: qsTr("The EULA of Speek")
                Accessible.name: qsTr("EULA")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                //: Label for button to connect to the Tor network
                text: uiMain.appstore_compliant ? qsTr("I have read and agree to the above EULA and Launch Speek.Chat") : qsTr("Launch Speek.Chat with default settings")
                isDefault: true
                onClicked: {
                    // Reset to defaults and proceed to bootstrap page
                    configPage.reset()
                    configPage.save()
                    uiSettings.write("eulaAccepted", "true")
                }
                Accessible.role: Accessible.Button
                Accessible.name: text
                Accessible.onPressAction: {
                    configPage.reset()
                    configPage.save()
                    uiSettings.write("eulaAccepted", "true")
                }
            }

            Button {
                visible: !uiMain.appstore_compliant
                anchors.horizontalCenter: parent.horizontalCenter
                //: Label for button to configure the Tor daemon beore connecting to the Tor network
                text: qsTr("Advanced Network Configuration")
                onClicked: window.openConfig()

                Accessible.role: Accessible.Button
                Accessible.name: text
                Accessible.onPressAction: {
                    window.openConfig()
                }
                style: ButtonStyle {
                    background: Rectangle {
                        color: "transparent"
                    }
                    label: Text {
                        renderType: Text.NativeRendering
                        text: control.text
                        color: control.hovered ? styleHelper.chatIconColorHover : styleHelper.chatIconColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                     }
                }
            }
        }
    }

    Action {
        shortcut: StandardKey.Close
        onTriggered: window.close()
    }
}
