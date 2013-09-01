class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :folder_id
      t.integer :room_id
      t.string :name
      t.time :updated_at
      t.integer :uuid
      t.integer :user_id
      t.integer :file_size
      t.string :file_content_type
      t.string :state

      t.timestamps
    end
  end
end