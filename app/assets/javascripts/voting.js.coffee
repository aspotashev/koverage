# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

capitalizeFirstLetter = (s) ->
  s[0].toUpperCase() + s[1..]

# jQuery "plugin"
$.fn.classList = ->
  this.attr('class').split /\s+/

# http://www.discoded.com/2012/04/05/my-favorite-javascript-string-extensions-in-coffeescript/
if typeof String::startsWith != 'function'
  String::startsWith = (s) ->
    return this.slice(0, s.length) == s

packageToModule = (package_id) ->
  global.p2mCache[package_id]

fileToPackage = (file_id) ->
  global.f2pCache[file_id]

createDiv = (classes) ->
  d = $('<div>')
  for cl in classes
    d.addClass(cl)
  d

createViewItem = (text) ->
  el = $('<div>')
  el.addClass('item')
  el.append(createDiv(['text-content']).append(text))
  for color in ['gray', 'pink', 'yellow', 'green']
    btn = createDiv(['vote-btn', color])
    btn.append(createDiv(['vote-empty']))
    el.append(btn)
  el

renderModuleList = ->
  mEl = $('#module.col')
  mEl.html('')
  for m in global.votes_tree
    item = createViewItem(m.name)
    mEl.append(item)
    renderVote(item)

updatePackageList = ->
  pEl = $('#package.col')
  pEl.html('')
  for p in findById(global.votes_tree, global.currentModuleId).packages
    item = createViewItem(p.name)
    pEl.append(item)
    renderVote(item)

updateFileList = ->
  fEl = $('#file.col')
  fEl.html('')
  for f in findPackageById(global.votes_tree, global.currentPackageId).files
    item = createViewItem(f.name)
    fEl.append(item)
    renderVote(item)

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

# http://stackoverflow.com/questions/9231096/jquery-find-an-element-by-its-index
fileElementById = (id) ->
  $('#file.col').children().eq(viewIndexById('file', id))

packageElementById = (id) ->
  $('#package.col').children().eq(viewIndexById('package', id))

moduleElementById = (id) ->
  $('#module.col').children().eq(viewIndexById('module', id))

onClickFile = (id) ->
  old_id = global.currentFileId

  new_id = id
  # Second click clears selection
  if old_id == id
    new_id = undefined

  global.currentFileId = new_id

  if old_id != undefined and old_id != new_id
    el = fileElementById(old_id)
    if el
      el.removeClass('active')

  popup = $('#popup')
  if new_id != undefined
    fileElementById(new_id).addClass('active')
    popup.html('<p>Loading...</p>')
    popup.removeClass('hidden')
    $.ajax(
      type: 'get'
      url: '/voting/file_voters'
      dataType: 'html'
      data:
        'id' : new_id
      success: (data) ->
        popup.html(data)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(textStatus)
    )
  else
    popup.addClass('hidden')

changeCurrentPackage = (id) ->
  old_id = global.currentPackageId
  global.currentPackageId = id
  packageElementById(old_id).removeClass('active')
  packageElementById(id).addClass('active')
  updateFileList()

changeCurrentModule = (id) ->
  old_id = global.currentModuleId
  global.currentModuleId = id
  moduleElementById(old_id).removeClass('active')
  moduleElementById(id).addClass('active')
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
    onClickFile(undefined)
  #  changeCurrentFile(preferredFile(global.currentPackageId))

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

setVoteRemote = (type, id, voteChoice) ->
  $.ajax(
    type: 'put'
    url: '/voting/set_vote'
    dataType: 'json'
    data:
      'type': type
      'id' : id
      'choice' : voteChoice
    success: (result) ->
      console.log(result)
    error: (jqXHR, textStatus, errorThrown) ->
      console.log(textStatus)
  )

# func = function(acc, cur) { ... }
reduce = (arr, func) ->
  if arr.length <= 0
    undefined
  else
    acc = arr[0]
    for x in arr[1..]
      acc = func(acc, x)
    acc

