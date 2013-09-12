module OssActiveRecord
  class SearchRequest
    def initialize(index_instance)
      @params = {'start' => 0,  'rows' => 10}
      @filters = []
      @index_instance = index_instance
      @order_by = {}
    end

    def fulltext(keywords, &block)
      @params['query'] = keywords
    end

    def filter(field, value, negative)
      @filters << {"type"=> "QueryFilter",  "negative"=> negative,  "query"=> "#{field}:(#{value})"}
    end

    def with(field, value)
      index_field = @index_instance.find_field_name(field)
      filter index_field, value, false unless index_field.nil?
    end

    def without(field, value)
      index_field = @index_instance.find_field_name(field)
      filter index_field, value, true unless index_field.nil?
    end

    def returns(fields)
      @params['returnedFields'] = fields.uniq
    end

    def paginate(params)
      rows = params[:per_page].to_i
      page = params[:page].to_i
      @params['start'] = (page - 1) * rows
      @params['rows'] = rows
    end

    def order_by(field = nil, direction = :asc)
      index_field = field == :score ? 'score' :@index_instance.find_sortable_name(field)
      @order_by[index_field] = direction.to_s.upcase unless index_field.nil?
    end

    def execute(&block)
      self.instance_eval(&block) unless block.nil?
      @params['filters'] = @filters unless @filters.length == 0
      fields = []
      @index_instance.text_fields.each do |key, value|
        fields<<{ "field"=> value,"phrase"=> true,"boost"=> 1.0}
      end
      @params['searchFields'] = fields unless fields.length == 0
      sorts = []
      @order_by.each do |key, value|
        sorts<<{ "field"=> key,"direction"=> value}
      end
      @params['sorts'] = sorts unless sorts.length == 0
      return @index_instance.oss_index.search_field(@params)
    end

  end

end
