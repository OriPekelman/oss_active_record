require_relative '../../../test_helper'

class DocumentTest < ActiveSupport::TestCase
  fixtures :documents

  setup do
    Document.reindex!
  end

  test "the truth" do
    assert true
  end

  test "Search document" do
    result = Document.search(:include => { :current_revision => :user }) do
      fulltext 'document'
      with(:room_id, 42)
      without(:room_id, 43)
      paginate page: 1, per_page: 10
      order_by :score, :desc
      order_by :id
    end
    assert result.length == 2, 'The number of document returned is wrong'
  end

  test "Suggestion" do
    result = Document.search do
      fulltext 'An' do
        fields('name|suggestion')
      end
    end
    assert result.length == 1, 'The number of returned suggestion is wrong'
  end

end