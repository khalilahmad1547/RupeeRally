# frozen_string_literal: true

module Api::V0::Transactions
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

      @transaction = yield fetch_transaction
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :transaction

    def fetch_transaction
      @transaction = current_user.transactions.includes(:user_transactions).where('transactions.id = ? ',
                                                                                  params[:id]).first

      return Success(transaction) if transaction

      Failure(:not_found)
    end

    def json_serialize
      Api::V0::TransactionsSerializer.render_as_hash([transaction], root: :transactions)
    end
  end
end
