class CreateArs < ActiveRecord::Migration
  def up
    create_table :firsts
    create_table :seconds
  end

  def down
  end
end
