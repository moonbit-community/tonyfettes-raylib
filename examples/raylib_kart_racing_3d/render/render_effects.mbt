// Visual effects rendering: drift sparks, boost flames, explosions, dust, speed lines, confetti

// Draw all visual effects

///|
pub fn draw_effects(game : @types.Game) -> Unit {
  draw_drift_spark_trails(game)
  draw_boost_exhaust_flames(game)
  draw_dropped_items_3d(game)
  draw_dust_trails(game)
  draw_speed_lines(game)
  draw_start_confetti(game)
  draw_wrong_way_indicator(game)
  draw_lightning_flash(game)
  draw_star_glow(game)
  draw_shield_bubbles(game)
}

// Draw colored drift spark trails behind drifting karts

///|
fn draw_drift_spark_trails(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) {
      continue
    }
    if not(kart.drift_left) && not(kart.drift_right) {
      continue
    }
    if kart.drift_level <= @types.drift_level_none {
      continue
    }
    let dc = @types.get_drift_spark_color(kart.drift_level)
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    let spark_side : Float = if kart.drift_left { 1.0 } else { -1.0 }
    // Left rear wheel spark position
    let sx1 : Float = kart.x -
      sin_a * @types.kart_length * 0.4 +
      cos_a * spark_side * @types.kart_width * 0.6
    let sz1 : Float = kart.z -
      cos_a * @types.kart_length * 0.4 -
      sin_a * spark_side * @types.kart_width * 0.6
    // Right rear wheel spark position
    let sx2 : Float = kart.x -
      sin_a * @types.kart_length * 0.4 -
      cos_a * spark_side * @types.kart_width * 0.2
    let sz2 : Float = kart.z -
      cos_a * @types.kart_length * 0.4 +
      sin_a * spark_side * @types.kart_width * 0.2
    // Spark intensity based on drift level
    let intensity : Float = if kart.drift_level == @types.drift_level_mini {
      0.6
    } else if kart.drift_level == @types.drift_level_super {
      0.8
    } else {
      1.0
    }
    let spark_size : Float = 0.12 * intensity
    let pulse = @math.sinf(
      Float::from_int(game.frame_counter) * 0.6 + Float::from_int(i),
    )
    let pulse_size : Float = spark_size + pulse * 0.04
    // Main spark at rear wheel
    @raylib.draw_sphere(
      @raylib.Vector3::new(sx1, kart.y + 0.08, sz1),
      pulse_size,
      @raylib.Color::new(dc.0, dc.1, dc.2, 220),
    )
    // Secondary smaller spark
    let sec_size : Float = pulse_size * 0.7
    @raylib.draw_sphere(
      @raylib.Vector3::new(sx2, kart.y + 0.06, sz2),
      sec_size,
      @raylib.Color::new(dc.0, dc.1, dc.2, 180),
    )
    // Trailing spark line
    let trail_len : Float = 0.5 + intensity * 0.3
    let trail_x : Float = sx1 - sin_a * trail_len
    let trail_z : Float = sz1 - cos_a * trail_len
    let trail_size : Float = pulse_size * 0.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail_x, kart.y + 0.05, trail_z),
      trail_size,
      @raylib.Color::new(dc.0, dc.1, dc.2, 120),
    )
    // Ultra drift gets extra bright center spark
    if kart.drift_level == @types.drift_level_ultra {
      let ultra_size : Float = spark_size * 0.4
      @raylib.draw_sphere(
        @raylib.Vector3::new(sx1, kart.y + 0.12, sz1),
        ultra_size,
        @raylib.Color::new(255, 255, 255, 200),
      )
    }
  }
}

// Draw boost exhaust flame effect from kart rear

