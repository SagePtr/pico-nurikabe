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

-- keys --
----------

k_left = 0
k_right = 1
k_up = 2
k_down = 3
k_mark = 4
k_fill = 5

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

-- constants --
---------------

debug = 1
cell_width = 8
cell_height = 8
border_width = cell_width
border_height = cell_height
screen_width = 128
screen_height = 128
numbers_offset = 15 -- number sprites start at 16
bg = col_lilac

-- globals --
-------------

actor = {}
pointer = nil
level = nil
level_id = nil
offset_x = nil
offset_y = nil
board_offset_x = nil
board_offset_y = nil
map_screen_x = nil
map_screen_y = nil

levels = {}
levels[1] = {}
levels[1]["width"] = 10
levels[1]["height"] = 10
levels[1]["islands"] = {
  {1,0,0}, {2,3,0}, {2,5,0},
  {2,8,1},
  {3,0,2}, {3,6,2},
  {2,7,3},
  {2,0,4}, {1,3,4},
  {2,9,5},
  {1,1,6}, {2,6,6}, {2,8,6},
  {6,3,7},
  {1,2,8}, {1,4,8},
  {4,1,9}, {2,7,9}, {1,9,9}
}
levels[1]["solution"] = {
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

board = {}
marks = {}
checked_indexes = {}
checked_cells = {}
is_island_connected = false
is_correct = false
pool_count = 0
sea_marks = {}

-- entry point --
-----------------

function _init()
  debug_print("_init")
  -- use dark green instead of black as the transparent colour
  palt(col_black, false)
  palt(col_darkgreen, true)

  pointer = make_pointer()
  load_level(1)

  -- load_solution()
  -- check_solution()
end

function _update()
  read_inputs()
end

function _draw()
  cls()
  draw_level()

  foreach(actor,draw_actor)
end

-- load the given level in
-- performs one-off calculations to set the state of the board
function load_level(id)
  level_id = id
  level = levels[id]
  marks = {}

  for x = 0, level["width"] - 1 do
    marks[x] = {}
    for y = 0, level["height"] - 1 do
      marks[x][y] = nil
    end
  end

  local board_width = level["width"] * cell_width
  local board_height = level["height"] * cell_height

  offset_x = (screen_width - board_width) / 2
  offset_y = (screen_height - board_height) / 2
  board_offset_x = offset_x - border_width
  board_offset_y = offset_y - border_height
  map_screen_x = level["width"] + 2
  map_screen_y = level["height"] + 2

  build_board()
  init_menu()
  mode = mode_level
end

-- initialise the level menu items
function init_menu()
  menuitem(1, "check solution", check_solution)
  menuitem(2, "continue", function () mode = mode_level end)

  if debug == 1 then menuitem(3, "show solution", load_solution) end
end

-- load the solution to the current level in
function load_solution()
  marks = {}

  for x = 0,level["width"] - 1 do
    marks[x] = {}
    for y = 0,level["height"] - 1 do
      marks[x][y] = nil
    end
  end

  for cell in all(level["solution"]) do
    marks[cell[1]][cell[2]] = spr_fill
  end
end

-- check whether the current solution is correct
function check_solution()
  is_correct = true

  check_islands()
  check_sea()

  if is_correct then
    debug_print("solution is correct")
  else
    debug_print("solution is not correct")
  end
end

-- check each island contains the required number of cells and does
-- not connect to any other islands
function check_islands()
  -- reset the variables we'll use to check the solution
  checked_indexes = {}
  checked_cells = {}

  for k,v in pairs(level["islands"]) do
    check_island(k, v[1], v[2], v[3])
  end
end

-- check the island has the required number of cells
function check_island(idx, count, x, y)
  -- skip islands that we've already hit in earlier checks
  if checked_indexes[idx] then
    debug_print("already checked "..tostr(idx))
    return
  end

  debug_print("checking island "..tostr(idx).." at "..tostr(x)..","..tostr(y).." should have "..tostr(count))

  local actual_count = 1
  is_island_connected = false

  mark_cell_checked(x, y)
  checked_indexes[idx] = true

  actual_count += check_island_cell(x, y - 1)
  actual_count += check_island_cell(x + 1, y)
  actual_count += check_island_cell(x, y + 1)
  actual_count += check_island_cell(x - 1, y)

  debug_print("count was "..tostr(actual_count)..", should be "..tostr(count))

  if actual_count ~= count then
    debug_print("count was "..tostr(actual_count)..", should be "..tostr(count))
    is_correct = false
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

  debug_print("checking island cell "..tostr(x)..","..tostr(y))

  if (is_cell_number(x, y)) then
    debug_print("***hit another island***")
    is_island_connected = true
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
  checked_indexes = {}
  checked_cells = {}
  pool_count = 0
  sea_marks = {}
  sea_mark_count = 0

  for x = 0,level["width"] - 1 do
    for y = 0,level["height"] - 1 do
      if (marks[x][y] == spr_fill) then
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
  end
end

-- mark a cell as checked
function mark_cell_checked(x, y)
  if (checked_cells[x] == nil) checked_cells[x] = {}
  checked_cells[x][y] = true
end

-- return true if the cell has already been checked
function is_cell_checked(x, y)
  if (checked_cells[x] ~= nil and checked_cells[x][y] ~= nil) then
    return true
  end

  return false
end

-- return true if the cell is clear or marked as clear
function is_cell_clear(x, y)
  if (marks[x][y] == nil or marks[x][y] == spr_mark) return true
  return false
end

-- return true if the co-ordinates are within the level boundary
function is_cell_valid(x, y)
  if (x >= 0 and y >=0 and x < level["width"] and y < level["height"]) return true
  return false
end

-- return true if the co-ordinates are a number
function is_cell_number(x, y)
  for cell in all(level["islands"]) do
    if (cell[2] == x and cell[3] == y) then
      return true
    end
  end
  return false
end

-- return true if the co-ordinates have been filled
function is_cell_filled(x, y)
  return marks[x][y] == spr_fill
end

function is_cell_valid_and_filled(x, y)
  return is_cell_valid(x, y) and is_cell_filled(x, y)
end

-- build the board in the map
function build_board()
  -- draw the border
  for x = 0, level["width"] + 1 do
    mset(x, 0, spr_board_border)
    mset(x, level["height"] + 1, spr_board_border)
  end
  for y = 1, level["height"] do
    mset(0, y, spr_board_border)
    mset(level["width"] + 1, y, spr_board_border)
  end

  -- fill the board
  for x = 1, level["width"] do
    for y = 1, level["height"] do
      mset(x, y, spr_board_background)
    end
  end
end

-- draw the level, the board and the markings
function draw_level()
  rectfill(0, 0, 127, 127, bg)
  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)
  draw_numbers()
  draw_marks()

  print("level "..tostr(level_id), 5, 5, col_white)

  -- flip whether the point is visible every 16 frames
  pointer.counter += 1

  if (pointer.counter == 16) then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end
