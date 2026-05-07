class ChangeRecordedAtToDatetimeInEmotions < ActiveRecord::Migration[8.1]
  def change
    change_column :emotions, :recorded_at, :datetime
  end
end
