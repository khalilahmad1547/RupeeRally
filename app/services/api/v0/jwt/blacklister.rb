# frozen_string_literal: true

module Api::V0::Jwt
  module Blacklister
    module_function

    def blacklist!(jti:, user:)
      user.blacklisted_tokens.create!(
        jti:,
        exp: Time.now.utc
      )
    end

    def blacklisted?(jti:)
      BlacklistedToken.exists?(jti:)
    end
  end
end