///|
fn draw_boost_exhaust_flames(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) {
      continue
    }
    if kart.boost_timer <= 0.0 {
      continue
    }
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    // Exhaust position (rear of kart)
    let ex_x : Float = kart.x - sin_a * @types.kart_length * 0.7
    let ex_z : Float = kart.z - cos_a * @types.kart_length * 0.7
    let ex_y : Float = kart.y + @types.kart_height * 0.4
    // Flickering flame effect
    let flicker = @math.sinf(
      Float::from_int(game.frame_counter) * 0.8 + Float::from_int(i) * 1.5,
    )
    let flame_size : Float = 0.25 + flicker * 0.08
    // Core flame (bright orange-yellow)
    @raylib.draw_sphere(
      @raylib.Vector3::new(ex_x, ex_y, ex_z),
      flame_size,
      @raylib.Color::new(255, 180, 30, 230),
    )
    // Inner flame (white-hot center)
    let inner_size : Float = flame_size * 0.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(ex_x, ex_y, ex_z),
      inner_size,
      @raylib.Color::new(255, 255, 200, 200),
    )
    // Outer flame (red-orange trail)
    let trail_dist : Float = 0.4 + flicker * 0.1
    let trail_x : Float = ex_x - sin_a * trail_dist
    let trail_z : Float = ex_z - cos_a * trail_dist
    let outer_size : Float = flame_size * 0.7
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail_x, ex_y - 0.05, trail_z),
      outer_size,
      @raylib.Color::new(255, 100, 20, 180),
    )
    // Second trail element (darker, further back)
    let trail2_x : Float = ex_x - sin_a * trail_dist * 2.0
    let trail2_z : Float = ex_z - cos_a * trail_dist * 2.0
    let tail_size : Float = flame_size * 0.4
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail2_x, ex_y - 0.1, trail2_z),
      tail_size,
      @raylib.Color::new(200, 60, 10, 120),
    )
    // Star boost gets rainbow-tinted flames
    if kart.star_timer > 0.0 {
      let rainbow_phase : Float = game.star_rainbow_timer +
        Float::from_int(i) * 0.5
      let rr_f : Float = 127.0 + @math.sinf(rainbow_phase) * 128.0
      let rg_f : Float = 127.0 + @math.sinf(rainbow_phase + 2.0) * 128.0
      let rb_f : Float = 127.0 + @math.sinf(rainbow_phase + 4.0) * 128.0
      let rr = rr_f.to_int()
      let rg = rg_f.to_int()
      let rb = rb_f.to_int()
      let rainbow_size : Float = flame_size * 0.6
      @raylib.draw_sphere(
        @raylib.Vector3::new(ex_x, ex_y + 0.15, ex_z),
        rainbow_size,
        @raylib.Color::new(
          @types.clampi(rr, 0, 255),
          @types.clampi(rg, 0, 255),
          @types.clampi(rb, 0, 255),
          180,
        ),
      )
    }
  }
}

// Draw dropped items on the track (bananas, oil slicks)

///|
fn draw_dropped_items_3d(game : @types.Game) -> Unit {
  for i in 0..<game.dropped_items.length() {
    let item = game.dropped_items[i]
    if not(item.active) {
      continue
    }
    if item.item_type == @types.powerup_banana {
      let bob : Float = @math.sinf(item.rotation) * 0.05
      @raylib.draw_cube(
        @raylib.Vector3::new(item.x, item.y + bob, item.z),
        0.5,
        0.15,
        0.3,
        @raylib.Color::new(255, 230, 50, 255),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(item.x, item.y + 0.1 + bob, item.z),
        0.15,
        0.2,
        0.15,
        @raylib.Color::new(140, 100, 30, 255),
      )
    } else if item.item_type == @types.powerup_oil_slick {
      let pulse = @math.sinf(
        Float::from_int(game.frame_counter) * 0.1 + Float::from_int(i),
      )
      let slick_size : Float = 1.2 + pulse * 0.1
      let slick_depth : Float = slick_size * 0.8
      @raylib.draw_cube(
        @raylib.Vector3::new(item.x, item.y + 0.02, item.z),
        slick_size,
        0.04,
        slick_depth,
        @raylib.Color::new(30, 30, 40, 200),
      )
      let sheen_w : Float = slick_size * 0.3
      let sheen_d : Float = slick_size * 0.2
      @raylib.draw_cube(
        @raylib.Vector3::new(item.x + 0.2, item.y + 0.03, item.z + 0.1),
        sheen_w,
        0.02,
        sheen_d,
        @raylib.Color::new(60, 50, 80, 150),
      )
    }
    // Warning indicator for nearby player
    let player = game.karts[@types.player_kart]
    let dist_to_player = @types.distance2d(player.x, player.z, item.x, item.z)
    if dist_to_player < 12.0 && dist_to_player > 2.0 {
      let warn_pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.3)
      let warn_alpha_f : Float = 60.0 + warn_pulse * 30.0
      let warn_alpha = warn_alpha_f.to_int()
      @raylib.draw_sphere(
        @raylib.Vector3::new(item.x, item.y + 0.3, item.z),
        0.4,
        @raylib.Color::new(255, 50, 50, @types.clampi(warn_alpha, 0, 255)),
      )
    }
  }
}

