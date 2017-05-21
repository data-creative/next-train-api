class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.string :source_url, :null => false
      t.datetime :published_at, :null => false
      t.integer :content_length
      t.string :etag
      t.boolean :active, :default => false

      t.timestamps
    end

    add_index :schedules, [:source_url, :published_at], :unique => true
    add_index :schedules, :source_url
    add_index :schedules, :published_at
    add_index :schedules, :active
  end
end
