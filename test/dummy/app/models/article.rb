class Article < ActiveRecord::Base

  searchable do
    integer  :id
    text     :title              # fulltext
    string   :title              # order_by
    text     :content            #fulltext
    integer  :category_id
    time     :updated_at
  end

end
