class CreateI18nPackages < ActiveRecord::Migration
  def change
    create_table :i18n_packages do |t|
      t.string :name
      t.belongs_to :i18n_module

      t.timestamps
    end
  end
end
