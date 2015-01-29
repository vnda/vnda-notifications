class ApiController < ApplicationController
  before_action :set_shop

  def schedule
    options = JSON.parse(params[:options], {:symbolize_names => true}) if params[:options]
    vars = JSON.parse(params[:vars], {:symbolize_names => true}) if params[:vars]
    promotion = options[:promotion_name] if params[:promotion_name]
    to = params[:to]
    options[:recipients] = to unless to.blank?

    email = Email.new(promotion, options, vars) if options && vars && promotion

    minutes_delay = params[:minutes_delay].to_i
    if minutes_delay.blank?
      MadmimiWorker.perform_async(@shop.credentials, email) if options && vars && promotion
    else
      MadmimiWorker.perform_in(minutes_delay.minutes, @shop, email) if options && vars && promotion
    end
    render :json => 'ok'
  end

end