# http://jsperf.com/jquery-class-create-vs-pure-js-function/3
SingleUserStats = Class.create()
SingleUserStats.prototype =
  initialize: (itemsCount) ->
    this.stats = {}
    for name in SingleUserStats.choices
      this.stats[name] = 0
    this.stats['none'] = itemsCount
  initSingle: (voteChoice) ->
    this.initialize(1)
    if voteChoice in SingleUserStats.choices and voteChoice != 'none'
      this.stats[voteChoice] = 1
      this.stats['none'] -= 1
  getFillingGrade: (voteChoice) ->
    selected = 0
    other = 0
    for name in SingleUserStats.choices
      if name == voteChoice
        selected += this.stats[name]
      else
        other += this.stats[name]
    console.log([selected, other])
    if selected == 0
      'empty'
    else if other == 0
      'full'
    else
      'partial'
SingleUserStats.choices = ['gray', 'pink', 'yellow', 'green', 'none']
SingleUserStats.sum = (a, b) ->
  r = new SingleUserStats(0)
  for name in SingleUserStats.choices
    r.stats[name] = a.stats[name] + b.stats[name]
  r
SingleUserStats.sumArray = (arr) ->
  reduce(arr,
    (acc, cur) ->
      SingleUserStats.sum(acc, cur)
  )

statsPerFile = (module_index, package_index, index) ->
  file = global.votes_tree[module_index].packages[package_index].files[index]
  r = new SingleUserStats(1)
  r.initSingle(global.my_votes[file.id])
  #console.log('spf: ' + r)
  r

statsPerPackage = (module_index, index) ->
  nFiles = global.votes_tree[module_index].packages[index].files.length
  r = SingleUserStats.sumArray((statsPerFile(module_index, index, i) for i in [0...nFiles]))
  #console.log('spp: ' + r)
  r

statsPerModule = (index) ->
  nPackages = global.votes_tree[index].packages.length
  r = SingleUserStats.sumArray((statsPerPackage(index, i) for i in [0...nPackages]))
  #console.log('spm: ' + r)
  r

renderVote = (item) ->
  viewIdx = item.index()
  type = item.parent().attr('id')
  id = viewIdByIndex(type, viewIdx)
  stats = switch type
    when 'module'
      statsPerModule(viewIdx)
    when 'package'
      moduleIdx = viewIndexById('module', global.currentModuleId)
      statsPerPackage(moduleIdx, viewIdx)
    when 'file'
      moduleIdx = viewIndexById('module', global.currentModuleId)
      packageIdx = viewIndexById('package', global.currentPackageId)
      statsPerFile(moduleIdx, packageIdx, viewIdx)
  #console.log("renderVote: " + type + ' #' + viewIdx)
  for voteChoice in ['gray', 'pink', 'yellow', 'green'] # filter out "undefined"
    item.find('.vote-btn.' + voteChoice).find('div').attr('class', 'vote-' + stats.getFillingGrade(voteChoice))

# set vote in the internal database (global.votes_tree)
setVoteInternal = (type, id, voteChoice) ->
  switch type
    when 'module'
      for p in findById(global.votes_tree, id).packages
        setVoteInternal('package', p.id, voteChoice)
    when 'package'
      for f in findPackageById(global.votes_tree, id).files
        setVoteInternal('file', f.id, voteChoice)
    when 'file'
      #console.log(1)
      global.my_votes[id] = voteChoice
      #setVoteInternal() renderVote(fileElementById(id), voteChoice)
      # TBD: re-render parent package and module

# voteChoice in ['gray', 'pink', 'yellow', 'green', 'none']
# Render the chosen item and its dependencies
renderVoteDependencies = (type, id) ->
  switch type
    when 'module'
      for p in findById(global.votes_tree, id).packages
        renderVoteDependencies('package', p.id)
      renderVote(moduleElementById(id))
    when 'package'
      for f in findPackageById(global.votes_tree, id).files
        renderVoteDependencies('file', f.id)
      renderVote(packageElementById(id))
      # Re-render parent module
      module_id = packageToModule(id)
      renderVote(moduleElementById(module_id))
    when 'file'
      renderVote(fileElementById(id))
      # Re-render parent package and module
      package_id = fileToPackage(id)
      module_id = packageToModule(package_id)
      renderVote(packageElementById(package_id))
      renderVote(moduleElementById(module_id))

