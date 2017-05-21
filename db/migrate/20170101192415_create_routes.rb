class CreateRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.integer :schedule_id, :null => false
      t.string :guid, :null => false
      t.string :agency_guid
      t.string :short_name
      t.string :long_name
      t.string :description
      t.integer :code, :length => 4 # @see https://developers.google.com/transit/gtfs/reference/extended-route-types
      t.string :url
      t.string :color, :length => 6
      t.string :text_color, :length => 6

      t.timestamps
    end

    add_index :routes, [:schedule_id, :guid], :unique => true
    add_index :routes, :schedule_id
    add_index :routes, :guid
    add_index :routes, :code
  end
end
