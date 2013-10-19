require 'httpi'
require 'nori'
require 'hashie'

module Netaxept
  class Client
    include Netaxept::Configurable

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Netaxept::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] ||
          Netaxept.instance_variable_get(:"@#{key}"))
      end

      unless debug
        HTTPI.log       = false
        HTTPI.log_level = :info
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
        amount: amount,
        orderNumber: order_id,
        redirectUrl: options[:redirect_url],
        language: options.fetch(:language) { language },
      }

      register_response params
    end

    ##
    # Captures the whole amount instantly

    def sale(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'SALE'
      }

      process_response params
    end

    ##
    # Authorize the whole amount on the credit card

    def auth(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'AUTH'
      }

      process_response params
    end

    ##
    # Captures the whole amount on the credit card

    def capture(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'CAPTURE',
      }

      process_response params
    end

    ##
    # Credits an amount of an already captured order to the credit card

    def credit(transaction_id, amount)
      params = {
        :amount => amount,
        :transactionId => transaction_id,
        :operation => 'CREDIT'
      }

      process_response params
    end

    def annul(transaction_id)
      params = {
        :transactionId => transaction_id,
        :operation => 'ANNUL'
      }

      process_response params
    end

    def register_response(params)
      get_response params
    end

    def process_response(params)
      get_response params
    end

    def get_response(params)
      type      = api_page
      request   = build_request File.join(base_uri, api_path(type)), params
      response  = HTTPI.get(request)
      body      = parser.parse(response.body)

      client_response = if res = body["#{type}_response".to_sym]
        res
      else
        body[:exception]
      end

      Hashie::Mash.new(client_response)
    end

    def build_request(url, params = {})
      request = HTTPI::Request.new url: url
      request.headers = {"User-Agent" => user_agent}
      request.query = {
        merchantId:  merchant_id,
        token:  netaxept_token,
        currencyCode:  default_currency,
      }.merge(params)

      request
    end

    def api_page
      if RUBY_VERSION >= '2.0'
        caller_locations(3, 1)[0].label.gsub("_response", "")
      else
        caller[0] =~ /`([^']*)'/ and $1
      end
    end

    def api_path(type)
      "/Netaxept/#{type}.aspx"
    end

    def parser
      @parser ||= Nori.new(strip_namespaces: true, convert_tags_to: ->(tag){tag.snakecase.to_sym})
    end

    ##
    # The terminal url for a given transaction id

    def terminal_url(transaction_id)
      path = "/terminal/default.aspx?MerchantID=#{merchant_id}&TransactionID=#{transaction_id}"
      File.join(base_uri, path)
    end
  end
end