module SenchaHelpers

  def process_filter_params
    if params[:filter]
      filter = ActiveSupport::JSON.decode(params[:filter])
      params[filter[0].values[0]] = filter[0].values[1]
    end
  end
end
