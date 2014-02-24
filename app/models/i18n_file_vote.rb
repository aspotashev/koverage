class I18nFileVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :i18n_file
end
