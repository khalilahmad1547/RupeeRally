# frozen_string_literal: true

module Api::V0::Accounts
  class Show
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      @account = yield fetch_account
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :account

    def fetch_account
      @account = current_user.accounts.find_by(id: params[:id])

      return Success(account) if account

      Failure(:not_found)
    end

    def json_serialize
      Api::V0::AccountsSerializer.render_as_hash([account], root: :accounts)
    end
  end
end
