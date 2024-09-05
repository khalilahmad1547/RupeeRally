# frozen_string_literal: true

module Transfers
  class SameAccountError < ::CustomError
    def message
      'Transfer should have two different accounts'
    end
  end
end
