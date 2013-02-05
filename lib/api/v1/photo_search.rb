module Api
  module V1

    class PhotoSearch

      # time_factor_param, 0 to 4, refering to the position of the slider
      # 0: full left: recent
      # 4: full right: all time
      def self.time_factor_from_param(time_factor_param)
        if time_factor_param.nil?
          Rails.logger.warn "time_factor param is nil, using default, slider in the middle"
          time_factor_param = "2"
        end

        #Time:
        #
        #4. 0 : All time : full right
        #3. -1.15e-10
        #2. -1.15e-9  : middle position
        #1. -0.8e-7
        #0. -1e-5 : recent : full left
        case time_factor_param
          when "0" # recent, full left
           return "-1e-5"
          when "1"
            return "-0.8e-7"
          when "2" # middle, default value
            return "-1.15e-9"
          when "3"
            return "-1.15e-10"
          when "4" # all time, full right
            return "0"
          else
            logger.warn "Time factor param value: #{time_factor_param} not expected. Using default"
            return "-1.15e-9"
        end
      end

      # distance_factor_param, 0 to 4, refering to the position of the slider
      # 0: full left: nearby
      # 4: full right: global
      def self.distance_factor_from_param(distance_factor_param)
        if distance_factor_param.nil?
          Rails.logger.warn "distance_factor param is nil, using default, slider in the middle"
          distance_factor_param = "2"
        end
        #Distance:
        #
        #4. 0 : Global: full right
        #3. -7e-5
        #2. -7e-4 : middle
        #1. -7e-2
        #0. 10 : local : full left

        case distance_factor_param
          when '0' # recent, full left
            return "10"
          when '1'
            return "-7e-2"
          when '2' # middle, default value
            return "-7e-4"
          when '3'
            return "-7e-5"
          when '4' # all time, full right
            return "0"
          else
            Rails.logger.warn "Distance factor param value: #{distance_factor_param} not expected. Using default"
            return "-7e-4"
        end
      end

    end
  end
end
