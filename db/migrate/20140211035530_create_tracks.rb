class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :description
      t.string :kind
      t.integer :buffer_size
      t.integer :sample_rate
      t.timestamps
    end

    add_attachment :tracks, :audio
  end
end
