# frozen_string_literal: true

module Api::V0
  class TransactionsController < ApiController
    def index
      Transactions::Index.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transactions| success_response(transactions, status: :ok) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def show
      Transactions::Show.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def create
      Transactions::Create.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { success_response }
        result.failure(:account_not_found) { not_found_response('Account not found') }
        result.failure(:category_not_found) { not_found_response('Category not found') }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def update
      Transactions::Update.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |transaction| success_response(transaction, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def destroy
      Transactions::Destroy.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { success_response }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
