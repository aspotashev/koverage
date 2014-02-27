class I18nFile < ActiveRecord::Base
  belongs_to :i18n_package
  has_many :users, through: :i18n_file_votes

  validates :name, presence: true, uniqueness: true

  def to_votes_tree
    { name: name, id: id } #, my_vote: users.find(current_user) || 0 }
  end
end
