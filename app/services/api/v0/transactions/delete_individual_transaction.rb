# frozen_string_literal: true

module Api::V0::Transactions
  class DeleteIndividualTransaction < ::BaseService
    def call(parent_transaction)
      @parent_transaction = parent_transaction
      @user_transaction = parent_transaction.user_transactions.first
      @account = user_transaction.account
      @transaction_type = user_transaction.transaction_type
      @amount_cents = parent_transaction.amount_cents

      ActiveRecord::Base.transaction do
        update_account
        parent_transaction.destroy!
      end
    end

    private

    attr_reader :parent_transaction, :user_transaction, :account, :transaction_type, :amount_cents

    def update_account
      user_transaction.expense? ? account.record_expense(-amount_cents) : account.record_income(-amount_cents)
      account.save!
    end
  end
end
