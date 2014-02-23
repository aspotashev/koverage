class CreateI18nModules < ActiveRecord::Migration
  def change
    create_table :i18n_modules do |t|
      t.string :name

      t.timestamps
    end
  end
end
