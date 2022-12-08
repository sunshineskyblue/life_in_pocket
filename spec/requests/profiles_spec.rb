require 'rails_helper'

RSpec.describe "プロフィールページ", type: :request do
  describe "GET /settings/:id/profiles" do
    let(:user) { create(:user, name: "I_am_test_user", introduction: "please_find_me") }

    before do
      sign_in user
      get edit_user_profile_path user
    end

    it "リクエストが成功すること" do
      expect(response).to have_http_status(200)
    end

    it "ユーザー名が取得できること" do
      expect(response.body).to include user.name
    end

    it "自己紹介が取得できること" do
      expect(response.body).to include user.introduction
    end
  end
end
