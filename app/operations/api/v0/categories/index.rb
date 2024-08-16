# frozen_string_literal: true

module Api::V0::Categories
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
      @categories = current_user.categories

      records = process_categories
      Success(json_serialize(records))
    end

    private

    attr_reader :params, :current_user, :categories

    def process_categories
      @categories = categories.order(Arel.sql(sort_query))
      paginate(categories, params[:page], params[:per_page])
    end

    def sort_query
      "categories.#{sort_by} #{sort_direction}"
    end

    def sort_by
      permitted_columns = Category.column_names
      return params[:sort_by] if permitted_columns.include? params[:sort_by]

      'name'
    end

    def sort_direction
      return params[:sort_direction] if Constants::ORDER_DIRECTIONS.include?(params[:sort_direction])

      'asc'
    end

    def json_serialize(records)
      Api::V0::CategoriesSerializer.render_as_hash(records, root: :categories, meta: meta_date)
    end

    def meta_date
      {
        total: categories.count
      }
    end
  end
end
