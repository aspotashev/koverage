class I18nModule < ActiveRecord::Base
  has_many :i18n_packages

  validates :name, presence: true, uniqueness: true

  def to_votes_tree
    { name: name, id: id, packages: i18n_packages.order(:name).map(&:to_votes_tree) }
  end
end
