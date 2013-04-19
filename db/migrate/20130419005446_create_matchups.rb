class CreateMatchups < ActiveRecord::Migration
  def change
    create_table :matchups do |t|
      t.belongs_to :thing_1
      t.belongs_to :thing_2
      t.boolean :featured, null: false, default: false

      t.timestamps
    end
    add_index :matchups, :thing_1_id
    add_index :matchups, :thing_2_id
    add_index :matchups, :featured
  end
end
