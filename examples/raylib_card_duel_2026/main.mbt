///|
let sw : Int = 980

///|
let sh : Int = 700

///|
let card_count : Int = 5

///|
fn card_name(card : Int) -> String {
  match card {
    0 => "Strike"
    1 => "Guard"
    2 => "Burst"
    3 => "Sap"
    _ => "Repair"
  }
}

///|
fn card_cost(card : Int) -> Int {
  match card {
    0 => 1
    1 => 1
    2 => 2
    3 => 2
    _ => 2
  }
}

///|
fn card_desc(card : Int) -> String {
  match card {
    0 => "Deal 6"
    1 => "Gain 7 block"
    2 => "Deal 12"
    3 => "Break block, deal 4"
    _ => "Heal 6"
  }
}

///|
fn deal_damage(hp : Int, block : Int, dmg : Int) -> (Int, Int) {
  let mut hp2 = hp
  let mut block2 = block
  let absorbed = if block2 < dmg { block2 } else { dmg }
  block2 = block2 - absorbed
  let left = dmg - absorbed
  hp2 = hp2 - left
  (hp2, block2)
}

///|
fn roll_hand(hand : Array[Int]) -> Unit {
  hand.clear()
  for i = 0; i < 3; i = i + 1 {
    hand.push(@raylib.get_random_value(0, card_count - 1))
  }
}

