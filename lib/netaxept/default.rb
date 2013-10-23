require 'netaxept/version'

module Netaxept

  # Default configuration options for {Client}
  module Default

    # Default API environment
    ENVIRONMENT = :test

    # Default User Agent header string
    USER_AGENT   = "Netaxept Ruby Gem #{Netaxept::VERSION}".freeze

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Netaxept::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Netaxept environment from ENV or {ENVIRONMENT}
      # @return [String]
      def environment
        ENV['NETAXEPT_ENVIRONMENT'] || ENVIRONMENT
      end

      # Netaxept merchant id from ENV or configuration
      # @return [String]
      def merchant_id
        ENV['NETAXEPT_MERCHANT_ID']
      end

      # Netaxept merchant id from ENV or configuration
      # @return [String]
      def language
        ENV['NETAXEPT_LANGUAGE'] || 'no_NO'
      end

      # Netaxept merchant password from ENV or configuration
      # @return [String]
      def netaxept_token
        ENV['NETAXEPT_TOKEN']
      end

      def default_currency
        ENV['NETAXEPT_CURRENCY'] || "NOK"
      end

      def base_uri
        if environment == :production
          "https://epayment.bbs.no/"
        else
          "https://epayment-test.bbs.no/"
        end
      end

      def debug
        false
      end

      def log
        false
      end

      def log_level
        :warning
      end

      def logger
        # STDOUT
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['NETENT_USER_AGENT'] || USER_AGENT
      end
    end
  end
end
