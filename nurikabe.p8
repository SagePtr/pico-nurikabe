pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- sprites --
-------------

spr_board_border = 1
spr_board_background = 2
spr_pointer = 3
spr_mark = 4
spr_fill = 5
spr_border_top = 7
spr_border_right = 8
spr_border_bottom = 9
spr_border_left = 10
spr_border_top_right = 11
spr_border_bottom_right = 12
spr_border_bottom_left = 13
spr_border_top_left = 14

-- keys --
----------

k_left = 0
k_right = 1
k_up = 2
k_down = 3
k_confirm = 4
k_cancel = 5

-- palette --
-------------

col_black = 0
col_darkblue = 1
col_lilac = 2
col_darkgreen = 3
col_brown = 4
col_grey = 5
col_lightgrey = 6
col_white = 7
col_red = 8
col_orange = 9
col_yellow = 10
col_lightgreen = 11
col_lightblue = 12
col_lightpurple = 13
col_pink = 14
col_tan = 15
col_trans = col_darkgreen

-- constants --
---------------

cart_id = "mmawdsley_nurikabe_1"
debug = 1
cell_width = 8
cell_height = 8
border_width = cell_width
border_height = cell_height
screen_width = 128
screen_height = 128
number_col = col_black
number_error_col = col_red
bg = col_lilac
menu_bg = col_white
menu_fg = col_orange
menu_x = 32
menu_y = 32
menu_padding = 2
char_width = 4
pointer_min_x = 20
pointer_min_y = 30
pointer_max_x = 110
pointer_max_y = 100
offset_x_min = 24
offset_y_min = 32
bar_bg = col_darkblue
bar_fg = col_white
bar_fg_shadow = col_black
bottom_bar_height = 10
success_bg = col_tan
success_fg = col_black
success_shadow = col_lightgrey

-- modes --
-----------

mode_menu = 1
mode_level = 2
mode_level_select = 3
mode_how_to_play = 4
mode = nil

-- difficulties --

diff_easy = 1
diff_normal = 2
diff_hard = 3

-- globals --
-------------

actor = {}
pointer = nil
level = nil
level_id = 1
level_size = nil
level_islands = nil
level_duration = nil
level_start = nil
level_width = nil
level_height = nil
offset_x = nil
offset_y = nil
board_offset_x = nil
board_offset_y = nil
map_screen_x = nil
map_screen_y = nil
menu_items = {}
menu_item_count = 0
menu_item_height = 8
menu_item_gap = 4
menu_idx = 1

