///|
struct CivilianSite {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut waiting : Int
}

///|
struct Game {
  terrain : Array[Int]
  lava : Array[Bool]
  lava_buf : Array[Bool]
  route : Array[Int]
  sites : Array[CivilianSite]
  mut route_len : Int
  mut route_running : Bool
  mut step_timer : Float
  mut lava_timer : Float
  mut lava_interval : Float
  mut site_count : Int
  mut truck_x : Int
  mut truck_y : Int
  mut start_x : Int
  mut start_y : Int
  mut shelter_x : Int
  mut shelter_y : Int
  mut carrying : Int
  mut rescued : Int
  mut lost : Int
  mut goal_rescue : Int
  mut total_civilians : Int
  mut heat : Float
  mut fuel : Float
  mut coolant : Float
  mut mission_time : Float
  mut mission_limit : Float
  mut level_index : Int
  mut state : Int
  mut result : Int
  mut ui_t : Float
  mut msg : String
  mut msg_t : Float
  mut touch_cd : Float
  mut last_plan_ok : Bool
  mut selected_tx : Int
  mut selected_ty : Int
}

///|
fn CivilianSite::new() -> CivilianSite {
  { active: false, x: 0, y: 0, waiting: 0 }
}

///|
fn Game::new() -> Game {
  {
    terrain: Array::make(max_cells, tile_ground),
    lava: Array::make(max_cells, false),
    lava_buf: Array::make(max_cells, false),
    route: Array::make(max_route_steps, dir_none),
    sites: Array::makei(max_sites, fn(_i) { CivilianSite::new() }),
    route_len: 0,
    route_running: false,
    step_timer: 0.0,
    lava_timer: 0.0,
    lava_interval: 1.5,
    site_count: 0,
    truck_x: 0,
    truck_y: 0,
    start_x: 0,
    start_y: 0,
    shelter_x: 0,
    shelter_y: 0,
    carrying: 0,
    rescued: 0,
    lost: 0,
    goal_rescue: 0,
    total_civilians: 0,
    heat: 0.0,
    fuel: max_fuel,
    coolant: max_coolant,
    mission_time: 0.0,
    mission_limit: 0.0,
    level_index: 0,
    state: state_title,
    result: result_none,
    ui_t: 0.0,
    msg: "",
    msg_t: 0.0,
    touch_cd: 0.0,
    last_plan_ok: false,
    selected_tx: -1,
    selected_ty: -1,
  }
}
