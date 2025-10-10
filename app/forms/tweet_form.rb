class TweetForm < Reform::Form
  property :content

  validates :content, presence: true
end
