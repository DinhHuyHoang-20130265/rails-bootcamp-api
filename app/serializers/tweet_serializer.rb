class TweetSerializer < ActiveModel::Serializer
  attributes :id, :content, :parent_id, :created_at, :updated_at
  belongs_to :user, serializer: UserSerializer
end

