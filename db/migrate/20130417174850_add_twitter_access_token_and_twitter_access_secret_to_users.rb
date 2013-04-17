class AddTwitterAccessTokenAndTwitterAccessSecretToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_access_token, :string
    add_column :users, :twitter_access_secret, :string
    add_column :users, :twitter_id, :integer
    add_index :users, :twitter_access_token
    add_index :users, :twitter_id
  end
end
