class AddGeneratedAtToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :generated_at, :datetime
  end
end
