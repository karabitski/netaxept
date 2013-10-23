module Netaxept

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    CONFIGURATION_KEYS = [
      :merchant_id,
      :netaxept_token,
      :default_currency,
      :language,
      :environment,
      :user_agent,
      :base_uri,
      :debug,
      :log,
      :logger,
      :log_level
    ]

    attr_accessor(*CONFIGURATION_KEYS)

    class << self

      # List of configurable keys for {Netaxept::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= CONFIGURATION_KEYS
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    def environment=(new_environment = :production)
      @environment = new_environment
      self.base_uri = if new_environment == :production
          "https://epayment.bbs.no/"
        else
          "https://epayment-test.bbs.no/"
        end
    end

    # Reset configuration options to default values
    def reset!
      Netaxept::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Netaxept::Default.options[key])
      end

      HTTPI.logger    = self.logger if self.logger
      HTTPI.log       = self.log || self.debug
      HTTPI.log_level = self.log_level
      self
    end
    alias setup reset!

    def options
      Hash[Netaxept::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end