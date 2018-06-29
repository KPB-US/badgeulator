class AddDnToBadge < ActiveRecord::Migration[4.2]
  def change
    add_column :badges, :dn, :string
  end
end
