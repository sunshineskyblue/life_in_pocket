class RoomsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def index
    @rooms = current_user.rooms.with_attached_room_image
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      flash[:notice] = "ルーム情報を追加しました"
      redirect_to room_path(@room.id)
    else
      render 'rooms/new'
    end
  end

  def show
    @room = Room.find_by(id: params[:id])
  end

  private

  def room_params
    params.require(:room).permit(:name, :introduction, :fee, :adress, :user_id, :room_image)
  end
end
