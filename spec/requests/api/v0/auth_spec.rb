# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/auth', type: :request do
  describe '/signup' do
    let(:email) { Faker::Internet.email }
    let(:name) { Faker::Name }
    let(:password) { Faker::Internet.password }
    let(:params) do
      {
        email:,
        name:,
        password:
      }
    end

    before { post '/api/v0/auth/signup', params: }

    describe 'success' do
      context 'when required params are provides' do
        it 'should create user' do
          expect(response).to be_created
          expect(response).to match_json_schema('v0/user')
        end
      end
    end

    describe 'failour' do
      context 'when email is not provided' do
        let(:email) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when name is not provided' do
        let(:name) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when password is not provided' do
        let(:password) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when user with email already exist' do
        let!(:user) { create(:user) }
        let(:params) do
          {
            email: user.email,
            name:,
            password:
          }
        end

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end
    end
  end

  describe '/signin' do
    let!(:user) { create(:user) }
    let(:email) { user.email }
    let(:password) { user.password }
    let(:params) do
      {
        email:,
        password:
      }
    end

    before { post '/api/v0/auth/signin', params: }

    describe 'success' do
      context 'when user credential are correct' do
        it 'returns ok response' do
          expect(response).to be_ok
        end
      end
    end
  end

  describe '/refresh' do
    let(:user) { create(:user) }
    let(:token_pair) { Jwt::Issuer.call(user) }
    let(:access_token) { valid_jwt(user) }
    let(:refresh_token) { token_pair[:refresh_token].token }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:params) do
      {
        access_token:,
        refresh_token:
      }
    end

    before { post '/api/v0/auth/refresh', headers:, params: }

    describe 'success' do
      context 'when access_token & refresh_token are valid' do
        it 'returns new access_token' do
          expect(response).to be_created
        end
      end
    end
  end
end
