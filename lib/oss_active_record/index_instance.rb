module OssActiveRecord
  class IndexInstance

    @@_analyzers = {
      :text => 'StandardAnalyzer',
      :integer => 'IntegerAnalyzer',
      :decimal => 'DecimalAnalyzer',
      :suggestion => 'SuggestionAnalyzer'}

    def initialize(index_name)
      @_index_name ||= index_name
      @_fields= []
      @_field_id = nil
      @_text_fields = {}
      @_sortable_fields = {}
      @_all_fields = {}
      @_index = nil
    end

    def text_fields
      @_text_fields
    end

    def fields
      @_fields
    end

    def field_id
      @_field_id
    end

    def oss_index
      if @_index.nil?
        @_index = Oss::Index.new(@_index_name,
        Rails.configuration.open_search_server_url,
        Rails.configuration.open_search_server_login,
        Rails.configuration.open_search_server_apikey)
        create_schema!
      end
      @_index
    end

    def find_sortable_name(field_name)
      field_name == :score ? 'score' : @_sortable_fields[field_name] unless field_name.nil?
    end

    def find_field_name(field_name)
      @_all_fields[field_name] unless field_name.nil?
    end

    def add_field(name, type, block=nil)
      @_fields<<{:name => name, :type => type,:block => block}
    end

    def create_schema!
      @_index.create('EMPTY_INDEX') unless @_index.list.include? @_index_name
      @_field_id =  @_fields.detect {|f| f[:name] == :id }
      @_field_id = {:name => 'id', :type => 'integer',:block => nil} if @_field_id.nil?
      @_fields <<  @_field_id
      @_fields.each do |field|
        create_schema_field!(field)
      end
    end

    def create_schema_field!(field)
      analyzer = @@_analyzers[field[:type]] if field[:name] != :id
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
      @_text_fields[field[:name]] = name if field[:type] == :text
      @_sortable_fields[field[:name]] = name unless field[:type] == :text
      @_all_fields[field[:name]] = name
      @_index.set_field(params)
      @_index.set_field_default_unique(name, name) if field[:name] == :id
    end

    def index(docs)
      @_index.documents << docs
      @_index.index!
    end

    def delete_by_id(id)
      id_field = find_sortable_name(:id)
      @_index.delete_document_by_value(id_field, id) unless id_field.nil?
    end

  end

end