class RepliesController < ApplicationController
  include Pagination
  include OwnershipAuthorization



  before_action :authenticate_user!
  before_action :set_tweet
  before_action :set_reply, only: [ :update, :destroy ]
  before_action :authorize_owner!, only: [ :update, :destroy ]



  def index
    @per_page = 5
    base_scope = @tweet.replies.order(created_at: :asc)
    @replies, @has_more_replies = paginate(base_scope)
    @tweet_left = @tweet.replies.count - (current_page * per_page)

    render json: {
      data: ActiveModelSerializers::SerializableResource.new(
        @replies, each_serializer: ReplySerializer
      ).as_json,
      meta: {
        has_more: @has_more_replies,
        page: current_page,
        per_page: per_page,
        remaining: @tweet_left
      }
    }
  end
  def show
    @reply = @tweet.replies.find(params[:id]) rescue nil

    if @tweet.nil? || @reply.nil?
      render json: { error: "Tweet or Reply not found" }, status: :not_found
    else
      render json: {
        reply: ActiveModelSerializers::SerializableResource.new(
          @reply, serializer: ReplySerializer
        ).as_json
      }
    end
  end

  def create
    @form =
      ReplyForm.new(
        @tweet.replies.build(reply_params.merge(user: current_user))
      )

    if @form.validate(reply_params) && @form.save
      render json: {
        reply: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: ReplySerializer
        ).as_json
      }, status: :created
    else
      render json: { errors: @form.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @form.validate(reply_params) && @form.save
      render json: {
        reply: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: ReplySerializer
        ).as_json
      }, status: :ok
    else
      render json: { errors: @form.errors.messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    @form.model.destroy!

    head :no_content
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
