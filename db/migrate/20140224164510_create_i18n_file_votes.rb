class CreateI18nFileVotes < ActiveRecord::Migration
  def change
    create_table :i18n_file_votes do |t|
      t.belongs_to :user
      t.belongs_to :i18n_file

      t.timestamps
    end
  end
end
