# frozen_string_literal: true

module Api::V0::Transactions
  class Update
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
        required(:name).filled(:string)
        optional(:initial_balance_cents).maybe(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      @account = yield fetch_account
      @account = yield update_account
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :account

    def fetch_account
      @account = current_user.accounts.find_by(id: params[:id])

      return Success(account) if account

      Failure(:not_found)
    end

    def update_account
      initial_balance_cents = params[:initial_balance_cents] || account.initial_balance_cents
      name = params[:name]

      return Success(account.reload) if account.update(name:, initial_balance_cents:)

      Failure(account.errors.full_messages)
    end

    def json_serialize
      Api::V0::AccountsSerializer.render_as_hash([account], root: :accounts)
    end
  end
end
