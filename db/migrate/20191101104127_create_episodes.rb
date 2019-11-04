class CreateEpisodes < ActiveRecord::Migration[6.0]
  def change
    create_table :episodes do |t|
      t.string :href, nil: false
      t.string :title, nil: false
      t.string :number, nil: false
      t.date   :date, nil: false
      t.string :label, nil: false
      t.text   :description, nil: false
      t.text   :fresh_summary
      t.timestamps
    end
  end
end
