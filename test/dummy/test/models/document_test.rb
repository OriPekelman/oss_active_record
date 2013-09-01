require_relative '../../../test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
  
  test "Search" do
    @documents = Document.search(:include => { :current_revision => :user }) do
         fulltext filters[:query]
         with :room_id, room_id
         paginate page: filters[:page], per_page: filters[:per]
       end
       @documents.results.each { |document| puts document }
  end
end