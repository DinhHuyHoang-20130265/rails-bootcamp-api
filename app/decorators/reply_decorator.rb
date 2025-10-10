class ReplyDecorator < Draper::Decorator
  delegate_all

  def date_format
    l(model.created_at, format: :custom)
  end
end
