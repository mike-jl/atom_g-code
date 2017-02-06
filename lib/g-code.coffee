{CompositeDisposable} = require 'atom'

module.exports = GCode =
  subscriptions: null

  config:
    NumberingIncrementation:
      type: 'integer'
      default: 10

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'g-code:renumbering': => @renumbering()
    @subscriptions.add atom.commands.add 'atom-workspace', 'g-code:delNumbering': => @delNumbering()

  deactivate: ->
    @subscriptions.dispose()

  renumbering: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact ( ->
        editor.scan(/^N[0-9]+\s?/g, ({replace}) -> replace(""))
        oldpos = editor.getCursorBufferPosition()
        lines = editor.getLineCount()
        linecorr = 0
        inc = atom.config.get 'g-code.NumberingIncrementation'
        for line in [0...lines]
          if editor.lineTextForBufferRow(line) == ""
            linecorr = linecorr + 1
          else
            editor.setCursorBufferPosition([line,0])
            editor.insertText("N#{(line + 1 - linecorr) * inc} ")
            if line == lines - 1
              editor.insertNewlineBelow()
        editor.setCursorBufferPosition(oldpos)
      )

  delNumbering: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact ( ->
        editor.scan(/^N[0-9]+\s?/g, ({replace}) -> replace(""))
      )
