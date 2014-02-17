@TRAX ||= {}
@TRAX.Buffer = class Buffer

  buffers: []

  constructor: (context) ->
    @context = context

  play: (tracks) =>
    for track in tracks
      bufferSource = @context.createBufferSource()
      bufferSource.buffer = @context.createBuffer(1, track['buffers'][0].length, 44100)
      bufferSource.buffer.getChannelData(0).set(track['buffers'][0])
      bufferSource.buffer.getChannelData(0).set(track['buffers'][1])
      bufferSource.connect(@context.destination)
      @buffers.push(bufferSource)

    for bufferSource in @buffers
      bufferSource.noteOn(0)

  stop: =>
    for bufferSource in @buffers
      bufferSource.disconnect(@context.destination)
    @buffers = []