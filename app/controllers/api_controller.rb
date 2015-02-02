class ApiController < ApplicationController
  before_action :set_shop

  def schedule
    event =  params[:event]
    case event
    when 'order-received'
      subject = "Pedido recebido"
      promotion = "pedido-recebido"
    when 'order-sent'
      subject = "Pedido enviado"
      promotion = "pedido-enviado"
    when 'order-canceled'
      subject = "Pedido cancelado"
      promotion = "pedido-cancelado"
    when 'order-delivered'
      subject = "Pedido entregue"
      promotion = "pedido-entregue"
    when 'order-confirmed'
      subject = "Pedido confirmado"
      promotion = "pedido-confirmado"
    end

    email = OrderEmailBase.from_order(@shop, params['order'], promotion, subject)
    options = email.options.symbolize_keys

    email_parsed = Email.new(promotion, options, email.vars.symbolize_keys) if email.options && email.vars && event

    options[:recipients] = "#{@shop.name} - <#{@shop.madmimi_email}>" if params[:to].present? && params[:to] == 'shop'
    options[:recipients] = params[:to] if params[:to].present? && params[:to] != 'shop'

    minutes_delay = params[:minutes_delay].to_i
    if minutes_delay.blank?
      MadmimiWorker.perform_async(@shop.credentials, email_parsed) if email.options && email.vars && event
    else
      MadmimiWorker.perform_in(minutes_delay.minutes, @shop, email) if email.options && email.vars && event
    end
    render :json => 'ok'
  end

end
