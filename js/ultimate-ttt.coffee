{div, h1, h2, h3, textarea, span, form, input, br,
table, tbody, tr, th, td, ul, li} = React.DOM

# http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

# http://stackoverflow.com/a/17903018/742872
do -> Array::uniq ?= ->
  @.reduce (p, c) ->
    p.push(c) if (p.indexOf(c) < 0)
    p
  , []

class TicTacToeReferee
  constructor: (@state) ->

  checkIfFieldsAreEqual: (id1, id2, id3) ->
    unique = [@state[id1], @state[id2], @state[id3]].uniq()
    if unique.length == 1 and unique[0] != null
      true
    else
      false

  decision: ->
    winningStates = [
      [0, 1, 2], [0, 3, 6], [0, 4, 8],
      [1, 4, 7],
      [2, 5, 8], [2, 4, 6],
      [3, 4, 5],
      [6, 7, 8]
    ]

    winner = null

    for states in winningStates
      if @checkIfFieldsAreEqual(states[0], states[1], states[2])
        winner = @state[states[0]]
        break

    if winner
      winner
    else
      # if board is full
      if @state.indexOf(null) == -1
        "tie"
      else
        "continue"

Game = React.createClass({
  getInitialState: ->
    whoStarts = ["xs", "os"].shuffle()[0]
    return {turn: whoStarts, currentTableId: null}

  nextTurnBy: ->
    currentTurn = @.state.turn
    nextTurn = if currentTurn == "xs" then "os" else "xs"
    return nextTurn

  handleTableClick: (clickedCellId)->
    @.setState({turn: @.nextTurnBy(), currentTableId: clickedCellId})

  render: ->
    tables = [0..8].map (i) =>
      return Table(
        {
          turn: @.state.turn
          tableId: i
          currentTableId: @.state.currentTableId
          handleTableClick: @.handleTableClick
        }
      )

    return (
      (div {className: "big-table"}, [
        (h2 {}, "It's #{@.state.turn} turn!"),
        (div {}, tables)
      ])
    )
})

Table = React.createClass({
  isActive: ->
    unless @.props.currentTableId == null
      @.props.currentTableId == @.props.tableId
    else
      true

  handleCellClick: (cellId) ->
    @.props.handleTableClick(cellId)

  render: ->
    cellProps = (count) =>
      return {
        turn: @.props.turn
        cellId: count
        handleCellClick: @.handleCellClick
      }

    renderCells = (range) ->
      cells = range.map (i) =>
        return Cell(cellProps(i))
      return cells

    return (
      (div {className: "col-md-4"}, [
        (div {className: "overlay"}) unless @.isActive(),
        (table {className: "small-table table table-bordered #{"active-table box-shadow" if @.isActive()}"},
          (tbody {}, [
            (tr {}, renderCells([0..2])),
            (tr {}, renderCells([3..5])),
            (tr {}, renderCells([6..8]))
          ])
        )
      ])
    )
})

Cell = React.createClass({
  getInitialState: ->
    return {owner: null}

  handleClick: ->
    # There's no point in updating a cell
    # if it already has an owner.
    unless @.state.owner
      @.setState {owner: @.props.turn, lastClicked: true}
      @.props.handleCellClick(@.props.cellId)

  render: ->
    owner = @.state.owner || "none"
    return (td {className: "cell #{owner} #{"last-clicked box-shadow" if @.state.lastClicked}", onClick: @.handleClick})
})

React.renderComponent(
  Game({}),
  document.getElementById('game')
)
