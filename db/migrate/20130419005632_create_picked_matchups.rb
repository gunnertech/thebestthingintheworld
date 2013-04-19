class CreatePickedMatchups < ActiveRecord::Migration
  def change
    create_table :picked_matchups do |t|
      t.belongs_to :matchup
      t.belongs_to :thing
      t.belongs_to :user

      t.timestamps
    end
    add_index :picked_matchups, :matchup_id
    add_index :picked_matchups, :thing_id
    add_index :picked_matchups, :user_id
  end
end
