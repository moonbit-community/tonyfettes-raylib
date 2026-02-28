// Particle system update

fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Gravity
    p.vy -= @types.particle_gravity * dt
    // Drag
    p.vx *= @types.particle_drag
    p.vz *= @types.particle_drag
    // Floor collision
    if p.y < 0.0 {
      p.y = 0.0
      p.vy = @types.absf(p.vy) * 0.3
      if @types.absf(p.vy) < 0.5 {
        p.vy = 0.0
      }
    }
    // Shrink as life depletes
    let life_ratio = p.life / p.max_life
    if life_ratio < 0.3 {
      p.size *= 0.98
    }
  }
}
