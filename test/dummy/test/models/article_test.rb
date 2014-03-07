require_relative '../../../test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles

  setup do
    Article.reindex!
  end

  test "Full text search" do

    results = Article.search do
      fulltext 'weather'
    end

    assert results.length == 1, 'The number of result is wrong, should be one'
    assert results[0][:title] == 'Weather report', 'The returned title is wrong'
  end

  test "Ascending order" do

    results = Article.search do
      order_by :category_id, :asc
    end

    cat_id = nil
    results.each do |article|
      assert(cat_id <= article[:category_id], 'Order is wrong') unless cat_id.nil?
      cat_id = article[:category_id]
    end
  end

  test "Descending order" do

    results = Article.search do
      order_by :category_id, :desc
    end

    cat_id = nil
    results.each do |article|
      assert(cat_id >= article[:category_id], 'Order is wrong') unless cat_id.nil?
      cat_id = article[:category_id]
    end

  end

  test "Deletion" do

    results = Article.search do
      fulltext 'weather'
    end

    results[0].destroy
  end

end
