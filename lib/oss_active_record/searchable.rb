require 'pry'
module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      @@_fields={:integer=>[],:text=>[],:string=>[],:time=>[]}
      def _fields
        @@_fields
      end
      
      def searchable(options = {}, &block)
        #integer text string time
        yield
        unless options[:auto_index] == false
          before_save :do_something_before
          after_save :index
        end
      end

      def integer(field_name)
        @@_fields[:integer]<<field_name
      end
      def text(field_name)
        @@_fields[:text]<<field_name
      end
      def string(field_name)
        @@_fields[:string]<<field_name
      end
      def time(field_name)
        @@_fields[:time]<<field_name
      end
    end
    

    def search(*args, &block)
    end
    
    module LocalInstanceMethods
      #      def index(self)
        # here we index the record!
      #end
    end

  end
end


 

ActiveRecord::Base.send :include, OssActiveRecord::Searchable
