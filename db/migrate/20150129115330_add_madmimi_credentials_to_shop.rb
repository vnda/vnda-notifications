class AddMadmimiCredentialsToShop < ActiveRecord::Migration
  def change
    add_column :shops, :madmimi_email, :string
    add_column :shops, :madmimi_api_key, :string
    add_column :shops, :madmimi_list_name, :string
  end
end
