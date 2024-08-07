FactoryBot.define do
  factory :category do
    name { 'Food' }
    amount_cents { Faker::Number.number(digits: 5) }
    category_type { 1 }
  end
end
