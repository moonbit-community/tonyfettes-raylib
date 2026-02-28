///|
fn fighter_draw_pos(game : @types.Game, fighter : @types.Fighter) -> (Float, Float) {
  (
    @types.camera_project_x(game, fighter.x) + fighter.hurt_shake_x,
    @types.camera_project_y(game, fighter.y) + fighter.hurt_shake_y,
  )
}

///|
fn fighter_flash_color(
  base : @raylib.Color,
  fighter : @types.Fighter,
) -> @raylib.Color {
  if fighter.flash_timer > @types.f(0.0) {
    @raylib.color_lerp(base, @raylib.white, @types.f(0.72))
  } else {
    base
  }
}

///|
fn draw_fighter_shadow(game : @types.Game, fighter : @types.Fighter, sx : Float) -> Unit {
  let width = @types.camera_project_size(
    game,
    @types.fighter_body_width * (if fighter.crouching { @types.f(0.92) } else { @types.f(1.08) }),
  )
  let height = @types.camera_project_size(game, @types.f(20.0))

  @raylib.draw_ellipse(
    sx.to_int(),
    @types.camera_project_y(game, @types.floor_y + @types.f(4.0)).to_int(),
    width * @types.f(0.52),
    height * @types.f(0.45),
    @raylib.Color::new(0, 0, 0, 110),
  )
}

///|
fn draw_fighter_body(
  game : @types.Game,
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
) -> Unit {
  let mut body_h = @types.fighter_body_height
  if fighter.crouching {
    body_h = body_h * @types.f(0.72)
  } else if not(fighter.on_ground) {
    body_h = body_h * @types.f(0.88)
  }

  let body_w = @types.fighter_body_width
  let bob_amp = if fighter.action == @types.action_walk_forward ||
    fighter.action == @types.action_walk_back {
    @types.f(3.5)
  } else {
    @types.f(1.4)
  }
  let bob = Float::from_double(
      @math.sin(
        (fighter.action_elapsed * @types.f(8.5) + Float::from_int(fighter.slot)).to_double(),
      ),
    ) *
    bob_amp

  let draw_x = @types.camera_project_x(game, fighter.x) + fighter.hurt_shake_x
  let draw_y = @types.camera_project_y(game, fighter.y) + fighter.hurt_shake_y + bob

  let body_color = fighter_flash_color(archetype.body_main, fighter)
  let trim_color = fighter_flash_color(archetype.body_trim, fighter)

  let bx = (draw_x - @types.camera_project_size(game, body_w * @types.f(0.5))).to_int()
  let by = (draw_y - @types.camera_project_size(game, body_h)).to_int()
  let bw = @types.camera_project_size(game, body_w).to_int()
  let bh = @types.camera_project_size(game, body_h).to_int()

  @raylib.draw_rectangle(bx, by, bw, bh, body_color)
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.color_alpha(trim_color, @types.f(0.95)),
  )

  @raylib.draw_rectangle(
    bx + 6,
    by + 8,
    bw - 12,
    @types.camera_project_size(game, body_h * @types.f(0.35)).to_int(),
    @raylib.color_alpha(trim_color, @types.f(0.22)),
  )

  let head_r = @types.camera_project_size(game, @types.f(18.0))
  let head_y = by - @types.camera_project_size(game, @types.f(18.0)).to_int()
  @raylib.draw_circle(
    draw_x.to_int(),
    head_y,
    head_r,
    @raylib.Color::new(234, 208, 184, 255),
  )
  @raylib.draw_circle_lines(
    draw_x.to_int(),
    head_y,
    head_r,
    @raylib.color_alpha(trim_color, @types.f(0.8)),
  )

  let fx = @types.facing_sign(fighter.facing)
  let arm_y = by + bh * 3 / 7

  let mut punch_ext = @types.f(0.0)
  if fighter.action == @types.action_attack {
    let mv = fighter.current_move
    if fighter.action_frame >= mv.startup_frames &&
      fighter.action_frame <= mv.startup_frames + mv.active_frames {
      punch_ext = @types.f(20.0)
    } else if fighter.action_frame < mv.startup_frames {
      punch_ext = @types.f(-8.0)
    }
  }

  let hand_x0 = draw_x + @types.camera_project_size(game, @types.f(22.0)) * fx
  let hand_x1 = draw_x + @types.camera_project_size(game, @types.f(22.0) + punch_ext) * fx

  @raylib.draw_line_ex(
    @raylib.Vector2::new(draw_x, Float::from_int(arm_y)),
    @raylib.Vector2::new(hand_x0, Float::from_int(arm_y + 4)),
    @types.camera_project_size(game, @types.f(8.0)),
    @raylib.color_alpha(trim_color, @types.f(0.85)),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(draw_x, Float::from_int(arm_y + 12)),
    @raylib.Vector2::new(hand_x1, Float::from_int(arm_y + 10)),
    @types.camera_project_size(game, @types.f(8.0)),
    @raylib.color_alpha(trim_color, @types.f(0.9)),
  )

  let leg_w = @types.camera_project_size(game, @types.f(14.0)).to_int()
  let leg_h = @types.camera_project_size(
    game,
    if fighter.crouching {
      @types.f(34.0)
    } else {
      @types.f(46.0)
    },
  ).to_int()

  let stride = if fighter.action == @types.action_walk_forward ||
    fighter.action == @types.action_walk_back {
    Float::from_double(
      @math.sin((fighter.action_elapsed * @types.f(12.0)).to_double()),
    ) *
    @types.camera_project_size(game, @types.f(8.0))
  } else {
    @types.f(0.0)
  }

  @raylib.draw_rectangle(
    (draw_x - @types.camera_project_size(game, @types.f(16.0)) + stride).to_int(),
    by + bh - 4,
    leg_w,
    leg_h,
    @raylib.color_alpha(trim_color, @types.f(0.95)),
  )
  @raylib.draw_rectangle(
    (draw_x + @types.camera_project_size(game, @types.f(2.0)) - stride).to_int(),
    by + bh - 4,
    leg_w,
    leg_h,
    @raylib.color_alpha(trim_color, @types.f(0.95)),
  )

  if fighter.action == @types.action_attack {
    let mv = fighter.current_move
    if fighter.action_frame >= mv.startup_frames &&
      fighter.action_frame < mv.startup_frames + mv.active_frames {
      let hitbox = @types.attack_hitbox_for(fighter, mv)
      let hx = @types.camera_project_x(game, hitbox.x)
      let hy = @types.camera_project_y(game, hitbox.y)
      let hw = @types.camera_project_size(game, hitbox.width)
      let hh = @types.camera_project_size(game, hitbox.height)

      let aura = @raylib.color_alpha(
        archetype.aura_color,
        if mv.move_kind == @types.move_kind_super {
          @types.f(0.55)
        } else {
          @types.f(0.35)
        },
      )
      @raylib.draw_rectangle(
        hx.to_int(),
        hy.to_int(),
        hw.to_int(),
        hh.to_int(),
        aura,
      )
      @raylib.draw_rectangle_lines(
        hx.to_int(),
        hy.to_int(),
        hw.to_int(),
        hh.to_int(),
        @raylib.color_alpha(@raylib.white, @types.f(0.65)),
      )
    }
  }

  if fighter.action == @types.action_victory {
    let glow = Float::from_double(
        @math.sin((fighter.action_elapsed * @types.f(6.0)).to_double()),
      ) *
      @types.f(0.5) +
      @types.f(0.5)
    @raylib.draw_circle_lines(
      draw_x.to_int(),
      by + bh / 2,
      @types.camera_project_size(game, @types.f(54.0) + glow * @types.f(12.0)),
      @raylib.color_alpha(archetype.aura_color, @types.f(0.7)),
    )
  }
}

