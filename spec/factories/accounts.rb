FactoryBot.define do
  factory :account do
    name { 'Cash' }
    balance_cents { Faker::Number.number(digits: 5) }
    total_income { Faker::Number.number(digits: 5) }
    total_expense { Faker::Number.number(digits: 5) }
  end
end
