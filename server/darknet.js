var cp = require('child_process')

function spawn (name, cmd, args) {
  var waitingQueue = []
  var working = {}
  var yoloReady = false

  var yolo = cp.spawn(cmd, args)

  yolo.stdout.on('data', (data) => {
    var lines = data.toString().split('\n')
    var filename = null
    for (var i = 0; i < lines.length; i++) {
      data = lines[i]
      if (data.includes('filename')) {
        // data line update the file data list
        data = JSON.parse(data)
        filename = data.filename
        delete data.filename
        working[filename].data.push(data)
      } else if (data.includes('detection done')) {
        // detection just finished
        filename = data.split(':')[1]
        working[filename].callback(
          working[filename].data
        )
      } else if (data.includes('Enter Image Path')) {
        // ready to start working again
        yoloReady = true
        console.log(`-- ${name} detector ready --`)
      }
    }
  })

  yolo.on('close', (code) => {
    console.log(`-- ${name} detector exited --`)
  })

  function detect (filename, callback) {
    // add the file and queue it for processing
    waitingQueue.unshift({
      filename: filename,
      callback: callback
    })
  }

  function run () {
    // active waiting for new files to work on
    if (yoloReady) {
      var todo = waitingQueue.pop()
      if (!todo) { return setTimeout(run, 1000) }
      console.log(`-- ${name} processing --: ${todo.filename}`)
      yoloReady = false
      working[todo.filename] = {
        callback: todo.callback,
        data: []
      }
      yolo.stdin.write(`${todo.filename}\n`)
    }
    setTimeout(run, 1000)
  }
  run()
  return detect
}

module.exports = {
  // 'yolo': spawn('yolo', './darknet', [
  //   'detector', 'test', 'data/obj.data', 'cfg/yolov4.cfg', '/yolov3.weights', '-dont_show', '-thresh 0.2'
  // ]),
  'yolo-tiny-3l': spawn('yolo-tiny-3l', './darknet', [
    'detector', 'test', 'data/obj.data', 'cfg/yolov4-tiny-3l.cfg', '/yolov3-tiny.weights', '-dont_show', '-thresh 0.2'
  ])
}
