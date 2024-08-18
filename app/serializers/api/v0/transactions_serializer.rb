# frozen_string_literal: true

module Api::V0
  class TransactionsSerializer < Blueprinter::Base
    identifier :id
    fields :description,
           :amount_cents,
           :divided_by,
           :selected_date,
           :selected_time
    association :user_transactions, blueprint: Api::V0::UserTransactionsSerializer
  end
end
