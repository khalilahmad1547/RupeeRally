FactoryBot.define do
  factory :account do
    name { "MyString" }
    balance_cents { 1 }
    total_income { 1 }
    total_expense { 1 }
  end
end
