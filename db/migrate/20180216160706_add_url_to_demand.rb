# frozen_string_literal: true

class AddUrlToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :url, :string
  end
end
