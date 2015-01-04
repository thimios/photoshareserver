module Api
  module V1

    class LocationSearch
      require_dependency 'api/v1/sunspot_search'
      def self.suggest_followable_locations(current_user, page, limit)
        exclude_location_ids =  current_user.following_location_ids
        SunspotSearch.suggest_followable NamedLocation, exclude_location_ids, page, limit, current_user
      end
    end
  end
end
