module OssActiveRecord
  module Searchable
    extend ActiveSupport::Concern
    def index
      doc = self.to_indexable
      oss_doc = Oss::Document.new
      doc.each do |name,value|
        oss_doc.fields << Oss::Field.new(name, value)
      end
      self.class.oss_index.documents << oss_doc
      self.class.oss_index.index!
    end

    module ClassMethods
      @@field_types= [:integer, :text, :string, :time] #supported field types
      @@_fields=[]
      @@_field_id = nil
      @@_text_fields = {}
      @@_sortable_fields = {}
      @@index = nil

      def _fields
        @@_fields
      end

      def searchable(options = {}, &block)
        yield
        unless options[:auto_index] == false
          after_save :index
        end
      end

      def oss_index
        if @@index.nil?
          @@index_name ||= self.name.downcase
          @@index = Oss::Index.new(@@index_name, Rails.configuration.open_search_server_url)
          create_schema!
        end
        @@index
      end

      def add_field(name, type, block=nil)
        @@_fields<<{:name => name, :type => type,:block => block}
      end

      def create_schema!
        @@index.create('EMPTY_INDEX') unless @@index.list.include? @@index_name
        @@_field_id = @@_fields.detect {|f| f[:name] == :id }
        @@_field_id = {:name => 'id', :type => 'integer',:block => nil} if @@_field_id.nil?
        @@_fields <<  @@_field_id
        @@_fields.each do |field|
          create_schema_field!(field)
        end
      end

      def reindex!
        self.oss_index.delete!
        self.create_schema!

        self.all.find_in_batches  do |group|
          group.each { |doc| doc.index }
        end
      end

      def create_schema_field!(field)
        analyzers = { :text => 'StandardAnalyzer',  :integer => 'DecimalAnalyzer'}
        analyzer = analyzers[field[:type]] if field[:name] != :id
        termVectors = { :text => 'POSITIONS_OFFSETS'}
        termVector = termVectors[field[:type]] || 'NO'
        name =  "#{field[:name]}|#{field[:type]}"
        params = {
          'name' => name,
          'analyzer' => analyzer,
          'stored' => 'NO',
          'indexed' => 'YES',
          'termVector' => termVector
        }
        @@_text_fields[field[:name]] = name if field[:type] == :text
        @@_sortable_fields[field[:name]] = name unless field[:type] == :text
        self.oss_index.set_field(params)
        self.oss_index.set_field_default_unique(name, name) if field[:name] == :id
      end

      def method_missing(method, *args, &block)
        yield unless block.nil?
        add_field args[0], method, block if @@field_types.include? method
      end

      def search(*args, &block)
        searchRequest = SearchRequest.new(self.oss_index, @@_text_fields, @@_sortable_fields)
        searchRequest.returns @@_fields.map {|f|"#{f[:name]}|#{f[:type]}"}
        active_record_from_result searchRequest.execute(&block)
      end

      def get_ids_from_results(search_result)
        ids = []
        id_field_name = "#{@@_field_id[:name]}|#{@@_field_id[:type]}"
        search_result['documents'].each do |document|
          document['fields'].each do |field|
            ids << field['values'].map {|f|f.to_i}.uniq if field['fieldName'] == id_field_name
          end
        end
        return ids
      end

      def active_record_from_result(search_result)
        find get_ids_from_results(search_result)
      end

    end

    def to_indexable
      doc={}
      self.class._fields.each do |field|
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
end

ActiveRecord::Base.send :include, OssActiveRecord::Searchable