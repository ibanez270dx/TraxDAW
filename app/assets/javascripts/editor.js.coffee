
class Editor

  constructor: (editor, options) ->
    @editor = editor
    @track =
      grid: @editor.find('canvas#grid')
      wave: @editor.find('canvas#wave')
      cursor: @editor.find('canvas#cursor')

    [@micRunning, @isRecording] = [false, false]
    [@width, @height] = [0, 0]

    @chromaOrange = new chroma.scale(["#00ff00", "#e0e000", "#ff7f00", "#b60101"])
    @context = new webkitAudioContext()
    @scriptProcessor = @context.createScriptProcessor(2048, 1, 1)
    @scriptProcessor.connect(@context.destination)

    @analyser = @context.createAnalyser()
    @analyser.smoothingTimeConstant = 0
    @analyser.fftSize = 512
    @analyser.connect(@scriptProcessor)

    @_setupAudioHandler()
    @_setupClickHandlers()
    @_setupCanvases()
    @_drawGrid()

  _setupAudioHandler: =>
    @scriptProcessor.onaudioprocess = =>
      array = new Uint8Array(@analyser.frequencyBinCount)
      @analyser.getByteTimeDomainData(array)
      @_drawLiveWaveform(array) if @micRunning
      @_drawRecording(array) if @isRecording

  _setupCanvases: =>
    @width = @editor.find("#canvases").width()
    @height = @editor.find("#canvases").height()

    for id, element of @track
      ctx = element[0].getContext("2d")
      ctx.canvas.width = @width
      ctx.canvas.height = @height
      console.log "#{id}: ", element
      console.log "#{@width}x#{@height}"

  _drawGrid: =>
    ctx = @track['grid'][0].getContext("2d")
    for i in [0..@width]
      if (i%100 is 0 && i isnt 0 && i isnt @width)
        ctx.fillStyle = "#333333"
        ctx.fillRect(i, 0, 1, @height)

  _drawLiveWaveform: (array) =>
    ctx = @editor.find('#live-waveform')[0].getContext("2d")
    ctx.clearRect(0, 0, 100, 35)

    for i in [0..array.length]
      value = array[i]
      ctx.fillStyle = @chromaOrange(value / 255).hex()
      ctx.fillRect((i * 100) / 255, (value / 2) - 45, 1, 1)

  _drawWaveform: (array) =>
    ctx = @track['wave'][0].getContext("2d")
    waveValues = []
    min = Math.min.apply(Math, array) * 400 / 255
    max = Math.max.apply(Math, array) * 400 / 255
    while min < max
      waveValues.push(min)
      min++

    for i in [0..waveValues.length]
      value = waveValues[i]
      ctx.fillStyle = @chromaOrange(value / 400).hex()
      ctx.fillRect(0, value, 1, 1)
    ctx.translate(1, 0)

  _drawCursor: =>
    ctx = $("#cursor").get()[0].getContext("2d")
    ctx.fillStyle = "rgba(255,255,255,0.1)"
    ctx.fillRect(0, 0, 1, @height)
    ctx.translate(1, 0)

  _drawRecording: (array) =>
    @_drawWaveform(array)
    @_drawCursor()

  _setupClickHandlers: =>
    @editor.find("#mic-start").on 'click', (event) =>
      console.log "clicked mic start"
      navigator.webkitGetUserMedia { audio: true }, (stream) =>
        @micSource = @context.createMediaStreamSource(stream)
        @micSource.connect(@analyser)
        @micRunning = true
        $(".navbar .record").removeClass("disabled")

    @editor.find("#mic-stop").on 'click', (event) =>
      @micSource.disconnect(@analyser)
      @micRunning = false
      $("#live-waveform").get()[0].getContext("2d").clearRect(0, 0, 100, 35)
      $(".navbar .record").addClass("disabled")

    @editor.find("#rec-start").on 'click', (event) =>
      if !$(this).closest("div.record").hasClass("disabled")
        $("div.record i").addClass("active")
        @isRecording = true

    @editor.find("#rec-stop").on 'click', (event) =>
      $("div.record i").removeClass("active")
      @isRecording = false

$(document).on 'ready', ->
  new Editor($('[data-editor]'));