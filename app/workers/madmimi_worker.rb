class MadmimiWorker
  include Sidekiq::Worker

  def perform(shop_id, email)
    @credentials = Shop.find(shop_id).credentials
    puts "Options: #{email["options"]}"
    puts "Vars: #{email["vars"]}"

    response = mimi.send_mail(email["options"], email["vars"])

    if response_ok? response
      puts "Email sent to #{email["options"]["recipients"]} about #{email["options"]["promotion_name"]}"
    else
      puts "Could not send mail: #{response} for key #{@credentials['api_key']}"
    end
  end

  def response_ok? response
    if response.to_i == 0
      if !response.strip.empty?
        return false
      end
    end
    true
  end

  def mimi
    @mimi ||= MadMimi.new(@credentials['email'], @credentials['api_key'])
  end

end
