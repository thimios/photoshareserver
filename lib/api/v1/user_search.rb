module Api
  module V1

    class UserSearch
      require_dependency 'api/v1/sunspot_search'

      def self.followed_by_current_user current_user, page, limit
        users = User.where(:id => current_user.following_user_ids).order("username").page(page).per(limit)
        return [ users, users.total_count ]
      end

      def self.followed_by_user user_id, page, limit
        users = User.where(:id => User.find(user_id).following_user_ids).order("username").page(page).per(limit)
        return [ users, users.total_count ]
      end

      def self.full_text_search search_string, page, limit
        search = Sunspot.search (User) do
          if !search_string.blank?
            fulltext search_string
          end

          if !page.blank?
            paginate(:page => page, :per_page => limit)
          end
        end
        return [ search.results, search.total ]
      end

      def self.suggest_followable_users(current_user, page, limit)
        page = page || 1
        limit = limit || 24
        exclude_user_ids =  [current_user.id] + current_user.following_user_ids
        SunspotSearch.suggest_followable User, exclude_user_ids, page, limit, current_user
      end
    end
  end
end
