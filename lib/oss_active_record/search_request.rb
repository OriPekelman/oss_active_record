module OssActiveRecord
  class SearchRequest
    def initialize(index, text_fields, sortable_fields)
      @index = index
      @params = {'start' => 0,  'rows' => 10}
      @filters = [];
      @text_fields = text_fields;
      @sortable_fields = sortable_fields;
      @order_by = {};
    end

    def fulltext(keywords, &block)
      @params['query'] = keywords
    end

    def filter(field, value, negative)
      @filters << {"type"=> "QueryFilter",  "negative"=> negative,  "query"=> "#{field}:#{value}"}
    end

    def with(field, value)
      filter field, value, false
    end

    def without(field, value)
      filter field, value, true
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
      field = field == :score ? 'score' :@sortable_fields[field]
      @order_by[field.to_s] = direction.to_s.upcase unless field.nil?
    end

    def execute(&block)
      self.instance_eval(&block) unless block.nil?
      @params['filters'] = @filters unless @filters.length == 0
      fields = []
      @text_fields.each do |key, value|
        fields<<{ "field"=> value,"phrase"=> true,"boost"=> 1.0}
      end
      @params['searchFields'] = fields unless fields.length == 0
      sorts = []
      @order_by.each do |key, value|
        sorts<<{ "field"=> key,"direction"=> value}
      end
      @params['sorts'] = sorts unless sorts.length == 0
      return @index.search_field(@params)
    end

  end

end
