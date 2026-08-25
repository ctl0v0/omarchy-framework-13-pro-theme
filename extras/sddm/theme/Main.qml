import QtQuick 2.15
import QtQuick.Window 2.15
import SddmComponents 2.0

Rectangle {
  id: root
  width: Screen.width
  height: Screen.height
  color: "black"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  readonly property color accentColor: "#ff7447"
  readonly property color errorColor: "#ff5f6d"
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1) return i
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.forceActiveFocus()
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  AuroraVeil {
    id: aurora
    anchors.fill: parent
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onPositionChanged: function(mouse) {
      aurora.movePointer(mouse.x, mouse.y)
    }
    onExited: aurora.clearPointer()
    onClicked: function(mouse) {
      aurora.activate(mouse.x, mouse.y)
      password.forceActiveFocus()
    }
  }

  ModuleMark {
    z: 10
    anchors.centerIn: parent
    size: 200
  }

  Rectangle {
    id: inputField
    z: 11
    width: 381
    height: 67
    anchors.centerIn: parent
    anchors.verticalCenterOffset: 180
    color: "#e629313a"
    border.width: 3
    border.color: root.loginFailed ? root.errorColor : root.accentColor
    radius: 4

    TextInput {
      id: password
      anchors.fill: parent
      anchors.margins: 12
      verticalAlignment: TextInput.AlignVCenter
      horizontalAlignment: TextInput.AlignHCenter
      echoMode: TextInput.Password
      passwordCharacter: "●"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 24
      font.letterSpacing: text.length > 0 ? 5 : 0
      color: "#e9ecf2"
      selectionColor: root.accentColor
      focus: true

      onTextChanged: root.loginFailed = false
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          if (password.text.length > 0)
            sddm.login(root.currentUser, password.text, root.sessionIndex)
          event.accepted = true
        }
      }
    }

    Text {
      anchors.fill: parent
      visible: password.text.length === 0
      text: root.loginFailed ? "Login Failed" : "Enter Password"
      color: root.loginFailed ? root.errorColor : "#8a8f99"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 22
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }

  Component.onCompleted: password.forceActiveFocus()
}
