module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern
 
    included do
    end
 
    def index
      doc={}
      self.class._fields.each do |field|
        if field[:block].nil?
          val = self.send(field[:name].to_sym)
        else
          val = field[:block].call
        end
        doc[field[:name]]=val
      end
      doc
    end
    
    def index!
      doc = self.index
      doc[:id] ||= SecureRandom.uuid
      oss_doc = Oss::Document.new("en", doc[:id])  
      doc.each do |name,value|
          oss_doc.add_field(k,v)
      end
      index.add_document(oss_doc)
    end
    
 
    module ClassMethods
      @@field_types= [:integer, :text, :string, :time] #supported field types
      @@_fields=[]
      
      def _fields
        @@_fields
      end
      
      def searchable(options = {}, &block)
        yield
        unless options[:auto_index] == false
          before_save :do_something_before
          after_save :index
        end
      end
      
      def add_field(name, type, block=nil)
        @@_fields<<{:name => name, :type => type,:block => block}
      end

      def create_schema!
        @@_fields.each do |field|
          create_schema_field!(field)
        end
      end

      def create_schema_field!(field)
      end
      
      def method_missing(method, *args, &block)  
        add_field args[0], method, block if @@field_types.include? method
      end
      
    end
    

    def search(*args, &block)
    end

  end
end

ActiveRecord::Base.send :include, OssActiveRecord::Searchable