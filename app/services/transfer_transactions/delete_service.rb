# frozen_string_literal: true

module TransferTransactions
  class DeleteService < ::BaseService
    def call(parent_transaction)
      @parent_transaction = parent_transaction
      @from_account = parent_transaction.user_transactions.expense.account
      @to_account = parent_transaction.user_transactions.income.account
      @previous_amount = parent_transaction.amount_cents

      ActiveRecord::Base.transaction do
        update_from_account
        update_to_account
        parent_transaction.destroy!
      end
    end

    private

    attr_reader :parent_transaction, :from_account, :to_account, :previous_amount

    def update_from_account
      from_account.record_expense(-previous_amount)
      from_account.save!
    end

    def update_to_account
      to_account.record_income(-previous_amount)
      to_account.save!
    end
  end
end