///|
fn draw_fighter_nameplate(
  game : @types.Game,
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
  sx : Float,
  sy : Float,
) -> Unit {
  let y = (sy - @types.camera_project_size(game, @types.fighter_body_height) - @types.f(56.0)).to_int()
  @types.draw_center_shadow_text(
    archetype.name,
    sx.to_int(),
    y,
    16,
    @raylib.color_alpha(archetype.ui_color, @types.f(0.95)),
  )

  if fighter.combo_counter >= 2 {
    @types.draw_center_shadow_text(
      "\{fighter.combo_counter} HIT",
      sx.to_int(),
      y - 18,
      15,
      @raylib.gold,
    )
  }
}

///|
fn draw_single_fighter(game : @types.Game, fighter : @types.Fighter) -> Unit {
  let archetype = @types.fighter_archetype(game, fighter)
  let (sx, sy) = fighter_draw_pos(game, fighter)
  draw_fighter_shadow(game, fighter, sx)
  draw_fighter_body(game, fighter, archetype)
  draw_fighter_nameplate(game, fighter, archetype, sx, sy)

  if game.debug_overlay {
    let hurt = @types.hurtbox_for(fighter)
    let hx = @types.camera_project_x(game, hurt.x)
    let hy = @types.camera_project_y(game, hurt.y)
    let hw = @types.camera_project_size(game, hurt.width)
    let hh = @types.camera_project_size(game, hurt.height)
    @raylib.draw_rectangle_lines(
      hx.to_int(),
      hy.to_int(),
      hw.to_int(),
      hh.to_int(),
      @raylib.lime,
    )
  }
}

///|
fn draw_fighters(game : @types.Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if p1.y <= p2.y {
    draw_single_fighter(game, p2)
    draw_single_fighter(game, p1)
  } else {
    draw_single_fighter(game, p1)
    draw_single_fighter(game, p2)
  }
}
