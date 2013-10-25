require 'httpi'
require 'nori'
require 'hashie'
require 'netaxept/communication_normalizer'

module Netaxept
  class Client
    include Netaxept::Configurable
    include Netaxept::CommunicationNormalizer


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

      params = options.reverse_merge({
        amount: amount,
        order_number: order_id,
        language: language,
      })

      register_response params
    end

    ##
    # Captures the whole amount instantly

    def sale(transaction_id, amount)
      params = {
        :amount => amount,
        :transaction_id => transaction_id,
        :operation => 'SALE'
      }

      process_response params
    end

    ##
    # Authorize the whole amount on the credit card

    def auth(transaction_id, amount)
      params = {
        :amount => amount,
        :transaction_id => transaction_id,
        :operation => 'AUTH'
      }

      process_response params
    end

    ##
    # Captures the whole amount on the credit card

    def capture(transaction_id, amount)
      params = {
        :amount => amount,
        :transaction_id => transaction_id,
        :operation => 'CAPTURE',
      }

      process_response params
    end

    ##
    # Credits an amount of an already captured order to the credit card

    def credit(transaction_id, amount)
      params = {
        amount: amount,
        transaction_id: transaction_id,
        operation: 'CREDIT'
      }

      process_response params
    end

    ##
    # Credits an amount of an already captured order to the credit card

    def query(transaction_id)
      params = {transaction_id: transaction_id}
      query_response params
    end

    def annul(transaction_id)
      params = {
        :transaction_id => transaction_id,
        :operation => 'ANNUL'
      }

      process_response params
    end

    def query_response(params)
      get_response params
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
      if debug

      end
      response  = HTTPI.get(request)
      body      = parser.parse(response.body)

      client_response = if res = body["#{type}_response".to_sym]
        res
      else
        body[:exception]
      end

      client_response ||= body[:payment_info]
      Hashie::Mash.new(deep_underscore(client_response))
    end

    def build_request(url, params = {})
      request = HTTPI::Request.new url: url
      request.headers = {"User-Agent" => user_agent}
      request.query = deep_camelize({
        merchant_id:  merchant_id,
        token:  netaxept_token,
        currency_code:  default_currency,
      }.merge(params))

      request
    end

    def api_page
      if RUBY_VERSION >= '2.0'
        caller_locations(2, 1)[0].label.gsub("_response", "")
      else
        caller[1].match(/`([^']*)'/)[1].gsub("_response", "")
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