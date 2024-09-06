# frozen_string_literal: true

module Api::V0
  class IndividualTransactionsController < ApiController
    def create
      Api::V0::IndividualTransactions::Create.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :created) }
        result.failure(:account_not_found) { not_found_response('Account not found') }
        result.failure(:category_not_found) { not_found_response('Category not found') }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def update
      Api::V0::IndividualTransactions::Update.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure(:account_not_found) { not_found_response('Account not found') }
        result.failure(:category_not_found) { not_found_response('Category not found') }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
