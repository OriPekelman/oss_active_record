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
         fulltext 'test'
         with :room_id, 1
         paginate page: 1, per_page: 10
         order_by :score, :desc
         order_by :id
       end
       result.each { |document| puts document }
       assert true
  end
end