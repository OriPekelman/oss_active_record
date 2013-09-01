module OssActiveRecord
  class SearchRequest
    def initialize(index)
      @index = index
      @params = {'start' => 0,  'rows' => 10}
    end

    def fulltext(keywords)
      @params['query'] = keywords
    end

    def with(field, value)
      puts "WITH #{field} #{value}"
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

    def execute(&block)
      self.instance_eval(&block) unless block.nil?
      puts "PARAMS #{@params}"
      return @index.search_pattern(@params)
    end

  end

end
