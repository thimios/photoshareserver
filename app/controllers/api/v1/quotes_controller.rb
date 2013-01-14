module Api
  module V1

    class QuotesController < ApplicationController
      #before_filter :my_authenticate_user no authentication necessary to get the quote
      # the api is always available to all logged in users
      skip_authorization_check

      # GET /quotes/1
      # GET /quotes/1.json
      def show
        @quote = Quote.first
        render json: @quote
      end

    end
  end
end
