class AddDefaultToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :default, :boolean
  end
end
