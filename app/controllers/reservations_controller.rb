class ReservationsController < ApplicationController
  def new
    # 未ログインの場合  => ログイン画面につなぐ
    if !user_signed_in?
      redirect_to(new_user_session_path) && return
    end

    # プロフィール未登録 => 登録画面につなぐ
    if current_user.invalid?
      redirect_to(profile_user_profile_path(current_user.id)) && return
    end

    @reservation = Reservation.new(reservation_params_from_room)
    @reservation.guest_id = current_user.id
    @reservation.host_id = @reservation.room.user.id

    if @reservation.invalid?
      flash[:errors] = @reservation.errors.full_messages
      redirect_to(room_path(@reservation.room_id,
        :checkin => @reservation.checkin,
        :checkout => @reservation.checkout,
        :number => @reservation.number)) && return
    end
    @reservation.payment
    @stay_length = @reservation.stay_length
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.guest_id = current_user.id
    @reservation.host_id = @reservation.room.user.id

    if @reservation.save
      @reservation.create_reservation_notification
      flash[:notice] = '予約を受付いたしました'
      redirect_to registered_reservation_path(@reservation.id)
    else
      # newアクション時に検証済みだが、一意性の検証でエラーになる場合もある
      flash[:errors] = @reservation.errors.full_messages
      redirect_to(room_path(@reservation.room_id,
        :checkin => @reservation.checkin,
        :checkout => @reservation.checkout,
        :number => @reservation.number)) && return
    end
  end

  def index
    @reservations = current_user.guest_reservations.
      where('checkout >= ? and cancel = ?', Date.today, false).
      order(checkin: 'ASC').
      includes(room: { room_image_attachment: :blob })
  end

  def show
    @reservation = current_user.guest_reservations.find_by(id: params[:id])

    unchecked = @reservation.
      notifications.
      guest_unchecked(guest_id: current_user.id, checked: false)
    unchecked.update_all(checked: true) if unchecked.present?
  end

  def update
    @reservation = current_user.guest_reservations.find_by(id: params[:id])

    if @reservation.update(cancel: true)
      @reservation.create_cancel_notification
      @reservation.destroy_cancel_requst_notification
      flash[:notice] = '予約がキャンセルされました'
      redirect_to reservations_path
    else
      render 'reservations/show'
    end
  end

  def registered
    @reservation = Reservation.find_by(id: params[:id])
  end

  def completed
    @reservations = current_user.guest_reservations.
      where('checkout < ?', Date.today).
      or(current_user.guest_reservations.where(cancel: true)).
      order(checkin: 'DESC').
      includes(room: { room_image_attachment: :blob })
  end

  private

  def reservation_params
    params.require(:reservation).permit(:checkin, :checkout, :number, :payment, :room_id)
  end

  def reservation_params_from_room
    params.permit(:checkin, :checkout, :number, :room_id)
  end
end
