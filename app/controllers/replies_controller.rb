class RepliesController < ApplicationController
  include Pagination
  include OwnershipAuthorization

  before_action :authenticate_user!
  before_action :set_tweet
  before_action :set_reply, only: [ :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]



  def show
    @tweet = Tweet.find(params[:tweet_id])
    @reply = @tweet.replies.find(params[:id])

    respond_to do |format|
      format.turbo_stream # renders show.turbo_stream.erb
      format.html
    end
  end

  def load_more
    @per_page = 5
    base_scope = @tweet.replies.order(created_at: :asc)
    @replies, @has_more_replies = paginate(base_scope)
    @tweet_left = @tweet.replies.count - (current_page * per_page)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
    @form =
      ReplyForm.new(
        @tweet.replies.build(reply_params.merge(user: current_user)))

    if @form.validate(reply_params) && @form.save
      respond_to do |format|
        format.turbo_stream # renders create.turbo_stream.erb
        format.html { redirect_to tweets_path, notice: "Replied." }
      end
    else
      respond_to do |format|
        format.turbo_stream # re-render form with errors
        format.html { redirect_to tweets_path, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream # renders edit.turbo_stream.erb
      format.html
    end
  end

  def update
    if @form.validate(reply_params) && @form.save
      respond_to do |format|
        format.turbo_stream # renders update.turbo_stream.erb
        format.html { redirect_to tweets_path, notice: "Reply updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream # render form with errors
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @form.model.destroy!

    respond_to do |format|
      format.turbo_stream # renders destroy.turbo_stream.erb
      format.html { redirect_to tweets_path, notice: "Reply deleted." }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def set_reply
    @form = ReplyForm.new(@tweet.replies.find(params[:id]))
  end

  def reply_params
    params.require(:reply).permit(:content)
  end

  def authorize_owner!
    super(@form)
  end
end