///|
fn enemy_turn(
  p_hp : Int,
  p_block : Int,
  e_hp : Int,
  e_block : Int,
  turn_no : Int,
) -> (Int, Int, Int, Int, String) {
  let mut p_hp = p_hp
  let mut p_block = p_block
  let mut e_hp = e_hp
  let mut e_block = e_block
  let mut log = "Enemy turn: "
  for act = 0; act < 2; act = act + 1 {
    let roll = @raylib.get_random_value(0, 99)
    if roll < 55 {
      let dmg = 6 + turn_no / 4
      let (nhp, nblock) = deal_damage(p_hp, p_block, dmg)
      p_hp = nhp
      p_block = nblock
      log = "\{log} Slash(\{dmg})"
    } else if roll < 80 {
      e_block = e_block + 7
      log = "\{log} Guard"
    } else {
      let dmg = 4
      let (nhp, nblock) = deal_damage(p_hp, p_block, dmg)
      p_hp = nhp
      p_block = nblock
      e_hp = e_hp + 3
      log = "\{log} Drain"
    }
    if act == 0 {
      log = "\{log},"
    }
  }
  (p_hp, p_block, e_hp, e_block, log)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Card Duel 2026")
  @raylib.set_target_fps(60)

  let hand : Array[Int] = []
  let mut player_hp = 80
  let mut player_block = 0
  let mut enemy_hp = 95
  let mut enemy_block = 0
  let mut energy = 3
  let mut turn_no = 1
  let mut log = "Play cards with 1/2/3, end turn with E."
  let mut won = false
  let mut lost = false

  roll_hand(hand)

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_hp = 80
      player_block = 0
      enemy_hp = 95
      enemy_block = 0
      energy = 3
      turn_no = 1
      log = "New duel begins."
      won = false
      lost = false
      roll_hand(hand)
    }

    if not(won) && not(lost) {
      for slot = 0; slot < hand.length(); slot = slot + 1 {
        let key_hit = (slot == 0 && @raylib.is_key_pressed(@raylib.KeyOne)) ||
          (slot == 1 && @raylib.is_key_pressed(@raylib.KeyTwo)) ||
          (slot == 2 && @raylib.is_key_pressed(@raylib.KeyThree))
        if not(key_hit) {
          continue
        }

        let card = hand[slot]
        let cost = card_cost(card)
        if energy < cost {
          log = "Not enough energy for \{card_name(card)}."
          continue
        }

        energy = energy - cost
        match card {
          0 => {
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 6)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Strike for 6."
          }
          1 => {
            player_block = player_block + 7
            log = "Played Guard (+7 block)."
          }
          2 => {
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 12)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Burst for 12."
          }
          3 => {
            enemy_block = 0
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 4)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Sap (break +4)."
          }
          _ => {
            player_hp = player_hp + 6
            if player_hp > 80 {
              player_hp = 80
            }
            log = "Played Repair (+6 hp)."
          }
        }

        if enemy_hp <= 0 {
          won = true
          break
        }

        ignore(hand.remove(slot))
        break
      }

      if not(won) && @raylib.is_key_pressed(@raylib.KeyE) {
        let (php, pblk, ehp, eblk, turn_log) = enemy_turn(
          player_hp, player_block, enemy_hp, enemy_block, turn_no,
        )
        player_hp = php
        player_block = pblk
        enemy_hp = ehp
        enemy_block = eblk
        log = turn_log

        turn_no = turn_no + 1
        energy = 3
        player_block = if player_block > 0 { player_block - 2 } else { 0 }
        enemy_block = if enemy_block > 0 { enemy_block - 2 } else { 0 }
        roll_hand(hand)
      }

      if player_hp <= 0 {
        lost = true
      }
      if enemy_hp <= 0 {
        won = true
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 20, 30, 255))

    @raylib.draw_text("CARD DUEL 2026", 24, 20, 34, @raylib.skyblue)
    @raylib.draw_text("Turn \{turn_no}", 28, 60, 24, @raylib.raywhite)
    @raylib.draw_text("Energy \{energy}", 160, 60, 24, @raylib.yellow)

    @raylib.draw_rectangle(
      60,
      120,
      380,
      170,
      @raylib.Color::new(34, 48, 72, 255),
    )
    @raylib.draw_text("PLAYER", 82, 138, 28, @raylib.raywhite)
    @raylib.draw_text("HP: \{player_hp}", 86, 178, 30, @raylib.lime)
    @raylib.draw_text("Block: \{player_block}", 86, 218, 28, @raylib.gray)

    @raylib.draw_rectangle(
      540,
      120,
      380,
      170,
      @raylib.Color::new(72, 38, 44, 255),
    )
    @raylib.draw_text("RIVAL", 564, 138, 28, @raylib.raywhite)
    @raylib.draw_text("HP: \{enemy_hp}", 568, 178, 30, @raylib.red)
    @raylib.draw_text("Block: \{enemy_block}", 568, 218, 28, @raylib.gray)

    for i = 0; i < hand.length(); i = i + 1 {
      let x = 120 + i * 260
      let y = 360
      let card = hand[i]
      @raylib.draw_rectangle(
        x,
        y,
        220,
        190,
        @raylib.Color::new(34, 34, 46, 255),
      )
      @raylib.draw_rectangle_lines(x, y, 220, 190, @raylib.lightgray)
      @raylib.draw_text("\{i + 1}", x + 10, y + 10, 28, @raylib.yellow)
      @raylib.draw_text(card_name(card), x + 20, y + 56, 30, @raylib.raywhite)
      @raylib.draw_text(
        "Cost \{card_cost(card)}",
        x + 20,
        y + 98,
        26,
        @raylib.orange,
      )
      @raylib.draw_text(card_desc(card), x + 20, y + 138, 24, @raylib.gray)
    }

    @raylib.draw_text(
      "Keys: 1/2/3 play card, E end turn, R restart", 200, 580, 24, @raylib.gray,
    )
    @raylib.draw_rectangle(
      40,
      620,
      900,
      56,
      @raylib.Color::new(24, 24, 34, 255),
    )
    @raylib.draw_text(log, 56, 638, 22, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(
        290,
        250,
        420,
        120,
        @raylib.fade(@raylib.black, 0.78),
      )
      @raylib.draw_text(
        if won {
          "VICTORY"
        } else {
          "DEFEAT"
        },
        415,
        287,
        46,
        if won {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @raylib.draw_text("Press R to rematch", 384, 336, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
