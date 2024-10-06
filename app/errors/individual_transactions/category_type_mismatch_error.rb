# frozen_string_literal: true

module IndividualTransactions
  class CategoryTypeMismatchError < ::CustomError
    def message
      'Category type should be same as transaction type'
    end
  end
end
