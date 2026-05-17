class AddAvatarGenerationStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :avatar_generation_status, :string, default: "idle", null: false
    add_column :users, :avatar_generation_error, :text
  end
end
