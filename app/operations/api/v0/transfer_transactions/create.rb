# frozen_string_literal: true

module Api::V0::TransferTransactions
  class Create
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:from_account_id).filled(:integer)
        required(:to_account_id).filled(:integer)
        required(:description).filled(:string)
        required(:amount_cents).filled(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      yield validate_not_same_account
      yield validate_from_account_id
      yield validate_to_account_id
      transaction = yield create_transfer
      Success(json_serialize(transaction))
    end

    private

    attr_reader :current_user, :params, :from_account, :to_account

    def validate_not_same_account
      return Success() unless params[:from_account_id] == params[:to_account_id]

      Failure('Transfer should have two different accounts')
    end

    def validate_from_account_id
      @from_account = current_user.accounts.find_by(id: params[:from_account_id])
      return Success(from_account) if from_account

      Failure(:from_account_not_found)
    end

    def validate_to_account_id
      @to_account = current_user.accounts.find_by(id: params[:to_account_id])
      return Success(to_account) if to_account

      Failure(:to_account_not_found)
    end

    def create_transfer
      transaction = Api::V0::TransferTransactions::CreateService.call(current_user,
                                                                      params,
                                                                      from_account,
                                                                      to_account)
      Success(transaction)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
      Failure(e.message)
    end

    def json_serialize(records)
      Api::V0::TransactionsSerializer.render_as_hash([records], root: :transactions)
    end
  end
end
