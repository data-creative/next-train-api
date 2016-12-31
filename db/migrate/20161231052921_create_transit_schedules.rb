class CreateTransitSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :transit_schedules do |t|
      t.string :source_url, :null => false
      t.datetime :published_at, :null => false
      t.integer :content_length
      t.string :etag

      t.timestamps
    end

    add_index :transit_schedules, [:source_url, :published_at], :unique => true
    add_index :transit_schedules, :source_url
    add_index :transit_schedules, :published_at
  end
end
