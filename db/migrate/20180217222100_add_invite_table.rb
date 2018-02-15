class AddInviteTable < ActiveRecord::Migration[5.1]
  def change
    create_table :invites do |t|
      t.integer :event_id, null: false
      t.integer :user_id, null: false
      t.boolean :rsvp, null: true
      t.integer :additional_guests, null: true
    end
  end
end