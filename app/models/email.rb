class Email

  REQUIRED_OPTIONS = [:promotion_name, :recipients, :subject, :from, :bcc]

  def initialize promotion_name, options, vars
    @options = {}
    @options.merge! options
    @options[:promotion_name] = promotion_name
    @options[:bcc] = "tech@vnda.com.br"
    @vars = vars || {}
    check_required_options
  end

  def check_required_options
    required_options_missing = REQUIRED_OPTIONS - @options.keys

    if !required_options_missing.empty?
      error = "The following required options were missing\n#{required_options_missing}"
      puts error
      raise MadMimiOptionsMissing, error
    end
  end

  def to_json(options = {})
    JSON({options: @options, vars: @vars})
  end

end
