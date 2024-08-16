FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category##{n}" }
    amount_cents { Faker::Number.number(digits: 5) }
    category_type { %i[income expense].sample }
    user { create(:user) }
  end
end
