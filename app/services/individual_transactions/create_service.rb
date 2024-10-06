# frozen_string_literal: true

module IndividualTransactions
  class CreateService < ::BaseService
    def call(params)
      process_params(params)

      ActiveRecord::Base.transaction do
        validate_category
        create_parent_transaction
        update_account
        update_category
      end

      parent_transaction
    end

    private

    attr_reader :current_user,
                :params,
                :description,
                :amount_cents,
                :direction,
                :account,
                :category,
                :parent_transaction

    def process_params(params)
      @params = params
      @current_user = params[:current_user]
      @description = params[:description]
      @amount_cents = params[:amount_cents]
      @direction = params[:direction]
      @account = params[:account]
      @category = params[:category]
    end

    def validate_category
      raise CategoryTypeMismatchError unless category.category_type == direction
    end

    def create_parent_transaction
      @parent_transaction = Transaction.create!(user: current_user,
                                                description:,
                                                direction:,
                                                amount_cents:,
                                                divided_by: :by_none,
                                                user_share: 100,
                                                transaction_type: :individual,
                                                category:,
                                                paid_by: current_user,
                                                account:)
    end

    def update_account
      parent_transaction.expense? ? account.record_expense(amount_cents) : account.record_income(amount_cents)
      account.save!
    end

    def update_category
      category.update_balance(amount_cents)
      category.save!
    end
  end
end
