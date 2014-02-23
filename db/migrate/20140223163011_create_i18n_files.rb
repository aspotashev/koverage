class CreateI18nFiles < ActiveRecord::Migration
  def change
    create_table :i18n_files do |t|
      t.string :name
      t.belongs_to :i18n_package

      t.timestamps
    end
  end
end
