class InvalidArticle < ActiveRecord::Base

  searchable do
    integer  :id
    glop     :room_id
    text     :title             # fulltext
    string   :title             # order_by
    text     :content
    time     :updated_at
  end

end
