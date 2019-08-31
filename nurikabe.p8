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
k_a = 4
k_b = 5

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
levels[1]["numbers"] = {
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

board = {}
marks = {}

-- entry point --
-----------------

function _init()
  debug_print("_init")
  -- use dark green instead of black as the transparent colour
  palt(col_black, false)
  palt(col_darkgreen, true)

  pointer = make_pointer()
  load_level(1)
end

function _update()
  read_inputs()
end

function _draw()
  cls()
  draw_level()

  foreach(actor,draw_actor)

  -- flip whether the point is visible every 16 frames
  pointer.counter += 1

  if (pointer.counter == 16) then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end
end

-- load the given level in
-- performs one-off calculations to set the state of the board
function load_level(id)
  level_id = id
  level = levels[id]
  marks = {}

  for x = 0,level["width"] - 1 do
    marks[x] = {}
    for y = 0,level["height"] - 1 do
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
end

-- read the cursor inputs
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

  if (btnp(k_a) and is_writable()) cycle_mark()
end

-- cycle the mark the current cell
function cycle_mark()
  if (marks[pointer.x][pointer.y] == nil) then
    marks[pointer.x][pointer.y] = spr_fill
  elseif (marks[pointer.x][pointer.y] == spr_fill) then
    marks[pointer.x][pointer.y] = spr_mark
  else
    marks[pointer.x][pointer.y] = nil
  end
end

-- return true if the cell can be marked
function is_writable()
  for cell in all(level["numbers"]) do
    if (cell[2] == pointer.x and cell[3] == pointer.y) then
      return false
    end
  end

  return true
end

-- draw the numbers on the board
function draw_numbers()
  for cell in all(level["numbers"]) do
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

function clamp(val, a, b)
  return max(a, min(b, val))
end

function debug_print(msg)
  if (debug == 1) printh(msg)
end

__gfx__
77777777666666656666666937777773333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333333333555555333888833000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333333333555555338888883000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333553333555555338888883000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333553333555555338888883000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333333333555555338888883000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333333333555555333888833000000000000000000000000000000000000000000000000000000000000000000000000
77777777555555559999999937777773333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33003333333003333330033333033033330000333330033333000033333003333330033330033033000000000000000000000000000000000000000000000000
33303333330330333303303333033033330333333303333333333033330330333303303333030303000000000000000000000000000000000000000000000000
33303333333330333333003333000033330003333300033333333033333003333303303333030303000000000000000000000000000000000000000000000000
33303333333003333333303333333033333330333303303333333033330330333330003333030303000000000000000000000000000000000000000000000000
33303333330333333303303333333033330330333303303333333033330330333333303333030303000000000000000000000000000000000000000000000000
33000333330000333330033333333033333003333330033333333033333003333333303330003033000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
