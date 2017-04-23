class IdeckoChangeColumnType < ActiveRecord::Migration[5.0]
  def change
    change_column(:users, :idecko, :string)
  end
end
