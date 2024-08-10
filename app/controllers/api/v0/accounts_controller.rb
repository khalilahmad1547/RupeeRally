# frozen_string_literal: true

module Api::V0
  class AccountsController < ApiController
    def index
      Accounts::Index.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |accounts| success_response(accounts, status: :ok) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def create
      Accounts::Create.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |data| success_response(data, status: :created) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
