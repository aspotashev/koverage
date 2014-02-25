# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

capitalizeFirstLetter = (s) ->
  s[0].toUpperCase() + s[1..]

# http://www.discoded.com/2012/04/05/my-favorite-javascript-string-extensions-in-coffeescript/
if typeof String::startsWith != 'function'
  String::startsWith = (s) ->
    return this.slice(0, s.length) == s

$.fn.itemId = ->
  html_id = this[0].id
  html_id.match(/[0-9]+/)[0]

$.fn.itemParentId = ->
  classes = this[0].className.split(/\s+/)
  belongs_class = classes.filter((x) -> x.startsWith("belongs-"))[0]
  belongs_class.match(/[0-9]+/)[0]

packageToModule = (package_id) ->
  $('#package-id-' + package_id).itemParentId()

fileToPackage = (file_id) ->
  $('#file-id-' + file_id).itemParentId()

changeCurrentModule = (module_id) ->
  old_module_id = global.currentModuleId
  global.currentModuleId = module_id
  $('[id^="module-id-"]').removeClass('active')
  $('#module-id-' + module_id).addClass('active')
  $('[class^="belongs-module-id-"]').addClass('hidden')
  $('.belongs-module-id-' + module_id).removeClass('hidden')

changeCurrentPackage = (package_id) ->
  old_package_id = global.currentPackageId
  global.currentPackageId = package_id
  $('[id^="package-id-"]').removeClass('active')
  $('#package-id-' + package_id).addClass('active')
  $('[class^="belongs-package-id-"]').addClass('hidden')
  $('.belongs-package-id-' + package_id).removeClass('hidden')

changeCurrentFile = (file_id) ->
  old_file_id = global.currentFileId
  global.currentFileId = file_id
  $('[id^="file-id-"]').removeClass('active')
  $('#file-id-' + file_id).addClass('active')

packageElementsByModule = (module_id) ->
  $('.item.belongs-module-id-' + module_id)

fileElementsByPackage = (package_id) ->
  $('.item.belongs-package-id-' + package_id)

# We are not saving the "preferred" HTML class yet, so choosing the first
# package for the given module.
preferredPackage = (module_id) ->
  packageElementsByModule(module_id).itemId()

# We are not saving the "preferred" HTML class yet, so choosing the first
# file for the given package.
preferredFile = (package_id) ->
  fileElementsByPackage(package_id).itemId()

propagateFolderSelection = ->
  if global.currentModuleId != packageToModule(global.currentPackageId)
    changeCurrentPackage(preferredPackage(global.currentModuleId))
  if global.currentPackageId != fileToPackage(global.currentFileId)
    changeCurrentFile(preferredFile(global.currentPackageId))

$(document).ready ->
  changeCurrentModule(global.currentModuleId)
  changeCurrentPackage(global.currentPackageId)
  changeCurrentFile(global.currentFileId)
  propagateFolderSelection()

  $(document).on 'click', '.item', ->
    html_id = $(this).attr('id')
    [type, id] = html_id.split('-id-')

    idVar = 'current' + capitalizeFirstLetter(type) + 'Id'
    if global[idVar] != id
      # do the explicitly requested change
      if type == 'module'
        changeCurrentModule(id)
      else if type == 'package'
        changeCurrentPackage(id)
      else if type == 'file'
        changeCurrentFile(id)
      # cleanup after the change
      propagateFolderSelection()
