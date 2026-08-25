import QtQuick 2.15

Item {
  id: root
  property real size: 200

  width: size
  height: size

  Rectangle {
    anchors.centerIn: parent
    width: root.size * 0.92
    height: root.size * 0.58
    radius: root.size * 0.1
    color: "#17151c"
    border.width: Math.max(2, root.size * 0.015)
    border.color: "#6f6c84"

    Rectangle {
      x: parent.width * 0.08
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width * 0.2
      height: parent.height * 0.72
      radius: parent.radius * 0.55
      color: "#ff7447"
    }

    Rectangle {
      anchors.centerIn: parent
      width: parent.width * 0.32
      height: parent.height * 0.72
      radius: parent.radius * 0.55
      color: "#bdb7d9"
    }

    Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: parent.width * 0.08
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width * 0.2
      height: parent.height * 0.72
      radius: parent.radius * 0.55
      color: "#3b6f54"
      opacity: 0.88
    }
  }
}
