class NotificationsController < ApplicationController
  def index
    @notifications = Notification.to_do_notifications(
      guest_id: current_user.id,
      host_id: current_user.id,
      cancel_request: "cancel_request",
      reserve: "reserve",
      cancel: "cancel"
    ).
      order(created_at: 'DESC').
      includes(guest: { image_attachment: :blob }, host: { image_attachment: :blob })
  end
end
