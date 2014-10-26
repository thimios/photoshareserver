class PhotoSearch

  def self.category_created_at(category_id, page, limit)
    page = page || 1
    limit = limit || 24

    search = Sunspot.search (Photo) do
      if !category_id.nil?
        with(:category_id, category_id)
        with(:banned, false)
        data_accessor_for(Photo).include = [:user]
      end

      paginate(:page => page, :per_page => limit)
      adjust_solr_params do |solr_params|

        #Points = (clicks + 1) * exp(c1 * distance) * exp(c2 * time)
        #
        #c1 and c2 are negative constants.
        #Distance is the distance between the current location and the picture
        #time the time between the current time and the time the picture was taken.
        #Clicks is the amount of votes the photo has received
        #
        #The constants are:
        #c1 = -7e-4
        #c2 = -1.15e-09
        #Assuming distance in km for c1 and milliseconds for c2.
        solr_params[:sort] = "product( sum(plusminus_i,1),
                                    exp(
                                      product(
                                          -1.15e-09,
                                          ms(NOW/HOUR, created_at_dt)
                                      )
                                    )
                                 ) desc".gsub(/\s+/, " ").strip
      end

    end
    photos = search.results

    return photos
  end

  def self.all(page, limit)
    page = page || 1
    limit = limit || 24

    search = Sunspot.search (Photo) do
      with(:banned, false)
      paginate(:page => page, :per_page => limit)
      order_by :created_at, :desc
      data_accessor_for(Photo).include = [:user]
    end
    photos = search.results

    return photos
  end

  def self.best(page, limit)
    page = page || 1
    limit = limit || 24

    search = Sunspot.search (Photo) do
      with(:banned, false)
      paginate(:page => page, :per_page => limit)
      order_by :plusminus, :desc
      data_accessor_for(Photo).include = [:user]
    end
    photos = search.results

    return photos
  end

  def self.reported
    Photo.joins(:photo_reports).order("photo_reports.created_at DESC").uniq
  end
end