class I18nModule < ActiveRecord::Base
  has_many :i18n_packages

  validates :name, presence: true, uniqueness: true
end
