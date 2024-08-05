FactoryBot.define do
  factory :transaction do
    description { "MyText" }
    amount_cents { 1 }
    divided_by { 1 }
  end
end
