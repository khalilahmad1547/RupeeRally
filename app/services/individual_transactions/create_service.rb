# frozen_string_literal: true

module IndividualTransactions
  class CreateService < ::BaseService
    def call(params)
      process_params(params)

      ActiveRecord::Base.transaction do
        create_parent_transaction
        create_user_transaction
        update_account
      end

      parent_transaction
    end

    private

    attr_reader :current_user,
                :params,
                :description,
                :amount_cents,
                :transaction_type,
                :account,
                :category,
                :parent_transaction,
                :user_transaction

    def process_params(params)
      @params = params
      @current_user = params[:current_user]
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @transaction_type = params[:transaction_type]
      @account = params[:account]
      @category = params[:category]
    end

    def create_parent_transaction
      @parent_transaction = Transaction.create!(user: current_user,
                                                description:,
                                                amount_cents:,
                                                divided_by: :by_none,
                                                transaction_type: :individual)
    end

    def create_user_transaction
      @user_transaction = UserTransaction.create!(user: current_user,
                                                  description:,
                                                  transaction_type:,
                                                  user_share: 100,
                                                  amount_cents:,
                                                  account:,
                                                  category:,
                                                  parent_transaction:,
                                                  paid_by: current_user)
    end

    def update_account
      user_transaction.expense? ? account.record_expense(amount_cents) : account.record_income(amount_cents)
      account.save!
    end
  end
end
