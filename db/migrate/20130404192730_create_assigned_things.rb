class CreateAssignedThings < ActiveRecord::Migration
  def change
    create_table :assigned_things do |t|
      t.belongs_to :thing
      t.belongs_to :user
      t.integer :position

      t.timestamps
    end
    add_index :assigned_things, :thing_id
    add_index :assigned_things, :user_id
  end
end
