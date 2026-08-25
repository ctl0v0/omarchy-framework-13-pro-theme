import QtQuick 2.15

Canvas {
  id: root

  property real pointerX: 0.5
  property real pointerY: 0.5
  property bool pointerActive: false
  property var ribbons: []
  property var bursts: []
  property real elapsed: 0
  property double lastFrame: 0
  property bool firstPaint: true

  renderTarget: Canvas.Image
  renderStrategy: Canvas.Cooperative

  function reset() {
    if (width <= 0 || height <= 0) return
    var next = []
    for (var i = 0; i < 180; i++) {
      next.push({
        x: Math.random() * width,
        y: Math.random() * height,
        life: Math.random() * 4,
        maxLife: 3 + Math.random() * 4,
        accent: Math.random() < 0.06
      })
    }
    ribbons = next
    bursts = []
    elapsed = 0
    lastFrame = 0
    firstPaint = true
    requestPaint()
  }

  function movePointer(x, y) {
    pointerX = x / width
    pointerY = y / height
    pointerActive = true
  }

  function clearPointer() {
    pointerActive = false
  }

  function activate(x, y) {
    var next = bursts.slice()
    next.push({ x: x, y: y, t: 0, life: 1.8 })
    bursts = next
  }

  function flow(x, y) {
    var dx = x - width / 2
    var dy = y - height / 2
    var angle = Math.atan2(dy, dx) + Math.PI / 2
    angle += Math.sin(x * 0.005 + elapsed * 0.4) * 0.6
    angle += Math.cos(y * 0.005 - elapsed * 0.3) * 0.6
    if (pointerActive) {
      var distance = Math.hypot(x - pointerX * width, y - pointerY * height) + 1
      angle += Math.exp(-distance / 220) * 2.5
    }
    return angle
  }

  onWidthChanged: seedTimer.restart()
  onHeightChanged: seedTimer.restart()
  Component.onCompleted: seedTimer.restart()

  Timer {
    id: seedTimer
    interval: 40
    onTriggered: root.reset()
  }

  Timer {
    interval: 33
    repeat: true
    running: root.visible
    onTriggered: root.requestPaint()
  }

  onPaint: {
    var context = getContext("2d")
    var now = Date.now()
    var delta = lastFrame ? Math.min(0.05, (now - lastFrame) / 1000) : 0.033
    lastFrame = now
    elapsed += delta

    context.fillStyle = firstPaint ? "#000000" : Qt.rgba(0, 0, 0, 0.12)
    context.fillRect(0, 0, width, height)
    firstPaint = false

    var liveBursts = []
    for (var i = 0; i < bursts.length; i++) {
      bursts[i].t += delta
      if (bursts[i].t < bursts[i].life) liveBursts.push(bursts[i])
    }
    bursts = liveBursts

    for (var j = 0; j < ribbons.length; j++) {
      var ribbon = ribbons[j]
      var angle = flow(ribbon.x, ribbon.y)
      var speed = 60

      for (var n = 0; n < liveBursts.length; n++) {
        var burst = liveBursts[n]
        var progress = burst.t / burst.life
        var distance = Math.hypot(ribbon.x - burst.x, ribbon.y - burst.y)
        speed += Math.exp(-Math.pow(distance - progress * 500, 2) / 4000) * (1 - progress) * 400
      }

      var nextX = ribbon.x + Math.cos(angle) * speed * delta
      var nextY = ribbon.y + Math.sin(angle) * speed * delta
      context.strokeStyle = ribbon.accent
        ? Qt.rgba(1, 0.45, 0.28, 0.9)
        : Qt.rgba(0.82, 0.83, 0.93, 0.5)
      context.lineWidth = ribbon.accent ? 1.2 : 0.7
      context.beginPath()
      context.moveTo(ribbon.x, ribbon.y)
      context.lineTo(nextX, nextY)
      context.stroke()

      ribbon.x = nextX
      ribbon.y = nextY
      ribbon.life += delta
      if (ribbon.life > ribbon.maxLife || ribbon.x < 0 || ribbon.x > width || ribbon.y < 0 || ribbon.y > height) {
        if (Math.random() < 0.4) {
          var startAngle = Math.random() * Math.PI * 2
          var startRadius = 130 + Math.random() * 30
          ribbon.x = width / 2 + Math.cos(startAngle) * startRadius
          ribbon.y = height / 2 + Math.sin(startAngle) * startRadius
        } else {
          ribbon.x = Math.random() * width
          ribbon.y = Math.random() * height
        }
        ribbon.life = 0
        ribbon.maxLife = 3 + Math.random() * 4
      }
    }
  }
}
