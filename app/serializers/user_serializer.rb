class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :display_name,
             :email, :created_at, :updated_at
end

