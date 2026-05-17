class AddSimFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :sim_name, :string
  end
end
