FactoryBot.define do
  factory :reservation do
    checkin { (Date.today + 1) }
    checkout { (Date.today + 2) }
    number { 3 }
    payment { 1000 }
    cancel { false }
    cancel_request { false }

    association :room
    association :guest, factory: :user
    host { room.user }
  end
end
