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



module Api
  module V1

    class UserSearch

      def self.suggest_followable_users(current_user, page, limit)
        page = page || 1
        limit = limit || 24

        exclude_user_ids =  [current_user.id] + current_user.following_user_ids
        search = Sunspot.search (User) do
          without(:id, exclude_user_ids)
          paginate(:page => page, :per_page => limit)
          adjust_solr_params do |solr_params|

            #Points = (clicks + 1) * exp(c1 * distance) * exp(c2 * time)
            #
            #c1 and c2 are negative constants.
            #Distance is the distance between the current location and the picture
            #time the time between the current time and the time the picture was taken.
            #Clicks is the amount of "so berlin" votes the photo has received
            #
            #The constants are:
            #c1 = -7e-4
            #c2 = -1.15e-09
            #Assuming distance in km for c1 and milliseconds for c2.
            solr_params[:sort] = "product(
                                     sum(plusminus_i,1),
                                      exp(
                                          product(
                                           -7e-4,
                                            geodist(
                                              coordinates_ll,
                                              #{current_user.latitude.round(4)},
                                              #{current_user.longitude.round(4)}
                                            )
                                          )
                                      )
                                  ) desc".gsub(/\s+/, " ").strip
          end
        end
        return [search.results, search.total]
      end
    end
  end
end
