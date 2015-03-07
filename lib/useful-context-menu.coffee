UsefulContextMenuView = require './useful-context-menu-view'
{CompositeDisposable} = require 'atom'
shell = require 'shell'
path = require 'path'
exec = require('child_process').exec


module.exports = UsefulContextMenu =
  usefulContextMenuView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @usefulContextMenuView = new UsefulContextMenuView(state.usefulContextMenuViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @usefulContextMenuView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    #@subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:toggle': => @toggle()
#    @toggle()

    # Copy Paths
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-file-path': => @copyFilePath()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-filename': => @copyFilename()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:copy-folder-path': => @copyFolderPath()

    # Show in Explorer
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:open-in-file-manager': => @openInFileManager()
    @subscriptions.add atom.commands.add 'atom-workspace', 'useful-context-menu:open-in-terminal': => @openInTerminal()

    @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @usefulContextMenuView.destroy()

  serialize: ->

  copyFilePath: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
#    atom.notifications.addSuccess('Copying file path ... ' + filePath)
    atom.clipboard.write(filePath) if filePath

  copyFilename: ->
    item = atom.workspace.getActivePaneItem()
    filename = item?.getTitle?()
#    atom.notifications.addSuccess('Copying filename ... ' + filename)
    atom.clipboard.write(filename) if filename

  copyFolderPath: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
    filePath = path.dirname(filePath)
#    atom.notifications.addSuccess('Copying folder name ... ' + filePath)
    atom.clipboard.write(filePath) if filePath


  openInFileManager: ->
    item = atom.workspace.getActivePaneItem()
    filePath = item?.getPath?()
#    atom.notifications.addSuccess('Opening in File Manager... ' + filePath)
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
#    atom.notifications.addSuccess('Opening in Terminal ' + filePath)
    @openTerminal filePath


  toggle: ->
    console.log 'UsefulContextMenu was toggled!'

    # Open the section
    atom.contextMenu.add {
      'atom-text-editor': [{type: 'separator'}]
    }

    # Copy...
    atom.contextMenu.add {
      'atom-text-editor': [
                           {label: 'Copy File Path', command: 'useful-context-menu:copy-file-path'},
                           {label: 'Copy Filename', command: 'useful-context-menu:copy-filename'},
                           {label: 'Copy Folder Path', command: 'useful-context-menu:copy-folder-path'}
                          ]
    }

    # Open In...
    atom.contextMenu.add {
      'atom-text-editor': [
                           {label: 'Open in Explorer', command: 'useful-context-menu:open-in-file-manager'}
                           {label: 'Open in Terminal', command: 'useful-context-menu:open-in-terminal'}
                          ]
    }

    # End the section
    atom.contextMenu.add {
      'atom-text-editor': [{type: 'separator'}]
    }
