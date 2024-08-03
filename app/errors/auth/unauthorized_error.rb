# frozen_string_literal: true

module Auth
  class UnauthorizedError < StandardError
    def message
      'user is unauthorized'
    end
  end
end
