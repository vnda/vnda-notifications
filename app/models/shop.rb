# == Schema Information
#
# Table name: shops
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  host              :string(255)
#  token             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  madmimi_email     :string(255)
#  madmimi_api_key   :string(255)
#  madmimi_list_name :string(255)
#

class Shop < ActiveRecord::Base
  before_create { self.token = SecureRandom.hex }

  def credentials
    {email: self.madmimi_email, api_key: self.madmimi_api_key}
  end
end
