# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/transactions', type: :request do
  describe 'GET#index' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let!(:transactions) { create_list(:transaction, 100, user:) }
    let(:page) { 1 }
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

    before { get '/api/v0/transactions', headers:, params: }

    describe 'success' do
      context 'without any params' do
        it 'should returns default number of transactions' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['transactions'].count).to eq(Constants::DEFAULT_PER_PAGE)
          expect(response).to match_json_schema('v0/transactions/index')
        end
      end

      context 'with per_page' do
        let(:per_page) { 5 }

        it 'should returns according to per_page value' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['transactions'].count).to eq(per_page)
          expect(response).to match_json_schema('v0/transactions/index')
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
    let(:transactions) { create_list(:transaction, 100, user:) }
    let(:selected_transactions) { transactions.sample }

    before { get "/api/v0/transactions/#{selected_transactions.id}", headers: }

    describe 'success' do
      context 'when transaction id is valid' do
        it 'returns transactions' do
          expect(response).to be_ok
          expect(response.parsed_body['data']['transactions'].count).to eq(1)
          expect(response.parsed_body['data']['transactions'].first['id']).to eq(selected_transactions.id)
          expect(response).to match_json_schema('v0/transactions/show')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when transaction id is not valid' do
        let(:selected_transactions) { create(:transaction) }

        it 'returns not_found' do
          expect(response).to be_not_found
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
    let(:accounts) { create_list(:account, 10, user:) }
    let(:selected_account) { accounts.sample }
    let(:account_id) { selected_account.id }
    let!(:previous_balance) { selected_account.balance_cents }
    let!(:previous_total_income) { selected_account.total_income_cents }
    let!(:previous_total_expense) { selected_account.total_expense_cents }
    let(:amount_cents) { Faker::Number.number(digits: 5) }
    let(:transaction) { create(:transaction, user:, divided_by: 0, amount_cents:) }
    let(:transaction_type) { 'income' }
    let!(:user_transaction) do
      create(:user_transaction,
             user:,
             paid_by: user,
             transaction_type:,
             account: selected_account,
             parent_transaction: transaction,
             amount_cents:)
    end

    before { delete "/api/v0/transactions/#{transaction.id}", headers: }

    describe 'success' do
      context 'when transaction id is valid' do
        context 'when income transaction' do
          it 'deletes transaction and update account balance' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/destroy')
            expect(Transaction.find_by(id: transaction.id)).to be_nil
            selected_account.reload
            expect(selected_account.balance_cents).to eql(previous_balance - amount_cents)
            expect(selected_account.total_income_cents).to eql(previous_total_income - amount_cents)
            expect(selected_account.total_expense_cents).to eql(previous_total_expense)
          end
        end

        context 'when expense transaction' do
          let(:transaction_type) { 'expense' }

          it 'deletes transaction and update account balance' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/destroy')
            expect(Transaction.find_by(id: transaction.id)).to be_nil
            selected_account.reload
            expect(selected_account.balance_cents).to eql(previous_balance + amount_cents)
            expect(selected_account.total_income_cents).to eql(previous_total_income)
            expect(selected_account.total_expense_cents).to eql(previous_total_expense - amount_cents)
          end
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when transaction id is not valid' do
        let(:transaction) { create(:transaction) }

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end
    end
  end
end
