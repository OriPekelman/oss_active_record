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
      self.class.oss_index.documents = []
    end

    module ClassMethods
      @@field_types= [:integer, :text, :string, :time] #supported field types
      @@_fields=[]
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
        @@_fields <<  {:name => "id", :type => "integer",:block => nil} if @@_fields.detect {|f| f[:name] == "id" }.nil?
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
        analyzer = analyzers[field[:type]]
        termVectors = { :text => 'POSITIONS_OFFSETS'}
        termVector = termVectors[field[:type]] || 'NO'
        name =  "#{field[:name]}|#{field[:type]}"
        params = {
          'name' => name,
          'analyzer' => analyzer,
          'stored' => 'YES',
          'indexed' => 'YES',
          'termVector' => termVector
        }
        self.oss_index.set_field(params)
        self.oss_index.set_field_default_unique(name, name) if field[:name] == "id"
      end

      def method_missing(method, *args, &block)
        yield unless block.nil?
        add_field args[0], method, block if @@field_types.include? method
      end

      def search(*args, &block)
        yield unless block.nil?
        params = {
          'query_template' => 'search',
          'start' => 0,
          'rows' => 10,
          'rf' => @@_fields.map {|f|f[:name]}
        }
        active_record_from_result self.oss_index.search(args[0], params)
      end

      def get_ids_from_results(search_result)
        search_result.css("result doc field[name='id']").map {|f|f.text.to_i}.uniq
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