{CompositeDisposable} = require 'atom'
shell = require 'shell'
path = require 'path'
exec = require('child_process').exec


module.exports = UsefulContextMenu =
  subscriptions: null
  
  config:
    groupItems:
      type: 'boolean'
      title: 'Group Items'
      description: 'Add all ontext menu items in a group called "Usefull"'
      default: false

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    
    # The menu items that will be added to context menu
    @menuItems = new CompositeDisposable

    # Copy Paths
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-file-path': => @copyFilePath()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-filename': => @copyFilename()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-folder-path': => @copyFolderPath()

    # Show in Explorer
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:open-in-file-manager': => @openInFileManager()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:open-in-terminal': => @openInTerminal()

    @groupItemsObserveSubscription = atom.config.observe 'useful-context-menu.groupItems', => @toggle()

    @toggle()

  deactivate: ->
    @removeItems()
    @subscriptions.dispose()
    @groupItemsObserveSubscription.dispose()

  copyFilePath: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
    atom.clipboard.write(filePath) if filePath

  copyFilename: ->
    item = atom.workspace.getActivePaneItem()
    filename = item?.getTitle?()
    atom.clipboard.write(filename) if filename

  copyFolderPath: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
    filePath = path.dirname(filePath)
    atom.clipboard.write(filePath) if filePath

  openInFileManager: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
    shell.showItemInFolder(filePath) if filePath

  openTerminal: (dirpath) ->
    app = "C:\\Windows\\System32\\cmd.exe"
    args = ''
    cmdline = "\"#{app}\ #{args}"
    cmdline = "start \"\" " + cmdline
    exec cmdline, cwd: dirpath

  openInTerminal: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
    filePath = path.dirname(filePath)
    @openTerminal filePath

  removeItems: ->
    @menuItems.dispose()
    @menuItems = new CompositeDisposable

  toggle: ->
    console.log 'UsefulContextMenu was toggled!'
    @removeItems()
        
    # Open the section
    @menuItems.add atom.contextMenu.add {
      'atom-text-editor': [{type: 'separator'}]
    }

    isGrouped = atom.config.get("useful-context-menu.groupItems")
    if isGrouped
      @menuItems.add atom.contextMenu.add {
        'atom-text-editor': [{
          label: 'Useful',
          submenu: [
            # Copy...
            {label: 'Copy File Path', command: 'useful-context-menu:copy-file-path'}
            {label: 'Copy Filename', command: 'useful-context-menu:copy-filename'}
            {label: 'Copy Folder Path', command: 'useful-context-menu:copy-folder-path'}
            # Open In...
            {label: 'Open in Explorer', command: 'useful-context-menu:open-in-file-manager'}
            {label: 'Open in Terminal', command: 'useful-context-menu:open-in-terminal'}
          ]
        }]
      }
    else
      # Copy...
      @menuItems.add atom.contextMenu.add {
        'atom-text-editor': [
                             {label: 'Copy File Path', command: 'useful-context-menu:copy-file-path'},
                             {label: 'Copy Filename', command: 'useful-context-menu:copy-filename'},
                             {label: 'Copy Folder Path', command: 'useful-context-menu:copy-folder-path'}
                            ]
      }
      # Open In...
      @menuItems.add atom.contextMenu.add {
        'atom-text-editor': [
                             {label: 'Open in Explorer', command: 'useful-context-menu:open-in-file-manager'}
                             {label: 'Open in Terminal', command: 'useful-context-menu:open-in-terminal'}
                            ]
      }
    
    # End the section
    @menuItems.add atom.contextMenu.add {
      'atom-text-editor': [{type: 'separator'}]
    }
