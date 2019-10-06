pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- nurikabe
-- by mmawdsley

-- sprites --
-------------

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
spr_title = 16

-- sound effects --
-------------------

sfx_moved = 0
sfx_blocked = 1
sfx_wrong = 2
sfx_fill = 3
sfx_mark = 4
sfx_correct = 5

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
-- col_darkblue = 1
col_lilac = 2
col_darkgreen = 3
-- col_brown = 4
col_grey = 5
col_lightgrey = 6
col_white = 7
col_red = 8
-- col_orange = 9
-- col_yellow = 10
-- col_lightgreen = 11
-- col_lightblue = 12
-- col_lightpurple = 13
col_pink = 14
col_tan = 15
col_trans = col_darkgreen

-- constants --
---------------

cart_id = "mmawdsley_nurikabe_1"
debug = 0
cell_width = 8
cell_height = 8
border_width = cell_width
border_height = cell_height
screen_width = 128
screen_height = 128
number_col = col_black
number_error_col = col_red
bg = col_white
menu_bg = col_grey
menu_fg = col_white
menu_active_bg = col_pink
menu_active_fg = col_black
menu_x = 32
menu_y = 42
menu_padding = 2
char_width = 4
pointer_min_x = 8
pointer_min_y = 21
pointer_max_x = 112
pointer_max_y = 102
offset_x_min = 8
offset_y_min = 21
shadow_box_bg = col_pink
shadow_box_border = col_lilac
shadow_box_text_col = col_white
shadow_box_text_border_col = col_lilac
bottom_bar_height = 10
success_bg = col_black
success_fg = col_white

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
errors = {}
pointer = nil
level_id = nil
offset_x = nil
offset_y = nil
board = nil
board_offset_x = nil
board_offset_y = nil
map_screen_x = nil
map_screen_y = nil
menu_items = {}
menu_item_count = 0
menu_item_height = 8
menu_item_gap = 4
menu_idx = 1
solution_checker = nil
base36_decoder = {}

-- levels --
------------

levels = {
  "1aa1022212c31352a22122f112421641811462511",
  "1aa40311d262b514120124g142b541532",
  "1aa224331625g453e4z41116021",
  "1aa493122252532454p21353728323031",
  "1aa1b211431412332372725312m2112372223",
  "1aa314231252g412441352g14274j4221",
  "1aa544o50342163225a223524304p",
  "1aa525l33a647363f232d4517",
  "1aa4b414232323k38453d335f53",
  "1aa325d11262g3m43a26a98",
  "1aa1c5532253435551a251544551245",
  "1aa3444174225352i11324c4a51433634",
  "1aa555j356a2221336a4o411411",
  "1aa2223542733221i22431b21412i424115",
  "1aa30c1413c3j241e642j2c1171",
  "1aa3i36583c52385a53325d3531",
  "1aa59521823433c2223403c3412442737",
  "1ai3121333a22234o5411535e322b533412143a2a33222c4c33222442",
  "1ai60353d45463124285d3331423a2n622c31334g2726253465",
  "1ai413122316j232e5421412b2d31333d3425364638272h686331",
  "1ai9031536j5d3j43311k4130114k51937j7d3j2311",
  "1ai794a4a313445328g381m2453663i5212322234al",
  "1ai303d31133f259e12539j6c413k51a29o5e4d",
  "2ai4061362g32275c1732431e233833414047233c36412e4037151745",
  "2ai464241454441454l454f4a4d434643424c4u444545",
  "2ai3a3245222c41313d465c4b324146332e263f332425315d3134",
  "2ai4215423m2477322a722c1h3432132352542f23523h223d51",
  "2ai4o215643131313535362233100412173342343733e73h",
  "2ai4a451d454d754525343535284515843515155d454d45",
  "2ai31ac2j1a6676503g24aa4295543f2j486q",
  "2ai7224351423544y42322412522c24733465242y3242742222",
  "2ai8a1742254e25144242454i5a3i75522214353e554227",
  "2ai4352254e31322c554245355100416512a2426343e254558",
  "2ai923421531b4a35512m471437324724274m41453a2b632134",
  "2ai5346445d7056451b3h553m74265b1b61212245374h",
  "2ai313233332c3h254a34611833314e11432851441a353h2c434362",
  "2ai415a765g656m27362i822b3fc4b33a143d31",
  "2ai634551bk58413t2536387i582417433b51d5",
  "2ai44414e153154351f42774f4f452a747a4e35426727",
  "2ai3068324g333e8535254c10237a43202c5515453e236g1238",
  "2ai4054161416243d44216416143b411g513b54364441342d2426142624",
  "2ai54472b31254630154724304d3232214e3f313b415c212k512241",
  "2ai7c115336452726251a342334211d6f74811e6123821b4d",
  "2ai24243144135437571u4227ae332f224343442663163a3645",
  "2eo1644443629311c26b0297f844221343h373k222612342b3c473021741328352132255s241335e91k893813",
  "2eo1416323b12659f3946325h43222f4223222e29214529352221211313223j124711543a242533462c5936214726a0296c",
  "2eo343e13423932444b525b3b4c595c463b42341459314e4b59325723453439293e3j455643314322235512",
  "2eo203462235a446h197a2m131b5532438h784723621l31455s5434672p6751717w49345226",
  "2eo7e35536h55136h25833l22231k42537k12838473322k33227k33322l73352h53157h4335",
  "2eo3cab351k33dk219816419g4a3c223q40291gc9353a29363126587156852p36526f",
  "3eo2345521123264a5j466j20253g35133f22751121483od8211155324f33251g25405j561j1a1623a1c245"
}

-- tutorial screens --
----------------------

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

-- entry point --
-----------------

function _init()
  debug_print("_init")
  cartdata(cart_id)
  -- use dark green instead of black as the transparent colour
  palt(col_black, false)
  palt(col_trans, true)
  pointer = make_pointer()

  set_next_level()
  -- open_level()
  -- load_solution()
  -- check_solution()
  open_menu()
  -- start_solution_checker()
  -- open_level_select()
  -- open_how_to_play()
  decompress_levels()
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

-- switch mode to menu
function open_menu()
  mode = mode_menu

  menu_item_count = 0
  menu_items = {}

  make_menu_item("level select", open_level_select)
  make_menu_item("how to play", open_how_to_play)
end

-- switch mode to level
function open_level()
  load_level()
  mode = mode_level
  pointer.x = 0
  pointer.y = 0
  board.start = time()
  board.duration = 0
  init_menu()
end

-- switch mode to level select
function open_level_select()
  mode = mode_level_select
  load_level()
end

-- switch mode to how to play
function open_how_to_play()
  mode = mode_how_to_play
  how_to_play_screen = 1
  load_how_to_play_screen()
