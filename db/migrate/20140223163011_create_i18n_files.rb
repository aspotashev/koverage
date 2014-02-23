class CreateI18nFiles < ActiveRecord::Migration
  def change
    create_table :i18n_files do |t|
      t.string :name
      t.integer :i18n_package_id

      t.timestamps
    end
  end
end
