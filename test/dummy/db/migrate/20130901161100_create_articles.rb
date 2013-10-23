class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :content
      t.integer :category_id
      t.time :updated_at
      t.timestamps
    end
  end
end
