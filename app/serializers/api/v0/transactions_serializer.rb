# frozen_string_literal: true

module Api::V0
  class TransactionsSerializer < Blueprinter::Base
    identifier :id
    fields :transaction_type,
           :direction,
           :description,
           :status,
           :amount_cents,
           :divided_by,
           :selected_date,
           :selected_time,
           :user_id,
           :account_id,
           :category_id,
           :paid_by_id
    field :created_at, datetime_format: '%H:%M %d:%m:%Y'
    association :child_transactions, blueprint: Api::V0::TransactionsSerializer
  end
end