end

-- load the level in
-- performs one-off calculations to set the state of the board
function load_level()
  local level = levels[level_id]

  board = make_board(level.width, level.height, level.islands)
  board.solution = level.solution
  board.diff = "unknown"

  if level.diff == diff_easy then
    board.diff = "easy"
  elseif level.diff == diff_normal then
    board.diff = "normal"
  elseif level.diff == diff_hard then
    board.diff = "hard"
  end

  build_board()
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
  menuitem(1, "check solution", start_solution_checker)
  menuitem(2, "level select", open_level_select)

  if debug == 1 then
    menuitem(3, "show solution", load_solution)
    menuitem(4, "mark as complete", cheat_complete_level)
  end
end

-- load the solution to the current level in
function load_solution()
  board.marks = {}

  for x = 0, board.width - 1 do
    for y = 0, board.height - 1 do
      board.marks[coord_to_index(x, y)] = nil
    end
  end

  for cell in all(board.solution) do
    board.marks[coord_to_index(cell[1], cell[2])] = spr_fill
  end
end

-- check whether the current solution is correct
function check_solution()
  errors = {}
  board.correct = true
  board.checking = 1
  board.has_pools = false

  draw_checking()
  check_islands()
  check_sea()

  if board.correct then
    pointer.show = 0
    sfx(sfx_correct, 0)
  else
    sfx(sfx_wrong, 0)
  end

  set_level_complete(level_id, board.correct)

  board.errors = errors
  board.checking = 0
end

-- start the solution checker routine
function start_solution_checker()
  solution_checker = cocreate(check_solution)
  coresume(solution_checker)
end

-- check each island contains the required number of cells and does
-- not connect to any other islands
function check_islands()
  for k, v in pairs(board.islands) do
    check_island(k, v[1], v[2], v[3])
  end
end

-- check the island has the required number of cells
function check_island(idx, count, x, y)
  debug_print("checking island "..tostr(idx).." at "..tostr(x)..","..tostr(y).." should have "..tostr(count))

  local actual_count = 1
  board.has_pools = false
  board.checked = {}

  mark_cell_checked(x, y)

  actual_count += check_island_cell(x, y - 1)
  actual_count += check_island_cell(x + 1, y)
  actual_count += check_island_cell(x, y + 1)
  actual_count += check_island_cell(x - 1, y)

  if actual_count ~= count then
    debug_print("count was "..tostr(actual_count)..", should be "..tostr(count))
    board.correct = false
    mark_cell_error(x, y)
  end

  if board.has_pools then
    debug_print("island hits another island")
    board.correct = false
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
  board.checked = {}
  sea_mark_count = 0

  local sea_marks = {}

  for x = 0, board.width - 1 do
    for y = 0, board.height - 1 do
      if (is_cell_filled(x, y)) then
        add(sea_marks, {x, y})
        sea_mark_count += 1
      end
    end
  end

  debug_print("counted "..tostr(sea_mark_count).." filled cells")

  if sea_mark_count == 0 then
    debug_print("no marks")
    board.correct = false
    return
  end

  debug_print("first mark is "..sea_marks[1][1]..","..sea_marks[1][2])
  debug_print("checking first mark is connected to the rest")

  local count = count_pool(sea_marks[1][1], sea_marks[1][2])

  debug_print("mark contains "..tostr(count).." cells")

  if count ~= sea_mark_count then
    board.has_pools = true
    board.correct = false
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
    board.correct = false

    mark_cell_error(x, y)
    mark_cell_error(x + 1, y)
    mark_cell_error(x, y + 1)
    mark_cell_error(x + 1, y + 1)
  end
end

-- mark a cell as checked
function mark_cell_checked(x, y)
  board.checked[coord_to_index(x, y)] = true
end

-- return true if the cell has already been checked
function is_cell_checked(x, y)
  return board.checked[coord_to_index(x, y)] == true
end

-- return true if the co-ordinates are within the level boundary
function is_cell_valid(x, y)
  if x >= 0 and x < board.width and y >= 0 and y < board.height then
    return true
  end
  return false
end

-- return true if the co-ordinates are a number
function is_cell_number(x, y)
  for cell in all(board.islands) do
    if (cell[2] == x and cell[3] == y) then
      return true
    end
  end
  return false
end

-- return true if the co-ordinates have been filled
function is_cell_filled(x, y)
  return board.marks[coord_to_index(x, y)] == spr_fill
end

-- return true if the co-ordinates are valid and have been filled
function is_cell_valid_and_filled(x, y)
  return is_cell_valid(x, y) and is_cell_filled(x, y)
end

-- mark the co-ordinates as having an error
function mark_cell_error(x, y)
  debug_print("flagging "..tostr(x)..","..tostr(y).." as error")
  errors[coord_to_index(x, y)] = true
end

-- build the board in the map
function build_board()
  -- draw the border
  for x = 1, board.width do
    mset(x, 0, spr_border_top)
    mset(x, board.height + 1, spr_border_bottom)
  end
  for y = 1, board.height do
    mset(0, y, spr_border_left)
    mset(board.width + 1, y, spr_border_right)
  end

  -- draw the corners
  mset(0, 0, spr_border_top_left)
  mset(board.width + 1, 0, spr_border_top_right)
  mset(board.width + 1, board.height + 1, spr_border_bottom_right)
  mset(0, board.height + 1, spr_border_bottom_left)

  -- fill the board
  for x = 1, board.width do
    for y = 1, board.height do
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

  if (btnp(k_confirm)) menu_items[menu_idx]["action"]()
end

-- update the level state
function update_level()
  if board.correct then
    update_level_complete_state()
  elseif board.checking > 0 then
    update_solution_checker()
  else
    update_level_state()
  end
end

-- read the level inputs and update the state
function update_level_state()
  local changed = false
  local dir_pressed = false
  local old_x, old_y = pointer.x, pointer.y

  if (btnp(k_left)) pointer.x -= 1 dir_pressed = true
  if (btnp(k_right)) pointer.x += 1 dir_pressed = true
  if (btnp(k_up)) pointer.y -= 1 dir_pressed = true
  if (btnp(k_down)) pointer.y += 1 dir_pressed = true

  -- flip whether the point is visible every 16 frames
  pointer.counter += 1

  if pointer.counter == 16 then
    pointer.show = 1 - pointer.show
    pointer.counter = 0
  end

  -- limit the range
  local clamp_x = clamp(pointer.x, 0, board.width - 1)
  local clamp_y = clamp(pointer.y, 0, board.height - 1)

  -- play a sound if they try to go off the board
  if clamp_x ~= pointer.x or clamp_y ~= pointer.y then
    sfx(sfx_blocked, 0)
    pointer.x = clamp_x
    pointer.y = clamp_y
  elseif pointer.x ~= old_x or pointer.y ~= old_y then
    sfx(sfx_moved, 0)
  end

  if dir_pressed then
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
      sfx(sfx_mark, 0)
    elseif btnp(k_cancel) then
      toggle_mark(spr_fill)
      sfx(sfx_fill, 0)
    end
    board.errors = {}
    board.has_pools = false
  end

  -- update how much time has been spent
  if (board.correct == false) then board.duration = time() - board.start end
