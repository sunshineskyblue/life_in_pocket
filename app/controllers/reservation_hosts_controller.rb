class ReservationHostsController < ApplicationController
  def index
    @reservations = current_user.host_reservations.
      where('checkout >= ? and cancel = ?', Date.today, false).
      order(checkin: 'ASC').
      includes(room: { room_image_attachment: :blob }).
      includes(:notifications)
  end

  def show
    @reservation = current_user.
      host_reservations.
      includes(:notifications).
      find_by(id: params[:id])

    @reservation.destroy_notifications(cancel: "cancel", reserve: "reserve")
  end

  def update
    @reservation = Reservation.find_by(id: params[:id])

    if @reservation.update(cancel_request: true)
      @reservation.create_cancel_requst_notification
      flash[:notice] = 'ゲストにキャンセルリクエストが送信されました'
      redirect_to reservation_hosts_path
    else
      render 'reservation_owners/show'
    end
  end

  def completed
    @reservations = current_user.host_reservations.
      where('checkout < ?', Date.today).
      or(current_user.host_reservations.where(cancel: true)).
      order(checkin: 'DESC').
      includes(room: { room_image_attachment: :blob }).
      includes(:notifications)
  end
end
