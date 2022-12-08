class Notification < ApplicationRecord
  belongs_to :guest, class_name: 'User'
  belongs_to :host, class_name: 'User'
  belongs_to :reservation

  scope :action_unchecked,
    -> (action:, checked:) {
      where('action = ? and checked = ? ', action, checked)
    }

  scope :host_unchecked,
    -> (host_id:, checked:) {
      where('host_id = ? and checked = ? ', host_id, checked)
    }

  scope :guest_unchecked,
    -> (guest_id:, checked:) {
      where('guest_id = ? and checked = ? ', guest_id, checked)
    }

  scope :to_do_notifications,
    -> (guest_id:, host_id:, cancel_request:, reserve:, cancel:) {
      where('guest_id = ? and action = ?', guest_id, cancel_request).
        or(where('host_id = ? and action = ?', host_id, reserve)).
        or(where('host_id = ? and action = ?', host_id, cancel))
    }

  def unchecked_count_or_false_if_zero(user_id:)
    notifications = Notification.to_do_notifications(
      guest_id: user_id,
      host_id: user_id,
      cancel_request: "cancel_request",
      reserve: "reserve",
      cancel: "cancel"
    ).
      where(checked: false)

    return notifications.size if notifications.exists?
    false
  end

  def has_user_as_host?(user_id:)
    host_id == user_id
  end

  def has_user_as_guest?(user_id:)
    guest_id == user_id
  end

  def checked?
    checked
  end

  def has_action?(**actions)
    if action == actions[:cancel_request] ||
                   action == actions[:cancel] ||
                   action == actions[:reserve]
      return true
    end

    false
  end

  def has_action_for_host?(user_id:, **actions)
    reserve = actions[:reserve] || 'reserve'
    cancel = actions[:cancel] || 'cancel'

    if has_user_as_host?(user_id: user_id) && has_action?(reserve: reserve, cancel: cancel)
      return true
    end

    false
  end

  def has_action_for_guest?(user_id:, **actions)
    cancel_request = actions[:cancel_request] || 'cancel_request'

    if has_user_as_guest?(user_id: user_id) && has_action?(cancel_request: cancel_request)
      return true
    end

    false
  end
end
