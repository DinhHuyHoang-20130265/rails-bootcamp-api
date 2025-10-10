class TweetsController < ApplicationController
  include Pagination

  before_action :authenticate_user!,
                only: [ :new, :create, :edit, :update, :destroy, :load_more ]
  before_action :set_tweet, only: %i[ show edit update destroy ]

  # GET /tweets or /tweets.json
  def index
    @form = TweetForm.new(current_user.tweets.build) if user_signed_in?

    base_scope = Tweet.top_level
    base_scope = apply_sorting(base_scope)
    @tweets, @has_more_tweets = paginate(base_scope)
    @tweets = @tweets.decorate

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
  end

  def load_more
    base_scope = Tweet.top_level
    base_scope = apply_sorting(base_scope)
    @tweets, @has_more_tweets = paginate(base_scope)
    @tweets = @tweets.decorate

    respond_to do |format|
      format.turbo_stream
    end
  end

  # GET /tweets/new
  def new
    # Build a non-persisted tweet for the form; associate only if signed in
    tweet = user_signed_in? ? current_user.tweets.build : Tweet.new
    @form = TweetForm.new(tweet)
  end

  # GET /tweets/1/edit
  def edit
    # @tweet = Tweet.find(params[:id])
    @form = TweetForm.new(Tweet.find(params[:id]))

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  # POST /tweets or /tweets.json
  def create
    # @tweet = current_user.tweets.build(tweet_params)
    @form = TweetForm.new(current_user.tweets.build)

    respond_to do |format|
      if @form.validate(tweet_params) && @form.save
        format.turbo_stream
        format.html {
          redirect_to tweets_path, notice: "Tweet created successfully."
        }
      else
        format.turbo_stream
        format.html { render :'tweets/index' }
      end
    end
  end

  # PATCH/PUT /tweets/1 or /tweets/1.json
  def update
    # @tweet = Tweet.find(params[:id])
    @form = TweetForm.new(Tweet.find(params[:id]))

    respond_to do |format|
      if @form.validate(tweet_params) && @form.save
        format.turbo_stream
        format.html {
          redirect_to tweets_path, notice: "Tweet updated successfully."
        }
      else
        format.turbo_stream
        format.html { render :'tweets/index' }
      end
    end
  end

  # DELETE /tweets/1 or /tweets/1.jsons
  def destroy
    @form.model.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html {
        redirect_to tweets_path, notice: "Tweet was successfully destroyed."
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tweet
    @form = TweetForm.new(Tweet.find(params[:id]))
  end

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
