@TRAX ||= {}
@TRAX.Workspace = class Workspace

  width: 0
  height: 0
  duration: 45  # set this for initial track length
  trackIndex: 0
  tracks: {}
  currentTrack: undefined

  constructor: (context, workspace) ->
    @context = context
    @workspace = workspace
    @intervals =
      time: 0.04643990844488144      
      pixel: 45
    @buffer = new TRAX.Buffer(@context)

    # Resize the working area for overflow
    @resize()

  ############################################################################################################
  # HTML5 Canvases   
  ############################################################################################################

  drawGrid: =>
    @workspace.find('#canvases #tracks').width(@width)

    grid = @workspace.find('#canvases #grid')
    ctx = grid[0].getContext("2d")
    ctx.canvas.width = @width
    ctx.canvas.height = @height-6  # padding is 3px top+bottom
    ctx.save()

    # How many pixels is 1 second? 
    # --> When interval passes new whole number
    interval = 0
    second = 0
    for x in [0..@width] 
      interval += @intervals['time']
      if parseInt(interval) > second
        ctx.fillStyle = "rgba(0,0,0,0.15)"
        ctx.fillRect(x, 0, 1, @height)
      second = parseInt(interval)

  ############################################################################################################
  # Workspace Methods   
  ############################################################################################################

  resize: =>
    @width = @duration*@intervals['pixel']
    @height = @workspace.find('#canvases #tracks').height()
    @drawGrid()

  nextTrackIndex: =>
    @trackIndex += 1
    
  createTrack: =>
    $.get '/editor/add-track', (data) =>
      @workspace.find('#controls').append(data['controls'])
      @workspace.find('#canvases #tracks').append(data['canvases'])       

      # Create Track Object
      id = @nextTrackIndex()
      track = new TRAX.Track(@context, @workspace.find('[data-track-id="init"]'), id)
      @tracks["#{id}"] = track
      @selectTrackById(id)
      @resize()

      # Create Click Handlers
      @currentTrack.controls.on 'click', (event) =>
        event.preventDefault()
        track_id = $(event.currentTarget).data('track-id')
        @selectTrackById(track_id)

  selectTrackById: (track_id) =>
    @workspace.find("[data-track-id]").removeClass('active')
    @workspace.find("[data-track-id=#{track_id}]").addClass('active')
    @currentTrack = @tracks["#{track_id}"]

  startPlayback: =>
    @buffer.play(@tracks)

  stopPlayback: =>
    @buffer.stop()


