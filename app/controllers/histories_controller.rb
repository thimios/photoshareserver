class HistoriesController < ApplicationController
  before_filter :my_authenticate_user

  # GET /histories
  # GET /histories.json
  def index
    if params[:filter]
      @filter_params = HashWithIndifferentAccess.new
      @filter = ActiveSupport::JSON.decode(params[:filter])
      @filter_params[@filter[0].values[0]] = @filter[0].values[1]
      if @filter_params[:user_id]
        params[:user_id] = @filter_params[:user_id]
      end

    end

    unless params[:user_id].nil?
      @activities = PublicActivity::Activity.where("owner_id = ? AND activities.key IN ('photo.create', 'vote.create', 'comment.create')",params[:user_id]).order("created_at DESC").page(params[:page]).per(params[:limit])
      @histories = Array.new
      @activities.each do |activity|

        #:created_at, #date, time string
        #:title, #Posted a photo, Commented on Jimmy's photo, Liked Jimmy's photo
        #:description, #either the comment or the photo description
        #:photo_id, # the id of the photo posted, liked or commented
        #:comment_id, # the id of the posted comment, or blank
        #:thumb_url, # the url of the thumbnail of the photo posted, liked or commented


        @history = History.new
        @history.created_at = activity.created_at

        if activity.key == "comment.create"
          @comment = Comment.find(activity.trackable_id)
          @photo = Photo.find(@comment.commentable_id)

          @history.title = "Commented on "+@photo.author_name+"'s photo."
          @history.description = @comment.body
          @history.photo_id = @photo.id
          @history.comment_id = @comment.id
          @history.thumb_url = @photo.thumb_size_url

        elsif activity.key == "photo.create"
          @photo = Photo.find(activity.trackable_id)
          @history.title = "Posted a photo."
          @history.description = @photo.description
          @history.photo_id = @photo.id
          @history.comment_id = ""
          @history.thumb_url = @photo.thumb_size_url

        elsif activity.key == "vote.create"
          @vote = Vote.find(activity.trackable_id)
          @photo = Photo.find(@vote.voteable_id)
          @history.title = "Liked "+@photo.author_name+"'s photo."
          @history.description = @photo.description
          @history.photo_id = @photo.id
          @history.comment_id = ""
          @history.thumb_url = @photo.thumb_size_url
        else
          logger.debug "Should not load activity with key: #{activity.key} "
        end

        @histories << @history
      end
    else
      # TODO: respond with error
    end
  end

end
