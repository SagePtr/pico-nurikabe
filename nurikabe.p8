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
level_size = nil
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
  0, 1,
  2, 2,
  1, 2,
  12, 2,
  1, 3,
  5, 3,
  10, 2,
  2, 2,
  2, 1,
  15, 2,
  1, 1,
  4, 2,
  1, 2,
  4, 6,
  8, 1,
  1, 1,
  6, 4,
  5, 2,
  1, 1
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
error_indexes = {}
is_island_connected = false
is_correct = false
pool_count = 0

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
  level["islands"] = decompress_islands(level["islands"])
  level_size = coord_to_index(level["width"] - 1, level["height"] - 1)
  marks = {}

  for x = 0, level["width"] - 1 do
    for y = 0, level["height"] - 1 do
      marks[coord_to_index(x, y)] = nil
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

-- load the islands from the run-length encoded data
function decompress_islands(data)
  local idx = 0
  local coord = nil
  local count = nil
  local value = nil
  local islands = {}

  for i = 1, #data / 2 do
    count = data[i * 2 - 1]
    value = data[i * 2]

    idx += count
    coord = index_to_coord(idx)
    idx += 1

    add(islands, {value, coord[1], coord[2]})
  end

  return islands
end

-- initialise the level menu items
function init_menu()
  menuitem(1, "check solution", check_solution)

  if debug == 1 then menuitem(3, "show solution", load_solution) end
end

-- load the solution to the current level in
function load_solution()
  marks = {}

  for x = 0,level["width"] - 1 do
    for y = 0,level["height"] - 1 do
      marks[coord_to_index(x, y)] = nil
    end
  end

  for cell in all(level["solution"]) do
    marks[coord_to_index(cell[1], cell[2])] = spr_fill
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
  error_indexes = {}

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

  if actual_count ~= count then
    debug_print("count was "..tostr(actual_count)..", should be "..tostr(count))
    is_correct = false
    flag_cell_as_error(x, y)
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
    flag_cell_as_error(x, y)
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
  sea_mark_count = 0

  local sea_marks = {}

  for x = 0,level["width"] - 1 do
    for y = 0,level["height"] - 1 do
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

    flag_cell_as_error(x, y)
    flag_cell_as_error(x + 1, y)
    flag_cell_as_error(x, y + 1)
    flag_cell_as_error(x + 1, y + 1)
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
  local idx = coord_to_index(x, y)

  return idx >= 0 and idx <= level_size
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
  return marks[coord_to_index(x, y)] == spr_fill
end

-- return true if the co-ordinates are valid and have been filled
function is_cell_valid_and_filled(x, y)
  return is_cell_valid(x, y) and is_cell_filled(x, y)
end

-- flag the co-ordinates as having an error
function flag_cell_as_error(x, y)
  debug_print("flagging "..tostr(x)..","..tostr(y).." as error")
  error_indexes[coord_to_index(x, y)] = true
end

-- build the board in the map
function build_board()
  -- draw the border
  for x = 1, level["width"] do
    mset(x, 0, spr_border_top)
    mset(x, level["height"] + 1, spr_border_bottom)
  end
  for y = 1, level["height"] do
    mset(0, y, spr_border_left)
    mset(level["width"] + 1, y, spr_border_right)
  end

  -- draw the corners
  mset(0, 0, spr_border_top_left)
  mset(level["width"] + 1, 0, spr_border_top_right)
  mset(level["width"] + 1, level["height"] + 1, spr_border_bottom_right)
  mset(0, level["height"] + 1, spr_border_bottom_left)

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

  if xor(btnp(k_confirm), btnp(k_cancel)) and is_writable() then
    if btnp(k_confirm) then
      toggle_mark(spr_mark)
    elseif btnp(k_cancel) then
      toggle_mark(spr_fill)
    end
    error_indexes = {}
  end
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
  for cell in all(level["islands"]) do
    local sprite = cell[1] + numbers_offset

    if cell_has_error(cell[2], cell[3]) then
      sprite += 16
    end

    spr(sprite, cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y)
  end
end

-- return true if the co-ordinates have an error
function cell_has_error(x, y)
  return error_indexes[coord_to_index(x, y)]
end

-- draw the marks onto the board
function draw_marks()
  local idx = nil
  local sprite = nil

  for x = 0, level["width"] - 1 do
    for y = 0, level["height"] - 1 do
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
  return level["width"] * y + x
end

-- convert the index into x and y coordinates
function index_to_coord(idx)
  local x = nil
  local y = nil

  y = flr(idx / level["width"])
  x = idx - y * level["width"]

  return {x, y}
end

-- restrict the value to the given range
function clamp(val, a, b)
  return max(a, min(b, val))
end

-- print the message when debugging
function debug_print(msg)
  if (debug == 1) printh(msg)
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
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33003333333003333330033333033033330000333330033333000033333003333330033330033033000000000000000000000000000000000000000000000000
33303333330330333303303333033033330333333303333333333033330330333303303333030303000000000000000000000000000000000000000000000000
33303333333330333333003333000033330003333300033333333033333003333303303333030303000000000000000000000000000000000000000000000000
33303333333003333333303333333033333330333303303333333033330330333330003333030303000000000000000000000000000000000000000000000000
33303333330333333303303333333033330330333303303333333033330330333333303333030303000000000000000000000000000000000000000000000000
33000333330000333330033333333033333003333330033333333033333003333333303330003033000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33883333333883333338833333833833338888333338833333888833333883333338833338833833000000000000000000000000000000000000000000000000
33383333338338333383383333833833338333333383333333333833338338333383383333838383000000000000000000000000000000000000000000000000
33383333333338333333883333888833338883333388833333333833333883333383383333838383000000000000000000000000000000000000000000000000
33383333333883333333383333333833333338333383383333333833338338333338883333838383000000000000000000000000000000000000000000000000
33383333338333333383383333333833338338333383383333333833338338333333383333838383000000000000000000000000000000000000000000000000
33888333338888333338833333333833333883333338833333333833333883333333383338883833000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
