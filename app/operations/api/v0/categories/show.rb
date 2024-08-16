# frozen_string_literal: true

module Api::V0::Categories
  class Show
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:id).filled(:integer)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      @category = yield fetch_category
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :category

    def fetch_category
      @category = current_user.categories.find_by(id: params[:id])

      return Success(category) if category

      Failure(:not_found)
    end

    def json_serialize
      Api::V0::CategoriesSerializer.render_as_hash([category], root: :categories)
    end
  end
end