// Draw dust/dirt particles trailing behind off-road karts

///|
fn draw_dust_trails(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) || not(kart.on_ground) {
      continue
    }
    if kart.speed < 5.0 {
      continue
    }
    if kart.on_surface_type != @types.surface_dirt &&
      kart.on_surface_type != @types.surface_grass {
      continue
    }
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    let dust_x : Float = kart.x - sin_a * @types.kart_length * 0.6
    let dust_z : Float = kart.z - cos_a * @types.kart_length * 0.6
    let dust_y : Float = kart.y + 0.2
    let speed_factor : Float = @types.clampf(kart.speed / 20.0, 0.3, 1.0)
    let dust_size : Float = 0.3 * speed_factor
    let dust_alpha_f : Float = 120.0 * speed_factor
    let dust_alpha = dust_alpha_f.to_int()
    let dc : (Int, Int, Int) = if kart.on_surface_type == @types.surface_dirt {
      (160, 130, 80)
    } else {
      (80, 140, 60)
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(dust_x, dust_y, dust_z),
      dust_size,
      @raylib.Color::new(dc.0, dc.1, dc.2, @types.clampi(dust_alpha, 0, 255)),
    )
    let offset_x : Float = dust_x - sin_a * 0.3 + cos_a * 0.15
    let offset_z : Float = dust_z - cos_a * 0.3 - sin_a * 0.15
    let sec_dust : Float = dust_size * 0.7
    @raylib.draw_sphere(
      @raylib.Vector3::new(offset_x, dust_y + 0.1, offset_z),
      sec_dust,
      @raylib.Color::new(
        dc.0,
        dc.1,
        dc.2,
        @types.clampi(dust_alpha - 30, 0, 255),
      ),
    )
  }
}

// Draw speed lines effect when player is boosting

///|
fn draw_speed_lines(game : @types.Game) -> Unit {
  let kart = game.karts[@types.player_kart]
  if not(kart.active) {
    return
  }
  if kart.boost_timer <= 0.0 && kart.star_timer <= 0.0 {
    return
  }
  let line_count = 8
  let base_alpha : Float = if kart.star_timer > 0.0 { 180.0 } else { 120.0 }
  for li in 0..<line_count {
    let seed = li * 137 + game.frame_counter * 3
    let x_base = seed % @types.screen_width
    let y_base = (seed * 7 + 31) % @types.screen_height
    let line_len = 40 + seed * 3 % 60
    let alpha_f : Float = base_alpha - Float::from_int(li * 15)
    let alpha = @types.clampi(alpha_f.to_int(), 30, 200)
    let color = if kart.star_timer > 0.0 {
      let phase : Float = game.star_rainbow_timer + Float::from_int(li) * 0.8
      let r_f : Float = 127.0 + @math.sinf(phase) * 128.0
      let g_f : Float = 127.0 + @math.sinf(phase + 2.0) * 128.0
      let b_f : Float = 127.0 + @math.sinf(phase + 4.0) * 128.0
      @raylib.Color::new(
        @types.clampi(r_f.to_int(), 0, 255),
        @types.clampi(g_f.to_int(), 0, 255),
        @types.clampi(b_f.to_int(), 0, 255),
        alpha,
      )
    } else {
      @raylib.Color::new(255, 220, 100, alpha)
    }
    @raylib.draw_line(x_base, y_base, x_base, y_base + line_len, color)
  }
}

// Draw confetti effect at race start during countdown

///|
fn draw_start_confetti(game : @types.Game) -> Unit {
  if game.state != @types.Countdown {
    return
  }
  if game.countdown_timer > 0.5 {
    return
  }
  let confetti_count = 20
  for ci in 0..<confetti_count {
    let seed = ci * 97 + game.frame_counter
    let x = (seed * 13 + 41) % @types.screen_width
    let y_offset = game.frame_counter * 3 + ci * 17
    let y = y_offset % @types.screen_height
    let size = 3 + seed % 5
    let r = 100 + seed * 7 % 156
    let g = 100 + seed * 11 % 156
    let b = 100 + seed * 13 % 156
    @raylib.draw_rectangle(
      x,
      y,
      size,
      size,
      @raylib.Color::new(
        @types.clampi(r, 0, 255),
        @types.clampi(g, 0, 255),
        @types.clampi(b, 0, 255),
        200,
      ),
    )
  }
}

