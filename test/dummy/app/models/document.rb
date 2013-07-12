class Document < ActiveRecord::Base
  #  belongs_to :current_revision
  def folder
    self.folder_id = 42
    self
    
  end
  
  def current_revision
    self.uuid= 42
    self.user_id=42
    self.state = 42
    self
  end
  
  def self.folder
    Document
  end
  
  def self.current_revision
    Document
  end
  searchable do
    integer  :id
    integer  :folder_id
    integer  :room_id           do folder.room_id end

    text     :name              # fulltext
    string   :name              # order_by
    time     :updated_at

    integer  :uuid              do current_revision.uuid end
    integer  :user_id           do current_revision.user_id end
    integer  :file_size         do current_revision.file_size end
    string   :file_content_type do current_revision.file_content_type end
    string   :state             do current_revision.state end
  end
  
end