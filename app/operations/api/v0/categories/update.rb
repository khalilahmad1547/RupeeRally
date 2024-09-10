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

      yield require_update?
      @category = yield fetch_category
      @category = yield update_category
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :category

    def require_update?
      return Success() if params.any? { |key, value| key != :id && value.present? }

      Failure('nothing to update')
    end

    def fetch_category
      @category = current_user.categories.find_by(id: params[:id])

      return Success(category) if category

      Failure(:not_found)
    end

    def update_category
      name = params[:name]
      category_type = params[:category_type]

      return Success(category.reload) if category.update(name:, category_type:)

      Failure(category.errors.full_messages)
    end

    def json_serialize
      Api::V0::CategoriesSerializer.render_as_hash([category], root: :categories)
    end
  end
end
