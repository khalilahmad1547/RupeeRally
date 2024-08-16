# frozen_string_literal: true

module Api::V0
  class CategoriesSerializer < Blueprinter::Base
    identifier :id
    fields :name,
           :amount_cents,
           :category_type
  end
end
