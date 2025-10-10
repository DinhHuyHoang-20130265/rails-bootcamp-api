class TweetDecorator < Draper::Decorator
  delegate_all
  decorates_association :replies

  def date_format
    l(model.created_at, format: :custom)
  end
end
