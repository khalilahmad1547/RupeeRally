# frozen_string_literal: true

module Api::V0::IndividualTransactions
  class CreateService < ::BaseService
    def call(current_user, params, account, category)
      set_params(current_user, params, account, category)

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

    def set_params(current_user, params, account, category)
      @current_user = current_user
      @params = params
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @transaction_type = params[:transaction_type]
      @account = account
      @category = category
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
