class TweetsController < ApplicationController
  include Pagination

  before_action :authenticate_user!



  def index
    base_scope = Tweet.top_level
    base_scope = apply_sorting(base_scope)
    @tweets, @has_more_tweets = paginate(base_scope)

    render json: {
      data: ActiveModelSerializers::SerializableResource.new(
        @tweets, each_serializer: TweetSerializer
      ).as_json,
      meta: {
        has_more: @has_more_tweets,
        page: current_page,
        per_page: per_page
      }
    }
  end

  def show
    @tweet = Tweet.find(params[:id]) rescue nil

    if @tweet.nil?
      render json: { error: "Tweet not found" }, status: :not_found
    else
      render json: {
        tweet: ActiveModelSerializers::SerializableResource.new(
          @tweet, serializer: TweetSerializer
        ).as_json
      }
    end
  end

  def create
    @form = TweetForm.new(current_user.tweets.build)

    if @form.validate(tweet_params) && @form.save
      render json: {
        tweet: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: TweetSerializer
        ).as_json
      }, status: :created
    else
      render json: { errors: @form.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    @form = TweetForm.new(Tweet.find(params[:id]))

    if @form.validate(tweet_params) && @form.save
      render json: {
        tweet: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: TweetSerializer
        ).as_json
      }, status: :ok
    else
      render json: { errors: @form.errors.messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    @form = TweetForm.new(Tweet.find(params[:id]))
    @form.model.destroy!

    render json: { message: "Tweet deleted successfully" }, status: :ok
  end

  private

  # Only allow a list of trusted parameters through.
  def tweet_params
    params.require(:tweet).permit(:content)
  end

  def apply_sorting(scope)
    sort = params[:sort].to_s
    direction = params[:direction].to_s

    case sort
    when "date"
      direction = %w[asc desc].include?(direction) ? direction : "desc"
      scope.order_by_date(direction)
    when "most_replies"
      scope.order_by_most_replies
    when "display_name"
      direction = %w[asc desc].include?(direction) ? direction : "asc"
      scope.order_by_display_name(direction)
    else
      scope.ordered_desc
    end
  end
end
