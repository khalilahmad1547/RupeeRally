# frozen_string_literal: true

module Api::V0::Categories
  class Update
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
        optional(:name).maybe(:string)
        optional(:category_type).maybe(:string)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      @category = yield fetch_category
      @category = yield update_category
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :category

    def fetch_category
      @category = current_user.categories.find_by(id: params[:id])

      return Success(category) if category

      Failure(:not_found)
    end

    def update_category
      name = params[:name]
      category_type = params[:category_type]

      return Success(category.reload) if require_update? && category.update(name:, category_type:)

      Failure(category.errors.full_messages)
    end

    def require_update?
      params[:name] || params[:category_type]
    end

    def json_serialize
      Api::V0::CategoriesSerializer.render_as_hash([category], root: :categories)
    end
  end
end
