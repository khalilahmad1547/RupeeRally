# frozen_string_literal: true

module Api::V0::Jwt
  module Authenticator
    module_function

    def call(headers:)
      token = Api::V0::Jwt::Authenticator.authenticate_header(
        headers
      )
      raise ::Auth::MissingTokenError if token.blank?

      decoded_token = Api::V0::Jwt::Decoder.call(access_token: token)
      raise ::Auth::UnauthorizedError unless decoded_token

      user = Api::V0::Jwt::Authenticator.authenticate_user_from_token(decoded_token)
      raise ::Auth::UnauthorizedError if user.blank?

      [user, decoded_token]
    end

    def authenticate_header(headers)
      headers['Authorization']&.split('Bearer ')&.last
    end

    def authenticate_user_from_token(decoded_token)
      raise ::Auth::InvalidTokenError unless decoded_token[:jti].present? && decoded_token[:user_id].present?

      user = User.find(decoded_token.fetch(:user_id))
      blacklisted = Api::V0::Jwt::Blacklister.blacklisted?(jti: decoded_token[:jti])

      user unless blacklisted
    end
  end
end
