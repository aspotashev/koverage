class I18nPackage < ActiveRecord::Base
  belongs_to :i18n_module
  has_many :i18n_files
end
