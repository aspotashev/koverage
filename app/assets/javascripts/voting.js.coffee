# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

capitalizeFirstLetter = (s) ->
  s[0].toUpperCase() + s[1..]

# http://www.discoded.com/2012/04/05/my-favorite-javascript-string-extensions-in-coffeescript/
if typeof String::startsWith != 'function'
  String::startsWith = (s) ->
    return this.slice(0, s.length) == s

packageToModule = (package_id) ->
  global.p2mCache[package_id]

fileToPackage = (file_id) ->
  global.f2pCache[file_id]

createViewItem = (text) ->
  el = $('<div>')
  el.addClass('item')
  el.append(text)
  for color in ['gray', 'pink', 'yellow', 'green']
    btn = $('<div>')
    btn.addClass('vote-btn')
    btn.addClass(color)
    el.append(btn)
  el

renderModuleList = ->
  mEl = $('#module.col')
  mEl.html('')
  for m in global.votes_tree
    mEl.append(createViewItem(m.name))

updatePackageList = ->
  pEl = $('#package.col')
  pEl.html('')
  for p in findById(global.votes_tree, global.currentModuleId).packages
    pEl.append(createViewItem(p.name))

updateFileList = ->
  fEl = $('#file.col')
  fEl.html('')
  for f in findPackageById(global.votes_tree, global.currentPackageId).files
    fEl.append(createViewItem(f.name))

# TBD: rewrite using indexById
findById = (arr, id) ->
  for x in arr
    if x.id == id
      return x
  null

indexById = (arr, id) ->
  for x, i in arr
    if x.id == id
      return i
  null

# type = "file" or "package" or "module"
viewIndexById = (type, id) ->
  switch type
    when 'file'    then indexById(findPackageById(global.votes_tree, global.currentPackageId).files, id)
    when 'package' then indexById(findById(global.votes_tree, global.currentModuleId).packages, id)
    when 'module'  then indexById(global.votes_tree, id)
    else null

# type = "file" or "package" or "module"
viewIdByIndex = (type, index) ->
  switch type
    when 'file'    then findPackageById(global.votes_tree, global.currentPackageId).files[index].id
    when 'package' then findById(global.votes_tree, global.currentModuleId).packages[index].id
    when 'module'  then global.votes_tree[index].id
    else null

changeCurrentFile = (file_id) ->
  old_file_id = global.currentFileId
  global.currentFileId = file_id
  # http://stackoverflow.com/questions/9231096/jquery-find-an-element-by-its-index
  $('#file.col').children().eq(
    viewIndexById('file', old_file_id)).removeClass('active')
  $('#file.col').children().eq(
    viewIndexById('file', file_id)).addClass('active')

changeCurrentPackage = (package_id) ->
  old_package_id = global.currentPackageId
  global.currentPackageId = package_id
  $('#package.col').children().eq(
    viewIndexById('package', old_package_id)).removeClass('active')
  $('#package.col').children().eq(
    viewIndexById('package', package_id)).addClass('active')
  updateFileList()

changeCurrentModule = (module_id) ->
  old_module_id = global.currentModuleId
  global.currentModuleId = module_id
  $('#module.col').children().eq(
    viewIndexById('module', old_module_id)).removeClass('active')
  $('#module.col').children().eq(
    viewIndexById('module', module_id)).addClass('active')
  updatePackageList()

findPackageById = (modules, package_id) ->
  for m in modules
    for p in m.packages
      if p.id == package_id
        return p
  null

# We are not saving the "preferred" HTML class yet, so choosing the first
# package for the given module.
preferredPackage = (module_id) ->
  findById(global.votes_tree, module_id).packages[0].id

# We are not saving the "preferred" HTML class yet, so choosing the first
# file for the given package.
preferredFile = (package_id) ->
  findPackageById(global.votes_tree, package_id).files[0].id

propagateFolderSelection = ->
  if global.currentModuleId != packageToModule(global.currentPackageId)
    changeCurrentPackage(preferredPackage(global.currentModuleId))
  if global.currentPackageId != fileToPackage(global.currentFileId)
    changeCurrentFile(preferredFile(global.currentPackageId))

precalcParents = ->
  global.p2mCache = {}
  for m in global.votes_tree
    for p in m.packages
      global.p2mCache[p.id] = m.id
  global.f2pCache = {}
  for m in global.votes_tree
    for p in m.packages
      for f in p.files
        global.f2pCache[f.id] = p.id

$(document).ready ->
  #changeCurrentModule(global.currentModuleId)
  #changeCurrentPackage(global.currentPackageId)
  #changeCurrentFile(global.currentFileId)
  #propagateFolderSelection()

  # JSON payload format:
  # [ module1, module2, ... ]
  #
  # "moduleN" is an object:
  # { name: 'moduleN-name', id: moduleN-id-in-database, packages: [ package1, package2, ... ]
  #
  # "packageN" is an object:
  # { name: 'packageN-name', id: packageN-id-in-database, files: [ file1, file2, ... ]
  #
  # "fileN" is an object:
  # { name: 'fileN-name', id: fileN-id-in-database, my_vote: integer-vote-code }
  #
  # "integer-vote-code" is one of:
  #   0 (gray = don't care),
  #   1 (pink = interested),
  #   2 (yellow = newbie user),
  #   3 (green = pro user)

  $.ajax(
    type: 'GET'
    url: '/voting/full_tree'
    dataType: 'json'
#    data:
#      'id' : fetch_id,
#      'secret' : fetch_secret
    success: (votes_tree) ->
      global.votes_tree = votes_tree
      #changeCurrentModule(votes_tree[0].id)
      #changeCurrentPackage(votes_tree[0].packages[0].id)
      #changeCurrentFile(votes_tree[0].packages[0].files[0].id)

      precalcParents()
      renderModuleList()

      changeCurrentModule(global.currentModuleId)
      changeCurrentPackage(global.currentPackageId)
      changeCurrentFile(global.currentFileId)
      propagateFolderSelection()
    error: (jqXHR, textStatus, errorThrown) ->
      alert(textStatus)
  )

#      //edit innerHTML of basic_modal
#      $('.basic_modal').html(
#        "<div id='modal_image'><%= escape_javascript(image_tag p[:url]) %></div><div id='photo_title'><%=data.title %></div>"
#       );
#
#      //load modal
#        $('.basic_modal').modal({
#        overlayClose:true
#      });
#
#    } //end success: function(result)
#  });


  # $('.item').append('<div class="vote-btn gray"></div>')

  $(document).on 'click', '.item', ->
    viewIdx = $(this).index()
    type = this.parentNode.id
    id = viewIdByIndex(type, viewIdx)

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

#  $(document).on 'click', '.vote-btn', ->
#    undefined
