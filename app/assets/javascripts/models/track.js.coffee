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
  length: 0
  width: 0
  height: 0

  constructor: (element, id) ->
    @track  = element
    @canvases = 
      wave: @track.find('canvas.wave')
      background: @track.find('canvas.background')
    
    # Determine Track Color
    colors = ['blue','yellow','purple','red','green','orange','teal','pink']
    color = if id <= 8 then colors[id-1] else 'blue'

    # Setup Track
    @track.prop('id', "track-#{id}")
    @track.find('.title').text("Track #{id}")
    @track.addClass(color)
    @_setupCanvases()

  _setupCanvases: =>
    @width = @track.find('td.canvases').width()
    @height = @track.find('td.canvases').height()-(parseInt(@track.find('td.canvases').css('padding'))*2)

    for id, element of @canvases
      ctx = element[0].getContext("2d")
      ctx.canvas.width = @width
      ctx.canvas.height = @height
      ctx.save()

  color: =>
    @track.find('.tag').css('background-color')

  stopRecording: => 
    # Flatten the left and right channels down and save
    leftBuffer  = @_mergeBuffers(@leftChannel,  @length)
    rightBuffer = @_mergeBuffers(@rightChannel, @length)
    @buffers = [leftBuffer, rightBuffer]

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
