require_relative '../../../test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles

  setup do
    Article.reindex!
  end

  test "Index article" do

    result = Article.search do
      fulltext 'weather'
    end
    assert result.length == 1
    assert result[0]['title'] == 'Weather report'
  end

end
