class AddProxyTypeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :proxy_type, :string
  end
end
