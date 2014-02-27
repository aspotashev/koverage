class I18nPackage < ActiveRecord::Base
  belongs_to :i18n_module
  has_many :i18n_files

  validates :name, presence: true, uniqueness: true

  def to_votes_tree
    { name: name, id: id, files: i18n_files.order(:name).map(&:to_votes_tree) }
  end
end
