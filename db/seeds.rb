# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'

def get_map(fn)
  open("http://ren-tour.com/kde/#{fn}").read.split("\n").map(&:split)
end

package2module = get_map('package-to-module.txt')
pot2package    = get_map('pot-to-package.txt')

modules = package2module.map(&:last).sort.uniq
modules.each do |mod|
  I18nModule.create(name: mod)
end

I18nPackage.create(package2module.map do |package,mod_name|
  mod = I18nModule.find_by(name: mod_name)
  { name: package, i18n_module: mod }
end)

I18nFile.create(pot2package.map do |pot,package_name|
  package = I18nPackage.find_by(name: package_name)
  { name: pot, i18n_package: package }
end)
