# frozen_string_literal: true

module Api::V0::Accounts
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
      @accounts = current_user.accounts

      records = process_accounts
      Success(json_serialize(records))
    end

    private

    attr_reader :params, :current_user, :accounts

    def process_accounts
      @accounts = accounts.order(Arel.sql(sort_query))
      paginate(accounts, params[:page], params[:per_page])
    end

    def sort_query
      "accounts.#{sort_by} #{sort_direction}"
    end

    def sort_by
      permitted_columns = Account.column_names
      return params[:sort_by] if permitted_columns.include? params[:sort_by]

      'name'
    end

    def sort_direction
      return params[:sort_direction] if Constants::ORDER_DIRECTIONS.include?(params[:sort_direction])

      'asc'
    end

    def json_serialize(records)
      Api::V0::AccountsSerializer.render_as_hash(records, root: :accounts, meta: meta_date)
    end

    def meta_date
      {
        total: accounts.count
      }
    end
  end
end
