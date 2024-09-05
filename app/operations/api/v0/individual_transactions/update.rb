# frozen_string_literal: true

module Api::V0::IndividualTransactions
  class Update
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
        required(:description).filled(:string)
        required(:transaction_type).filled(:string, included_in?: UserTransaction.transaction_types.keys)
        required(:amount_cents).filled(:integer)
        required(:account_id).filled(:integer)
        required(:category_id).filled(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      yield fetch_parent_transaction
      yield validate_account_id
      yield validate_category_id
      records = yield update_transaction
      Success(json_serialize(records))
    end

    private

    attr_reader :params, :current_user, :account, :category, :parent_transaction

    def fetch_parent_transaction
      @parent_transaction = current_user.transactions.includes(:user_transactions).where('transactions.id = ? ',
                                                                                         params[:id]).first

      return Success(parent_transaction) if parent_transaction

      Failure(:not_found)
    end

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

    def update_transaction
      transaction = ::IndividualTransactions::UpdateService.call(update_params)
      Success(transaction)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
      Failure(e.message)
    end

    def update_params
      {
        account:,
        category:,
        description: params[:description],
        transaction_type: params[:transaction_type],
        amount_cents: params[:amount_cents],
        parent_transaction:
      }
    end

    def json_serialize(records)
      Api::V0::TransactionsSerializer.render_as_hash([records], root: :transactions)
    end
  end
end
