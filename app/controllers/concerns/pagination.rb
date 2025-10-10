module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 10

  included do
    helper_method :current_page, :per_page
  end



  def current_page
    value = params[:page].to_i

    value.positive? ? value : 1
  end

  def per_page
    if defined?(@per_page) && @per_page.to_i.positive?
      @per_page.to_i
    else
      Pagination::DEFAULT_PER_PAGE
    end
  end

  def paginate(scope)
    collection = scope.for_page(current_page, per_page)
    has_more_data =
      Tweet.has_more_for?(scope, page: current_page, per_page: per_page)

    [ collection, has_more_data ]
  end
end
