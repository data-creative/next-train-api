class CreateAgencies < ActiveRecord::Migration[5.0]
  def change
    create_table :agencies do |t|
      t.integer :schedule_id, :null => false
      t.string :url, :null => false

      t.string :guid
      t.string :name #, :null => false ... enforce via model validation instead
      t.string :timezone #, :null => false ... enforce via model validation instead
      t.string :phone
      t.string :lang

      t.timestamps
    end

    add_index :agencies, [:schedule_id, :url], :unique => true
    add_index :agencies, :schedule_id
    add_index :agencies, :url

    add_index :agencies, :guid
    add_index :agencies, :name
  end
end