end

-- read the level complete inputs and update the state
function update_level_complete_state()
  if btnp(k_confirm) or btnp(k_cancel) then
    set_next_level()
    open_level_select()
  end
end

-- continue checking the solution until complete
function update_solution_checker()
  if costatus(solution_checker) == "suspended" then
    board.checking += 1
    if board.checking == 40 then board.checking = 1 end
    coresume(solution_checker)
  end
end

-- read the level select inputs
function update_level_select()
  local tmp_level_id = level_id

  if btnp(k_left) then
    level_id -= 1
  elseif btnp(k_right) then
    level_id += 1
  elseif btnp(k_up) then
    level_id += 5
  elseif btnp(k_down) then
    level_id -= 5
  end

  level_id = clamp(level_id, 1, #levels)

  if level_id ~= tmp_level_id then
    load_level()
  end

  if btnp(k_confirm) then
    if is_level_locked(level_id) then
      sfx(sfx_blocked, 0)
    else
      open_level()
    end
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

  board = make_board(screen.width, screen.height, screen.islands)

  for i = 1, #screen.fills do
    board.marks[screen.fills[i]] = spr_fill
  end

  for i = 1, #screen.marks do
    board.marks[screen.marks[i]] = spr_mark
  end

  for i = 1, #screen.error_cells do
    board.errors[screen.error_cells[i]] = true
  end

  -- override the offset
  offset_y = 50
  board_offset_y = offset_y - border_height

  build_board()
end

-- draw the menu
function draw_menu()
  rectfill(0, 0, 127, 127, col_white)
  spr(spr_title, 0, 8, 16, 15)

  for idx, menu_item in pairs(menu_items) do
    draw_menu_item(menu_item, idx)
  end
end

-- draw the menu item
-- use the index to figure out whether it's active
function draw_menu_item(item, idx)
  local offset = menu_item_height * idx
  local x = menu_x
  local y = menu_y + offset + menu_item_gap * idx
  local fg = idx == menu_idx and menu_active_fg or menu_fg
  local bg = idx == menu_idx and menu_active_bg or menu_bg
  local width = #item.text * char_width + menu_padding

  rounded_rectfill(x, y, width, menu_item_height, bg)
  print(item.text, x + menu_padding, y + menu_padding, fg)
end

-- draw the level, the board and the markings
function draw_level()
  rectfill(0, 0, screen_width - 1, screen_height - 1, bg)

  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)
  draw_numbers()
  draw_marks()

  foreach(actor, draw_actor)

  -- draw the ui over the top of the board
  draw_shadow_box(2, 4, 125, 11)
  draw_shadow_box(2, screen_height - 10, 125, 11)

  draw_level_name()
  draw_timer()

  print_border("▤menu", 4, 118, shadow_box_text_col, shadow_box_text_border_col)
  print_border("🅾️mark ❎fill", 73, 118, shadow_box_text_col, shadow_box_text_border_col)

  if (board.correct) draw_success()
  if (board.checking > 0) draw_checking()
end

-- draw the level select screen
function draw_level_select()
  rectfill(0, 0, 127, 127, bg)
  draw_shadow_box(2, 4, 125, 11)
  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)
  draw_numbers()
  draw_level_name()

  if is_level_locked(level_id) then
    draw_level_locked()
  elseif get_level_complete(level_id) then
    draw_level_complete()
  end

  draw_shadow_box(2, 118, 125, 11)
  print_border("🅾️start ❎back", 4, 118, shadow_box_text_col, shadow_box_text_border_col)
  print_border("⬅️prev ➡️next", 73, 118, shadow_box_text_col, shadow_box_text_border_col)
end

