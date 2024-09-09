# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/transfer_transactions', type: :request do
  describe 'POST#create' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end

    let(:description) { Faker::Lorem.sentence }
    let(:amount_cents) { Faker::Number.number(digits: 5) }
    let(:from_account) { create(:account, user:) }
    let(:from_account_id) { from_account.id }
    let!(:previous_from_acc_balance) { from_account.balance_cents }
    let!(:previous_from_acc_total_income) { from_account.total_income_cents }
    let!(:previous_from_acc_total_expense) { from_account.total_expense_cents }
    let(:to_account) { create(:account, user:) }
    let!(:previous_to_acc_balance) { to_account.balance_cents }
    let!(:previous_to_acc_total_income) { to_account.total_income_cents }
    let!(:previous_to_acc_total_expense) { to_account.total_expense_cents }
    let(:to_account_id) { to_account.id }
    let(:params) do
      {
        description:,
        amount_cents:,
        from_account_id:,
        to_account_id:
      }
    end

    before { post '/api/v0/transfer_transactions', headers:, params: }

    describe 'success' do
      context 'when params are valid' do
        it 'create transactions and update from and to account balances' do
          expect(response).to be_created
          transactions = response.parsed_body['data']['transactions']
          user_transactions = transactions.first['user_transactions']
          expect(transactions.count).to eq(1)
          expect(transactions.first['amount_cents']).to eq(amount_cents)
          expect(user_transactions.count).to eq(2)
          expect(user_transactions.first['amount_cents']).to eq(amount_cents)
          expect(user_transactions.second['amount_cents']).to eq(amount_cents)

          from_acc = from_account.reload
          expect(from_acc.balance_cents).to eql(previous_from_acc_balance - amount_cents)
          expect(from_acc.total_income_cents).to eql(previous_from_acc_total_income)
          expect(from_acc.total_expense_cents).to eql(previous_from_acc_total_expense + amount_cents)

          to_acc = to_account.reload
          expect(to_acc.balance_cents).to eql(previous_to_acc_balance + amount_cents)
          expect(to_acc.total_income_cents).to eql(previous_to_acc_total_income + amount_cents)
          expect(to_acc.total_expense_cents).to eql(previous_to_acc_total_expense)
        end
      end
    end

    describe 'failour' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when params are not valid' do
        context 'when from account id is missing' do
          let(:params) do
            {
              description:,
              amount_cents:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when to account id is missing' do
          let(:params) do
            {
              description:,
              amount_cents:,
              from_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when description is missing' do
          let(:params) do
            {
              amount_cents:,
              from_account_id:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when amount is missing' do
          let(:params) do
            {
              description:,
              from_account_id:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end
      end

      context 'when same id is given for from and to account' do
        let(:params) do
          {
            description:,
            amount_cents:,
            from_account_id: to_account_id,
            to_account_id:
          }
        end

        it 'create transactions and update from and to account balances' do
          expect(response).to be_unprocessable
          from_acc = from_account.reload
          expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
          to_acc = to_account.reload
          expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
        end
      end
    end
  end

  describe 'PUT#update' do
    let(:user) { create(:user) }
    let(:access_token) { valid_jwt(user) }
    let(:headers) do
      {
        Authorization: access_token
      }
    end

    let(:description) { Faker::Lorem.sentence }
    let(:amount_cents) { Faker::Number.number(digits: 5) }
    let(:from_account) { create(:account, user:) }
    let(:from_account_id) { from_account.id }
    let!(:previous_from_acc_balance) { from_account.balance_cents }
    let!(:previous_from_acc_total_income) { from_account.total_income_cents }
    let!(:previous_from_acc_total_expense) { from_account.total_expense_cents }
    let(:to_account) { create(:account, user:) }
    let!(:previous_to_acc_balance) { to_account.balance_cents }
    let!(:previous_to_acc_total_income) { to_account.total_income_cents }
    let!(:previous_to_acc_total_expense) { to_account.total_expense_cents }
    let(:to_account_id) { to_account.id }
    let(:params) do
      {
        description:,
        amount_cents:,
        from_account_id:,
        to_account_id:
      }
    end

    before { post '/api/v0/transfer_transactions', headers:, params: }

    describe 'success' do
      context 'when params are valid' do
        it 'create transactions and update from and to account balances' do
          expect(response).to be_created
          transactions = response.parsed_body['data']['transactions']
          user_transactions = transactions.first['user_transactions']
          expect(transactions.count).to eq(1)
          expect(transactions.first['amount_cents']).to eq(amount_cents)
          expect(user_transactions.count).to eq(2)
          expect(user_transactions.first['amount_cents']).to eq(amount_cents)
          expect(user_transactions.second['amount_cents']).to eq(amount_cents)

          from_acc = from_account.reload
          expect(from_acc.balance_cents).to eql(previous_from_acc_balance - amount_cents)
          expect(from_acc.total_income_cents).to eql(previous_from_acc_total_income)
          expect(from_acc.total_expense_cents).to eql(previous_from_acc_total_expense + amount_cents)

          to_acc = to_account.reload
          expect(to_acc.balance_cents).to eql(previous_to_acc_balance + amount_cents)
          expect(to_acc.total_income_cents).to eql(previous_to_acc_total_income + amount_cents)
          expect(to_acc.total_expense_cents).to eql(previous_to_acc_total_expense)
        end
      end
    end

    describe 'failour' do
      include_context 'forbidden'
      include_context 'unauthorized'

      context 'when params are not valid' do
        context 'when from account id is missing' do
          let(:params) do
            {
              description:,
              amount_cents:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when to account id is missing' do
          let(:params) do
            {
              description:,
              amount_cents:,
              from_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when description is missing' do
          let(:params) do
            {
              amount_cents:,
              from_account_id:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end

        context 'when amount is missing' do
          let(:params) do
            {
              description:,
              from_account_id:,
              to_account_id:
            }
          end

          it 'create transactions and update from and to account balances' do
            expect(response).to be_unprocessable
            from_acc = from_account.reload
            expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
            to_acc = to_account.reload
            expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
          end
        end
      end

      context 'when same id is given for from and to account' do
        let(:params) do
          {
            description:,
            amount_cents:,
            from_account_id: to_account_id,
            to_account_id:
          }
        end

        it 'create transactions and update from and to account balances' do
          expect(response).to be_unprocessable
          from_acc = from_account.reload
          expect(from_acc.balance_cents).to eql(previous_from_acc_balance)
          to_acc = to_account.reload
          expect(to_acc.balance_cents).to eql(previous_to_acc_balance)
        end
      end
    end
  end
end
