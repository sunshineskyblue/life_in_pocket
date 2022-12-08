class RoomSearchForm
  include ActiveModel::Model
  validates :keywords, presence: true, if: -> { adresses.blank? }
  validates :adresses, presence: true, if: -> { keywords.blank? }

  attr_accessor :keywords, :adresses

  def initialize(arg)
    @keywords = arg[:name_or_introduction_cont] ||= ""
    @adresses = arg[:adress_cont] ||= ""
  end

  # and検索をする
  def search_and_condition
    Room.
      ransack({ combinator: 'and', groupings: grouping_keywords_adresses }).
      result(distinct: true)
  end

  # or検索をする機能
  def search_or_condition
    Room.ransack({ combinator: 'or', groupings: grouping_adresses }).result(distinct: true)
  end

  # 検索ワードをページタイトルに挿入する
  def link_adresses_keywords
    if adresses.present? && keywords.present?
      adresses + " " + keywords
    elsif adresses.present?
      adresses
    else
      keywords
    end
  end

  private

  def multi_keywords_to_ary
    keywords.split(/[\p{blank}\s]+/)  # \p{blank} => 全角空白に対応
  end

  def multi_adresses_to_ary
    adresses.split(/[\p{blank}\s]+/)
  end

  def grouping_keywords
    multi_keywords_to_ary&.
      reduce({}) { |hash, word| hash.merge(word => { name_or_introduction_cont: word }) }
  end

  def grouping_adresses
    multi_adresses_to_ary&.reduce({}) { |hash, word| hash.merge(word => { adress_cont: word }) }
  end

  def grouping_keywords_adresses
    grouping_keywords&.merge(grouping_adresses)
  end
end
