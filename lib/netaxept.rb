# This gem wraps the current Netaxept REST api in a nice fashion
#
# Author::    Mikael Henriksson (mailto:mikael@zoolutions.se)
# Copyright:: No fucking copyright here. Use it and abuse it steal as much as you want!
# License::   TODO: do I really need to enter something here?

module Netaxept
  require 'netaxept/version'
  require 'netaxept/configurable'
  require 'netaxept/client'
  require 'netaxept/default'

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
