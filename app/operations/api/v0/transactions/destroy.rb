# frozen_string_literal: true

module Api::V0::Transactions
  class Destroy
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
      set_required_variables
      yield destroy_transaction
      Success()
    end

    private

    attr_reader :params,
                :current_user,
                :transaction,
                :transaction_type,
                :account,
                :amount_cents

    def fetch_transaction
      @transaction = current_user.transactions.includes(:user_transactions).where('transactions.id = ? ',
                                                                                  params[:id]).first

      return Success(transaction) if transaction

      Failure(:not_found)
    end

    def set_required_variables
      user_transaction = transaction.user_transactions.first
      @transaction_type = user_transaction.transaction_type
      @account = user_transaction.account
      @amount_cents = user_transaction.amount_cents
    end

    def destroy_transaction
      ActiveRecord::Base.transaction do
        transaction.destroy!
        update_account
      end

      Success()
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
      Failure(e.message)
    end

    def update_account
      transaction_type == 'expense' ? account.record_expense(-amount_cents) : account.record_income(-amount_cents)
      account.save!
    end
  end
end
