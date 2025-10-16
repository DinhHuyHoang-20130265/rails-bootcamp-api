class ReplySerializer < ActiveModel::Serializer
  attributes :id, :content, :user_id, :parent_id, :created_at, :updated_at
  belongs_to :user, serializer: UserSerializer
  belongs_to :parent, serializer: TweetSerializer
end

