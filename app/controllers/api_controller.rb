class ApiController < ApplicationController
  before_action :set_shop

  def schedule
    puts "Start schedule..."
    puts "Params: #{params}"

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

    puts "Shop: #{@shop.name}"
    puts "Order: #{params['order']}"
    puts "Promotion: #{promotion}"
    puts "Subject: #{subject}"

    email = OrderEmailBase.from_order(@shop, params['order'], promotion, subject)
    options = email.options.symbolize_keys

    puts "Options: #{options}"

    email_parsed = Email.new(promotion, options, email.vars.symbolize_keys) if email.options && email.vars && event

    puts "Email parsed: #{email_parsed}"

    options[:recipients] = "#{@shop.name} - <#{@shop.madmimi_email}>" if params[:to].present? && params[:to] == 'shop'
    options[:recipients] = params[:to] if params[:to].present? && params[:to] != 'shop'

    puts "Recipients: #{options[:recipients]}"

    minutes_delay = params[:minutes_delay].to_i
    if minutes_delay.blank?
      puts "Madmimi perform"
      MadmimiWorker.perform_async(@shop.credentials, email_parsed) if email.options && email.vars && event
    else
      puts "Madmimi perform with delay"
      MadmimiWorker.perform_in(minutes_delay.minutes, @shop, email) if email.options && email.vars && event
    end
    render :json => 'ok'
  end

end
