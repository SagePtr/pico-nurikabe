pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- sprites --
-------------

spr_board_border=1
spr_board_background=2
spr_pointer=3

-- keys --
----------

k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_dash=5

-- palette --
-------------

col_black=0
col_darkblue=1
col_lilac=2
col_darkgreen=3
col_brown=4
col_grey=5
col_lightgrey=6
col_white=7
col_red=8
col_orange=9
col_yellow=10
col_lightgreen=11
col_lightblue=12
col_lightpurple=13
col_pink=14
col_tan=15

-- constants --
---------------

debug=1
cell_width=8
cell_height=8
screen_width=128
screen_height=128
numbers_offset=15 -- Number sprites start at 16
bg=col_lilac

-- globals --
-------------

actor = {}
pointer=nil
level=nil
level_id=nil
offset_x=nil
offset_y=nil

levels={}
levels[1]={}
levels[1]["width"]=10
levels[1]["height"]=10
levels[1]["numbers"]={
  {1,1,1}, {2,4,1}, {2,6,2},
  {2,9,2},
  {3,1,3}, {3,7,3},
  {2,8,4},
  {2,1,5}, {1,4,5},
  {2,10,6},
  {1,2,7}, {2,7,7}, {2,9,7},
  {6,4,8},
  {1,3,9}, {1,5,9},
  {4,2,10}, {2,8,10}, {1,10,10}
}

board={}

-- entry point --
-----------------

function _init()
  debug_print("_init")
  palt(col_black, f)
  palt(col_darkgreen, t)
  make_pointer()
  load_level(1)
end

function _update()
  read_inputs()
end

function _draw()
  cls()
  draw_level()
  foreach(actor,draw_actor)

  -- Flip whether the point is visible every 16 frames
  pointer.counter += 1

  if (pointer.counter == 16) then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end
end

function load_level(id)
  level_id=id
  level=levels[id]
  board.state={}
  board.width=level["width"]*cell_width
  board.height=level["height"]*cell_height
  -- add two for the width of the border
  board.total_width=(level["width"]+2)*cell_width
  board.total_height=(level["height"]+2)*cell_height
  board.offset_x=(screen_width-board.total_width)/2
  board.offset_y=(screen_height-board.total_height)/2
  offset_x=(screen_width-board.width)/2
  offset_y=(screen_height-board.height)/2  
end

function draw_level()
  cls()
  rectfill(0,0,127,127,bg)
  draw_board()
  
  print("level "..tostr(level_id), 5, 5, col_white)
end

function read_inputs()
  local changed = false
  if (btnp(k_left)) pointer.x -= 1 changed = true
  if (btnp(k_right)) pointer.x += 1 changed = true
  if (btnp(k_up)) pointer.y -= 1 changed = true
  if (btnp(k_down)) pointer.y += 1 changed = true

  if (btnp(k_a)) then
  end

  if (btnp(k_b)) then
  end

  -- Limit the range
  pointer.x=clamp(pointer.x, 0, level["width"]-1)
  pointer.y=clamp(pointer.y, 0, level["height"]-1)

  -- Reset the counter so the pointer is visible
  if changed then
    pointer.show = 1
    pointer.counter = 0
  end
end

function draw_board()
  debug_print("Cell width is "..tostr(cell_width))
  debug_print("Cell height is "..tostr(cell_height))
  debug_print("Total width is "..tostr(board.total_width))
  debug_print("Total height is "..tostr(board.total_height))
  debug_print("Board width is "..tostr(board.width))
  debug_print("Board height is "..tostr(board.height))
  debug_print("Board offset x = "..tostr(board.offset_x))
  debug_print("Offset x = "..tostr(offset_x))

  -- Draw the border
  for x=0,11 do
    spr(spr_board_border, x*8+offset_x-cell_width, 0+offset_y-cell_height)
    spr(spr_board_border, x*8+offset_x-cell_width, 88+offset_y-cell_height)
  end
  for y=1,10 do
    spr(spr_board_border, 0+offset_x-cell_width, y*8+offset_y-cell_height)
    spr(spr_board_border, 88+offset_x-cell_width, y*8+offset_y-cell_height)
  end

  -- Fill the board
  for x=0,level["width"]-1 do
    for y=0,level["height"]-1 do
      spr(spr_board_background, x*cell_width+offset_x,y*cell_height+offset_y)
    end
  end

  -- Draw the numbers
  for cell in all(level["numbers"]) do
    spr(cell[1]+numbers_offset, cell[2]*cell_width+board.offset_x, cell[3]*cell_width+board.offset_y)
  end
end

-- function draw_pointer()
--   spr(pointer.spr, pointer.x*cell_width+offset_x+cell_width, pointer.y*cell_height+offset_y+cell_height)
-- end

function make_pointer()
  pointer = make_actor(0, 0)
  pointer.counter = 0
  pointer.spr = spr_pointer
end

function make_actor(x, y)
  a = {}
  a.show = 0
  a.x = x
  a.y = y

  add(actor,a)

  return a
end

-- helper functions --
----------------------

function draw_actor(a)
  if (a.show == 1) then
    local sx = a.x * cell_width + offset_x
    local sy = a.y * cell_height + offset_y
    spr(a.spr, sx, sy)
  end
end

function clamp(val,a,b)
  return max(a, min(b, val))
end

function debug_print(msg)
  if (debug == 1) printh(msg)
end

__gfx__
77777777666666656666666937777773333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337335555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337335555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337335555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777765d5d5d56f7f7f7973333337335555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776d5d5d5567f7f7f973333337333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777555555559999999937777773333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33003333333003333330033333033033330000333330033333000033333003333330033330033033000000000000000000000000000000000000000000000000
33303333330330333303303333033033330333333303333333333033330330333303303333030303000000000000000000000000000000000000000000000000
33303333333330333333003333000033330003333300033333333033333003333303303333030303000000000000000000000000000000000000000000000000
33303333333003333333303333333033333330333303303333333033330330333330003333030303000000000000000000000000000000000000000000000000
33303333330333333303303333333033330330333303303333333033330330333333303333030303000000000000000000000000000000000000000000000000
33000333330000333330033333333033333003333330033333333033333003333333303330003033000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
