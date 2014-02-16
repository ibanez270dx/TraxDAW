class EditorController < ApplicationController

  def index
  end

  ##################################
  # JSON actions
  ##################################
  
  def add_track
    render json: { html: render_to_string(partial: 'track', formats: [:html]) }
  end

end
