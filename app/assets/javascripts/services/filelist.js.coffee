module = angular.module("plunker.filelist", [])

module.factory "fileList", [ () ->
  new class FileList
    constructor: ->
      @root = 
        "type": "directory"
        "path": "/"
        "name": ""
        "children":
          "liu": 
            "name":"liu"
            "path":"/liu"
            "type": "file" 
          "zhong":
            "name":"zhong"
            "path":"/zhong"
            "type": "directory"
            "children":
              "yang": 
                "name":"yang"
                "path":"/zhong/yang"
                "type": "file"
                
    
    fetchFile: (path ,callback ) ->
      nodes = path.split("/")
      curNode = @root
      curName = ""
      for nodeName in nodes
        if not nodeName 
          continue
        if curNode.children and nodeName of curNode.children
          curNode = curNode.children[nodeName]
          curName = nodeName
        else 
          callback "file not exists "
      callback null , 
        "path": path
        "type": curNode.type
        "label": curName
        "children": if curNode.children then curNode.children else {} 
      
]