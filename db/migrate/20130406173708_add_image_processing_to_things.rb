class AddImageProcessingToThings < ActiveRecord::Migration
  def change
    add_column :things, :image_processing, :boolean
  end
end
