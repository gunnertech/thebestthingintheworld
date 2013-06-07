class AddWinsLossesAndWinPercentageToThings < ActiveRecord::Migration
  def change
    add_column :things, :wins, :integer
    add_column :things, :losses, :integer
    add_column :things, :win_percentage, :float
    add_column :things, :appearances, :integer
  end
end
