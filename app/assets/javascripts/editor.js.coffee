#####################################
# Globals
#####################################

micRunning = false
isRecording = false
width = 0
height = 0

chromaOrange = new chroma.scale(["#00ff00", "#e0e000", "#ff7f00", "#b60101"])
context = new webkitAudioContext()

scriptProcessor = context.createScriptProcessor(2048, 1, 1)
scriptProcessor.connect(context.destination)

analyser = context.createAnalyser()
analyser.smoothingTimeConstant = 0
analyser.fftSize = 512
analyser.connect(scriptProcessor)

#####################################
# Functions
#####################################

scriptProcessor.onaudioprocess = ->
  console.log "on audio process"
  array = new Uint8Array(analyser.frequencyBinCount)
  analyser.getByteTimeDomainData(array)
  drawLiveWaveform(array) if micRunning
  drawRecording(array) if isRecording

setupCanvases = ->
  width = $("#canvases").width()
  height = $("#canvases").height()

  $("#grid, #recording, #cursor").each ->
    ctx = $(this)[0].getContext("2d")
    ctx.canvas.width = width
    ctx.canvas.height = height

drawGrid = ->
  ctx = $("#grid")[0].getContext("2d")

  # draw the grid
  i = 0
  while i < width
    if(i%100==0 && i!=0 && i!=width)
      ctx.fillStyle = "#333333"
      ctx.fillRect i, 0, 1, height
    i++

drawLiveWaveform = (array) ->
  console.log "calling draw live waveform"
  ctx = $("#live-waveform").get()[0].getContext("2d")
  ctx.clearRect 0, 0, 100, 35
  i = 0
  while i < (array.length)
    value = array[i]
    ctx.fillStyle = chromaOrange(value / 255).hex()
    ctx.fillRect (i * 100) / 255, (value / 2) - 45, 1, 1
    i++

drawWaveform = (array) ->
  ctx = $("#recording").get()[0].getContext("2d")
  waveValues = []
  min = Math.min.apply(Math, array) * 400 / 255
  max = Math.max.apply(Math, array) * 400 / 255

  while min < max
    waveValues.push min
    min++

  i = 0
  while i < waveValues.length
    value = waveValues[i]
    ctx.fillStyle = chromaOrange(value / 400).hex()
    ctx.fillRect 0, value, 1, 1
    i++
  ctx.translate 1, 0

drawCursor = ->
  ctx = $("#cursor").get()[0].getContext("2d")
  ctx.fillStyle = "rgba(255,255,255,0.1)"
  ctx.fillRect 0, 0, 1, height
  ctx.translate 1, 0

drawRecording = (array) ->
  drawWaveform(array)
  drawCursor()

#####################################
# On-Ready
#####################################
$(document).ready ->

  # microphone start
  $("#mic-start").click ->
    console.log "clicked mic start"
    navigator.webkitGetUserMedia
      audio: true
    , (stream) ->
      micSource = context.createMediaStreamSource(stream)
      micSource.connect(analyser)
      micRunning = true
      $(".navbar .record").removeClass "disabled"

  # microphone stop
  $("#mic-stop").click ->
    micSource.disconnect(analyser)
    micRunning = false
    $("#live-waveform").get()[0].getContext("2d").clearRect(0, 0, 100, 35)
    $(".navbar .record").addClass("disabled")

  # recording start
  $("#rec-start").click ->
    unless $(this).closest("div.record").hasClass("disabled")
      $("div.record i").addClass("active")
      isRecording = true

  # recording stop
  $("#rec-stop").click ->
    $("div.record i").removeClass("active")
    isRecording = false

  setupCanvases()
  drawGrid()
