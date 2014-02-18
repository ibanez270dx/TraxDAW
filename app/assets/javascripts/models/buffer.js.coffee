@TRAX ||= {}
@TRAX.Buffer = class Buffer

  buffers: []

  constructor: (context) ->
    @context = context

  play: (tracks) =>
    startTime = @context.currentTime

    for index, track of tracks
      bufferSource = @context.createBufferSource()
      bufferSource.buffer = @context.createBuffer(1, track['buffers'][0].length, 44100)
      bufferSource.buffer.getChannelData(0).set(track['buffers'][0])
      bufferSource.buffer.getChannelData(0).set(track['buffers'][1])
      bufferSource.onended = (event) =>
        console.log "ended!"

      # Connect source to speakers and add to buffer list
      bufferSource.connect(@context.destination)
      @buffers.push(bufferSource)

    # Play all the buffers
    for bufferSource in @buffers
      bufferSource.noteOn(0)

  stop: =>
    for bufferSource in @buffers
      bufferSource.disconnect(@context.destination)
    @buffers = []