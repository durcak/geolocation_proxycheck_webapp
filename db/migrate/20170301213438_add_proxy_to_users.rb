class AddProxyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_proxy, :boolean, default: false
  end
end
