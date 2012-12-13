class PhotoSearch

  def self.category_created_at(category_id, page, limit)
    # home.html.erb
    search = Sunspot.search (Photo) do
      if !category_id.nil?
        with(:category_id, category_id)
      end
      if !page.blank?
        paginate(:page => page, :per_page => limit)
        order_by :created_at, :desc
      end
    end
    photos = search.results

    return photos
  end

  def self.all(page, limit)
    search = Sunspot.search (Photo) do
      if !page.blank?
        paginate(:page => page, :per_page => limit)
        order_by :created_at, :desc
      end
    end
    photos = search.results

    return photos
  end

  def self.best(page, limit)
    search = Sunspot.search (Photo) do
      if !page.blank?
        paginate(:page => page, :per_page => limit)
        order_by :plusminus, :desc
      end
    end
    photos = search.results

    return photos
  end

  def self.reported(page, limit)

  end
end