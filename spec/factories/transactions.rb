FactoryBot.define do
  factory :transaction do
    description { Faker::Lorem.sentence }
    amount_cents { Faker::Number.number(digits: 5) }
    divided_by { Transaction.divided_bies.keys.sample }
    selected_date { Date.today.strftime(Constants::API_DATE_FROMAT) }
    selected_time { Time.now.strftime(Constants::API_TIME_FROMAT) }
    user { create(:user) }
  end
end
