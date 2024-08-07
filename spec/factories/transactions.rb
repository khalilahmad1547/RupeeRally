FactoryBot.define do
  factory :transaction do
    description { 'my expense' }
    amount_cents { Faker::Number.number(digits: 5) }
    divided_by { 1 }
  end
end
