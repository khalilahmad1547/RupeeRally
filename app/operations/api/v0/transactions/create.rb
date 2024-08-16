# frozen_string_literal: true

module Api::V0::Transactions
  class Create
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:description).filled(:string)
        required(:transaction_type).filled(:string, included_in?: UserTransaction.transaction_types.keys)
        required(:amount_cents).filled(:integer)
        required(:account_id).filled(:integer)
        required(:category_id).filled(:integer)
        optional(:divide_on).maybe(:array)
        optional(:division_method).value(:string, included_in?: Transaction.divided_bies.keys)
        optional(:user_share).maybe(:hash)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      puts "** #{params}"
      Success()
    end

    private

    attr_reader :params, :current_user, :account

    def create_transaction; end

    def json_serialize
      Api::V0::AccountsSerializer.render_as_hash([account], root: :accounts)
    end
  end
end