// Draw wrong way indicator overlay

///|
fn draw_wrong_way_indicator(game : @types.Game) -> Unit {
  let kart = game.karts[@types.player_kart]
  if not(kart.active) || not(kart.wrong_way) {
    return
  }
  if kart.wrong_way_timer < 0.5 {
    return
  }
  let flash = @math.sinf(
    Float::from_int(game.frame_counter) * @types.wrong_way_flash_speed * 0.05,
  )
  let alpha_f : Float = 80.0 + flash * 40.0
  let alpha = @types.clampi(alpha_f.to_int(), 30, 150)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(255, 0, 0, alpha),
  )
  let text = "WRONG WAY!"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    48,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let sub = "Turn Around!"
  let sw = @raylib.measure_text(sub, 24)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 - 25,
    24,
    @raylib.Color::new(255, 200, 200, 220),
  )
}

// Draw lightning flash overlay when lightning is active

///|
fn draw_lightning_flash(game : @types.Game) -> Unit {
  if not(game.lightning_active) {
    return
  }
  let remaining = game.lightning_timer
  if remaining > @types.lightning_duration - 0.3 {
    let flash_t : Float = (@types.lightning_duration - remaining) / 0.3
    let alpha_f : Float = (1.0 - flash_t) * 200.0
    let alpha = @types.clampi(alpha_f.to_int(), 0, 200)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 255, 220, alpha),
    )
  }
  if game.frame_counter % 15 < 3 {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 255, 200, 30),
    )
  }
}

// Draw star power glow around star-powered karts

///|
fn draw_star_glow(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) || kart.star_timer <= 0.0 {
      continue
    }
    let phase : Float = game.star_rainbow_timer + Float::from_int(i) * 1.2
    let r_f : Float = 127.0 + @math.sinf(phase) * 128.0
    let g_f : Float = 127.0 + @math.sinf(phase + 2.094) * 128.0
    let b_f : Float = 127.0 + @math.sinf(phase + 4.189) * 128.0
    let r = @types.clampi(r_f.to_int(), 0, 255)
    let g = @types.clampi(g_f.to_int(), 0, 255)
    let b = @types.clampi(b_f.to_int(), 0, 255)
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.3)
    let glow_size : Float = 1.5 + pulse * 0.2
    let kart_mid_y : Float = kart.y + @types.kart_height * 0.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(kart.x, kart_mid_y, kart.z),
      glow_size,
      @raylib.Color::new(r, g, b, 50),
    )
    let inner_glow : Float = glow_size * 0.6
    @raylib.draw_sphere(
      @raylib.Vector3::new(kart.x, kart_mid_y, kart.z),
      inner_glow,
      @raylib.Color::new(255, 255, 200, 40),
    )
  }
}

// Draw shield bubble effect around shielded karts

///|
fn draw_shield_bubbles(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) || kart.shield_timer <= 0.0 {
      continue
    }
    let pulse = @math.sinf(
      Float::from_int(game.frame_counter) * 0.15 + Float::from_int(i),
    )
    let size : Float = 1.3 + pulse * 0.1
    let base_alpha : Float = if kart.shield_timer < 1.0 {
      let flicker = @math.sinf(Float::from_int(game.frame_counter) * 0.5)
      40.0 + flicker * 20.0
    } else {
      60.0
    }
    let alpha = @types.clampi(base_alpha.to_int(), 20, 80)
    let shield_y : Float = kart.y + @types.kart_height * 0.4
    @raylib.draw_sphere(
      @raylib.Vector3::new(kart.x, shield_y, kart.z),
      size,
      @raylib.Color::new(80, 180, 255, alpha),
    )
    let wire_w : Float = size * 1.8
    let wire_h : Float = size * 1.4
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(kart.x, shield_y, kart.z),
      wire_w,
      wire_h,
      wire_w,
      @raylib.Color::new(120, 200, 255, @types.clampi(alpha + 20, 0, 100)),
    )
  }
}
