# frozen_string_literal: true

module Api::V0
  class TransfersController < ApiController
    def create
      Transfers::Create.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :created) }
        result.failure(:from_account_not_found) { not_found_response('From account not found') }
        result.failure(:to_account_not_found) { not_found_response('To account not found') }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def update; end

    def destroy; end
  end
end
