module OssActiveRecord
  class SearchRequest
    def initialize(index_instance)
      @params = {'start' => 0,  'rows' => 10}
      @filters = []
      @index_instance = index_instance
      @order_by = {}
      @fields = []
    end

    def fulltext(keywords, &block)
      @params['query'] = keywords
      self.instance_eval(&block) unless block.nil?
    end

    def field(field, phrase = false, boost = 1.0)
      @fields<<{ "field"=> @index_instance.find_field_name(field), "phrase" => phrase, "boost" => boost} if field.is_a?Symbol
      @fields<<{ "field"=> field, "phrase" => phrase, "boost" => boost} if field.is_a?String
    end

    def fields(fields)
      fields.each do |key, value|
        field key, false, value
      end if fields.is_a?Hash
      field fields unless fields.is_a?Hash
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
      @index_instance.text_fields.each do |key, value|
        field value, true
      end unless @fields.any?
      @params['searchFields'] = @fields unless @fields.length == 0
      sorts = []
      @order_by.each do |key, value|
        sorts<<{ "field"=> key,"direction"=> value}
      end
      @params['sorts'] = sorts unless sorts.length == 0
      return @index_instance.oss_index.search_field(@params)
    end

  end

end
