# frozen_string_literal: true

module Api::V0::Jwt
  class Encoder
    attr_reader :user, :jti, :exp

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
      @jti = SecureRandom.hex
      @exp = token_expiry
    end

    def call
      access_token = new_jwt

      [access_token, jti, exp]
    end

    def new_jwt
      JWT.encode(
        {
          user_id: user.id,
          jti:,
          iat: token_issued_at,
          exp:
        },
        ENV.fetch('SECRET_KEY_BASE', nil)
      )
    end

    def token_expiry
      token_issued_at + Constants::SESSION_LIFETIME.to_i
    end

    def token_issued_at
      Time.now.utc.to_i
    end
  end
end
