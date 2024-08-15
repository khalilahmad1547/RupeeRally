FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account##{n}" }
    balance_cents { Faker::Number.number(digits: 5) }
    initial_balance_cents { Faker::Number.number(digits: 5) }
    total_income_cents { Faker::Number.number(digits: 5) }
    total_expense_cents { Faker::Number.number(digits: 5) }
    user { create(:user) }
  end
end
