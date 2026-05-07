class CreateEmotions < ActiveRecord::Migration[8.1]
  def change
    create_table :emotions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :mood
      t.integer :intensity
      t.text :note
      t.date :recorded_at

      t.timestamps
    end
  end
end
