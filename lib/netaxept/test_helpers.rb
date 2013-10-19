module Netaxept
  module TestHelpers

    #
    # Error:         None
    # Response code: OK
    def valid_cc
      "4925000000000004"
    end

    # Error:         REGISTER will go ok, but PROCESS AUTH or PROCESS SALE
    #                will fail. Use this cardnumber to validate your error
    #                handling of the PROCESS AUTH and PROCESS SALE command.
    # Response code: OK/99
    def fails_auth_and_sale_cc
      "4925000000000087"
    end

    # Error:         REGISTER and PROCESS AUTH will go ok, but the PROCESS
    #                CAPTURE will fail. Use this cardnumber to validate your
    #                error handing of the PROCESS CAPTURE command.
    # Response code: OK/OK/99
    def fails_capture_cc
      "4925000000000079"
    end
  end
end
