class OrderEmailBase
  extend ActionView::Helpers::NumberHelper

  attr_reader :shop, :options, :vars

  OPTION_FIELDS = [
    "promotion_name",
    "recipients",
    "subject",
    "from",
    "bcc"
  ]

  COMMON_OPTIONS = {
    "bcc" => "tech@vnda.com.br"
  }

  COMMON_VARS = [
    "nome",
    "sobrenome",
    "pedido",
    "paginadopedido",
    "experienciadocliente",
    "valordodesconto",
    "valordoenvio",
    "valordopedido",
    "formadepagamento",
    "formadeenvio",
    "itensdopedido",
    "enderecoentrega",
    "bairroentrega",
    "cidadeentrega",
    "estadoentrega",
    "enderecocobranca",
    "bairrocobranca",
    "cidadecobranca",
    "estadocobranca"
  ]

  def initialize shop, options, vars
    @shop = shop
    @options = options.merge(COMMON_OPTIONS)
    @vars = vars
  end

  def email_complete?
    check_required_options(options)
    # check_required_vars(vars)
    # nao precisa
  end

  def self.from_order shop, order, promotion_name, subject
    address = order.billing_address || order.shipping_address
    # Buscar o endereço api

    options = extract_options(shop, order, address, promotion_name, subject)

    # vars = extract_variables(shop, order, address)
    # nao precisa
    vars = nil

    self.new(shop, options, vars)
  end

  protected

  def self.extract_options shop, order, address, promotion_name, subject
    {
      "promotion_name" => promotion_name,
      "subject" => subject,
      "from" => "#{shop.name} <#{shop.email}>",
      "recipients" => "#{address.full_name} <#{address.email}>"
    }
  end

  def self.extract_variables shop, order, address
    shipping_information = order_shipping(order)

    {
      "nome" => address.first_name,
      "sobrenome" => address.last_name,
      "pedido" => order.code,
      "paginadopedido" => "https://#{shop.host}/pedido/#{order.token}",
      "experienciadocliente" => review_links(shop.host, order.token),
      "valordodesconto" => order.discount_price.to_f > 0 ? number_to_currency(order.discount_price) : 0,
      "valordoenvio" => shipping_information["valordoenvio"],
      "valordopedido" => number_to_currency(order.total),
      "formadepagamento" => order_installments(order),
      "itensdopedido" => order_items(order),
      "enderecoentrega" => order.shipping_address.full_address,
      "bairroentrega" => order.shipping_address.neighborhood,
      "cidadeentrega" => order.shipping_address.city,
      "estadoentrega" => order.shipping_address.state,
      "enderecocobranca" => order.billing_address.full_address,
      "bairrocobranca" => order.billing_address.neighborhood,
      "cidadecobranca" => order.billing_address.city,
      "estadocobranca" => order.billing_address.state,
      "linkdoboleto" => order.slip? ? order.slip_url : ""
    }.merge(extra_infos(order))
  end

  def self.extra_infos order
    {}.tap do |infos|
      order.extra.select{|name, value| value.present? }.each do |name, value|
        key = ActiveSupport::Inflector.transliterate(name).downcase.gsub(/[^a-z]/, "")
        infos[key] = value
      end
    end
  end

  def self.order_shipping_address order
    # url = "http://#{shop.api_username}:#{shop.api_password}@#{shop.host}/api/v2/carts/#{cart.id}/installments"
    url = "http://#{shop.api_username}:#{shop.api_password}@#{@shop.host}/api/v2/orders/#{order['code']}/shipping_address"
    response = Excon.get(url)
    {
      "formadeenvio" => order['shipping_method'],
      "valordoenvio" => number_to_currency(response['price'])
    }
  end

  def self.order_installments order
    return "N/A" unless order.payment_method

    text = I18n.t(order.payment_method, :scope => [:order, :payment_methods])
    if order.payment_method =~ /^credit/
      if order.installments.to_i > 1
        text << " (em #{order.installments} vezes)"
      else
        text << " (à vista)"
      end
    end

    text
  end

  def self.review_links(host, token)
    [].tap do |links|
      { :excelente => :excelent, :bom => :good, :ruim => :bad }.each do |label, icon|
        links << "<a href=\"http://#{host}/pedido/#{token}/avaliacao/#{label}\"><img src=\"http://#{host}/admin/images/review/#{icon}-130x130.png\"/></a>"
      end
    end.join("&nbsp;")
  end

  def self.order_items(order)
    erb = ERB.new <<-HTML
      <table cellspacing="0" cellpadding="10" border="0">
        <% order.items.each_with_index do |item, index| %>
          <tr>
            <td>
              <img src="http:<%= item.thumb('80x80') %>" />
            </td>
            <td>
              Item <%= index + 1 %>: <%= item.name %><br />
              Preço: <%= number_to_currency(item.price) %><br />
              Quantidade: <%= item.quantity %><br />
              Subtotal: <%= number_to_currency(item.price * item.quantity) %>
            </td>
          </tr>
        <% end %>
      </table>
    HTML
    erb.result(binding)
  end

  def check_required_options options
    options_provided = options.keys - OPTION_FIELDS
    raise "The following options are required for the email #{options_provided.to_s}" if !options_provided.empty?
  end

  def check_required_vars vars
    vars_provided = vars.keys - COMMON_VARS
    raise "The following variables were not supplied, and are needed for the email generation #{vars_provided.to_s}" if !vars_provided.empty?
  end

end
