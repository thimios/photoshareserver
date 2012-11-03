class CommentsController < Opinio::CommentsController
  before_filter :my_authenticate_user

  def index
    if  params[:filter]
      @filter_params = HashWithIndifferentAccess.new
      @filter = ActiveSupport::JSON.decode(params[:filter])
      @filter_params[@filter[0].values[0]] = @filter[0].values[1]
      if @filter_params[:photo_id]
        params[:photo_id] = @filter_params[:photo_id]
      end
    end

    @comments = resource.comments.page(params[:page]).per(params[:limit])

  end

  def create
    @comment = resource.comments.build(params[:comment] )
    @comment.owner = send(Opinio.current_user_method)

    if @comment.save
      flash_area = :notice
      message = t('opinio.messages.comment_sent')
      set_flash(flash_area, message)
      redirect_to(opinio_after_create_path(resource))
    else
      flash_area = :error
      message = t('opinio.messages.comment_sending_error')

      set_flash(flash_area, message)
      redirect_to(opinio_after_create_path(resource))
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
