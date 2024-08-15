# frozen_string_literal: true

module Api::V0
  class AccountsController < ApiController
    def index
      Accounts::Index.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |accounts| success_response(accounts, status: :ok) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def show
      Accounts::Show.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |data| success_response(data, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def create
      Accounts::Create.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |data| success_response(data, status: :created) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def update
      Accounts::Update.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { |data| success_response(data, status: :ok) }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def destroy
      Accounts::Destroy.call(params.to_unsafe_h, current_user: @current_user) do |result|
        result.success { success_response }
        result.failure(:not_found) { not_found_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