levels = {
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {0, 1, 2, 2, 1, 2, 12, 2, 1, 3, 5, 3, 10, 2, 2, 2, 2, 1, 15, 2, 1, 1, 4, 2, 1, 2, 4, 6, 8, 1, 1, 1, 6, 4, 5, 2, 1, 1},
    solution = {
      {1, 0}, {4, 0}, {7, 0}, {8, 0}, {9, 0},
      {0, 1}, {1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {9, 1},
      {3, 2}, {7, 2}, {9, 2},
      {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}, {6, 3}, {8, 3}, {9, 3},
      {2, 4}, {4, 4}, {6, 4}, {8, 4},
      {0, 5}, {1, 5}, {2, 5}, {3, 5}, {6, 5}, {7, 5}, {8, 5},
      {0, 6}, {2, 6}, {5, 6}, {7, 6}, {9, 6},
      {1, 7}, {2, 7}, {4, 7}, {5, 7}, {7, 7}, {9, 7},
      {1, 8}, {3, 8}, {5, 8}, {6, 8}, {7, 8}, {8, 8}, {9, 8},
      {2, 9}, {3, 9}, {4, 9}, {5, 9}, {8, 9}
    }
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {0, 4, 1, 3, 13, 1, 6, 2, 11, 2, 1, 5, 1, 4, 0, 2, 2, 1, 16, 4, 4, 1, 11, 2, 4, 5, 5, 1, 2, 3},
    solution = {
      {1, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0}, {9, 0},
      {1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {7, 1}, {9, 1},
      {2, 2}, {5, 2}, {6, 2}, {9, 2},
      {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {6, 3}, {8, 3},
      {2, 4}, {4, 4}, {6, 4}, {8, 4},
      {0, 5}, {1, 5}, {2, 5}, {3, 5}, {4, 5}, {5, 5}, {6, 5}, {7, 5}, {8, 5},
      {4, 6}, {6, 6}, {8, 6},
      {0, 7}, {1, 7}, {2, 7}, {3, 7}, {4, 7}, {5, 7}, {6, 7}, {8, 7}, {9, 7},
      {1, 8}, {7, 8}, {9, 8},
      {2, 9}, {3, 9}, {4, 9}, {5, 9}, {6, 9}, {7, 9}, {8, 9}, {9, 9}
    }
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {2, 2, 3, 4, 1, 3, 2, 6, 16, 5, 5, 4, 14, 3, 35, 4, 1, 4, 1, 1, 0, 6, 1, 2},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {9, 4, 1, 3, 2, 2, 5, 2, 5, 2, 2, 3, 5, 4, 25, 4, 1, 2, 5, 3, 7, 3, 8, 2, 2, 3, 0, 3, 1, 3},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {11, 1, 1, 2, 4, 1, 1, 3, 1, 4, 3, 2, 2, 3, 7, 3, 7, 2, 5, 2, 1, 3, 22, 2, 1, 2, 2, 1, 7, 3, 2, 2, 3, 2},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {1, 3, 2, 4, 1, 3, 5, 2, 16, 2, 1, 4, 4, 2, 1, 4, 5, 3, 16, 2, 4, 1, 7, 2, 19, 4, 2, 4, 1, 2},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {4, 5, 24, 4, 0, 5, 4, 3, 1, 2, 3, 6, 2, 2, 10, 5, 2, 2, 5, 3, 4, 2, 0, 3, 25, 4},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {2, 5, 21, 5, 3, 3, 6, 10, 7, 4, 6, 3, 15, 3, 3, 2, 13, 2, 5, 4, 7, 1},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {11, 4, 1, 4, 2, 4, 2, 3, 2, 3, 20, 3, 8, 3, 5, 4, 13, 3, 3, 3, 15, 5, 3, 5},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {2, 3, 13, 5, 1, 1, 6, 2, 16, 2, 22, 3, 3, 4, 2, 10, 10, 6, 8, 9},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {12, 1, 5, 5, 2, 3, 5, 2, 4, 3, 5, 3, 5, 5, 10, 1, 5, 2, 5, 1, 4, 4, 5, 5, 2, 1, 5, 4},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {4, 3, 4, 4, 7, 1, 2, 4, 5, 2, 5, 3, 18, 2, 1, 1, 2, 3, 12, 4, 10, 4, 1, 5, 3, 4, 6, 3, 4, 3},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {5, 5, 19, 5, 5, 3, 10, 6, 2, 2, 1, 2, 3, 3, 10, 6, 24, 4, 1, 4, 4, 1, 1, 1},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {2, 2, 3, 2, 4, 5, 7, 2, 3, 3, 2, 2, 18, 1, 2, 2, 3, 4, 11, 1, 1, 2, 1, 4, 18, 2, 2, 4, 1, 4, 5, 1},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {0, 3, 1, 12, 1, 4, 12, 3, 19, 3, 4, 2, 14, 1, 4, 6, 19, 2, 12, 2, 1, 1, 1, 7},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {18, 3, 6, 3, 8, 5, 12, 3, 2, 5, 8, 3, 10, 5, 3, 5, 2, 3, 13, 5, 5, 3, 1, 3},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 10,
    islands = {9, 5, 2, 5, 8, 1, 3, 2, 3, 4, 12, 3, 2, 2, 3, 2, 0, 4, 12, 3, 4, 3, 2, 1, 4, 4, 7, 2, 7, 3},
    solution = {}
  },
  {
    diff = diff_easy,
    width = 10,
    height = 18,
    islands = {1, 3, 1, 2, 3, 3, 10, 3, 2, 2, 3, 2, 24, 4, 4, 5, 1, 1, 3, 5, 14, 5, 2, 3, 11, 2, 3, 5, 4, 3, 2, 1, 4, 1, 10, 3, 10, 2, 3, 3, 2, 2, 12, 2, 12, 4, 3, 3, 2, 2, 4, 2, 2, 4},
    solution = {}
  },
}

how_to_play_screens = {
  {
    lines = {"1/6 in nurikabe you must solve", "    which blocks are islands", "    and which are part of", "    the sea"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {},
    fills = {},
    error_cells = {},
    width = 5,
    height = 5
  },
  {
    lines = {"2/6 each number indicates an", "    island with that many", "    blocks in"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {},
    fills = {
      1, 2, 3, 4,
      6, 9,
      11, 13, 14,
      15, 16, 17, 19,
      21, 24
    },
    error_cells = {},
    width = 5,
    height = 5
  },
  {
    lines = {"3/6 islands can only contain", "    one number"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {},
    fills = {
      1, 2, 3, 4,
      6, 9,
      11, 14,
      15, 16, 19,
      21, 22, 23, 24
    },
    error_cells = {12, 18},
    width = 5,
    height = 5
  },
  {
    lines = {"4/6 all filled blocks must", "    be connected together"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {},
    fills = {
      1, 3, 4,
      6, 8, 9,
      11, 13, 14,
      15, 16, 17, 19,
      21, 24
    },
    error_cells = {3, 4, 8, 9, 13, 14, 19, 24},
    width = 5,
    height = 5
  },
  {
    lines = {"5/6 filled blocks cannot have", "    any area of 2x2 or more"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {},
    fills = {
      2, 3, 4,
      6, 9,
      10, 11, 13, 14,
      15, 16, 17, 19,
      21, 24
    },
    error_cells = {10, 11, 15, 16},
    width = 5,
    height = 5
  },
  {
    lines = {"6/6 you can mark blocks as", "    land to help narrow down", "    the solution"},
    islands = {0, 3, 11, 3, 5, 3, 1, 1},
    marks = {5, 7, 8, 10, 22, 23},
    fills = {
      1, 2, 3, 4,
      6, 9,
      11, 13, 14,
      15, 16, 17, 19,
      21, 24
    },
    error_cells = {},
    width = 5,
    height = 5
  }
}

how_to_play_screen = 1
how_to_play_islands = {}

marks = {}
checked_cells = {}
error_cells = {}
is_island_connected = false
is_correct = false

-- entry point --
-----------------

function _init()
  debug_print("_init")
  cartdata(cart_id)
  -- use dark green instead of black as the transparent colour
  palt(col_black, false)
  palt(col_trans, true)
  pointer = make_pointer()

  -- load_level()
  -- open_level()
  -- load_solution()
  -- check_solution()
  open_menu()
  -- open_how_to_play()
end

function _update()
  if mode == mode_menu then
    update_menu()
  elseif mode == mode_level then
    update_level()
  elseif mode == mode_level_select then
    update_level_select()
  elseif mode == mode_how_to_play then
    update_how_to_play()
  end
end

function _draw()
  cls()
  if mode == mode_menu then
    draw_menu()
  elseif mode == mode_level then
    draw_level()
  elseif mode == mode_level_select then
    draw_level_select()
  elseif mode == mode_how_to_play then
    draw_how_to_play()
  end
end

-- reset commonly uses variables
function reset()
  level = nil
  level_size = nil
  level_islands = nil
  level_duration = nil
  level_start = nil
  level_width = nil
  level_height = nil
  error_cells = {}
  marks = {}
  is_correct = false
end

-- switch mode to menu
function open_menu()
  reset()
  mode = mode_menu

  menu_item_count = 0
  menu_items = {}

  make_menu_item("level select", open_level_select)
  make_menu_item("how to play", open_how_to_play)
end

-- switch mode to level
function open_level()
  reset()
  load_level()
  mode = mode_level
  pointer.x = 0
  pointer.y = 0
  level_start = time()
  level_duration = 0
  init_menu()
end

-- switch mode to level select
function open_level_select()
  reset()
  mode = mode_level_select
  load_level()
end

-- switch mode to how to play
function open_how_to_play()
  reset()
  mode = mode_how_to_play
  how_to_play_screen = 6
  load_how_to_play_screen()
end

-- load the level in
-- performs one-off calculations to set the state of the board
function load_level()
  level = levels[level_id]
  level_width = level["width"]
  level_height = level["height"]
  level_islands = decompress_rle(level["islands"])
  level_size = coord_to_index(level_width - 1, level_height - 1)
  is_correct = false
  marks = {}

  for x = 0, level_width - 1 do
    for y = 0, level_height - 1 do
      marks[coord_to_index(x, y)] = nil
    end
  end

  local board_width = level_width * cell_width
  local board_height = level_height * cell_height

  offset_x = (screen_width - board_width) / 2
  offset_y = (screen_height - board_height) / 2

  offset_x = max(offset_x, offset_x_min)
  offset_y = max(offset_y, offset_y_min)

  board_offset_x = offset_x - border_width
  board_offset_y = offset_y - border_height
  map_screen_x = level_width + 2
  map_screen_y = level_height + 2

  build_board(level_width, level_height)
end

-- load the values in from the run-length encoded data
function decompress_rle(data)
  local idx = 0
  local x, y = nil, nil
  local count = nil
  local value = nil
  local values = {}

  for i = 1, #data / 2 do
    count = data[i * 2 - 1]
    value = data[i * 2]

    idx += count
    x, y = index_to_coord(idx)
    idx += 1

    add(values, {value, x, y})
  end

  return values
end

-- initialise the level menu items
function init_menu()
  menuitem(1, "check solution", check_solution)
  menuitem(2, "level select", open_level_select)

  if debug == 1 then menuitem(3, "show solution", load_solution) end
end

-- load the solution to the current level in
function load_solution()
  marks = {}

  for x = 0,level_width - 1 do
    for y = 0,level_height - 1 do
      marks[coord_to_index(x, y)] = nil
    end
  end

  for cell in all(level["solution"]) do
    marks[coord_to_index(cell[1], cell[2])] = spr_fill
  end
end

-- check whether the current solution is correct
function check_solution()
  error_cells = {}
  is_correct = true

  check_islands()
  check_sea()

  if is_correct then pointer.show = 0 end

  set_level_complete(level_id, is_correct)
end

-- check each island contains the required number of cells and does
-- not connect to any other islands
function check_islands()
  for k, v in pairs(level_islands) do
    check_island(k, v[1], v[2], v[3])
  end
end

-- check the island has the required number of cells
function check_island(idx, count, x, y)
  debug_print("checking island "..tostr(idx).." at "..tostr(x)..","..tostr(y).." should have "..tostr(count))

  local actual_count = 1
  is_island_connected = false
  checked_cells = {}

  mark_cell_checked(x, y)

  actual_count += check_island_cell(x, y - 1)
  actual_count += check_island_cell(x + 1, y)
  actual_count += check_island_cell(x, y + 1)
  actual_count += check_island_cell(x - 1, y)

  if actual_count ~= count then
    debug_print("count was "..tostr(actual_count)..", should be "..tostr(count))
    is_correct = false
    mark_cell_error(x, y)
  end

  if is_island_connected then
    debug_print("island hits another island")
    is_correct = false
  end
end

-- count the number of clear cells starting at the given co-ordinates
-- return the count
function check_island_cell(x, y)
  if (is_cell_valid(x, y) == false or is_cell_checked(x, y) == true or is_cell_filled(x, y) == true) then
    return 0
  end

  mark_cell_checked(x, y)

  -- debug_print("checking island cell "..tostr(x)..","..tostr(y))

  if (is_cell_number(x, y)) then
    debug_print("***hit another island***")
    is_island_connected = true
    mark_cell_error(x, y)
    return 0
  end

  local count = 1

  count += check_island_cell(x, y - 1)
  count += check_island_cell(x + 1, y)
  count += check_island_cell(x, y + 1)
  count += check_island_cell(x - 1, y)

  return count
end

-- check all of the filled cells are:
-- 1. part of a single contiguous area
-- 2. do not contain any regions of 2x2 or greater
function check_sea()
  -- reset the variables we'll use to check the solution
  checked_cells = {}
  sea_mark_count = 0

  local sea_marks = {}

  for x = 0,level_width - 1 do
    for y = 0,level_height - 1 do
      if (is_cell_filled(x, y)) then
        add(sea_marks, {x, y})
        sea_mark_count += 1
      end
    end
  end

  debug_print("counted "..tostr(sea_mark_count).." filled cells")

  if sea_mark_count == 0 then
    debug_print("no marks")
    is_correct = false
    return
  end

  debug_print("first mark is "..sea_marks[1][1]..","..sea_marks[1][2])
  debug_print("checking first mark is connected to the rest")

  local count = count_pool(sea_marks[1][1], sea_marks[1][2])

  debug_print("mark contains "..tostr(count).." cells")

  if count ~= sea_mark_count then
    is_correct = false
  end

  debug_print("checking marks do not contain regions of 2x2 or greater")

  for sea_mark in all(sea_marks) do
    check_size(sea_mark[1], sea_mark[2])
  end
end

-- count the number of filled cells starting at the given co-ordinates
-- return the count
function count_pool(x, y)
  local count = 1

  mark_cell_checked(x, y)

  count += check_pool_cell(x, y - 1)
  count += check_pool_cell(x + 1, y)
  count += check_pool_cell(x, y + 1)
  count += check_pool_cell(x - 1, y)

  return count
end

-- count the number of filled cells starting at the given co-ordinates
-- return the count
function check_pool_cell(x, y)
  if (is_cell_valid(x, y) == false or is_cell_checked(x, y) == true or is_cell_filled(x, y) == false) then
    return 0
  end

  mark_cell_checked(x, y)

  local count = 1

  count += check_pool_cell(x, y - 1)
  count += check_pool_cell(x + 1, y)
  count += check_pool_cell(x, y + 1)
  count += check_pool_cell(x - 1, y)

  return count
end

-- check the co-ordinate is not 2x2 or greater
function check_size(x, y)
  if (is_cell_valid_and_filled(x + 1, y)
      and is_cell_valid_and_filled(x, y + 1)
      and is_cell_valid_and_filled(x + 1, y + 1))
  then
    debug_print("found 2x2 at "..tostr(x)..","..tostr(y))
    is_correct = false

    mark_cell_error(x, y)
    mark_cell_error(x + 1, y)
    mark_cell_error(x, y + 1)
    mark_cell_error(x + 1, y + 1)
  end
end

-- mark a cell as checked
function mark_cell_checked(x, y)
  checked_cells[coord_to_index(x, y)] = true
end

-- return true if the cell has already been checked
function is_cell_checked(x, y)
  return checked_cells[coord_to_index(x, y)] == true
end

-- return true if the co-ordinates are within the level boundary
function is_cell_valid(x, y)
  if x >= 0 and x < level_width and y >= 0 and y < level_height then
    return true
  end
  return false
end

-- return true if the co-ordinates are a number
function is_cell_number(x, y)
  for cell in all(level_islands) do
    if (cell[2] == x and cell[3] == y) then
      return true
    end
  end
  return false
end

-- return true if the co-ordinates have been filled
function is_cell_filled(x, y)
  return marks[coord_to_index(x, y)] == spr_fill
end

-- return true if the co-ordinates are valid and have been filled
function is_cell_valid_and_filled(x, y)
  return is_cell_valid(x, y) and is_cell_filled(x, y)
end

-- mark the co-ordinates as having an error
function mark_cell_error(x, y)
  debug_print("flagging "..tostr(x)..","..tostr(y).." as error")
  error_cells[coord_to_index(x, y)] = true
end

-- build the board in the map
function build_board(width, height)
  -- draw the border
  for x = 1, width do
    mset(x, 0, spr_border_top)
    mset(x, height + 1, spr_border_bottom)
  end
  for y = 1, height do
    mset(0, y, spr_border_left)
    mset(width + 1, y, spr_border_right)
  end

  -- draw the corners
  mset(0, 0, spr_border_top_left)
  mset(width + 1, 0, spr_border_top_right)
  mset(width + 1, height + 1, spr_border_bottom_right)
  mset(0, height + 1, spr_border_bottom_left)

  -- fill the board
  for x = 1, width do
    for y = 1, height do
      mset(x, y, spr_board_background)
    end
  end
end

-- read the menu inputs
function update_menu()
  if (btnp(k_up)) then
    menu_idx -= 1
  elseif (btnp(k_down)) then
    menu_idx += 1
  end

  menu_idx = clamp(menu_idx, 1, #menu_items)

  if btnp(k_confirm) then
    menu_items[menu_idx]["action"]()
  end
end

-- update the level state
function update_level()
  if is_correct then
    update_level_complete_state()
  else
    update_level_state()
  end
end

-- read the level inputs and update the state
function update_level_state()
  local changed = false

  if (btnp(k_left)) pointer.x -= 1 changed = true
  if (btnp(k_right)) pointer.x += 1 changed = true
  if (btnp(k_up)) pointer.y -= 1 changed = true
  if (btnp(k_down)) pointer.y += 1 changed = true

  -- flip whether the point is visible every 16 frames
  pointer.counter += 1

  if pointer.counter == 16 then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end

  -- limit the range
  pointer.x = clamp(pointer.x, 0, level_width - 1)
  pointer.y = clamp(pointer.y, 0, level_height - 1)

  if changed then
    -- reset the counter so the pointer is visible
    pointer.show = 1
    pointer.counter = 0

    local pointer_x, pointer_y = get_actor_coords(pointer)

    -- update offsets
    if pointer_x > pointer_max_x then
      board_offset_x -= cell_width
      offset_x -= cell_width
    elseif pointer_x < pointer_min_x then
      board_offset_x += cell_width
      offset_x += cell_width
    end

    if pointer_y > pointer_max_y then
      board_offset_y -= cell_width
      offset_y -= cell_width
    elseif pointer_y < pointer_min_y then
      board_offset_y += cell_width
      offset_y += cell_width
    end
  end

  if xor(btnp(k_confirm), btnp(k_cancel)) and is_writable() then
    if btnp(k_confirm) then
      toggle_mark(spr_mark)
    elseif btnp(k_cancel) then
      toggle_mark(spr_fill)
    end
    error_cells = {}
  end

  -- update how much time has been spent
  if (is_correct == false) then level_duration = time() - level_start end
end

-- read the level complete inputs and update the state
function update_level_complete_state()
  if btnp(k_confirm) or btnp(k_cancel) then
    open_level_select()
  end
end

-- read the level select inputs
function update_level_select()
  local tmp_level_id = level_id

  if btnp(k_left) then
    level_id -= 1
  elseif btnp(k_right) then
    level_id += 1
  end

  level_id = clamp(level_id, 1, #levels)

  if level_id ~= tmp_level_id then
    load_level()
  end

  if btnp(k_confirm) then
    open_level()
  elseif btnp(k_cancel) then
    open_menu()
  end
end

-- read the how to play inputs
function update_how_to_play()
  local tmp_screen = how_to_play_screen

  if btnp(k_confirm) or btnp(k_cancel) then
    open_menu()
  elseif btnp(k_left) then
    how_to_play_screen -= 1
  elseif btnp(k_right) then
    how_to_play_screen += 1
  end

  how_to_play_screen = clamp(how_to_play_screen, 1, #how_to_play_screens)

  if how_to_play_screen ~= tmp_screen then
    load_how_to_play_screen()
  end
end

-- load in the current page of the how to play section
function load_how_to_play_screen()
  local screen = how_to_play_screens[how_to_play_screen]

  marks = {}
  error_cells = {}
  level_width = screen["width"]
  level_height = screen["height"]

  for i = 1, #screen["fills"] do
    marks[screen["fills"][i]] = spr_fill
  end

  for i = 1, #screen["marks"] do
    marks[screen["marks"][i]] = spr_mark
  end

  for i = 1, #screen["error_cells"] do
    error_cells[screen["error_cells"][i]] = true
  end

  how_to_play_islands = decompress_rle(screen["islands"])

  local board_width = screen["width"] * cell_width

  offset_x = (screen_width - board_width) / 2
  offset_y = 50

  board_offset_x = offset_x - border_width
  board_offset_y = offset_y - border_height
  map_screen_x = screen["width"] + 2
  map_screen_y = screen["height"] + 2

  build_board(screen["width"], screen["height"])
end

-- draw the menu
function draw_menu()
  rectfill(0, 0, 127, 127, bg)

  for idx, menu_item in pairs(menu_items) do
    draw_menu_item(menu_item, idx)
  end
end

-- draw the menu item
-- use the index to figure out whether it's active
function draw_menu_item(item, idx)
  local offset = menu_item_height * idx
  local y = menu_y + offset + menu_item_gap * idx

  if idx == menu_idx then
    local width = #item.text * char_width + menu_padding
    rounded_rectfill(menu_x, y, width, menu_item_height, menu_bg)
  end

  print(item.text, menu_x + menu_padding, y + menu_padding, menu_fg)
end

-- draw the level, the board and the markings
function draw_level()
  rectfill(0, 0, screen_width - 1, screen_height - 1, bg)

  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)
  draw_numbers()
  draw_marks()

  foreach(actor, draw_actor)

  -- draw the ui over the top of the board
  rectfill(0, 0, screen_width - 1, cell_height + 6, bar_bg)
  rectfill(0, screen_height - cell_height - 3, screen_width - 1, screen_height - 1, bar_bg)

  draw_level_name()
  draw_timer()
  print_shadow("🅾️mark ❎fill", 71, 120, bar_fg, bar_fg_shadow)

  if is_correct then draw_success() end
end

-- draw the level select screen
function draw_level_select()
  rectfill(0, 0, 127, 127, bg)
  rectfill(0, 0, screen_width - 1, cell_height + 6, bar_bg)
  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)
  draw_numbers()
  draw_level_name()

  if get_level_complete(level_id) then
    draw_level_complete()
  end
end

-- draw the label for the level
function draw_level_name()
  local diff = "unknown"

  if level["diff"] == diff_easy then
    diff = "easy"
  elseif level["diff"] == diff_normal then
    diff = "normal"
  elseif level["diff"] == diff_hard then
    diff = "hard"
  end

  print_shadow("level "..tostr(level_id), 5, 5, bar_fg, bar_fg_shadow)
  print_shadow(diff, screen_width - #diff*char_width - 5, 5, bar_fg)
end

-- draw that the level is complete
function draw_level_complete()
  local text = "completed"

  print_shadow(text, flr((screen_width - #text*char_width) / 2), 5, bar_fg)
end

-- draw the timer
function draw_timer()
  local hours, minutes, seconds = split_time(level_duration)
  local text = zero_pad(hours)..":"..zero_pad(minutes)..":"..zero_pad(seconds)

  print_shadow(text, flr((screen_width - #text*char_width) / 2), 5, bar_fg, bar_fg_shadow)
end

-- draw the success window
function draw_success()
  local text = "level complete!"
  local width = #text * char_width + menu_padding
  local height = menu_item_height
  local x = flr((screen_width - width) / 2)
  local y = flr((screen_height - height) / 2)

  rounded_rectfill(x + 1, y + 1, width, height, success_shadow)
  rounded_rectfill(x, y, width, height, success_bg)

  print(text, x + menu_padding, y + menu_padding, success_fg)
end

-- draw the how to play screen
function draw_how_to_play()
  local y = 4
  local lines = how_to_play_screens[how_to_play_screen].lines
  local col = nil

  rectfill(0, 0, 127, 127, bg)
  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)

  for cell in all(how_to_play_islands) do
    col = cell_has_error(cell[2], cell[3]) and number_error_col or number_col
    print_number(cell[1], cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y, col)
  end

  draw_marks()
  draw_numbers()

  for i = 1, #lines do
    print_shadow(lines[i], 4, y, bar_fg, bar_fg_shadow)
    y += cell_height
  end

  print_shadow("🅾️/❎back", 4, 119, bar_fg, bar_fg_shadow)
  print_shadow("⬅️prev ➡️next", 71, 119, bar_fg, bar_fg_shadow)
end

-- return the time in hours, minutes and seconds
function split_time(seconds)
  local hours, minutes = 0, 0

  if seconds >= 3600 then
    hours = flr(seconds / 3600)
    seconds -= hours * 3600
  end

  if seconds >= 60 then
    minutes = flr(seconds / 60)
    seconds -= minutes * 60
  end

  seconds = flr(seconds)

  return hours, minutes, seconds
end

-- toggle the sprite in the current cell
function toggle_mark(sprite)
  local idx = coord_to_index(pointer.x, pointer.y)

  if (marks[idx] == sprite) then
    marks[idx] = nil
  else
    marks[idx] = sprite
  end
end

-- return true if the cell can be marked
function is_writable()
  return not is_cell_number(pointer.x, pointer.y)
end

-- draw the numbers on the board
function draw_numbers()
  local col = nil

  for cell in all(level_islands) do
    col = cell_has_error(cell[2], cell[3]) and number_error_col or number_col
    print_number(cell[1], cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y, col)
  end
end

-- return true if the co-ordinates have an error
function cell_has_error(x, y)
  return error_cells[coord_to_index(x, y)]
end

-- draw the marks onto the board
function draw_marks()
  local idx = nil
  local sprite = nil

  for x = 0, level_width - 1 do
    for y = 0, level_height - 1 do
      idx = coord_to_index(x, y)

      if (marks[idx]) then
        sprite = marks[idx]
        if (sprite == spr_fill and cell_has_error(x, y)) sprite += 1
        spr(sprite, x * cell_width + offset_x, y * cell_width + offset_y)
      end
    end
  end
end

-- return a new pointer entity
function make_pointer()
  pointer = make_actor(0, 0)
  pointer.counter = 0
  pointer.spr = spr_pointer
  return pointer
end

-- return a new actor entity
function make_actor(x, y)
  a = {}
  a.show = 0
  a.x = x
  a.y = y

  add(actor, a)

  return a
end

-- return a new menu item
function make_menu_item(text, action)
  i = {}
  i.text = text
  i.action = action

  add(menu_items, i)

  return i
end

-- draw the given actor
function draw_actor(a)
  if (a.show == 1) then
    local x, y = get_actor_coords(a)
    spr(a.spr, x, y)
  end
end

-- return the actor's co-ordinates
function get_actor_coords(a)
  local x = a.x * cell_width + offset_x
  local y = a.y * cell_height + offset_y

  return x, y
end

-- return true if the level has been completed
function get_level_complete(level_id)
  return dget(level_id - 1) == 1 and true or false
end

-- set whether the level has been completed
function set_level_complete(level_id, is_complete)
  dset(level_id - 1, is_complete and 1 or 0)
end

-- helper functions --
----------------------

-- print the text with a "shadow"
function print_shadow(text, x, y, fg, bg)
  print(text, x + 1, y + 1, bg)
  print(text, x, y, fg)
end

-- draw a rounded rectangle
function rounded_rectfill(x, y, width, height, bg)
  rectfill(x, y + 1, x + width, y + height - 1, bg) -- short
  rectfill(x + 1, y, x + width - 1, y + height, bg) -- tall
end

-- exclusive or
function xor(a,b)
  if a and not b then
    return true
  elseif b and not a then
    return true
  else
    return false
  end
end

-- convert the x and y coordinates into an index
function coord_to_index(x, y)
  return level_width * y + x
end

-- convert the index into x and y coordinates
function index_to_coord(idx)
  local x, y = nil, nil

  y = flr(idx / level_width)
  x = idx - y * level_width

  return x, y
end

-- restrict the value to the given range
function clamp(val, a, b)
  return max(a, min(b, val))
end

-- pad the number to two digits
function zero_pad(number)
  if number < 10 then
    number = "0"..tostr(number)
  end
  return number
end

-- print the number but offset it based on its width
function print_number(number, x, y, col)
  local number_width = number > 9 and char_width * 2 or char_width
  local x_offset = flr((cell_width - number_width) / 2)
  local y_offset = 1

  print(number, x + x_offset, y + y_offset, col)
end

-- print the message when debugging
function debug_print(msg)
  if (debug == 1) printh(msg)
end

-- converts anything to string, even nested tables
function tostring(any)
  if type(any)=="function" then
    return "function"
  end
  if any==nil then
    return "nil"
  end
  if type(any)=="string" then
    return any
  end
  if type(any)=="boolean" then
    if any then return "true" end
    return "false"
  end
  if type(any)=="table" then
    local str = "{ "
    for k,v in pairs(any) do
      str=str..tostring(k).."->"..tostring(v).." "
    end
    return str.."}"
  end
  if type(any)=="number" then
    return ""..any
  end
  return "unknown" -- should never show
end

__gfx__
7777777766666665666666693777777333333333333333333333333333333333a7994333aaaaaaaa3334997a33333333a79943333334997a3333333300000000
7777777765d5d5d56f7f7f797333333733333333355555533888888333333333a7994333777777773334997a3333333379994333333499973333333300000000
777777776d5d5d5567f7f7f97333333733333333355555533888888333333333a7994333999999993334997a3333333399943333333349993333333300000000
7777777765d5d5d56f7f7f797333333733355333355555533888888344444444a7994333999999993334997a4433333399433333333334993333334400000000
777777776d5d5d5567f7f7f97333333733355333355555533888888399999999a7994333444444443334997a9943333344333333333333443333349900000000
7777777765d5d5d56f7f7f797333333733333333355555533888888399999999a7994333333333333334997a9994333333333333333333333333499900000000
777777776d5d5d5567f7f7f973333337333333333555555338888883aaaaaaaaa7994333333333333334997a7999433333333333333333333334999a00000000
7777777755555555999999993777777333333333333333333333333377777777a7994333333333333334997aa79943333333333333333333333499a700000000
