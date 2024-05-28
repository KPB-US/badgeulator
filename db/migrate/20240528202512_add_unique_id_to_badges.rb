class AddUniqueIdToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :unique_id, :string
  end
end
