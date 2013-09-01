class Article < ActiveRecord::Base

  searchable do
    integer  :id
    text     :title              # fulltext
    string   :title              # order_by
    text     :content            #fulltext
    time     :updated_at
  end

end
