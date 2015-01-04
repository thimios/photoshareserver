class UserSearch

  def self.fulltext(search_string, page, limit)
    page = page || 1
    limit = limit || 24
    search = Sunspot.search (User) do
      fulltext search_string
      paginate(:page => page, :per_page => limit)
    end

    return search.results
  end
end


