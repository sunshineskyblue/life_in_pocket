require 'rails_helper'

RSpec.describe "予約登録機能", type: :system do
  let(:number) { 3 }
  let(:fee) { 1000 }
  let(:checkin) { Date.today + 1 }
  let(:checkout) { Date.today + 3 }
  let(:stay_length) { 2 }  # checkout - checkin
  let(:payment) { 2000 } # 2泊 * 1000円
  let(:user) { create(:user) }
  let(:room) { create(:room, fee: fee) }

  # rooms/show => reservations/new
  describe 'エントリー画面から確定画面への遷移' do
    before do
      sign_in user
      visit room_path(room.id)
      fill_in "checkin", with: checkin
      fill_in "checkout", with: checkout
      fill_in "number", with: number
      click_on "予約する"
    end

    it '確定画面に切り替わり、予約内容が表示されること' do
      aggregate_failures do
        expect(page).to have_content "¥#{fee.to_s(:delimited)}"
        expect(page).to have_content checkin.strftime("%Y年%m月%d日 "\
          "(#{I18n.t("date.abbr_day_names")[checkin.wday]})")
        expect(page).to have_content checkout.strftime("%Y年%m月%d日 " \
          "(#{I18n.t("date.abbr_day_names")[checkout.wday]})")
        expect(page).to have_content stay_length
        expect(page).to have_content number
        expect(page).to have_content "¥" + "#{payment.to_s(:delimited)}"
      end
    end

    it '戻るリンクが存在し、エントリー画面に遷移すること' do
      find(".link-to-room-path", text: "エントリー画面に戻る").click
      expect(current_path).to eq room_path(room.id)
    end

    # reservations/new => create => reservations/registered
    describe '確定画面から完了画面への遷移' do
      before do
        click_on "予約を確定する"
      end

      it '予約がDBに登録されていること' do
        aggregate_failures do
          reservation = user.guest_reservations.find_by(room_id: room.id)
          expect(reservation.checkin).to eq checkin
          expect(reservation.checkout).to eq checkout
          expect(reservation.number).to eq number
          expect(reservation.payment).to eq payment
        end
      end

      it '完了画面に切り替わり、予約内容が表示されること' do
        reservation = user.guest_reservations.find_by(room_id: room.id)

        aggregate_failures do
          expect(page).to have_content room.name
          expect(page).to have_content room.adress
          expect(page).to have_content checkin.strftime("%Y年%m月%d日 "\
            "(#{I18n.t("date.abbr_day_names")[checkin.wday]})")
          expect(page).to have_content checkout.strftime("%Y年%m月%d日 "\
            "(#{I18n.t("date.abbr_day_names")[checkout.wday]})")
          expect(page).to have_content reservation.created_at.strftime("%Y年%m月%d日 "\
            "(#{I18n.t("date.abbr_day_names")[checkout.wday]})")
          expect(page).to have_content "¥#{payment.to_s(:delimited)}"
        end
      end

      it 'ホームに戻るリンクが存在し、ホーム画面に遷移すること' do
        find(".link-to-home", text: "ホームに戻る >>").click
        expect(current_path).to eq root_path
      end
    end
  end
end
