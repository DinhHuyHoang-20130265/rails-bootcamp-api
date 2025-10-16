class Tweet < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Tweet", optional: true
  has_many :replies, class_name: "Tweet", foreign_key: "parent_id",
           dependent: :destroy


  validates :user, presence: true



  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered_desc, -> { order(created_at: :desc) }
  # Pagination helpers
  scope :for_page,
        ->(page, per_page) { limit(per_page).offset((page - 1) * per_page) }

  def self.has_more_for?(base_scope, page:, per_page:)
    total = base_scope.unscope(:group, :select, :order).distinct.count(:id)

    total > (page * per_page)
  end

  # Sorting helpers
  def self.order_by_date(direction = :desc)
    direction =
      %i[asc desc].include?(direction.to_sym) ? direction.to_sym : :desc

    order(created_at: direction)
  end

  def self.order_by_most_replies
    left_joins(:replies)
      .group("tweets.id")
      .order(Arel.sql(
        "COUNT(replies_tweets.id) DESC, tweets.created_at DESC"
      ))
  end

  def self.order_by_display_name(direction = :asc)
    direction =
      %i[asc desc].include?(direction.to_sym) ? direction.to_sym : :asc

    joins(:user).order(
      "users.display_name #{direction.to_s.upcase}, tweets.created_at DESC"
    )
  end
end
