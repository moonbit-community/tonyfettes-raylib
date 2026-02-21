///|
fn reset_contract_slot(contract : StageContract) -> Unit {
  contract.kind = contract_none
  contract.name = "No Contract"
  contract.detail = ""
  contract.goal = 0
  contract.progress = 0
  contract.completed = false
  contract.failed = false
  contract.bonus_score = 0
}

///|
fn contract_name(kind : Int) -> String {
  if kind == contract_fast_clear {
    "Speedrun Clause"
  } else if kind == contract_no_death {
    "Ghost Walk"
  } else if kind == contract_no_base_break {
    "Stronghold Oath"
  } else if kind == contract_elite_hunt {
    "Elite Purge"
  } else if kind == contract_core_breaker {
    "Core Breaker"
  } else if kind == contract_combo_chain {
    "Combo Discipline"
  } else {
    "Idle"
  }
}

///|
fn contract_detail(kind : Int, goal : Int) -> String {
  if kind == contract_fast_clear {
    "Clear under \{goal}s"
  } else if kind == contract_no_death {
    "No player deaths"
  } else if kind == contract_no_base_break {
    "Base must survive"
  } else if kind == contract_elite_hunt {
    "Elites defeated: \{goal}"
  } else if kind == contract_core_breaker {
    "Destroy cores: \{goal}"
  } else if kind == contract_combo_chain {
    "Reach combo tier \{goal}"
  } else {
    ""
  }
}

///|
fn assign_contract(
  game : Game,
  slot : Int,
  kind : Int,
  goal : Int,
  bonus_score : Int,
) -> Unit {
  if slot < 0 || slot >= game.stage_contracts.length() {
    return
  }

  let c = game.stage_contracts[slot]
  c.kind = kind
  c.name = contract_name(kind)
  c.goal = clampi(goal, 1, 999)
  c.progress = 0
  c.failed = false
  c.completed = false
  c.bonus_score = clampi(bonus_score, 20, 99999)

  if kind == contract_no_death || kind == contract_no_base_break {
    c.progress = 1
    c.goal = 1
  }

  c.detail = contract_detail(kind, c.goal)
}

///|
fn contract_kind_for_slot(stage : Int, slot : Int) -> Int {
  let table : Array[Int] = [
    contract_fast_clear,
    contract_no_death,
    contract_no_base_break,
    contract_elite_hunt,
    contract_core_breaker,
    contract_combo_chain,
  ]
  let idx = (stage * 5 + slot * 3 + 1) % table.length()
  table[idx]
}

///|
fn setup_stage_contracts(game : Game, stage : Int) -> Unit {
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    reset_contract_slot(game.stage_contracts[i])
  }

  let stage_bonus = clampi(stage / 4, 0, 30)
  for slot = 0; slot < max_contracts; slot = slot + 1 {
    let kind = contract_kind_for_slot(stage, slot)
    let goal = if kind == contract_fast_clear {
      clampi(contract_time_goal_base - stage + slot * 6, 55, 120)
    } else if kind == contract_elite_hunt {
      clampi(contract_elite_goal_base + stage / 8 + slot, 2, 12)
    } else if kind == contract_core_breaker {
      clampi(contract_core_goal_base + stage / 10 + slot, 2, 10)
    } else if kind == contract_combo_chain {
      clampi(2 + stage / 12 + slot, 2, 7)
    } else {
      1
    }
    let bonus = contract_score_base + stage_bonus * 22 + slot * 40
    assign_contract(game, slot, kind, goal, bonus)
  }
}

///|
fn contract_on_enemy_destroyed(game : Game, enemy : Tank) -> Unit {
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.failed || c.completed {
      continue i + 1
    }

    if c.kind == contract_elite_hunt {
      if enemy.elite_rank > 0 {
        c.progress += 1
      }
    } else if c.kind == contract_combo_chain {
      c.progress = clampi(game.kill_combo, c.progress, 20)
    }
  }
}

///|
fn contract_on_core_destroyed(game : Game) -> Unit {
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.failed || c.completed {
      continue i + 1
    }
    if c.kind == contract_core_breaker {
      c.progress += 1
    }
  }
}

///|
fn contract_on_player_down(game : Game) -> Unit {
  game.stage_deaths += 1
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.kind == contract_no_death {
      c.failed = true
      c.progress = 0
    }
  }
}

///|
fn contract_on_base_broken(game : Game) -> Unit {
  if game.stage_base_losses <= 0 {
    game.stage_base_losses = 1
  }
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.kind == contract_no_base_break {
      c.failed = true
      c.progress = 0
    }
  }
}

///|
fn update_stage_contracts(game : Game, dt : Float) -> Unit {
  game.stage_timer += dt

  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.failed || c.completed {
      continue i + 1
    }

    if c.kind == contract_fast_clear {
      c.progress = clampi(c.goal - game.stage_timer.to_int(), 0, c.goal)
      if game.stage_timer > Float::from_int(c.goal) {
        c.failed = true
      }
    } else if c.kind == contract_no_death {
      c.progress = if game.stage_deaths == 0 { 1 } else { 0 }
      if game.stage_deaths > 0 {
        c.failed = true
      }
    } else if c.kind == contract_no_base_break {
      c.progress = if game.stage_base_losses == 0 && game.base_alive { 1 } else { 0 }
      if not(game.base_alive) || game.stage_base_losses > 0 {
        c.failed = true
      }
    } else if c.kind == contract_combo_chain {
      c.progress = clampi(game.kill_combo, c.progress, 20)
    }
  }
}

///|
fn finalize_stage_contracts(game : Game) -> Unit {
  let mut completed = 0

  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    let c = game.stage_contracts[i]
    if c.kind == contract_none || c.failed {
      continue i + 1
    }

    let ok = if c.kind == contract_fast_clear {
      game.stage_timer <= Float::from_int(c.goal)
    } else if c.kind == contract_no_death {
      game.stage_deaths == 0
    } else if c.kind == contract_no_base_break {
      game.stage_base_losses == 0 && game.base_alive
    } else {
      c.progress >= c.goal
    }

    if ok {
      c.completed = true
      completed += 1
      grant_score(game, team_player1, c.bonus_score)
      if game.coop_enabled {
        grant_score(game, team_player2, c.bonus_score / 2)
      }
    }
  }

  game.contracts_completed_stage = completed
  game.contracts_completed_total += completed

  // Stage contract rewards: utility and sustain.
  if completed >= 2 {
    for i = 0; i < max_players; i = i + 1 {
      if not(is_player_enabled(game, i)) {
        continue i + 1
      }
      let p = game.players[i]
      p.grenade_stock = clampi(p.grenade_stock + 1 + completed / 2, 0, 20)
      if p.active && completed == 3 {
        p.shield_timer = clampf(p.shield_timer + 2.0, 0.0, 14.0)
      }
    }
  }
}

///|
fn contract_progress_text(contract : StageContract) -> String {
  if contract.kind == contract_none {
    ""
  } else if contract.failed {
    "FAILED"
  } else if contract.completed {
    "DONE"
  } else {
    "\{contract.progress}/\{contract.goal}"
  }
}

///|
fn contract_completion_ratio(game : Game) -> Float {
  let mut done = 0
  let mut total = 0
  for i = 0; i < game.stage_contracts.length(); i = i + 1 {
    if game.stage_contracts[i].kind == contract_none {
      continue i + 1
    }
    total += 1
    if game.stage_contracts[i].completed {
      done += 1
    }
  }
  if total <= 0 {
    0.0
  } else {
    Float::from_int(done) / Float::from_int(total)
  }
}
