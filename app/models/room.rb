class Room < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy
  has_one_attached :room_image

  validates :name, presence: { message: "が未入力です" }, on: :create
  validates :introduction, presence: { message: "が未入力です" }, on: :create
  validates :fee, presence: { message: "が未入力です" }, on: :create
  validates :adress, presence: { message: "が未入力です" }, on: :create
  validates :fee, numericality: { greater_than_or_equal_to: 1000, message: "は1泊1000円以上で設定してください" },
                  on: :create
  validates :room_image,  presence: { message: "を登録してください" },
                          content_type: ['image/png', 'image/jpeg', 'image/jpg'],
                          dimension: {
                            width: { max: 1000 },
                            height: { max: 1000 }, message: 'は幅1000px以内の画像を使用してください',
                          },
                          size: {
                            less_than_or_equal_to: 1.megabytes,
                            message: 'は1つのファイル1MB以内にしてください',
                          },
                          on: :create

  def self.ransackable_attributes(auth_object = {})
    %w(name introduction adress)
  end

  def self.ransackable_attribules(auth_object = {})
    []
  end
end
