# frozen_string_literal: true

module Auth
  class InvalidTokenError < StandardError
    def message
      'jwt token is invalid'
    end
  end
end
