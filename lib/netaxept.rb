# This gem wraps the current Netaxept REST api in a nice fashion
#
# Author::    Håkon Lerring (mailto:hakon@powow.no)
# Copyright:: Copyright © 2011 Powow AS
# License::   TODO!

module Netaxept
  require 'netaxept/version'
  require 'netaxept/configurable'
  require 'netaxept/client'
  require 'netaxept/default'
  require 'netaxept/error_message'
  require 'netaxept/responses/response'
  require 'netaxept/responses/register_response'
  require 'netaxept/responses/sale_response'
  require 'netaxept/responses/auth_response'
  require 'netaxept/responses/capture_response'
  require 'netaxept/responses/credit_response'
  require 'netaxept/responses/annul_response'

  class << self
    include Netaxept::Configurable

    # API client based on configured options {Configurable}
    #
    # @return [Netaxept::Client] API wrapper
    def client
      unless defined?(@client) && @client.same_options?(options)
        @client = Netaxept::Client.new(options)
      end

      @client
    end

    # @private
    def respond_to_missing?(method_name, include_private = false)
      client.respond_to?(method_name, include_private)
    end if RUBY_VERSION >= '1.9'

    # @private
    def respond_to?(method_name, include_private = false)
      client.respond_to?(method_name, include_private) || super
    end if RUBY_VERSION < '1.9'

    private

      def method_missing(method_name, *args, &block)
        return super unless client.respond_to?(method_name)
        client.send(method_name, *args, &block)
      end
  end

  Netaxept.setup
end
