class AddIndexToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :ip
  end
end
