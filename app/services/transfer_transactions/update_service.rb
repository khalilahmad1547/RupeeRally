# frozen_string_literal: true

module TransferTransactions
  class UpdateService < ::BaseService
    def call(params)
      process_params(params)
      set_user_transactions
      set_previous_accounts
      set_current_accounts
      validate_not_same_account
      update_transfer
      parent_transaction.reload
    end

    private

    attr_reader :params,
                :parent_transaction,
                :expense_transaction,
                :income_transaction,
                :from_account,
                :to_account,
                :description,
                :amount_cents,
                :previous_from_acc,
                :previous_to_acc,
                :previous_amount

    def process_params(params)
      @params = params
      @parent_transaction = params[:parent_transaction]
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @previous_amount = parent_transaction.amount_cents
    end

    def set_user_transactions
      @expense_transaction = parent_transaction.user_transactions.expense.first
      @income_transaction = parent_transaction.user_transactions.income.first
    end

    def set_previous_accounts
      @previous_from_acc = expense_transaction.account
      @previous_to_acc = income_transaction.account
    end

    def set_current_accounts
      @from_account = params[:from_account].presence || previous_from_acc
      @to_account = params[:to_account].presence || previous_to_acc
    end

    def validate_not_same_account
      raise Transfers::SameAccountError if same_from_acc? || same_to_acc?
    end

    def same_from_acc?
      from_account.id != previous_from_acc.id && from_account.id != previous_to_acc.id
    end

    def same_to_acc?
      to_account.id != previous_to_acc.id && to_account.id == previous_from_acc.id
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
      parent_transaction.update!(description: parent_trn_desc, amount_cents:)
    end

    def update_from_account_transaction
      from_acc_desc = "Transfered to #{to_account.name} account for '#{description}'"
      expense_transaction.update!(description: from_acc_desc,
                                  amount_cents:,
                                  account: from_account)
    end

    def update_to_account_transaction
      to_acc_desc = "Transfered from #{from_account.name} account for '#{description}'"
      income_transaction.update!(description: to_acc_desc,
                                 amount_cents:,
                                 account: to_account)
    end
  end
end
