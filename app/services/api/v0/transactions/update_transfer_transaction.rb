# frozen_string_literal: true

module Api::V0::Transactions
  class UpdateTransferTransaction < ::BaseService
    def call(parent_transaction, params, from_account, to_account)
      set_params(parent_transaction, params, from_account, to_account)
      update_transfer
      parent_transaction.reload
    end

    private

    attr_reader :parent_transaction,
                :from_account,
                :to_account,
                :description,
                :amount_cents,
                :previous_from_acc,
                :previous_to_acc,
                :previous_amount

    def set_params(parent_transaction, params, from_account, to_account)
      @parent_transaction = parent_transaction
      @from_account = from_account
      @to_account = to_account
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @previous_from_acc = parent_transaction.user_transactions.expense.account
      @previous_to_acc = parent_transaction.user_transactions.income.account
      @previous_amount = parent_transaction.amount_cents
    end

    def update_transfer
      ActiveRecord::Base.transaction do
        revert_previous_from_acc_change
        revert_previous_to_acc_change
        record_from_account_change
        record_update_to_account_change
        update_parent_transaction
        update_from_account_transaction
        update_to_account_transaction
      end
    end

    def revert_previous_from_acc_change
      @previous_from_acc = previous_from_acc
      previous_from_acc.record_expense(-previous_amount)
      previous_from_acc.save!
    end

    def revert_previous_to_acc_change
      @previous_to_acc = previous_to_acc
      previous_to_acc.record_income(-previous_amount)
      previous_to_acc.save!
    end

    def record_from_account_change
      @from_account = from_account.reload
      from_account.record_expense(amount_cents)
      from_account.save!
    end

    def record_update_to_account_change
      @to_account = to_account.reload
      to_account.reload.record_income(amount_cents)
      to_account.save!
    end

    def update_parent_transaction
      parent_trn_desc = "Transfer from #{from_account.name} to #{to_account.name} account"
      @parent_transaction = Transaction.update!(description: parent_trn_desc, amount_cents:)
    end

    def update_from_account_transaction
      from_acc_desc = "Transfered to #{to_account.name} account for '#{description}'"
      UserTransaction.update!(description: from_acc_desc,
                              amount_cents:,
                              account: from_account,
                              parent_transaction:)
    end

    def update_to_account_transaction
      to_acc_desc = "Transfered from #{from_account.name} account for '#{description}'"
      UserTransaction.update!(description: to_acc_desc,
                              amount_cents:,
                              account: to_account)
    end
  end
end
