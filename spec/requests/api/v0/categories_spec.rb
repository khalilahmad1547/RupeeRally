# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/categories', type: :request do
  describe 'GET#index' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let!(:categories) { create_list(:category, 100, user:) }
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

    before { get '/api/v0/categories', headers:, params: }

    describe 'success' do
      context 'without any params' do
        it 'should returns default number of categories' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['categories'].count).to eq(Constants::DEFAULT_PER_PAGE)
          expect(response).to match_json_schema('v0/categories/index')
        end
      end

      context 'without per_page' do
        let(:per_page) { 5 }

        it 'should returns according to per_page value' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['categories'].count).to eq(per_page)
          expect(response).to match_json_schema('v0/categories/index')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'
    end
  end

  describe 'GET#show' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:categories) { create_list(:category, 100, user:) }
    let(:selected_category) { categories.sample }

    before { get "/api/v0/categories/#{selected_category.id}", headers: }

    describe 'success' do
      context 'when category id is valid' do
        it 'returns category' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['categories'].count).to eq(1)
          expect(response.parsed_body['data']['categories'].first['id']).to eq(selected_category.id)
          expect(response).to match_json_schema('v0/categories/show')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when category id is not valid' do
        let(:selected_category) { create(:category) }

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end
    end
  end

  describe 'POST#create' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end

    let(:category_name) { 'test_category_no_01' }
    let(:category_type) { %i[income expense].sample.to_s }
    let(:params) do
      {
        name: category_name,
        category_type:
      }
    end

    before { post '/api/v0/categories', headers:, params: }

    describe 'success' do
      context 'with default params' do
        it 'creates and return new category with amount cents 0' do
          expect(response).to be_created
          expect(response.parsed_body['data']['categories'].count).to eq(1)
          expect(response.parsed_body['data']['categories'].first['amount_cents']).to eq(0)
          expect(response.parsed_body['data']['categories'].first['name']).to eq(category_name)
          expect(response.parsed_body['data']['categories'].first['category_type']).to eq(category_type.to_s)
          expect(response).to match_json_schema('v0/categories/create')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when category with name already exist' do
        let(:category) { create(:category, user:) }
        let(:params) do
          {
            name: category.name,
            category_type:
          }
        end

        it 'returns unprocessable' do
          expect(response).to be_unprocessable
          expect(response.parsed_body['errors'][0][0]).to eq('Name has already been taken')
        end
      end
    end
  end

  describe 'DELETE#destroy' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:categories) { create_list(:category, 100, user:) }
    let(:selected_category) { categories.sample }

    before { delete "/api/v0/categories/#{selected_category.id}", headers: }

    describe 'success' do
      context 'when category id is valid' do
        it 'deletes category' do
          expect(response).to be_ok
          expect(response).to match_json_schema('v0/categories/destroy')
          expect(Category.find_by(id: selected_category.id)).to be_nil
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when category id is not valid' do
        let(:selected_category) { create(:category) }

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end
    end
  end

  describe 'PATCH#update' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:categories) { create_list(:category, 100, user:) }
    let(:selected_category) { categories.sample }
    let(:updated_name) { 'other_account' }
    let(:updated_category_type) { %i[income expense].sample.to_s }
    let(:params) do
      {
        name: updated_name,
        category_type: updated_category_type
      }
    end

    before { patch "/api/v0/categories/#{selected_category.id}", params:, headers: }

    describe 'success' do
      context 'when category id is valid' do
        it 'updates category' do
          expect(response).to be_ok
          expect(response).to match_json_schema('v0/categories/update')
          category = Category.find_by(id: selected_category.id)
          expect(category.name).to eql(updated_name)
          expect(category.category_type).to eql(updated_category_type)
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when category id is not valid' do
        let(:selected_category) { create(:category) }

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end
    end
  end
end
