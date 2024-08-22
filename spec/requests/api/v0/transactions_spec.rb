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

  describe 'POST#create' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end

    let(:description) { Faker::Lorem.sentence }
    let(:transaction_type) { 'income' }
    let(:amount_cents) { Faker::Number.number(digits: 5) }
    let(:accounts) { create_list(:account, 10, user:) }
    let(:selected_account) { accounts.sample }
    let(:account_id) { selected_account.id }
    let!(:previous_balance) { selected_account.balance_cents }
    let!(:previous_total_income) { selected_account.total_income_cents }
    let!(:previous_total_expense) { selected_account.total_expense_cents }
    let(:categories) { create_list(:category, 10, user:) }
    let(:selected_category) { categories.sample }
    let(:category_id) { selected_category.id }
    let(:params) do
      {
        description:,
        transaction_type:,
        amount_cents:,
        account_id:,
        category_id:
      }
    end

    before { post '/api/v0/transactions', headers:, params: }

    describe 'success' do
      context 'with income transaction type' do
        it 'creates and return new transaction increase account balance' do
          expect(response).to be_created
          expect(response.parsed_body['data']['transactions'].count).to eq(1)
          expect(response.parsed_body['data']['transactions'].first['description']).to eq(description)

          user_transactions = response.parsed_body['data']['transactions'].first['user_transactions'].first
          expect(user_transactions['account_id']).to eq(account_id)
          expect(user_transactions['category_id']).to eq(category_id)
          expect(user_transactions['amount_cents']).to eq(amount_cents)

          selected_account.reload
          expect(selected_account.balance_cents).to eql(previous_balance + amount_cents)
          expect(selected_account.total_income_cents).to eql(previous_total_income + amount_cents)
          expect(selected_account.total_expense_cents).to eql(previous_total_expense)
          expect(response).to match_json_schema('v0/transactions/create')
        end
      end

      context 'with income transaction type' do
        let(:transaction_type) { 'expense' }

        it 'creates and return new transaction increase account balance' do
          expect(response).to be_created
          expect(response.parsed_body['data']['transactions'].count).to eq(1)
          expect(response.parsed_body['data']['transactions'].first['description']).to eq(description)

          user_transactions = response.parsed_body['data']['transactions'].first['user_transactions'].first
          expect(user_transactions['account_id']).to eq(account_id)
          expect(user_transactions['category_id']).to eq(category_id)
          expect(user_transactions['amount_cents']).to eq(amount_cents)

          selected_account.reload
          expect(selected_account.balance_cents).to eql(previous_balance - amount_cents)
          expect(selected_account.total_income_cents).to eql(previous_total_income)
          expect(selected_account.total_expense_cents).to eql(previous_total_expense + amount_cents)
          expect(response).to match_json_schema('v0/transactions/create')
        end
      end
    end

    describe 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when account id is invalid' do
        let(:account_id) { create(:account).id }

        it 'returns not_found' do
          expect(response).to be_not_found
          expect(response.parsed_body['errors'][0]).to eq('Account not found')
        end
      end

      context 'when category id is invalid' do
        let(:category_id) { create(:category).id }

        it 'returns not_found' do
          expect(response).to be_not_found
          expect(response.parsed_body['errors'][0]).to eq('Category not found')
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

  describe 'PATCH#update' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:accounts) { create_list(:account, 10, user:) }
    let(:account_01) { accounts.sample }
    let(:account_01_id) { account_01.id }
    let!(:account_01_previous_balance) { account_01.balance_cents }
    let!(:account_01_previous_total_income) { account_01.total_income_cents }
    let!(:account_01_previous_total_expense) { account_01.total_expense_cents }
    let(:account_02) { accounts.sample }
    let(:account_02_id) { account_02.id }
    let!(:account_02_previous_balance) { account_02.balance_cents }
    let!(:account_02_previous_total_income) { account_02.total_income_cents }
    let!(:account_02_previous_total_expense) { account_02.total_expense_cents }
    let(:previous_amount) { Faker::Number.number(digits: 5) }
    let(:updated_amount) { Faker::Number.number(digits: 5) }
    let(:transaction) { create(:transaction, user:, divided_by: 0, amount_cents: previous_amount) }
    let(:category) { create(:category, user:) }
    let(:transaction_type) { 'income' }
    let!(:user_transaction) do
      create(:user_transaction,
             user:,
             paid_by: user,
             transaction_type:,
             account: account_01,
             parent_transaction: transaction,
             amount_cents: previous_amount,
             category:)
    end
    let(:params) do
      {
        description: transaction.description,
        transaction_type: user_transaction.transaction_type,
        amount_cents: updated_amount,
        account_id: account_01_id,
        category_id: category.id
      }
    end

    before { patch "/api/v0/transactions/#{transaction.id}", params:, headers: }

    context 'success' do
      context 'when account remain same transaction type & amount is changed' do
        context 'with income transaction' do
          it 'should update account balance and total income' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/update')
            account_01.reload
            expect(account_01.balance_cents).to eql(account_01_previous_balance - previous_amount + updated_amount)
            expect(account_01.total_income_cents).to eql(account_01_previous_total_income - previous_amount + updated_amount)
            expect(account_01.total_expense_cents).to eql(account_01_previous_total_expense)
          end
        end

        context 'with expense transaction' do
          let(:transaction_type) { 'expense' }

          it 'should update account balance and total expense' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/update')
            account_01.reload
            expect(account_01.balance_cents).to eql(account_01_previous_balance + previous_amount - updated_amount)
            expect(account_01.total_income_cents).to eql(account_01_previous_total_income)
            expect(account_01.total_expense_cents).to eql(account_01_previous_total_expense - previous_amount + updated_amount)
          end
        end
      end

      context 'when account is changed' do
        let(:params) do
          {
            description: transaction.description,
            transaction_type: user_transaction.transaction_type,
            amount_cents: updated_amount,
            account_id: account_02_id,
            category_id: category.id
          }
        end

        context 'with income transaction' do
          it 'should update both accounts balances and total income' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/update')
            account_01.reload
            account_02.reload
            expect(account_01.balance_cents).to eql(account_01_previous_balance - previous_amount)
            expect(account_01.total_income_cents).to eql(account_01_previous_total_income - previous_amount)
            expect(account_01.total_expense_cents).to eql(account_01_previous_total_expense)
            expect(account_02.balance_cents).to eql(account_02_previous_balance + updated_amount)
            expect(account_02.total_income_cents).to eql(account_02_previous_total_income + updated_amount)
            expect(account_02.total_expense_cents).to eql(account_02_previous_total_expense)
          end
        end

        context 'with expense transaction' do
          let(:transaction_type) { 'expense' }

          it 'should update account balance and total expense' do
            expect(response).to be_ok
            expect(response).to match_json_schema('v0/transactions/update')
            account_01.reload
            account_02.reload
            expect(account_01.balance_cents).to eql(account_01_previous_balance + previous_amount)
            expect(account_01.total_income_cents).to eql(account_01_previous_total_income)
            expect(account_01.total_expense_cents).to eql(account_01_previous_total_expense - previous_amount)
            expect(account_02.balance_cents).to eql(account_02_previous_balance - updated_amount)
            expect(account_02.total_income_cents).to eql(account_02_previous_total_income)
            expect(account_02.total_expense_cents).to eql(account_02_previous_total_expense + updated_amount)
          end
        end
      end
    end

    context 'failure' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when transaction id is not valid' do
        let(:transaction) { create(:transaction) }

        it 'returns not_found' do
          puts "** #{response.parsed_body}"
          expect(response).to be_not_found
        end
      end

      context 'when account id is not valid' do
        let(:account) { create(:account) }
        let(:params) do
          {
            description: transaction.description,
            transaction_type: user_transaction.transaction_type,
            amount_cents: updated_amount,
            account_id: account.id,
            category_id: category.id
          }
        end

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end

      context 'when category id is not valid' do
        let(:category) { create(:category) }
        let(:params) do
          {
            description: transaction.description,
            transaction_type: user_transaction.transaction_type,
            amount_cents: updated_amount,
            account_id: account_01_id,
            category_id: category.id
          }
        end

        it 'returns not_found' do
          expect(response).to be_not_found
        end
      end
    end
  end
end
