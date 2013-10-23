module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
      include InstanceMethods
    end

    module ClassMethods
      @@field_types= [:integer, :text, :string, :time, :suggestion] #supported field types
      @@index_instances = {}

      def searchable(options = {}, &block)
        yield
        unless options[:auto_index] == false
          after_save :index
        end
      end

      def index_instance
        idx_inst = @@index_instances[self.name.downcase]
        if idx_inst.nil?
          idx_inst = IndexInstance.new(self.name.downcase)
          @@index_instances[self.name.downcase] = idx_inst
        end
        idx_inst
      end

      def reindex!
        index_instance.oss_index.delete!
        index_instance.create_schema!
        self.all.find_in_batches  do |group|
          group.each { |doc| doc.index(index_instance) }
        end
      end

      def method_missing(method, *args, &block)
        return index_instance.add_field(args[0], method, block) if @@field_types.include? method
        super
      end

      def search(*args, &block)
        searchRequest = SearchRequest.new(index_instance)
        searchRequest.returns index_instance.fields.map {|f|"#{f[:name]}|#{f[:type]}"}
        find_results(searchRequest.execute(&block), index_instance.field_id)
      end

      def find_results(search_result, field_id)
        id_field_name = "#{field_id[:name]}|#{field_id[:type]}"
        results = []
        search_result['documents'].each do |document|
          document['fields'].each do |field|
            id = field['values'].map {|f|f.to_i}.uniq if field['fieldName'] == id_field_name
            results<<find(id)[0] unless id.nil?
          end
        end
        return results
      end
      
    end

    def index(index_instance)
      doc = self.to_indexable(index_instance.fields)
      oss_doc = Oss::Document.new
      doc.each do |name,value|
        oss_doc.fields << Oss::Field.new(name, value)
      end
      index_instance.index(oss_doc)
    end

    def to_indexable(fields)
      doc={}
      fields.each do |field|
        if field[:block].nil?
          val = self.send(field[:name].to_sym)
        else
          val = field[:block].call
        end
        doc["#{field[:name]}|#{field[:type]}"]=val
      end
      doc
    end

  end

  #TODO Working on deletion
  module InstanceMethods
    def delete!
      self.class.index_instance
    end
    alias :delete :delete!
  end
end

ActiveRecord::Base.send :include, OssActiveRecord::Searchable