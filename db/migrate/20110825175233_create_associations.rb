class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.string :objectName
      t.string :roleName
      t.integer :cql_object_id

      t.timestamps
    end
  end

  def self.down
    drop_table :associations
  end
end
