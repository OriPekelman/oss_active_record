require 'pry'
module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def searchable(options = {})
        #integer text string time
        binding.pry
      end
    end
 
    module LocalInstanceMethods
    end

  end
end


 

ActiveRecord::Base.send :include, OssActiveRecord::Searchable
