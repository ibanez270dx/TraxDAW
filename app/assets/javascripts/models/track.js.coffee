###################################################
# TRAX.Track
#   CoffeeScript "class" defining a Track object.
#
###################################################

@TRAX ||= {}
@TRAX.Track = class Track

  leftChannel: []
  rightChannel: []
  buffers: []
  bufferSource: []
  waveform: []

  length: 0
  duration: 0
  numberOfChannels: 0
  gain: 0

  # Canvases
  width: 0
  height: 0

  constructor: (context, elements, id) ->
    @context = context
    @track =
      controls: elements.filter -> $(this).hasClass('controls')
      canvases: elements.filter -> $(this).hasClass('canvases')
    
    @id = id
    @controls = @track['controls']
    @canvases = 
      wave: @track['canvases'].find('canvas.wave')
      background: @track['canvases'].find('canvas.background')

    # Setup Track
    element.attr('data-track-id', @id) for name, element of @track  
    @track['controls'].find('.title').text("Track #{@id}")
    @_setupCanvases()
    
    # Pick a random Track color
    colors = ['blue','yellow','purple','red','green','orange','teal','pink']
    @setColor(colors[Math.floor(Math.random()*(7-0+1))+0])

  ############################################################################################################
  # Audio Utility (WAV Formatting)   
  ############################################################################################################
 
  _interleave: (leftChannel, rightChannel) =>
    length = leftChannel.length + rightChannel.length
    result = new Float32Array(length)
    inputIndex = 0
    index = 0

    while index < length
      result[index++] = leftChannel[inputIndex]
      result[index++] = rightChannel[inputIndex]
      inputIndex++
    result

  _mergeBuffers: (channelBuffer, recordingLength) =>
    result = new Float32Array(recordingLength)
    offset = 0
    lng = channelBuffer.length
    i = 0
    while i < lng
      buffer = channelBuffer[i]
      result.set buffer, offset
      offset += buffer.length
      i++
    result

  _writeUTFBytes: (view, offset, string) =>
    lng = string.length
    i = 0
    while i < lng
      view.setUint8 offset + i, string.charCodeAt(i)
      i++
    return

  _toWave: (buffers) =>
    # Now interleave both channels together
    interleaved = @_interleave(buffers[0], buffers[1])

    # Create a WAV file
    buffer = new ArrayBuffer(44 + interleaved.length * 2)
    view = new DataView(buffer)

    # RIFF chunk descriptor
    @_writeUTFBytes view, 0, "RIFF"
    view.setUint32 4, 44 + interleaved.length * 2, true
    @_writeUTFBytes view, 8, "WAVE"

    # FMT sub-chunk
    @_writeUTFBytes view, 12, "fmt "
    view.setUint32 16, 16, true
    view.setUint16 20, 1, true

    # stereo (2 channels)
    view.setUint16 22, 2, true
    view.setUint32 24, @sampleRate, true
    view.setUint32 28, @sampleRate * 4, true
    view.setUint16 32, 4, true
    view.setUint16 34, 16, true

    # data sub-chunk
    @_writeUTFBytes view, 36, "data"
    view.setUint32 40, interleaved.length * 2, true

    # write the PCM samples
    lng = interleaved.length
    index = 44
    volume = 1
    i = 0

    while i < lng
      view.setInt16 index, interleaved[i] * (0x7FFF * volume), true
      index += 2
      i++
    
    # our final binary blob
    @blob = new Blob([view], type: "audio/wav")
    @url = (window.URL || window.webkitURL).createObjectURL(@blob)
    return { blob: @blob, url: @url }

  ############################################################################################################
  # HTML5 Canvases 
  ############################################################################################################
 
   _setupCanvases: =>
    @width = @track['canvases'].width()
    @height = @track['canvases'].height()-(parseInt(@track['canvases'].css('padding'))*2)

    for id, element of @canvases
      ctx = element[0].getContext("2d")
      ctx.canvas.width = @width
      ctx.canvas.height = @height
      ctx.save()

  _drawWaveform: (array) =>
    min = Math.min.apply(Math, array)
    max = Math.max.apply(Math, array)
    @waveform.push(max-min)

    # Conversion for Track height
    value = (max-min)*(@height/255)

    # Draw the waveform
    ctx = @canvases['wave'][0].getContext("2d")
    ctx.fillStyle = "#{@getHexColor()}"
    ctx.fillRect(0, (@height/2)-(value/2), 1, value)
    ctx.translate(1, 0)

  _drawBackground: =>
    ctx = @canvases['background'][0].getContext("2d")
    ctx.fillStyle = "rgba(255,255,255,0.1)"
    ctx.fillRect(0, 0, 1, @height)
    ctx.translate(1, 0)
    @cursorPosition++

  ############################################################################################################
  # Track Methods   
  ############################################################################################################

  setColor: (color) =>
    for name, element of @track
      element.attr('data-color', color) 

  getHexColor: =>
    @track['controls'].find('.tag').css('background-color')

  draw: (array) =>
    @_drawWaveform(array)
    @_drawBackground()

  redraw: =>


  saveBuffers: => 
    # Flatten the left and right channels down and save
    leftBuffer  = @_mergeBuffers(@leftChannel,  @length)
    rightBuffer = @_mergeBuffers(@rightChannel, @length)
    @buffers = [leftBuffer, rightBuffer]

  reset: =>
    # Reset Details
    @leftChannel.length = @rightChannel.length = @length = 0

    # Reset Track Canvas
    for id, element of @canvases
      ctx = element[0].getContext("2d")
      ctx.save()
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, ctx.canvas.width, 100);
      ctx.restore()

    # FIXME: Reset the Cursor
    # wave = @track['canvases']['wave'][0].getContext("2d")
    # wave.translate(-@currentPosition, 0);
    # wave.restore()


