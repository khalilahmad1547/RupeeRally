FactoryBot.define do
  factory :user_transaction do
    description { "MyText" }
    transaction_type { 1 }
    user_share { 1 }
    amount_cents { 1 }
    status { 1 }
  end
end
