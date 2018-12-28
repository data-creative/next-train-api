class LongerRouteDescriptions < ActiveRecord::Migration[5.2]
  def up
    change_column :routes, :description, :text
  end

  def down
    change_column :routes, :description, :string
  end
end # h/t https://tosbourn.com/rails-migrate-change-column-type/
