FactoryBot.define do
  factory :user_transaction do
    description { 'my expense' }
    transaction_type { 1 }
    user_share { 1 }
    amount_cents { Faker::Number.number(digits: 5) }
    status { 0 }
  end
end
