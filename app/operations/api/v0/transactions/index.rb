# frozen_string_literal: true

module Api::V0::Transactions
  class Index
    include ApplicationService

    class Contract < ApplicationContract
      params do
        optional(:page).maybe(:integer)
        optional(:per_page).maybe(:integer)
        optional(:sort_by).maybe(:string)
        optional(:sort_direction).maybe(:string)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user
      @transactions = current_user.transactions.includes(:child_transactions)

      records = process_transactions
      Success(json_serialize(records))
    end

    private

    attr_reader :params, :current_user, :transactions

    def process_transactions
      @transactions = transactions.order(Arel.sql(sort_query))
      paginate(transactions, params[:page], params[:per_page])
    end

    def sort_query
      "transactions.#{sort_by} #{sort_direction}"
    end

    def sort_by
      permitted_columns = Transaction.column_names
      return params[:sort_by] if permitted_columns.include? params[:sort_by]

      'created_at'
    end

    def sort_direction
      return params[:sort_direction] if Constants::ORDER_DIRECTIONS.include?(params[:sort_direction])

      'desc'
    end

    def json_serialize(records)
      Api::V0::TransactionsSerializer.render_as_hash(records, root: :transactions, meta: meta_date)
    end

    def meta_date
      {
        total: transactions.count
      }
    end
  end
end
