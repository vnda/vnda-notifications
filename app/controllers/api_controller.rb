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

    order = params[:order] || params

    puts "Shop: #{@shop.name}"
    puts "Promotion: #{promotion}"
    puts "Subject: #{subject}"

    email = OrderEmailBase.from_order(@shop, order, promotion, subject)

    options = email.options.symbolize_keys

    options[:recipients] = "#{@shop.name} - <#{@shop.madmimi_email}>" if params[:to] && params[:to] == 'shop'
    options[:recipients] = params[:to] if params[:to] && params[:to] != 'shop'

    puts "Options: #{options}"

    email_parsed = Email.new(promotion, options, email.vars.symbolize_keys) if options && email.vars && event

    minutes_delay = params[:minutes_delay].to_i if params[:minutes_delay]
    if minutes_delay.blank?
      puts "Madmimi perform"
      MadmimiWorker.perform_async(@shop.id, email_parsed) if options && email.vars && event
    else
      puts "Madmimi perform with delay"
      MadmimiWorker.perform_in(minutes_delay.minutes, @shop.id, email_parsed) if options && email.vars && event
    end
    render :json => 'ok'
  end

end
