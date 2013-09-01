require_relative '../../../test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "Index" do
    article = Article.new(id: 1, title: 'Weather report', content: 'Sunny weather today')
    article.save
    article = Article.new(id: 2, title: 'Active record rocks', content: 'Using OpenSearchServer with active record is simple')
    article.save
    puts Article.search("title|text:weather")
  end
end
