pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- globals --
-------------

-- constants
cell_width=8
cell_height=8
screen_width=128
screen_height=128

-- sprites
spr_board_border=1
spr_board_background=2
spr_pointer=3

bg=0

-- keys
k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_dash=5

-- palette
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

pointer={
  x=0,
  y=0,
  show=0,
  counter=0
}

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

board={
  state={}
}

-- Number sprites start at 16
numbers_offset=15

-- entry point --
-----------------

function _init()
  printh("_init")
  palt(col_black, f)
  palt(col_darkgreen, t)
  make_sprites()
  load_level(1)
end

function _update()
  -- read inputs
  read_inputs()
end

function _draw()
  cls()
  draw_level()
  if(pointer.show == 1) then
    draw_pointer()
  end

  -- Flip whether the point is visible every 16 frames
  pointer.counter += 1

  if (pointer.counter == 16) then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end
end

function make_sprites()
  -- numbers[1]=16
  -- numbers[2]=17
  -- numbers[3]=18
  -- numbers[4]=19
  -- numbers[5]=20
  -- numbers[6]=21
  -- numbers[7]=22
  -- numbers[8]=23
  -- numbers[9]=24
  -- numbers[10]=25
end

function load_level(id)
  level_id=id
  level=levels[id]
  board.state={}
end

function draw_level()
  cls()
  rectfill(0,0,127,127,bg)
  draw_board()
  
  print("level "..tostr(level_id), 0, 0, col_white)
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
  local board_width=level["width"]*cell_width
  local board_height=level["height"]*cell_height

  -- Add two for the width of the border
  local total_width=(level["width"]+2)*cell_width
  local total_height=(level["height"]+2)*cell_height

  printh("Cell width is "..tostr(cell_width))
  printh("Cell height is "..tostr(cell_height))
  printh("Total width is "..tostr(total_width))
  printh("Total height is "..tostr(total_height))
  printh("Board width is "..tostr(board_width))
  printh("Board height is "..tostr(board_height))

  offset_x=(screen_width-total_width)/2
  offset_y=(screen_height-total_height)/2

  -- Draw the border
  for x=0,11 do
    spr(spr_board_border, x*8+offset_x, 0+offset_y)
    spr(spr_board_border, x*8+offset_x, 88+offset_y)
  end
  for y=1,10 do
    spr(spr_board_border, 0+offset_x, y*8+offset_y)
    spr(spr_board_border, 88+offset_x, y*8+offset_y)
  end

  -- Fill the board
  for x=1,10 do
    for y=1,10 do
      spr(spr_board_background, x*cell_width+offset_x,y*cell_height+offset_y)
    end
  end

  -- Draw the numbers
  for cell in all(level["numbers"]) do
    spr(cell[1]+numbers_offset, cell[2]*cell_width+offset_x, cell[3]*cell_width+offset_y)
  end
end

function draw_pointer()
  spr(spr_pointer, pointer.x*cell_width+offset_x+cell_width, pointer.y*cell_height+offset_y+cell_height)
end

-- helper functions --
----------------------

function clamp(val,a,b)
	return max(a, min(b, val))
end

__gfx__
77777777666666656666666937777773666666690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777699999956f7f7f79733333376f7f7f790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776999999567f7f7f973333337675555f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777699999956f7f7f79733333376f5555790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776999999567f7f7f973333337675555f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777699999956f7f7f79733333376f5555790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777776999999567f7f7f97333333767f7f7f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777555555559999999937777773999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
33003333333003333330033333033033330000333330033333000033333003333330033330033033000000000000000000000000000000000000000000000000
33303333330330333303303333033033330333333303333333333033330330333303303333030303000000000000000000000000000000000000000000000000
33303333333330333333003333000033330003333300033333333033333003333303303333030303000000000000000000000000000000000000000000000000
33303333333003333333303333333033333330333303303333333033330330333330003333030303000000000000000000000000000000000000000000000000
33303333330333333303303333333033330330333303303333333033330330333333303333030303000000000000000000000000000000000000000000000000
33000333330000333330033333333033333003333330033333333033333003333333303330003033000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000
