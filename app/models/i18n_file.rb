class I18nFile < ActiveRecord::Base
  belongs_to :i18n_package
  has_many :users, through: :i18n_file_votes

  validates :name, presence: true, uniqueness: true
end
