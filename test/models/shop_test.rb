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

require 'test_helper'

class ShopTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
