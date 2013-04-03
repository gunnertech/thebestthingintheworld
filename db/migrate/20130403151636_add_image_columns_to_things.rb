class AddImageColumnsToThings < ActiveRecord::Migration
  def self.up
    add_attachment :things, :image
  end

  def self.down
    remove_attachment :things, :image
  end
end
