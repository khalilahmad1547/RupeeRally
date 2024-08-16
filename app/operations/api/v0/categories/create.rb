# frozen_string_literal: true

module Api::V0::Categories
  class Create
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:name).filled(:string)
        required(:category_type).filled(:string)
      end
    end

    def execute(params, current_user:)
      @params = params
      @current_user = current_user

      yield create_category
      Success(json_serialize)
    end

    private

    attr_reader :params, :current_user, :category

    def create_category
      @category = Category.new(name: params[:name], category_type: params[:category_type], user: current_user)

      return Success(category) if category.save

      Failure(category.errors.full_messages)
    end

    def json_serialize
      Api::V0::CategoriesSerializer.render_as_hash([category], root: :categories)
    end
  end
end
