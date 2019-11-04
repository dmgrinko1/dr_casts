class Episode < ApplicationRecord
  # connects_to database: { writing: :drifting_ruby_app, reading: :drifting_ruby_app_dev_replica }
  validates :href, :title, :number, :date, :label, :description,
            presence: true
end
