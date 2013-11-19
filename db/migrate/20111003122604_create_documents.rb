class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_upload_at
      t.integer :course_id
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end