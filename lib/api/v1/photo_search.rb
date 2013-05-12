module Api
  module V1

    class PhotoSearch

      # time_factor_param, 0 to 4, refering to the position of the slider
      # 0: full left: recent
      # 4: full right: all time
      def self.time_factor_from_param(time_factor_param)


        #Time:
        #
        #4. 0 : All time : full right
        #3. -1.15e-10
        #2. -1.15e-9  : middle position
        #1. -0.8e-7
        #0. -1e-5 : recent : full left
        case time_factor_param
          when "0" # recent, full left
           return "-3.5E-09"
          when "2" # middle, default value
            return "-3.48414E-10"
          when "4" # all time, full right
            return "0"
          else
            Rails.logger.warn "Time factor param value: #{time_factor_param} not expected. Using default"
            return "-3.48414E-10"
        end
      end

      # distance_factor_param, 0 to 4, refering to the position of the slider
      # 0: full left: nearby
      # 4: full right: global
      def self.distance_factor_from_param(distance_factor_param)

        #Distance:
        #
        #4. 0 : Global: full right
        #3. -7e-5
        #2. -7e-4 : middle
        #1. -7e-2
        #0. 10 : local : full left

        case distance_factor_param
          when '0' # local, full left
            return "-3.01E-1"
          when '2' # middle, default value
            return "-3.01E-3"
          when '4' # global, full right
            return "0"
          else
            Rails.logger.warn "Distance factor param value: #{distance_factor_param} not expected. Using default"
            return "-3.01E-3"
        end
      end

      # get all photos of a specific user, with paging
      def self.user_photos(user_id, page, limit)
        page = page || 1
        limit = limit || 24

        search = Sunspot.search (Photo) do
          with(:user_id, user_id)
          paginate(:page => page, :per_page => limit)
          order_by :created_at, :desc
          data_accessor_for(Photo).include = [:user]
        end

        return search
      end

      # get photos feed for a user

      def self.user_feed(user, page, limit)
        page = page || 1
        limit = limit || 24

        search = Sunspot.search (Photo) do

          following_users_count = user.following_users_count
          following_location_count = user.following_named_locations_count

          if following_users_count > 0 and following_location_count > 0
            any_of do
              with(:user_id).any_of(user.following_users.map{|followed_user| followed_user.id})
              with(:named_location_id).any_of(user.following_location_ids)
            end
            without(:user_id).equal_to(user.id)
          elsif following_users_count == 0 and following_location_count > 0
            with(:named_location_id).any_of(user.following_location_ids)
            without(:user_id).equal_to(user.id)
          elsif following_users_count > 0 and following_location_count == 0
            with(:user_id).any_of(user.following_users.map{|followed_user| followed_user.id})
            without(:user_id).equal_to(user.id)
          elsif following_users_count == 0 and following_location_count == 0
            with(:user_id).equal_to(nil)
          end

          paginate(:page => page, :per_page => limit)
          order_by :created_at, :desc
          data_accessor_for(Photo).include = [:user]
        end

        return search
      end
    end
  end
end


