class EditorController < ApplicationController

  def index
  end

  ##################################
  # JSON actions
  ##################################
  
  def add_track
    render json: { 
      controls: render_to_string(partial: 'editor/track/controls', formats: [:html]),
      canvases: render_to_string(partial: 'editor/track/canvases', formats: [:html]) 
    }
  end

end
