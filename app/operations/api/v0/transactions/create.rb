# frozen_string_literal: true

module Api::V0::Transactions
  class Create
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:description).filled(:string)
        required(:transaction_type).filled(:string, included_in?: UserTransaction.transaction_types.keys)
        required(:amount_cents).filled(:integer)
        required(:account_id).filled(:integer)
        required(:category_id).filled(:integer)
        optional(:divide_on).maybe(:array)
        optional(:division_method).value(:string, included_in?: Transaction.divided_bies.keys)
        optional(:user_share).maybe(:hash)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      yield validate_account_id
      yield validate_category_id
      transaction = yield create_transaction
      Success(json_serialize(transaction))
    end

    private

    attr_reader :params, :current_user, :account, :category

    def validate_account_id
      account_id = params[:account_id]
      @account = current_user.accounts.find_by(id: account_id)
      return Success() if account_id && @account

      Failure(:account_not_found)
    end

    def validate_category_id
      category_id = params[:category_id]
      @category = current_user.categories.find_by(id: category_id)
      return Success() if category_id && category

      Failure(:category_not_found)
    end

    def create_transaction
      transaction = Api::V0::Transactions::CreateIndividualTransaction.call(current_user, params, account, category)
      Success(transaction)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
      Failure(e.message)
    end

    def json_serialize(records)
      Api::V0::TransactionsSerializer.render_as_hash([records], root: :transactions)
    end
  end
end
