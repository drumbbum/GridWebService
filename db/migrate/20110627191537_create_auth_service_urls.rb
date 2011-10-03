class CreateAuthServiceUrls < ActiveRecord::Migration
  def self.up
    create_table :auth_service_urls do |t|
      t.string :url
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :auth_service_urls
  end
end
