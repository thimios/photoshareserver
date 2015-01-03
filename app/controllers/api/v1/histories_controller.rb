module Api
  module V1

    class HistoriesController < ApplicationController
      before_filter :my_authenticate_user
      # the api is always available to all logged in users
      skip_authorization_check


      # GET /histories
      # GET /histories.json
      def index
        process_filter_params

        unless params[:user_id].nil?
          user_whose_history = params[:user_id] == current_user.id ? current_user : User.find(params[:user_id])
          @activities = PublicActivity::Activity.where("(recipient_id IN (?) OR owner_id = ?) AND activities.key IN ('photo.create', 'vote.create', 'comment.create')",user_whose_history.photo_ids, user_whose_history.id).order("created_at DESC").page(params[:page]).per(params[:limit])
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
            @history.created_at_date = activity.created_at.strftime("%d %b. %Y")
            @history.actor_id= activity.owner_id
            actor = User.find(activity.owner_id)
            actor.current_user= current_user
            @history.actor_followed_by_current_user= actor.followed_by_current_user
            if activity.key == "comment.create"
              @comment = Comment.find(activity.trackable_id)
              @photo = Photo.find(@comment.commentable_id)
              if current_user.id == @photo.user_id
                @history.title = "#{actor.username} commented on your photo."
              else
                @history.title = "#{actor.username} commented on #{@photo.author_name}'s photo."
              end

              @history.description = @comment.body
              @history.photo_id = @photo.id
              @history.comment_id = @comment.id
              @history.thumb_url = @photo.thumb_size_url

            elsif activity.key == "photo.create"
              @photo = Photo.find(activity.trackable_id)
              @history.title = "Posted a photo."

              @history.description = @photo.title
              @history.photo_id = @photo.id
              @history.comment_id = ""
              @history.thumb_url = @photo.thumb_size_url

            elsif activity.key == "photo.destroy"
              @photo = Photo.find(activity.trackable_id)
              @history.title = "#{actor.username} deleted a photo."

              @history.description = @photo.title
              @history.photo_id = @photo.id
              @history.comment_id = ""
              @history.thumb_url = @photo.thumb_size_url

            elsif activity.key == "vote.create"
              @vote = Vote.find(activity.trackable_id)
              @photo = Photo.find(@vote.voteable_id)

              if current_user.id == @photo.user_id
                @history.title = "#{actor.username} liked your photo."
              else
                @history.title = "#{actor.username} liked #{@photo.author_name}'s photo."
              end

              @history.description = @photo.title
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


        render :json =>  { :records => @histories, :total_count => @activities.total_count }

        end

    end
  end
end
