class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.float :latitude
      t.float :longitude
      t.string :city
      t.integer :idecko
      t.string :state
      t.string :isocode

      t.timestamps
    end
  end
end
