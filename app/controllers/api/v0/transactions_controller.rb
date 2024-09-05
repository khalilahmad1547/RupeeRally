# frozen_string_literal: true

module Api::V0
  class TransactionsController < ApiController
    def index
      Api::V0::Transactions::Index.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transactions| success_response(transactions, status: :ok) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def show
      Api::V0::Transactions::Show.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def destroy
      Api::V0::Transactions::Destroy.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { success_response }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
