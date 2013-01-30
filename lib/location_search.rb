module Api
  module V1

    class LocationSearch

      def self.suggest_followable_locations(current_user, page, limit)
        # home.html.erb
        exclude_location_ids =  current_user.following_location_ids
        search = Sunspot.search (NamedLocation) do

          unless exclude_location_ids.empty?
            without(:id, exclude_location_ids)
          end

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
                                              #{current_user.latitude},
                                              #{current_user.longitude}
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
