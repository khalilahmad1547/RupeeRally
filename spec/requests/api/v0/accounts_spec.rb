# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/accounts', type: :request do
  describe 'GET#index' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let!(:accounts) { create_list(:account, 100, user:) }
    let(:page) { nil }
    let(:per_page) { nil }
    let(:sort_by) { '' }
    let(:sort_direction) { 'asc' }
    let(:params) do
      {
        page:,
        per_page:,
        sort_by:,
        sort_direction:
      }
    end

    before { get '/api/v0/accounts', headers:, params: }

    describe 'success' do
      context 'without any params' do
        it 'should returns default number of accounts' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['accounts'].count).to eq(Constants::DEFAULT_PER_PAGE)
          expect(response).to match_json_schema('v0/account')
        end
      end

      context 'without per_page' do
        let(:per_page) { 5 }

        it 'should returns according to per_page value' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['accounts'].count).to eq(per_page)
          expect(response).to match_json_schema('v0/account')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'
    end
  end
end
