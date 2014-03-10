class AddChoiceToI18nFileVotes < ActiveRecord::Migration
  def change
    add_column :i18n_file_votes, :choice, :integer
  end
end
