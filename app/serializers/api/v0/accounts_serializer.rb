# frozen_string_literal: true

module Api::V0
  class AccountsSerializer < Blueprinter::Base
    identifier :id
    fields :name,
           :balance_cents,
           :total_income_cents,
           :total_expense_cents,
           :initial_balance_cents
  end
end
