[![Build Status](https://circleci.com/gh/mhenrixon/netaxept.png?circle-token=10202ac415ba19212bcb009def2b60edf64f798e)](https://circleci.com/gh/mhenrixon/netaxept/tree/master)
[![Coverage Status](https://coveralls.io/repos/mhenrixon/netaxept/badge.png)](https://coveralls.io/r/mhenrixon/netaxept)


10202ac415ba19212bcb009def2b60edf64f798e
Installation
-----------
run

    gem install netaxept

or include in your _Gemfile_:

    gem 'netaxept'

Usage
-----

First step is to tell Netaxept your credentials and the desired mode:

```ruby
Netaxept.configure do |config|
  config.merchant_id      = ENV["NETAXEPT_MERCHANT_ID"]
  config.netaxept_token   = ENV["NETAXEPT_TOKEN"]
  config.default_currency = "SEK"
  config.environment      = :test|:production
end
```

To interact with Netaxept you need to create an instance of `Netaxept.client

    client = Netaxept.client

### General

Every request returns a `Netaxept::Response` object, which has a `success?` method.
In case of an error you can call `errors`, which gives you a list of `Netaxept::ErrorMessage`s
(each with a `message`, `code`, `source` and `text`).

### Off-site payment workflow

The following applies for the _Nets hosted_ service type where the user is redirect to the
Netaxept site to enter her payment details (see the
[Netaxept docs](http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/Overview/)
for details).

#### Registering a payment

```ruby
client.register <amount in cents>, <order number>, <options>
```

Required options are `CurrencyCode` (3 letter ISO code) and `redirectUrl`.

On success the response object gives you a `transaction_id`.
You pass that to `client.terminal_url(<transaction id>)`

For details on the options see http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/API/Register/

#### Completing a payment

After the user has authorized the payment on the Netaxept site he is redirected to the `redirectUrl` you provided. Netaxept adds a `resonseCode` and `transactionId` parameter to the URL. To finalize the payment you call `sale` on the client.

```ruby
client.sale <transaction id>, <amount in cents>
```

The response is a `Responses::SaleResponse` which only has the `success?` and `errors` methods mentioned under _General_.

Congratulations, you have processed a payment.

Testing
-------

To run the tests:

    $ bundle
    $ MERCHANT_ID=<your merchant id> NETAXEPT_TOKEN=<your token> bundle exec rspec
