class CreateVisitors < ActiveRecord::Migration[7.2]
  def change
    create_table :visitors do |t|
      t.string :user_agent

      t.timestamps
    end
  end
end
