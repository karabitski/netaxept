require 'httpi'
require 'nori'
module Netaxept
  class Client
    include Netaxept::Configurable

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Netaxept::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] ||
          Netaxept.instance_variable_get(:"@#{key}"))
      end
    end

    # Compares client options to a Hash of requested options
    #
    # @param opts [Hash] Options to compare with current client options
    # @return [Boolean]
    def same_options?(opts)
      opts.hash == options.hash
    end

    ##
    # Registers the order parameters with netaxept. Returns a Responses::RegisterResponse

    def register(amount, order_id, options = {})

      params = {
        :amount => amount,
        :orderNumber => order_id,
      }.merge(options)

      register_response Responses::RegisterResponse, params
    end

    ##
    # Captures the whole amount instantly

    def sale(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'SALE'
      }

      process_response Responses::SaleResponse, params
    end

    ##
    # Authorize the whole amount on the credit card

    def auth(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'AUTH'
      }

      process_response Responses::AuthResponse, params
    end

    ##
    # Captures the whole amount on the credit card

    def capture(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'CAPTURE',
      }

      process_response Responses::CaptureResponse, params
    end

    ##
    # Credits an amount of an already captured order to the credit card

    def credit(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'CREDIT'
      }

      process_response Responses::CreditResponse, params
    end

    def annul(transaction_id)
      params = {
        :transactionId => transaction_id,
        :operation => 'ANNUL'
      }

      process_response Responses::AnnulResponse, params
    end

    def register_response(klazz, params)
      get_response klazz, params
    end

    def process_response(klazz, params)
      get_response klazz, params
    end

    def get_response(klazz, params)
      response = HTTPI.get(create_request params)
      klazz.new(parser.parse(response.body))
    end

    def create_request(params = {})
      api_path = "/Netaxept/#{api_page}.aspx"
      request = HTTPI::Request.new :url => File.join(base_uri, api_path)
      request.headers = {"User-Agent" => user_agent}
      request.query = {
        :MerchantID => merchant_id,
        :token => netaxept_token,
        :CurrencyCode => default_currency
      }.merge(params)

      request
    end

    def api_page
      if RUBY_VERSION >= '2.0'
        caller_locations(4, 1)[0].label.gsub("_response", "")
      else
        caller[0] =~ /`([^']*)'/ and $1
      end
    end

    def parser
      @parser ||= Nori.new
    end

    ##
    # The terminal url for a given transaction id

    def terminal_url(transaction_id)
      path = "/terminal/default.aspx?MerchantID=#{merchant_id}&TransactionID=#{transaction_id}"
      File.join(base_uri, path)
    end
  end
end