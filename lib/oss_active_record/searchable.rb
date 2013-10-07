require 'thread'

module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern

    module ClassMethods
      @@oss_field_types = [:integer, :text, :string, :time, :suggestion] # supported field types
      @@oss_mutex = Mutex.new

      def searchable(options = {}, &block)
        yield
        unless options[:auto_index] == false
          after_commit :index
        end
      end

      def index_instance
        @@oss_mutex.synchronize do
          @index_instance ||= IndexInstance.new(self.name.downcase)
        end
      end

      def reindex!
        index_instance.oss_index.delete!
        index_instance.create_schema!
        self.all.find_in_batches { |group| group.each(&:index) }
      end

      def method_missing(method, *args, &block)
        return index_instance.add_field(args[0], method, block) if @@oss_field_types.include? method
        super
      end

      def oss_search(*args, &block)
        options = args.extract_options!
        search_request = SearchRequest.new(index_instance)
        search_request.returns index_instance.fields.map { |f| "#{f[:name]}|#{f[:type]}" }
        find_results(search_request.execute(&block), index_instance.field_id, options)
      end
      alias_method :search, :oss_search

      def find_results(search_result, field_id, options)
        id_field_name = "#{field_id[:name]}|#{field_id[:type]}"

        ids = search_result['documents'].map do |document|
          field = document['fields'].find { |f| f['fieldName'] == id_field_name }
          field['values'].compact.first
        end.compact

        query = if options[:include]
                  unscoped.includes(options[:include])
                else
                  unscoped
                end
        records = query.find(ids)

        ids.map do |id|
          records.find { |record| record.id == id.to_i }
        end
      end
    end

    def index
      oss_doc = Oss::Document.new
      oss_doc.fields = to_indexable.map { |name, value| Oss::Field.new(name, value) }
      self.class.index_instance.index(oss_doc)
    end

    def to_indexable
      self.class.index_instance.fields.reduce({}) do |doc, field|
        val = if field[:block].nil?
                send(field[:name].to_sym)
              else
                instance_eval(&field[:block])
              end
        doc["#{field[:name]}|#{field[:type]}"] = val
        doc
      end
    end
  end
end

ActiveRecord::Base.send :include, OssActiveRecord::Searchable
