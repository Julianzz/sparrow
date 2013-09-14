###
module = angular.module("plunker.editor", ["ui.directives", "plunker.scratch", "plunker.url", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.statusbar", "plunker.multipanel", "plunker.toolbar"])
###
module = angular.module("plunker.editor", [
  "ui.directives", 
  "plunker.scratch", 
  "plunker.url", 
  "plunker.userpanel",
  "plunker.layout", 
  "plunker.ace", 
  "plunker.filelist",
  "plunker.downloader",
  "plunker.buffers",
  "plunker.filebrowser",
  "plunker.toolbar",
  "plunker.selectlist",
  "plunker.multipanel",
  "plunker.controller.editor",
  "plunker.controller.status",
  "plunker.browsertree"
])

module.value "ui.config",
  select2:
    tags:["angularjs","angular-ui","jquery","bootstrap","jquery-ui","coffee", "YUI"]
    tokenSeparators: [",", " "]
