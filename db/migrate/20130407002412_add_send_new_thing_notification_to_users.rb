class AddSendNewThingNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_new_thing_notification, :boolean, default: true, null: false
  end
end