end

-- read the level inputs
function read_inputs()
  local changed = false
  if (btnp(k_left)) pointer.x -= 1 changed = true
  if (btnp(k_right)) pointer.x += 1 changed = true
  if (btnp(k_up)) pointer.y -= 1 changed = true
  if (btnp(k_down)) pointer.y += 1 changed = true

  -- limit the range
  pointer.x = clamp(pointer.x, 0, level["width"] - 1)
  pointer.y = clamp(pointer.y, 0, level["height"] - 1)

  -- reset the counter so the pointer is visible
  if changed then
    pointer.show = 1
    pointer.counter = 0
  end

  if (btnp(k_mark) and is_writable()) then
    toggle_mark(spr_mark)
  elseif (btnp(k_fill) and is_writable()) then
    toggle_mark(spr_fill)
  end
end

-- toggle the sprite in the current cell
function toggle_mark(sprite)
  if (marks[pointer.x][pointer.y] == sprite) then
    marks[pointer.x][pointer.y] = nil
  else
    marks[pointer.x][pointer.y] = sprite
  end
end

-- return true if the cell can be marked
function is_writable()
  return not is_cell_number(pointer.x, pointer.y)
end

-- draw the numbers on the board
function draw_numbers()
  for cell in all(level["islands"]) do
    spr(cell[1] + numbers_offset, cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y)
  end
end

-- draw the marks onto the board
function draw_marks()
  for x=0, level["width"] - 1 do
    for y=0, level["height"] - 1 do
      if (marks[x][y]) then
        spr(marks[x][y], x * cell_width + offset_x, y * cell_width + offset_y)
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

-- draw the given actor
function draw_actor(a)
  if (a.show == 1) then
    local sx = a.x * cell_width + offset_x
    local sy = a.y * cell_height + offset_y
    spr(a.spr, sx, sy)
  end
end

-- helper functions --
----------------------

-- restrict the value to the given range
function clamp(val, a, b)
  return max(a, min(b, val))
end

-- print the message when debugging
function debug_print(msg)
  if (debug == 1) printh(msg)
end

__gfx__
77777777666666656666666937777773333333333333333305050505000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333333333555555350505050000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333333333555555305050505000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333553333555555350505050000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333553333555555305050505000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333333333555555350505050000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333333333555555305050505000000000000000000000000000000000000000000000000000000000000000000000000
77777777555555559999999937777773333333333333333350505050000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33003333333003333330033333033033330000333330033333000033333003333330033330033033000000000000000000000000000000000000000000000000
33303333330330333303303333033033330333333303333333333033330330333303303333030303000000000000000000000000000000000000000000000000
33303333333330333333003333000033330003333300033333333033333003333303303333030303000000000000000000000000000000000000000000000000
33303333333003333333303333333033333330333303303333333033330330333330003333030303000000000000000000000000000000000000000000000000
33303333330333333303303333333033330330333303303333333033330330333333303333030303000000000000000000000000000000000000000000000000
33000333330000333330033333333033333003333330033333333033333003333333303330003033000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
