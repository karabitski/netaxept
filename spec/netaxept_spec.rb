require 'spec_helper'

describe Netaxept do
  before do
    Netaxept.reset!
  end

  after do
    Netaxept.reset!
  end

  it 'sets defaults' do
    Netaxept::Configurable.keys.each do |key|
      expect(Netaxept.instance_variable_get(:"@#{key}")).to eq Netaxept::Default.send(key)
    end
  end

  describe ".environment" do
    it "sets the base_uri to https://epayment.bbs.no/ when set to production" do
      Netaxept.configure do |config|
        config.environment = :production
      end

      expect(Netaxept.base_uri).to eq "https://epayment.bbs.no/"
    end

    it "sets the base_uri to https://epayment-test.bbs.no/ when set to test" do
      Netaxept.configure do |config|
        config.environment = :test
      end

      expect(Netaxept.base_uri).to eq "https://epayment-test.bbs.no/"
    end
  end


  # describe ".terminal_url" do

  #   it "returns the terminal url if you pass a transaction id" do
  #     Netaxept::Client.should_receive(:merchant_id).and_return("123133")
  #     Netaxept::Client.terminal_url("deadbeef00").should == "https://epayment-test.bbs.no/terminal/default.aspx?MerchantID=123133&TransactionID=deadbeef00"
  #   end

  #   it "has a production terminal url if the environment is production" do
  #     Netaxept::Client.environment = :production
  #       Netaxept::Client.should_receive(:merchant_id).and_return("123133")
  #       Netaxept::Client.terminal_url("deadbeef00").should == "https://epayment.bbs.no/terminal/default.aspx?MerchantID=123133&TransactionID=deadbeef00"
  #     Netaxept::Client.environment = :test
  #   end

  # end

  describe '.client' do
    it 'creates an Netaxept::Client' do
      expect(Netaxept.client).to be_kind_of Netaxept::Client
    end

    it 'caches the client when the same options are passed' do
      expect(Netaxept.client).to eq Netaxept.client
    end

    it 'returns a fresh client when options are not the same' do
      client = Netaxept.client
      Netaxept.merchant_id = 'somecustomer'
      client_two = Netaxept.client
      client_three = Netaxept.client
      expect(client).to_not eq client_two
      expect(client_three).to eq client_two
    end
  end

  describe '.configure' do
    Netaxept::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Netaxept.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Netaxept.instance_variable_get(:"@#{key}")).to eq key
      end
    end
  end
end