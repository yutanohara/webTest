class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.text :password
      t.string :nickname
      t.string :comment

      t.timestamps
    end
  end
end
