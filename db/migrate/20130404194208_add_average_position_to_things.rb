class AddAveragePositionToThings < ActiveRecord::Migration
  def change
    add_column :things, :average_position, :float
  end
end
