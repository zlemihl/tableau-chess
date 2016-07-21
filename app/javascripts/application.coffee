# yo, I'm glad that you made it here


# 
require [ 'ToledoChess' ], (ToledoChess) ->

  # Tableau related initializations. 
  # Init viz, register event listener
  #
  initViz = ->
    logInfo "Info: Chessboard is loading, please wait"

    containerDiv = document.getElementById("vizContainer")
    vizURL = 'https://public.tableau.com/views/Chess_3/Board'
    options =
      hideTabs: true
      onFirstInteractive: ->
        getSheet().applyFilterAsync "Field Name + Piece", "", tableau.FilterUpdateType.ALL
        .then ->
          viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection)
        .then ->
          drawPieces()
          logInfo "Info: Feel free to make your first move!"
    window.viz = new tableau.Viz(containerDiv, vizURL, options)

  onMarksSelection = (marksEvent) ->
    marksEvent.getMarksAsync().then marksSelected

  getSheet = ->
    _.first window.viz.getWorkbook().getActiveSheet().getWorksheets()

  selectMark = (field, value) ->
    getSheet().selectMarksAsync(field, value, tableau.SelectionUpdateType.REPLACE)

  marksSelected = (marks) ->
    if marks.length == 1
      fieldID =  _.findWhere(
                     _.first(marks).getPairs(),
                     fieldName: 'ATTR(Toledo Field ID)'
                   ).formattedValue

      logInfo "Select: Select field #{fieldID}"
      ai.OnClick fieldID
    else if marks.length > 1
      logInfo 'Error: Please select only one field'



  logInfo = (msg) ->
    console.log msg
    $('.console-log-div')
      .stop()
      .animate { scrollTop: $('.console-log-div')[0].scrollHeight }, 800
    
  aiCallback = (player, from, to) ->
    logInfo "Move: #{if player == 0 then "Computer" else "Player"} #{from} -> #{to}"

  pieces = "\xa0\u265f\u265a\u265e\u265d\u265c\u265b  \u2659\u2654\u2658\u2657\u2656\u2655"
  
  drawPieces = ->
    #logInfo "Debug: Reload chessboard"
    board = _.map(
      _.range 21, 99
      (p) -> "#{p}#{pieces.charAt(ai.board[p] & 15)}"
    )
    getSheet().applyFilterAsync(
        "Toledo ID + Piece",
        board,
        tableau.FilterUpdateType.REPLACE
    )

 
  # Load AI, set callbacks
  ai = ToledoChess
  ai.drawCallback = drawPieces
  ai.aiCallback = aiCallback

  # make initViz a top level exported function
  window.initViz = initViz

  # TODO: kill me, just for convenient debug
  window.getSheet = getSheet
  window.ai = ai

