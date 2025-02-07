import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0

ColumnLayout {
    anchors {
        fill: parent
        margins: 8
    }

    Label {
        Layout.fillWidth: true
        //: %1 version, e.g. 1.0.0
        text: qsTr("Speek %1").arg(uiMain.version)
        horizontalAlignment: Qt.AlignHCenter

        Accessible.description: qsTr("Current Speek version")
        Accessible.role: Accessible.StaticText
        //: provides a readable interpretation of the Speek version number for accessibility tech like screen readers
        Accessible.name: qsTr("Speek version %1").arg(uiMain.accessibleVersion)
    }

    TextArea {
        Layout.fillWidth: true
        Layout.fillHeight: true

        readOnly: true
        text: uiMain.aboutText
        textFormat: TextEdit.PlainText
        wrapMode: TextEdit.Wrap

        Accessible.description: qsTr("The license of Speek and its dependencies")
        Accessible.name: qsTr("License")
    }

    Accessible.role: Accessible.Window
    Accessible.name: qsTr("About")
    //: summary of the window's contents for accessibility tech like screen readers
    Accessible.description: qsTr("About page, contains license and version information")
}

