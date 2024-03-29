class CreateImportedContacts < ActiveRecord::Migration
  def self.up
    create_table :imported_contacts do |t|
      t.integer :user_id
      t.string :name
      t.string :email, :limit => 100
      t.timestamps
    end
  end

  def self.down
    drop_table :imported_contacts
  end
end

