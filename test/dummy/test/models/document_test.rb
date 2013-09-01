require_relative '../../../test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
  
  test "Search" do
    @documents = Document.search(:include => { :current_revision => :user }) do
         fulltext 'test'
         with :room_id, 1
         paginate page: 1, per_page: 10
       end
       @documents.each { |document| puts document }
  end
end