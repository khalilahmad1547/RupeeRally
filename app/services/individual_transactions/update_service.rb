# frozen_string_literal: true

module IndividualTransactions
  class UpdateService < ::BaseService
    def call(params)
      process_params(params)

      ActiveRecord::Base.transaction do
        revert_previous_account_change
        add_updated_amount_to_account
        update_parent_transaction
        update_user_transaction
      end

      parent_transaction
    end

    private

    attr_reader :params,
                :description,
                :amount_cents,
                :transaction_type,
                :account,
                :category,
                :parent_transaction

    def process_params(params)
      @params = params
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @transaction_type = params[:transaction_type]
      @account = params[:account]
      @category = params[:category]
      @parent_transaction = params[:parent_transaction]
    end

    def user_transaction
      @user_transaction ||= parent_transaction.user_transactions.first
    end

    def previous_amount
      @previous_amount ||= parent_transaction.amount_cents
    end

    def previous_account
      @previous_account ||= user_transaction.account
    end

    def revert_previous_account_change
      if user_transaction.expense?
        previous_account.record_expense(-previous_amount)
      else
        previous_account.record_income(-previous_amount)
      end
      previous_account.save!
    end

    def add_updated_amount_to_account
      if transaction_type == 'expense'
        account.reload.record_expense(amount_cents)
      else
        account.reload.record_income(amount_cents)
      end
      account.save!
    end

    def update_parent_transaction
      parent_transaction.update!(description:, amount_cents:)
    end

    def update_user_transaction
      user_transaction.update!(description:,
                               transaction_type:,
                               user_share: 100,
                               amount_cents:,
                               account:,
                               category:)
    end
  end
end
