class CreateI18nPackages < ActiveRecord::Migration
  def change
    create_table :i18n_packages do |t|
      t.string :name
      t.integer :i18n_module_id

      t.timestamps
    end
  end
end
