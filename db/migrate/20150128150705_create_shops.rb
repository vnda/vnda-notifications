class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.string :host
      t.string :token

      t.timestamps
    end
  end
end
