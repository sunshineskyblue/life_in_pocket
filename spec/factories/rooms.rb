FactoryBot.define do
  factory :room do
    name { "テストルーム" }
    introduction { "この部屋はテスト用です" }
    fee { "1000" }
    adress { "神奈川県横浜市" }
    room_image { fixture_file_upload('test.jpg') }

    association :user
  end
end
