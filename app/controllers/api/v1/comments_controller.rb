module Api
  module V1
    class CommentsController < Opinio::CommentsController
      before_filter :my_authenticate_user
      # the api is always available to all logged in users
      skip_authorization_check

      def index
        process_filter_params

        @comments = resource.comments.page(params[:page]).per(params[:limit])
        render :json =>  { :records => @comments, :total_count => @comments.total_count }
      end

      def create
        @comment = resource.comments.build(params[:comment] )
        @comment.owner = send(Opinio.current_user_method)
        if @comment.save
          render json: @comment, status: :created
        else
          render json: @comment.errors, status: :unprocessable_entity
        end

      end

      #def destroy
      #  @comment = Opinio.model_name.constantize.find(params[:id])
      #
      #  if can_destroy_opinio?(@comment)
      #    @comment.destroy
      #    set_flash(:notice, t('opinio.messages.comment_destroyed'))
      #  else
      #    #flash[:error]  = I18n.translate('opinio.comment.not_permitted', :default => "Not permitted")
      #    logger.warn "user #{send(Opinio.current_user_method)} tried to remove a comment from another user #{@comment.owner.id}"
      #    render :text => "unauthorized", :status => 401 and return
      #  end
      #
      #  respond_to do |format|
      #    format.js
      #    format.html { redirect_to( opinio_after_destroy_path(@comment) ) }
      #    format.json { head :no_content }
      #  end
      #end
    end
  end
end
