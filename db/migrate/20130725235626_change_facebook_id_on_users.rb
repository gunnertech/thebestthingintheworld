class ChangeFacebookIdOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :facebook_id, :integer, limit: 8
  end

  def down
  end
end
