# frozen_string_literal: true

module Api::V0::TransferTransactions
  class CreateService < ::BaseService
    def call(params)
      process_params(params)

      ActiveRecord::Base.transaction do
        create_parent_transaction
        create_from_account_transaction
        create_to_account_transaction
        update_from_account
        update_to_account
      end

      parent_transaction
    end

    private

    attr_reader :current_user,
                :from_account,
                :to_account,
                :description,
                :amount_cents,
                :parent_transaction

    def process_params(params)
      @current_user = params[:current_user]
      @from_account = params[:from_account]
      @to_account = params[:to_account]
      @description = params[:description]
      @amount_cents = params[:amount_cents]
    end

    def create_parent_transaction
      parent_trn_desc = "Transfer from #{from_account.name} to #{to_account.name} account"
      @parent_transaction = Transaction.create!(user: current_user,
                                                description: parent_trn_desc,
                                                amount_cents:,
                                                divided_by: :by_none,
                                                transaction_type: :transfer)
    end

    def create_from_account_transaction
      from_acc_desc = "Transfered to #{to_account.name} account for '#{description}'"
      UserTransaction.create!(user: current_user,
                              description: from_acc_desc,
                              transaction_type: :expense,
                              user_share: 100,
                              amount_cents:,
                              account: from_account,
                              parent_transaction:,
                              paid_by: current_user)
    end

    def create_to_account_transaction
      to_acc_desc = "Transfered from #{from_account.name} account for '#{description}'"
      UserTransaction.create!(user: current_user,
                              description: to_acc_desc,
                              transaction_type: :income,
                              user_share: 100,
                              amount_cents:,
                              account: to_account,
                              parent_transaction:,
                              paid_by: current_user)
    end

    def update_from_account
      from_account.record_expense(amount_cents)
      from_account.save!
    end

    def update_to_account
      to_account.record_income(amount_cents)
      to_account.save!
    end
  end
end
