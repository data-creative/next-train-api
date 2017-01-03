class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.integer :schedule_id, :null => false
      t.string :service_guid, :null => false
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :calendars, [:schedule_id, :service_guid], :unique => true
    add_index :calendars, :schedule_id
    add_index :calendars, :service_guid
    add_index :calendars, :start_date
    add_index :calendars, :end_date
  end
end
