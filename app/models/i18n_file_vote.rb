class I18nFileVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :i18n_file

  def choice_string
    codes_to_names = {
      0 => 'none',
      1 => 'green',
      2 => 'yellow',
      3 => 'pink',
      4 => 'gray',
    }

    codes_to_names[choice]
  end
end
