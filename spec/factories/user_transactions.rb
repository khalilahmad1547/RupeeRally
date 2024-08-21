FactoryBot.define do
  factory :user_transaction do
    description { Faker::Lorem.sentence }
    transaction_type { UserTransaction.transaction_types.keys.sample }
    user_share { 1 }
    amount_cents { Faker::Number.number(digits: 5) }
    status { 0 }
    account { create(:account) }
    category { create(:category) }
    parent_transaction { create(:transaction) }
  end
end
