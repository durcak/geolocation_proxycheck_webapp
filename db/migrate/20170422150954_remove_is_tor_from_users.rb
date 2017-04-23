class RemoveIsTorFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :is_tor, :boolean
  end
end