-- draw the label for the level
function draw_level_name()
  print_border("level "..tostr(level_id), 4, 4, shadow_box_text_col, shadow_box_border)
  print_border(board.diff, screen_width - #board.diff*char_width - 3, 4, shadow_box_text_col, shadow_box_border)
end

-- draw that the level is locked
function draw_level_locked()
  local text = "locked"

  print_border(text, flr((screen_width - #text*char_width) / 2), 4, shadow_box_text_col, shadow_box_border)
end

-- draw that the level is complete
function draw_level_complete()
  local text = "completed"

  print_border(text, flr((screen_width - #text*char_width) / 2), 4, shadow_box_text_col, shadow_box_border)
end

-- draw the timer
function draw_timer()
  local hours, minutes, seconds = split_time(board.duration)
  local text = zero_pad(hours)..":"..zero_pad(minutes)..":"..zero_pad(seconds)

  print_border(text, flr((screen_width - #text*char_width) / 2), 4, shadow_box_text_col, shadow_box_border)
end

-- draw the success window
function draw_success()
  local text = "level complete!"
  local width = #text * char_width + menu_padding
  local height = menu_item_height
  local x = flr((screen_width - width) / 2)
  local y = flr((screen_height - height) / 2)

  print_border(text, x, y, success_fg, success_bg)
end

-- draw the "checking..." window
function draw_checking()
  local pip_count = flr(board.checking / 10)
  local pips = ""

  for i = 1, pip_count do
    pips = pips.."."
  end

  local text = "checking"
  local width = #text * char_width + menu_padding
  local height = menu_item_height
  local x = flr((screen_width - width) / 2)
  local y = flr((screen_height - height) / 2)

  print_border(text..pips, x, y, success_fg, success_bg)
end

-- draw the how to play screen
function draw_how_to_play()
  local y = 4
  local lines = how_to_play_screens[how_to_play_screen].lines
  local col = nil

  rectfill(0, 0, 127, 127, bg)
  map(0, 0, board_offset_x, board_offset_y, map_screen_x, map_screen_y)

  for cell in all(board.islands) do
    col = cell_has_error(cell[2], cell[3]) and number_error_col or number_col
    print_number(cell[1], cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y, col)
  end

  draw_marks()
  draw_numbers()
  draw_shadow_box(2, y, 125, #lines * cell_height + 3)

  for i = 1, #lines do
    print_border(lines[i], 4, y, shadow_box_text_col, shadow_box_text_border_col)
    y += cell_height
  end

  draw_shadow_box(2, 118, 125, 11)
  print_border("🅾️/❎back", 4, 118, shadow_box_text_col, shadow_box_text_border_col)
  print_border("⬅️prev ➡️next", 73, 118, shadow_box_text_col, shadow_box_text_border_col)
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

  if (board.marks[idx] == sprite) then
    board.marks[idx] = nil
  else
    board.marks[idx] = sprite
  end
end

-- return true if the cell can be marked
function is_writable()
  return not is_cell_number(pointer.x, pointer.y)
end

-- draw the numbers on the board
function draw_numbers()
  local col = nil

  for cell in all(board.islands) do
    col = cell_has_error(cell[2], cell[3]) and number_error_col or number_col
    print_number(cell[1], cell[2] * cell_width + offset_x, cell[3] * cell_width + offset_y, col)
  end
end

-- return true if the co-ordinates have an error
function cell_has_error(x, y)
  return board.errors[coord_to_index(x, y)]
end

-- draw the marks onto the board
function draw_marks()
  local idx = nil
  local sprite = nil

  for x = 0, board.width - 1 do
    for y = 0, board.height - 1 do
      idx = coord_to_index(x, y)

      if (board.marks[idx]) then
        sprite = board.marks[idx]

        if sprite == spr_fill and (board.has_pools or cell_has_error(x, y)) then
          sprite += 1
        end

        spr(sprite, x * cell_width + offset_x, y * cell_width + offset_y)
      end
    end
  end
end

-- return a new board entity
function make_board(width, height, islands)
  board = {}
  board.width = width
  board.height = height
  board.islands = decompress_rle(islands)
  board.size = coord_to_index(board.width - 1, board.height - 1)
  board.marks = {}
  board.errors = {}
  board.checked = {}
  board.checking = 0
  board.duration = nil
  board.start = nil
  board.correct = false
  board.has_pools = false
  board.solution = {}
  board.diff = nil

  -- set the default position
  local board_width = board.width * cell_width
  local board_height = board.height * cell_height

  offset_x = (screen_width - board_width) / 2
  offset_y = (screen_height - board_height) / 2

  offset_x = max(offset_x, offset_x_min)
  offset_y = max(offset_y, offset_y_min)

  board_offset_x = offset_x - border_width
  board_offset_y = offset_y - border_height
  map_screen_x = board.width + 2
  map_screen_y = board.height + 2

  return board
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

-- return whether the level is locked
function is_level_locked(level_id)
  -- first three levels are always unlocked
  if level_id <= 3 then return false end

  local complete_count = 0

  if get_level_complete(level_id - 1) then complete_count += 1 end
  if get_level_complete(level_id - 2) then complete_count += 1 end
  if get_level_complete(level_id - 3) then complete_count += 1 end

  -- two of the three previous levels must be complete to unlock a level
  if complete_count >= 2 then
    return false
  end

  return false
end

-- mark the level as complete
function cheat_complete_level()
  board.correct = true
  board.has_pools = false
  board.errors = {}
  board.checking = 0

  pointer.show = 0
  sfx(sfx_correct, 0)

  set_level_complete(level_id, board.correct)
end

-- set the next level to the first unsolved level
function set_next_level()
  level_id = get_next_level()
end

-- return the id of the first unsolved level
function get_next_level()
  for i = 1, #levels do
    if get_level_complete(i) == false then
      return i
    end
  end
  return #levels
end

-- helper functions --
----------------------

-- print the text with a "shadow"
function print_shadow(text, x, y, fg, bg)
  print(text, x + 1, y + 1, bg)
  print(text, x, y, fg)
end

-- print the text with a border
function print_border(text, x, y, fg, bg)
  for i = x - 1, x + 1 do
    for j = y - 1, y + 1 do
      print(text, i, j, bg)
    end
  end

  print(text, x, y, fg)
end

-- draw a rounded rectangle
function rounded_rectfill(x, y, width, height, bg)
  rectfill(x, y + 1, x + width, y + height - 1, bg) -- short
  rectfill(x + 1, y, x + width - 1, y + height, bg) -- tall
end

-- draw a shadow box
function draw_shadow_box(x, y, width, height)
  rounded_rectfill(x - 1, y - 3, width, height, shadow_box_border)
  rounded_rectfill(x, y - 2, width - 2, height - 3, shadow_box_bg)
end

-- exclusive or
function xor(a, b)
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
  return board.width * y + x
end

-- convert the index into x and y coordinates
function index_to_coord(idx)
  local x, y = nil, nil

  y = flr(idx / board.width)
  x = idx - y * board.width

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
  if type(any) == "function" then
    return "function"
  end
  if any == nil then
    return "nil"
  end
  if type(any) == "string" then
    return any
  end
  if type(any) == "boolean" then
    if any then return "true" end
    return "false"
  end
  if type(any) == "table" then
    local str = "{ "
    for k, v in pairs(any) do
      str=str..tostring(k).."->"..tostring(v).." "
    end
    return str.."}"
  end
  if type(any) == "number" then
    return ""..any
  end
  return "unknown" -- should never show
end

-- decompress levels 
function decompress_levels()
  base36_decoder:init()
  for i = 1, #levels do
    local level = {}
    base36_decoder:open(levels[i])
    level.diff = base36_decoder:next()
    -- if diff > 17, assume it's flag for next 2 values
    if level.diff > 17 then
      level.diff -= 18
      base36_decoder.digits = 2
    end
    level.width = base36_decoder:next()
    level.height = base36_decoder:next()
    -- read island data
    level.islands = {}
    while not base36_decoder:eof() do
      local number, dist
      -- resets on every single island info
      base36_decoder.digits = 1 
      number = base36_decoder:next()
      -- switch to multi-digit mode if we encounter zero
      while (number == 0) do
        base36_decoder.digits += 1
        number = base36_decoder:next()
      end
      dist = base36_decoder:next()
      add(level.islands, dist)
      add(level.islands, number)
    end
    levels[i] = level
  end
end

-- base36 reading functions --
------------------------------

-- init lookup table
function base36_decoder:init()
  local alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
  if not self.table then
    self.table = {}
    for i = 1, #alphabet do
      self.table[sub(alphabet, i, i)] = i-1
    end
  end
end

-- open the string and reset its pointer
function base36_decoder:open(str)
  self.str = str
  self.ptr = 1
  self.digits = 1
end

-- get next base36 number from the string
function base36_decoder:next()
  local x = 0
  for i = 1, self.digits do
    x *= 36
    x += self.table[sub(self.str, self.ptr, self.ptr)]
    self.ptr += 1
  end
  return x
end

-- check if the end of input string has been reached
function base36_decoder:eof()
  return self.ptr > #self.str
end

__gfx__
77777777555555556666666e37777773333333333333333333333333333333337fee2333777777773332ee7f33333333f7ee23333332ee7f3333333300000000
77777777666666656f7f7f7e73333337333333333222222338888883333333337fee2333ffffffff3332ee7f333333337eee23333332eee73333333300000000
7777777765d5d5d567f7f7fe73333337333333333222222338888883333333337fee2333eeeeeeee3332ee7f33333333eee2333333332eee3333333300000000
777777776d5d5d556f7f7f7e73333337333223333222222338888883222222227fee2333eeeeeeee3332ee7f22333333ee233333333332ee3333332200000000
7777777765d5d5d567f7f7fe73333337333223333222222338888883eeeeeeee7fee2333222222223332ee7fee2333332233333333333322333332ee00000000
777777776d5d5d556f7f7f7e73333337333333333222222338888883eeeeeeee7fee2333333333333332ee7feee23333333333333333333333332eee00000000
7777777765d5d5d567f7f7fe73333337333333333222222338888883ffffffff7fee2333333333333332ee7f7eee233333333333333333333332eee700000000
777777776d5d5d55eeeeeeee37777773333333333333333333333333777777777fee2333333333333332ee7ff7ee233333333333333333333332ee7f00000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7777777777777777776666667776666677777777777777777777777750000d500005777777777777777777775000057777777777777777777777777777777777
77777777777777777600000067600000677777777777777777777775000000000000577777777777777777750000005777777777777777777777777777777777
7777777777777777700666600600d6650677777777777777777777700e77600eef60577777777777777777700ef7605777777777777777777777777777777777
7777777777777777700fff760400e77d0777777777777777777777700eefe00ef770577777777777777777700ee7705777777777777777777777777777777777
7777777777777777602eeee60102ee7107dddd677dddd67dddd651101eee200ef7d06d666d76d555555677700eefd0555d777777655555677777777777777777
777777777777777750eeeeee000eeef00500005650000550000000000000002ef71000000dd00000000057602eee100000577760000000017777777777777777
777777777777777710eeeeee500eeef0004e660205666002676067f5566600eef7000d667500ee67776005d0eeee0e777001760016fff6001777777777777777
777777777777777700eeeeeee00eee6010eef7050e77700efff77771eeff00eef700eeefe00eeefffff70050eeeeeeef7700600eeeeeef700d77777777777777
777777777777777700eeeeeee00eee6000eef7000eff600eeeeeeee0eeee00eef60eeeed000eeeeeeeef6000eeeeeeeee76000eeeeeeeef60077777777777777
777777777777777601eee2eee15eeed000ee76000eef600eeeeed2e0eee600eeeeeeee200d0e10000eeee000eeee402eee6002eefe00eeef0077777777777777
777777777777777d04eee0eeeedeee0002ee75002eef501eeee00001eefd01eeeeeee20075000d66eeeee001eeee000eeef00eeee0002eee0077777777777777
77777777777777750eeef02eeeeeef000eef7000dee700deee20d604eef00deeeeef10175006777feeeee004eee1050eeee00eeeefeeeeee0077777777777777
77777777777777710eeef00eeeeeef010eef7000eeef00eeee007d0eeef00eeeeeef10d700eeeeeeeeee200eeee0000eeee02eeeeeeeeeee0077777777777777
77777777777777700eeee00eeeeee6050eee6000eeef00eeee01750eeef00eeeeeeef00d0eeee200eeee000eeee0101eeee04eee444444420077777777777777
77777777777777700eeee004eeeee6010eeef00eeeee00eeee0d700eee600eeee4eef6000eeee000eeee000eee7000eeee002eee200000200777777777777777
77777777777777602eee5000eeeee5010eeeeeeeeeed00eeee06700eef600eeee0eee7500eeee42eeeee000eeeef6eeeee000eeee422eee00777777777777777
77777777777777d0eeee0000eeeee0020eeeeeeeeef502eee207702eef505eee200eeef00eeeeeeeeeee002eeeeeeeeee0000eeeeeeeeee00777777777777777
77777777777777d0eeee0020eeeee00501eeeeeeeee00eeee00760eeef00eeee0002eef700eeeee2eee400eeee1eeeee001d00eeeeeeee201777777777777777
77777777777777d0000000600000000700022000000000000007600000000000000000000001220000000000000022100177d000242100017777777777777777
777777777777777d00000776000000777000000000006000007776000006000007700000d5000000000066000000000057777600000000577777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777766677777777777777666777777777666777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777667777777777777777777777777777777777767777777777777777666677
77777777777777777777777777777767777777777777777777777777777777777776777667777777777777777777777777777777767777777777777766666677
77777777777777777777777777777677777777777777777777777777777777777776777777666777777777777777777777777777677777777777777776666677
77777777777777777777777777777677777777777777777777777777777777777767777777777667777777777777777777777777677777777777777776667777
77777777777777777777777777776777777777777777777777777777777777777777777777777776666777777777777777777776777777777777777777777777
77777777777777777777777777776777777777777777777777777777777777777677777777777777777666777777777777777776777777777777777777777777
77777777777777777777777777767777777777777777777777777777777777776677777777777777777776666777777777777767777777777777777777777777
77777777777777777777777777677777777777777777666677777777777777776777777777777777777777776666777777777667777777777777777777777777
77777777777777777777777776677777777777777776ddd6777777777777777677777777777777777777777777776d6777777d77777777777777777777777777
777777777777777777777777767777777777777777766d7777777777777777767777777777777777777777777777776666776677777777777777777777777777
7777777777777777777777776677777777777777777777777777777777777767777777777777777777777777777777777666d677777777777777777777777777
d67777777777777777777777d777777777777777777777777777777777777667777777777777777777777777777777777777d6d6777777777777777777777777
76dd6677777777777777777d7777777777777777777777777777777777777d7777777777777777777777777777777777777d6776dd6677777777777777777777
777776dd6777777777777766777777777777777777777777777777777777667777777777777777777777777777777777776d77777766dd677777777777777777
77777777ddd67777777777d7777777777777777777777777777777777777d7777777777777777777777777777777777777d77777777776dd6777777777777777
777777777766dd6777777d6777777777777777777777777777777777777667777777777777777777777777777777777777d76677777777776ddd677777777777
777777777777776d56776d777777777777777777777777777777777777757777777777777777776d56777777777777777d67777777777777777665d677777777
77777777777777777ddd56777777777777777777777777777777777777d67777777777777776dd5d577777777777777775777777776777777777776dd6677777
7777777777777777777ddddd7777777777777777777777777777777776d7777777777777777d5555d777777777777777d6777777777777777777777776ddd677
777777777777777777757776556777777777777777777777777777777d67777777777777777751157777777777777776d7667777777777777777777766666d1d
77777777777777777756777777d5d6677777777777777777777777777d7777777777777777776557777777777777777d67777777777777777777776677777776
77777777777777777dd77777777776d5d77777777777777777777777577777777777777777777777777777777777777577777777666777777766677777777777
77777777777777777577777777777777d5567777777777777777777dd7777777777777777777777777777777777777d677777766677777766667777766777777
7777777777777777d677777777777777776d55d67777777777777775777777777777777777777777777777777777771777776667777777667777666777777777
77777777777777765777777777777777777777d51d7777777777776d777777777777777777777777777777777777756777667777777667777667777777667777
77777777777777757777777777777777777777776555667777777717777777777777777777777777777777777777657776777777766777666777777666777777
77777777777777d67777777777777777777777777776d55d77777567777777777777777777777777777777777777dd7777777766677666777777666777777777
77777777777777577777777777777777777777777777777d15676577777777777777777777777777777777777777577777776667766677777766677777776667
77777777777775677777777777777777777777777777777776551d7777777777777777777777777777777777777dd77777666776667777766677777776666777
777777777777dd777777777777777777777777777777777777765d15677777777777777777777777777777777770777766777667777776d67777776667777777
7777777777775777777777777777777777777777777777777775677651d67777777777777777777777777777775d76667766d777777667777777766677777777
77777777777d67777777777777777777777777777777777777dd777777655d677777777777777777777777777757767766677777766777777766677777766667
7777777777657777777777777777777777777777777777777757777777777650d677777777777777777777777dd7776667777766777777776d77777776677767
7777777777167777777777777777777777777777777777777d67777777777776d15d6777777777777777777771776dd777777667777777667777776667777777
777777777dd77777777777777777777777777777777777777576677777777777776d55d67777777777777777dd6dd67777667777777767777777666777777777
777777777577777777777777777777777777777777777777d6777777777777777777776116777777777777760567777766777777776677777776677777777777
77777777567777777777777776d1156777777777777777765777777776777777777777776555d6777777777d5777776d67777777667777776d6777777777777d
7777777d5777777777777777750000d777777777777777757777766777777777777777777776d516777777757777656777777766777777666777777777767771
77777771777777777777777776000077777777777777776d777767777776777777777777777777651d6777657777777777766d7777766d6777777777776777d1
777777d6777777777777777777d156777777777777777756777777776677777777777777777777777d5556167777777776dd6777766667777777776777777706
777777577777777777777777777777777777777777777657777777677777777777767777777777777777610d7777777755777776dd6777777776667777766617
777775677777777777777777777777777777777777777177777766777777777777777777777777777777716d15d6777777777776677777777666777767677567
7777dd77777777777777777777777777777777777777d6777777777777777777777777777777777777776d7776d51d7777777777777777777677776667776577
777657777777777777777777777777777777777777775777777777777776777777777667777777677777567777777d156777777777777777777777667777dd77
777d677777777777777777777777777777777777777dd77777777777766777777766777777777777777657777777777655d67777777777777777777777771666
77657777777777777777777777777777777777777761777777777776777777766777777667777777777167777777777777651567777777777777777777765dd7
77077777777777777777777777777777777777777756777777777777777776667777766777777777776577777777777777777611d67777777777777777716677
d16777777777777777777777777777777777777776d7777777767777776667777767777777777777775777777777777777777776d55d67777777777777657777
600d7777777777777777777777777777777777777567777666777777666777776777777777777777765777777777777777777777777d11d77777777777d67777
567d556677777777777777777777777777777777657777677777776d67777667777777777767777775677777777777777777777777777655d67777777757776d
d77776d51d777777777777777777777777777777177777777777666777667777777777777777777761777777777777777777777777777777655567777d577766
777777777515667777777777777777777777777d677777777766777766777777777677777777777716777777777777777777777777777777777d51d670677777
77777777777d55d6777777777777777777777765777777776677776777777777667777777777777657777777777777777777777777777777777776d550677777
77777777777777650567777777777777777777d67777777777766677777776667777777777777775677777777777d155d677777777777777777777771551d777
77777777777777776515677677777777777777577777767777677777777766777777777777777765777777777777100000056777777777777777777617765156
7777777777777777777d555d7777777777777567776777777777777776d67777777777677777775d777777777777101000000577777777777777777dd77777d5
77777777777777777767776d056777777777657777776d6777777776667777777777677777777607777777777777777765000007777777777777777167777777
7777777777777776677777777d15d6777777577777dd67777777766777777777776677777777756777777777777777777771000577777777777777d577777777
7777777777777667777777777776d51d6776d7777777777777766777777777776677777777766577777777777777777777770001777777777777770677777777
7777777777767777777766777667777d05616777777777776667777777777766777777776777d677777777777777777777775000677777777777765777777777
77777777667777777777777777777777760056777777777d67777777777666777777766777765777777777777777777777770000677777777777756777777777
7777776677777776777767777777777776176515777777777777777776667777777677777775d77777777777777d567777750001777777777777657777777777
777766777777776777777777777777777d67777d15d6777777777766667777777667777777607777777777777770001551000006777777777777dd7777777777
777777777777777677777777d6777777657777777d515d7777777777777776666777777777567777777777777761000000000567777777777777167777777777
667777777677777777777776677776775677777677776505777777777777766777777777765777777777777777776100001d677777777777777d177777777777
77777777667777777777777777776776577777777777777d15d6777777777777777777777dd77777777777777777776100567777777777777770677777777777
77777667777777777777777777777765777777777777777776d11d77777777777667777771777777777777777777777600017777777777777765777777777777
777667776777777677777767777766dd77777777777777777777650567777777767777775d7777777777777777777777d000677777777777775d777777777777
7767777777777777777777777766675777777777777777777777777d55d677777777777617777777777777777777777760005777777777777717777777777777
67766777777777777777777767677dd777777777777777777777777776611d7777777775d7777777777750677777777760001777777777777d57777777777777
77677777777777776677777677776177777777766777777777777777777765156777777177777777777d00067777777750001777777777777167777777777777
777777777777777777777777777756777777766777777667777777777777777d515677dd77777777777600005677777d0000d777777777776177777777777777
777777777777777777677777777657777776777777777677777777777777777776d10d1677777777777760000005d10000007777777777771d77777777777777
77777777777777777777777776756777767777776767777777777777777777777777600567777777777777500000000000067777777777761777777777777777
7777777777777777777777777765776677777766d77777777777777777777777777771665156777777777776d10000001d77777777777775d777777777777777
77777777777777777777777777077777777766777777777777777777767777777777dd7777d11d7777777777776d555677777777777777716777777777777777
7777777777777777777777777d57777777766777777777777777777777777777677756777777d555d67777777777777777777777777777d57777777777777777
7777777777777777777777777577777777777777777777777777777777777777777d577677777776515677777777777777777777777777067777777777777777
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7777777777777777776666667776666677777777777777777777777750000d500005777777777777777777775000057777777777777777777777777777777777
77777777777777777600000067600000677777777777777777777775000000000000577777777777777777750000005777777777777777777777777777777777
7777777777777777700666600600d6650677777777777777777777700e77600eef60577777777777777777700ef7605777777777777777777777777777777777
7777777777777777700fff760400e77d0777777777777777777777700eefe00ef770577777777777777777700ee7705777777777777777777777777777777777
7777777777777777602eeee60102ee7107dddd677dddd67dddd651101eee200ef7d06d666d76d555555677700eefd0555d777777655555677777777777777777
777777777777777750eeeeee000eeef00500005650000550000000000000002ef71000000dd00000000057602eee100000577760000000017777777777777777
777777777777777710eeeeee500eeef0004e660205666002676067f5566600eef7000d667500ee67776005d0eeee0e777001760016fff6001777777777777777
777777777777777700eeeeeee00eee6010eef7050e77700efff77771eeff00eef700eeefe00eeefffff70050eeeeeeef7700600eeeeeef700d77777777777777
777777777777777700eeeeeee00eee6000eef7000eff600eeeeeeee0eeee00eef60eeeed000eeeeeeeef6000eeeeeeeee76000eeeeeeeef60077777777777777
777777777777777601eee2eee15eeed000ee76000eef600eeeeed2e0eee600eeeeeeee200d0e10000eeee000eeee402eee6002eefe00eeef0077777777777777
777777777777777d04eee0eeeedeee0002ee75002eef501eeee00001eefd01eeeeeee20075000d66eeeee001eeee000eeef00eeee0002eee0077777777777777
77777777777777750eeef02eeeeeef000eef7000dee700deee20d604eef00deeeeef10175006777feeeee004eee1050eeee00eeeefeeeeee0077777777777777
77777777777777710eeef00eeeeeef010eef7000eeef00eeee007d0eeef00eeeeeef10d700eeeeeeeeee200eeee0000eeee02eeeeeeeeeee0077777777777777
77777777777777700eeee00eeeeee6050eee6000eeef00eeee01750eeef00eeeeeeef00d0eeee200eeee000eeee0101eeee04eee444444420077777777777777
77777777777777700eeee004eeeee6010eeef00eeeee00eeee0d700eee600eeee4eef6000eeee000eeee000eee7000eeee002eee200000200777777777777777
77777777777777602eee5000eeeee5010eeeeeeeeeed00eeee06700eef600eeee0eee7500eeee42eeeee000eeeef6eeeee000eeee422eee00777777777777777
77777777777777d0eeee0000eeeee0020eeeeeeeeef502eee207702eef505eee200eeef00eeeeeeeeeee002eeeeeeeeee0000eeeeeeeeee00777777777777777
77777777777777d0eeee0020eeeee00501eeeeeeeee00eeee00760eeef00eeee0002eef700eeeee2eee400eeee1eeeee001d00eeeeeeee201777777777777777
77777777777777d0000000600000000700022000000000000007600000000000000000000001220000000000000022100177d000242100017777777777777777
777777777777777d00000776000000777000000000006000007776000006000007700000d5000000000066000000000057777600000000577777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777766677777777777777666777777777666777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777667777777777777777777777777777777777767777777777777777666677
77777777777777777777777777777767777777777777777777777777777777777776777667777777777777777777777777777777767777777777777766666677
77777777777777777777777777777677777777777777777777777777777777777776777777666777777777777777777777777777677777777777777776666677
77777777777777777777777777777677777777777777777777777777777777777767777777777667777777777777777777777777677777777777777776667777
777777777777777777777777777767777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6777777777777777777776777777777777777777777777
77777777777777777777777777776777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666777777777777777776777777777777777777777777
77777777777777777777777777767777ee0eee000e0e0e000e0eeeeeeee00e000e0eee000ee00e000ee776666777777777777767777777777777777777777777
77777777777777777777777777677777ee0eee0eee0e0e0eee0eeeeeee0eee0eee0eee0eee0eeee0eee777776666777777777667777777777777777777777777
77777777777777777777777776677777ee0eee00ee0e0e00ee0eeeeeee000e00ee0eee00ee0eeee0eee7777777776d6777777d77777777777777777777777777
77777777777777777777777776777777ee0eee0eee000e0eee0eeeeeeeee0e0eee0eee0eee0eeee0eee777777777776666776677777777777777777777777777
77777777777777777777777766777777ee000e000ee0ee000e000eeeee00ee000e000e000ee00ee0eee77777777777777666d677777777777777777777777777
d67777777777777777777777d7777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777777777777d6d6777777777777777777777777
76dd6677777777777777777d777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777777777777d6776dd6677777777777777777777
777776dd6777777777777766777777777777777777777777777777777777667777777777777777777777777777777777776d77777766dd677777777777777777
77777777ddd67777777777d7777777777777777777777777777777777777d7777777777777777777777777777777777777d77777777776dd6777777777777777
777777777766dd6777777d6777777777777777777777777777777777777667777777777777777777777777777777777777d76677777777776ddd677777777777
777777777777776d56776d777777777775555555555555555555555555555555555555555555556d56777777777777777d67777777777777777665d677777777
77777777777777777ddd56777777777755555555555555555555555555555555555555555555555d577777777777777775777777776777777777776dd6677777
7777777777777777777ddddd77777777557575577575755555777557755555777575557775757555d777777777777777d6777777777777777777777776ddd677
777777777777777777757776556777775575757575757555555755757555557575755575757575557777777777777776d7667777777777777777777766666d1d
77777777777777777756777777d5d667557775757575755555575575755555777575557775777557777777777777777d67777777777777777777776677777776
77777777777777777dd77777777776d5557575757577755555575575755555755575557575557557777777777777777577777777666777777766677777777777
7777777777777777757777777777777755757577557775555557557755555575557775757577755777777777777777d677777766677777766667777766777777
7777777777777777d677777777777777555555555555555555555555555555555555555555555557777777777777771777776667777777667777666777777777
77777777777777765777777777777777755555555555555555555555555555555555555555555577777777777777756777667777777667777667777777667777
77777777777777757777777777777777777777776555667777777717777777777777777777777777777777777777657776777777766777666777777666777777
77777777777777d67777777777777777777777777776d55d77777567777777777777777777777777777777777777dd7777777766677666777777666777777777
77777777777777577777777777777777777777777777777d15676577777777777777777777777777777777777777577777776667766677777766677777776667
77777777777775677777777777777777777777777777777776551d7777777777777777777777777777777777777dd77777666776667777766677777776666777
777777777777dd777777777777777777777777777777777777765d15677777777777777777777777777777777770777766777667777776d67777776667777777
7777777777775777777777777777777777777777777777777775677651d67777777777777777777777777777775d76667766d777777667777777766677777777
77777777777d67777777777777777777777777777777777777dd777777655d677777777777777777777777777757767766677777766777777766677777766667
7777777777657777777777777777777777777777777777777757777777777650d677777777777777777777777dd7776667777766777777776d77777776677767
7777777777167777777777777777777777777777777777777d67777777777776d15d6777777777777777777771776dd777777667777777667777776667777777
777777777dd77777777777777777777777777777777777777576677777777777776d55d67777777777777777dd6dd67777667777777767777777666777777777
777777777577777777777777777777777777777777777777d6777777777777777777776116777777777777760567777766777777776677777776677777777777
77777777567777777777777776d1156777777777777777765777777776777777777777776555d6777777777d5777776d67777777667777776d6777777777777d
7777777d5777777777777777750000d777777777777777757777766777777777777777777776d516777777757777656777777766777777666777777777767771
77777771777777777777777776000077777777777777776d777767777776777777777777777777651d6777657777777777766d7777766d6777777777776777d1
777777d6777777777777777777d156777777777777777756777777776677777777777777777777777d5556167777777776dd6777766667777777776777777706
777777577777777777777777777777777777777777777657777777677777777777767777777777777777610d7777777755777776dd6777777776667777766617
777775677777777777777777777777777777777777777177777766777777777777777777777777777777716d15d6777777777776677777777666777767677567
7777dd77777777777777777777777777777777777777d6777777777777777777777777777777777777776d7776d51d7777777777777777777677776667776577
777657777777777777777777777777777777777777775777777777777776777777777667777777677777567777777d156777777777777777777777667777dd77
777d677777777777777777777777777777777777777dd77777777777766777777766777777777777777657777777777655d67777777777777777777777771666
77657777777777777777777777777777777777777761777777777776777777766777777667777777777167777777777777651567777777777777777777765dd7
77077777777777777777777777777777777777777756777777777777777776667777766777777777776577777777777777777611d67777777777777777716677
d16777777777777777777777777777777777777776d7777777767777776667777767777777777777775777777777777777777776d55d67777777777777657777
600d7777777777777777777777777777777777777567777666777777666777776777777777777777765777777777777777777777777d11d77777777777d67777
567d556677777777777777777777777777777777657777677777776d67777667777777777767777775677777777777777777777777777655d67777777757776d
d77776d51d777777777777777777777777777777177777777777666777667777777777777777777761777777777777777777777777777777655567777d577766
777777777515667777777777777777777777777d677777777766777766777777777677777777777716777777777777777777777777777777777d51d670677777
77777777777d55d6777777777777777777777765777777776677776777777777667777777777777657777777777777777777777777777777777776d550677777
77777777777777650567777777777777777777d67777777777766677777776667777777777777775677777777777d155d677777777777777777777771551d777
77777777777777776515677677777777777777577777767777677777777766777777777777777765777777777777100000056777777777777777777617765156
7777777777777777777d555d7777777777777567776777777777777776d67777777777677777775d777777777777101000000577777777777777777dd77777d5
77777777777777777767776d056777777777657777776d6777777776667777777777677777777607777777777777777765000007777777777777777167777777
7777777777777776677777777d15d6777777577777dd67777777766777777777776677777777756777777777777777777771000577777777777777d577777777
7777777777777667777777777776d51d6776d7777777777777766777777777776677777777766577777777777777777777770001777777777777770677777777
7777777777767777777766777667777d05616777777777776667777777777766777777776777d677777777777777777777775000677777777777765777777777
77777777667777777777777777777777760056777777777d67777777777666777777766777765777777777777777777777770000677777777777756777777777
7777776677777776777767777777777776176515777777777777777776667777777677777775d77777777777777d567777750001777777777777657777777777
777766777777776777777777777777777d67777d15d6777777777766667777777667777777607777777777777770001551000006777777777777dd7777777777
777777777777777677777777d6777777657777777d515d7777777777777776666777777777567777777777777761000000000567777777777777167777777777
667777777677777777777776677776775677777677776505777777777777766777777777765777777777777777776100001d677777777777777d177777777777
77777777667777777777777777776776577777777777777d15d6777777777777777777777dd77777777777777777776100567777777777777770677777777777
77777667777777777777777777777765777777777777777776d11d77777777777667777771777777777777777777777600017777777777777765777777777777
777667776777777677777767777766dd77777777777777777777650567777777767777775d7777777777777777777777d000677777777777775d777777777777
7767777777777777777777777766675777777777777777777777777d55d677777777777617777777777777777777777760005777777777777717777777777777
67766777777777777777777767677dd777777777777777777777777776611d7777777775d7777777777750677777777760001777777777777d57777777777777
77677777777777776677777677776177777777766777777777777777777765156777777177777777777d00067777777750001777777777777167777777777777
777777777777777777777777777756777777766777777667777777777777777d515677dd77777777777600005677777d0000d777777777776177777777777777
777777777777777777677777777657777776777777777677777777777777777776d10d1677777777777760000005d10000007777777777771d77777777777777
77777777777777777777777776756777767777776767777777777777777777777777600567777777777777500000000000067777777777761777777777777777
7777777777777777777777777765776677777766d77777777777777777777777777771665156777777777776d10000001d77777777777775d777777777777777
77777777777777777777777777077777777766777777777777777777767777777777dd7777d11d7777777777776d555677777777777777716777777777777777
7777777777777777777777777d57777777766777777777777777777777777777677756777777d555d67777777777777777777777777777d57777777777777777
7777777777777777777777777577777777777777777777777777777777777777777d577677777776515677777777777777777777777777067777777777777777

__sfx__
000100000815016100141001310012100081001110011100101001010010100101000f1000f1000f100055000e1000e1000d1000d1000d1000d1000e1000e1000f1000f100111001210013100141001610018100
000100001355012550105500e5500c550095500855006550055500455003550005500150001500015000550001500025000150001500015000150002500035000550006500065000650006500065000650006500
0002000014450124500f4500c4500a45008450054500345001450004500045005200184001540012400104000d4000b4000840005400024000040000400004000040000400004000040000400000000000000000
000500000e7500e7000a5001600016000160001700000400170001700017000170001700017000170001700018000180001800018000180001700012000170001600017000000001700017000170001700017000
000500000a7500a700003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00001505016050170501a0501e05021050220502305023050230402303023020230100770006700090000670005700057000570006700100000670007700090000870008700097000c000097000970009700
