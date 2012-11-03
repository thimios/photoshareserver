module Api
  module V1

    class CategoriesController < ApplicationController
      before_filter :my_authenticate_user

      # GET /categories
      # GET /categories.json
      def index
        @categories = Category.all
        render json: @categories
      end

      # GET /categories/1
      # GET /categories/1.json
      def show
        @category = Category.find(params[:id])
        render json: @category
      end
    end
  end
end
