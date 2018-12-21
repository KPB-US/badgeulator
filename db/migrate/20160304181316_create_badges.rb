class CreateBadges < ActiveRecord::Migration[4.2]
  def change
    create_table :badges do |t|
      t.string :employee_id
      t.string :name
      t.string :title
      t.string :department
      t.binary :picture

      t.timestamps null: false
    end
  end
end