addVote = (type, id, voteChoice) ->
  #console.log(type)
  setVoteInternal(type, id, voteChoice)
  renderVoteDependencies(type, id)
  setVoteRemote(type, id, voteChoice)

removeVote = (type, id, voteChoice) ->
  setVoteInternal(type, id, 'none')
  renderVoteDependencies(type, id)
  setVoteRemote(type, id, 'none')

onClickItem = (item) ->
  viewIdx = item.index()
  type = item.parent().attr('id')
  id = viewIdByIndex(type, viewIdx)

  idVar = 'current' + capitalizeFirstLetter(type) + 'Id'
  if type == 'file'
    onClickFile(id)
  else if global[idVar] != id
    # do the explicitly requested change
    if type == 'module'
      changeCurrentModule(id)
    else if type == 'package'
      changeCurrentPackage(id)
    # cleanup after the change
    propagateFolderSelection()

loadFullTree = ->
  $.ajax(
    type: 'get'
    url: '/voting/full_tree'
    dataType: 'json'
#    data:
#      'id' : fetch_id,
#      'secret' : fetch_secret
    success: (data) ->
      global.votes_tree = data.tree

      global.my_votes = {}
      intToColor =
        0: 'none'
        1: 'green'
        2: 'yellow'
        3: 'pink'
        4: 'gray'
      for k, v of data.my_votes
        global.my_votes[k] = intToColor[v]

      #changeCurrentModule(votes_tree[0].id)
      #changeCurrentPackage(votes_tree[0].packages[0].id)
      #changeCurrentFile(votes_tree[0].packages[0].files[0].id)

      precalcParents()
      renderModuleList()

      changeCurrentModule(global.currentModuleId)
      changeCurrentPackage(global.currentPackageId)
      #changeCurrentFile(global.currentFileId)
      propagateFolderSelection()
    error: (jqXHR, textStatus, errorThrown) ->
      alert(textStatus)
  )

initVotingMy = ->
  #changeCurrentModule(global.currentModuleId)
  #changeCurrentPackage(global.currentPackageId)
  #changeCurrentFile(global.currentFileId)
  #propagateFolderSelection()

  # JSON payload format:
  # {
  #   tree: [ module1, module2, ... ],
  #   my_votes: { file1_id: my_file1_vote, ... }
  # }
  #
  # "moduleN" is an object:
  # { name: 'moduleN-name', id: moduleN-id-in-database, packages: [ package1, package2, ... ]
  #
  # "packageN" is an object:
  # { name: 'packageN-name', id: packageN-id-in-database, files: [ file1, file2, ... ]
  #
  # "fileN" is an object:
  # { name: 'fileN-name', id: fileN-id-in-database }
  #
  # "integer-vote-code" is one of:
  #   0 (gray = don't care),
  #   1 (pink = interested),
  #   2 (yellow = newbie user),
  #   3 (green = pro user)

  loadFullTree()

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
    onClickItem($(this))

  $(document).on 'click', '.vote-btn', ->
    item = $(this).parent()
    onClickItem(item)

    viewIdx = item.index()
    type = item.parent().attr('id')
    #console.log('type = ' + type)
    id = viewIdByIndex(type, viewIdx)
    currentState = $(this).children().eq(0).attr('class')
    voteChoice = $(this).classList().filter((x) -> x in ['gray', 'pink', 'yellow', 'green'])[0]
    switch currentState
      when 'vote-empty', 'vote-partial'
        addVote(type, id, voteChoice)
      when 'vote-full'
        removeVote(type, id)

$(document).ready ->
  if $('#main-columns').length > 0
    initVotingMy()
