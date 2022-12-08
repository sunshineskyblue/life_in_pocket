class RoomSearchFormsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    search_form = RoomSearchForm.new(search_params)

    if search_form.valid?
      @search_title = search_form.link_adresses_keywords
      @rooms = search_form.search_and_condition.
        with_attached_room_image.
        order(updated_at: 'DESC').
        page(params[:page]).
        per(8)
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def area_search
    search_form = RoomSearchForm.new(search_params)
    @search_title = search_form.link_adresses_keywords
    @rooms = search_form.search_or_condition.
      with_attached_room_image.
      order(updated_at: 'DESC').
      page(params[:page]).
      per(8)
  end

  private

  def search_params
    params.require(:q)
  end
end
