FactoryBot.define do
  factory :notification do
    action { '' }
    checked { false }

    association :reservation
    host { reservation.host }
    guest { reservation.guest }
  end
end
