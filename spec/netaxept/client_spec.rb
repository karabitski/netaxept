require "spec_helper"

describe Netaxept::Client do

  let(:client) { Netaxept::Client.new }

  describe ".register" do

    describe "a valid request" do

      let(:response) { client.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return") }

      it "is successful" do
        expect(response).to be_successful
      end

      it "has a transaction_id" do
        expect(response.transaction_id).to_not be_nil
      end

    end

    describe "a request without error (no money)" do

      let(:response) { client.register(0, 12, :redirectUrl => "http://localhost:3000/order/1/return") }

      it "is not a success" do
        response.should fail.with_message("Transaction amount must be greater than zero.")
      end

      it "does not have a transaction id" do
        expect(response.transaction_id).to be_nil
      end

    end

  end

  context "with a transaction id" do

    let(:transaction_id) { client.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return").transaction_id }

    before do

      # Register some card data with the transaction.
      url = client.terminal_url(transaction_id)
      mechanic = Mechanize.new
      mechanic.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      mechanic.get(url) do |page|
        form = page.form_with(:name => "form1")
        cc_form = form.click_button(form.button_with(:value => /^Neste/)).form_with(:name => "form1") do |form|

          form.field_with(:id => "cardNo").value = "4925000000000004"
          form.field_with(:id => "month").options.last.tick
          form.field_with(:id => "year").options.last.tick
          form.field_with(:id => "securityCode").value = "111"

        end
        mechanic.redirect_ok = false
        cc_form.click_button(cc_form.button_with(:id => "okButton"))
      end

    end

    describe "a valid sale request" do

      it "is a success" do
        response = client.sale(transaction_id, 20100)
        expect(response).to be_successful
      end

    end

    describe "a valid auth request" do

      it "is a success" do
        response = client.auth(transaction_id, 20100)
        expect(response).to be_successful
      end

    end

    describe "a valid capture request" do

      it "is a success" do
        client.auth(transaction_id, 20100)
        response = client.capture(transaction_id, 20100)
        expect(response).to be_successful
      end

    end

    describe "a valid credit request" do

      it "is a success" do
        client.sale(transaction_id, 20100)
        response = client.credit(transaction_id, 20100)
        expect(response).to be_successful
      end
    end

    describe "a valid annul request" do

      it "is a success" do
        client.auth(transaction_id, 20100)
        response = client.annul(transaction_id)
        expect(response).to be_successful
      end
    end


  end
end