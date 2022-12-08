class Reservation < ApplicationRecord
  belongs_to :room
  belongs_to :guest, class_name: 'User'
  belongs_to :host, class_name: 'User'
  has_many   :notifications, dependent: :destroy

  validates :room_id, presence: true, on: :create
  validates :guest_id, presence: true, on: :create
  validates :host_id, presence: true, on: :create
  validates :checkin, presence: { message: "が未入力です" }, on: :create
  validates :checkout, presence: { message: "が未入力です" }, on: :create
  validates :number, presence: { message: "が未入力です" },
                     numericality: { greater_than: 0, message: "は１名以上で入力してください" },
                     on: :create
  validates :cancel, inclusion: { in: [true, false] }, on: :update
  validates :cancel_request, inclusion: { in: [true, false] }, on: :update

  validate :disallow_checkout_before_or_equal_checkin,
           :disallow_checkin_before_or_equal_today,
           :disallow_double_booking,
           :disallow_reservation_by_host,
            on: :create

  scope :across_new_checkin,
    -> (room_id:, checkin:) {
      where(room_id: room_id).
        where('checkin <= ? and checkout >= ? ', checkin, checkin)
    }
  scope :across_new_checkout,
    -> (room_id:, checkout:) {
      where(room_id: room_id).
        where('checkin <= ? and checkout >= ?', checkout, checkout)
    }
  scope :between_checkin_checkout,
    -> (room_id:, checkin:, checkout:) {
      where(room_id: room_id).
        where('checkin >= ? and checkout <= ?', checkin, checkout)
    }

  def stay_length
    (checkout - checkin).to_i
  end

  def payment
    self.payment = room.fee.to_i * stay_length
  end

  def canceled?
    cancel
  end

  def cancel_requested?
    cancel_request unless canceled?
  end

  def ongoing?
    Date.today <= checkout unless canceled?
  end

  def has_user_as_host?(user_id:)
    host_id == user_id
  end

  def has_user_as_guest?(user_id:)
    guest_id == user_id
  end

  def has_notifications_unchecked_by_host?(host_id:)
    notifications.each do |notification|
      if !notification.checked? && notification.has_action_for_host?(user_id: host_id)
        return true
        break
      else
        next
      end
    end

    false
  end

  def cancel_completed?(user_id:)
    canceled? && (has_user_as_guest?(user_id: user_id) ||
    has_user_as_host?(user_id: user_id) && !has_notifications_unchecked_by_host?(host_id: user_id))
  end

  # TODO: コード位置再検討
  def create_cancel_notification
    Notification.create(
      reservation_id: id,
      guest_id: guest_id,
      host_id: host_id,
      action: 'cancel'
    )
  end

  # TODO: コード位置再検討
  def create_reservation_notification
    Notification.create(
      reservation_id: id,
      guest_id: guest_id,
      host_id: host_id,
      action: 'reserve'
    )
  end

  # TODO: コード位置再検討
  def create_cancel_requst_notification
    Notification.create(
      reservation_id: id,
      guest_id: guest_id,
      host_id: host_id,
      action: 'cancel_request'
    )
  end

  # TODO: コード位置再検討
  def destroy_cancel_requst_notification
    Notification.
      where('reservation_id = ?
        and guest_id = ?
        and host_id = ?
        and action = ?',
        id, guest_id, host_id, "cancel_request").
      destroy_all                                  # recordが無ければ空の配列を返す。返り値確認は現状不要
  end

  private

  def disallow_checkout_before_or_equal_checkin
    if !checkout&.after? checkin
      errors.add(:checkout, "は#{Reservation.human_attribute_name :checkin}より先の日付で入力してください")
    end
  end

  def disallow_checkin_before_or_equal_today
    errors.add(:checkin, "は本日より先の日付で入力してください") if !checkin&.after? Time.zone.now
  end

  def disallow_double_booking
    reservation = Reservation.where(cancel: false)

    has_reserved =
      reservation.
        across_new_checkin(room_id: room_id, checkin: checkin)&.first ||
      reservation.
        across_new_checkout(room_id: room_id, checkout: checkout)&.first ||
      reservation.
        between_checkin_checkout(room_id: room_id, checkin: checkin, checkout: checkout)&.first

    if has_reserved.present?
      errors.add(:base, "恐れ入りますが、空室がございません。\n予約済み1件 #{has_reserved.checkin} ~ #{has_reserved.checkout}")
    end
  end

  def disallow_reservation_by_host
    if host_id == guest_id
      errors.add(:base, "ホスト自身の物件を予約することはできません")
    end
  end
end
