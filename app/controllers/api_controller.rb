class ApiController < ApplicationController
  before_action :set_shop

  def schedule
    promotion =  params[:event]

    case promotion
    when 'order-confirmed'
      subject = "Pedido confirmado"
    when 'order-received'
      subject = "Pedido recebido"
    end

    email = OrderEmailBase.from_order(@shop, params['order'], promotion, subject)
    email_parsed = Email.new(promotion, email.options.symbolize_keys, email.vars.symbolize_keys) if email.options && email.vars && promotion

    minutes_delay = params[:minutes_delay].to_i
    if minutes_delay.blank?
      MadmimiWorker.perform_async(@shop.credentials, email_parsed) if email.options && email.vars && promotion
    else
      MadmimiWorker.perform_in(minutes_delay.minutes, @shop, email) if email.options && email.vars && promotion
    end
    render :json => 'ok'
  end

end
