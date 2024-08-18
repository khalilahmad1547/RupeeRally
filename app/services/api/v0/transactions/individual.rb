# frozen_string_literal: true

module Api::V0::Transactions
  module Individual
    module_function

    def create(current_user, description, transaction_type, amount_cents, account, category)
      ActiveRecord::Base.transaction do
        parent_transaction = Transaction.create!(user: current_user, description:, amount_cents:, divided_by: :by_none)
        user_transaction = UserTransaction.create!(user: current_user,
                                                   description:,
                                                   transaction_type:,
                                                   user_share: 100,
                                                   amount_cents:,
                                                   account:,
                                                   category:,
                                                   parent_transaction:,
                                                   paid_by: current_user)
        user_transaction.expense? ? account.record_expense(amount_cents) : account.record_income(amount_cents)
        account.save!
        parent_transaction
      end
    end
  end
end
