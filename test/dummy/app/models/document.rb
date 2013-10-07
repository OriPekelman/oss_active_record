class CurrentRevision
  def uuid
    42
  end

  def user_id
    42
  end

  def file_size
    42
  end

  def file_content_type
    "42/42"
  end

  def state
    "42"
  end
end

class Folder
  def room_id
    42
  end
end

class Document < ActiveRecord::Base
  belongs_to :current_revision

  def folder
    Folder.new
  end

  def current_revision
    CurrentRevision.new
  end

  searchable do
    integer  :id
    integer  :folder_id
    integer  :room_id           do folder.room_id end

    text     :name              # fulltext
    string   :name              # order_by
    suggestion :name            # Suggestion (autocompletion)
    time     :updated_at

    integer  :uuid              do current_revision.uuid end
    integer  :user_id           do current_revision.user_id end
    integer  :file_size         do current_revision.file_size end
    string   :file_content_type do current_revision.file_content_type end
    string   :state             do current_revision.state end
  end
end
