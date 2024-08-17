# frozen_string_literal: true

module Api::V0
  class TransactionsSerializer < Blueprinter::Base
    identifier :id
    fields :description,
           :transaction_type,
           :user_share,
           :amount_cents,
           :status,
           :user_id,
           :account_id,
           :category_id,
           :transaction_id,
           :paid_by_id
  end
end
