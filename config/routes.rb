AudioTrax::Application.routes.draw do

  root to: 'editor#index'

  controller :editor do
    get 'editor/add-track', action: 'add_track', as: 'add_track'
  end
end
