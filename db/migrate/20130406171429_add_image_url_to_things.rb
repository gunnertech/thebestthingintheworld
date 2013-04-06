class AddImageUrlToThings < ActiveRecord::Migration
  def change
    add_column :things, :image_url, :string
  end
end
