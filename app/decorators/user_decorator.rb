class UserDecorator < Draper::Decorator
  delegate_all

  def date_format
    l(model.created_at, format: :custom)
  end

  def display_name
    model.display_name.presence || model.username || "User"
  end
end
