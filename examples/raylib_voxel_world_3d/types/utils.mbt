///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn lerpi(a : Int, b : Int, t : Float) -> Int {
  (Float::from_int(a) + Float::from_int(b - a) * t).to_int()
}

///|
pub fn floorf(v : Float) -> Int {
  let i = v.to_int()
  if Float::from_int(i) > v {
    i - 1
  } else {
    i
  }
}

///|
pub fn signf(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
pub fn fmodf(a : Float, b : Float) -> Float {
  a - Float::from_int((a / b).to_int()) * b
}

// Smoothstep interpolation

///|
pub fn smoothstep(edge0 : Float, edge1 : Float, x : Float) -> Float {
  let t = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  t * t * (3.0 - 2.0 * t)
}

// ========== Noise Functions ==========

// Hash function for noise generation

///|
fn hash_int(x_in : Int) -> Int {
  let mut x = x_in.reinterpret_as_uint()
  x = x ^ (x >> 16)
  x = x * 73244475U // 0x45d9f3b
  x = x ^ (x >> 16)
  x = x * 73244475U
  x = x ^ (x >> 16)
  let result = x.reinterpret_as_int()
  if result < 0 {
    -result
  } else {
    result
  }
}

// 2D hash combining two coordinates

///|
fn hash_2d(x : Int, z : Int) -> Int {
  hash_int(x * 374761393 + z * 668265263 + 1274126177)
}

// Simple noise function for terrain generation using sin/cos

///|
pub fn noise2d(x : Float, z : Float) -> Float {
  let v1 = @math.sinf(x * 0.1 + z * 0.3) * 0.5
  let v2 = @math.cosf(x * 0.2 - z * 0.1) * 0.3
  let v3 = @math.sinf((x + z) * 0.15) * 0.2
  v1 + v2 + v3
}

// Value noise with smooth interpolation

///|
pub fn value_noise_2d(x : Float, z : Float) -> Float {
  let ix = floorf(x)
  let iz = floorf(z)
  let fx = x - Float::from_int(ix)
  let fz = z - Float::from_int(iz)
  // Smoothstep interpolation factors
  let sx = fx * fx * (3.0 - 2.0 * fx)
  let sz = fz * fz * (3.0 - 2.0 * fz)
  // Hash corners to get pseudo-random values
  let v00 = Float::from_int(hash_2d(ix, iz) % 1000) / 1000.0
  let v10 = Float::from_int(hash_2d(ix + 1, iz) % 1000) / 1000.0
  let v01 = Float::from_int(hash_2d(ix, iz + 1) % 1000) / 1000.0
  let v11 = Float::from_int(hash_2d(ix + 1, iz + 1) % 1000) / 1000.0
  // Bilinear interpolation
  let top = lerpf(v00, v10, sx)
  let bottom = lerpf(v01, v11, sx)
  lerpf(top, bottom, sz) * 2.0 - 1.0
}

// Multi-octave noise for terrain

///|
pub fn fractal_noise_2d(x : Float, z : Float, octaves : Int) -> Float {
  let mut amplitude : Float = 1.0
  let mut frequency : Float = 1.0
  let mut value : Float = 0.0
  let mut max_val : Float = 0.0
  for i in 0..<octaves {
    value += value_noise_2d(x * frequency, z * frequency) * amplitude
    max_val += amplitude
    amplitude *= 0.5
    frequency *= 2.0
    ignore(i)
  }
  value / max_val
}

// 3D noise for cave generation

///|
pub fn noise3d(x : Float, y : Float, z : Float) -> Float {
  let v1 = @math.sinf(x * 0.1 + y * 0.2 + z * 0.3) * 0.3
  let v2 = @math.cosf(x * 0.15 - z * 0.1 + y * 0.25) * 0.25
  let v3 = @math.sinf((x + y + z) * 0.12) * 0.2
  let v4 = @math.cosf(x * 0.08 + y * 0.15 - z * 0.12) * 0.25
  v1 + v2 + v3 + v4
}

// Cave noise using 3D value noise approximation

///|
pub fn cave_noise_3d(x : Float, y : Float, z : Float) -> Float {
  let freq = cave_frequency
  let n1 = @math.sinf(x * freq + y * freq * 0.7) *
    @math.cosf(z * freq * 1.2 + y * freq * 0.5)
  let n2 = @math.sinf(x * freq * 1.5 + z * freq * 0.8 + 2.0) *
    @math.cosf(y * freq * 1.3 + 1.5)
  let n3 = @math.cosf(x * freq * 0.6 + y * freq * 1.1 + z * freq * 0.9 + 3.0) *
    0.5
  (n1 + n2 + n3) / 2.5
}

// Better noise combining multiple octaves

///|
pub fn terrain_noise(wx : Float, wz : Float) -> Float {
  let freq = terrain_frequency
  let n1 = @math.sinf(wx * freq) * @math.cosf(wz * freq * 1.3) * 0.5
  let n2 = @math.sinf(wx * freq * 2.1 + 1.7) *
    @math.cosf(wz * freq * 1.9 + 0.8) *
    0.25
  let n3 = @math.sinf(wx * freq * 0.5 + 3.1) *
    @math.cosf(wz * freq * 0.7 + 2.3) *
    0.6
  let n4 = @math.cosf(wx * freq * 3.0 + wz * freq * 2.5) * 0.15
  n1 + n2 + n3 + n4
}

// Biome noise - determines which biome at a given position

///|
pub fn biome_noise(wx : Float, wz : Float) -> Float {
  let freq : Float = 0.008
  let n1 = @math.sinf(wx * freq + 5.3) * @math.cosf(wz * freq * 0.8 + 2.1) * 0.5 +
    0.5
  let n2 = @math.cosf(wx * freq * 0.6 + wz * freq * 0.5 + 1.7) * 0.3 + 0.5
  (n1 + n2) * 0.5
}

// Temperature noise - for biome blending

///|
pub fn temperature_noise(wx : Float, wz : Float) -> Float {
  let freq : Float = 0.005
  let n = @math.sinf(wx * freq + 10.0) * @math.cosf(wz * freq * 1.1 + 7.0)
  n * 0.5 + 0.5
}

// Moisture noise - for biome blending

///|
pub fn moisture_noise(wx : Float, wz : Float) -> Float {
  let freq : Float = 0.006
  let n = @math.cosf(wx * freq + 3.0) * @math.sinf(wz * freq * 0.9 + 5.0)
  n * 0.5 + 0.5
}

// ========== Biome determination ==========

///|
pub fn get_biome_at(wx : Int, wz : Int) -> Int {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let temp = temperature_noise(fx, fz)
  let moist = moisture_noise(fx, fz)
  if temp < 0.25 {
    biome_tundra
  } else if temp > 0.75 && moist < 0.3 {
    biome_desert
  } else if temp > 0.5 && moist > 0.6 {
    biome_swamp
  } else if moist > 0.5 {
    biome_forest
  } else if fractal_noise_2d(fx * 0.01, fz * 0.01, 2) > 0.3 {
    biome_mountains
  } else {
    biome_plains
  }
}

// Get terrain height considering biome

///|
pub fn get_biome_terrain_height(wx : Int, wz : Int, biome : Int) -> Int {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let n = terrain_noise(fx, fz)
  let mut height_base : Float = Float::from_int(base_height)
  let mut amplitude : Float = terrain_amplitude
  if biome == biome_plains {
    height_base = Float::from_int(base_height) + 2.0
    amplitude = 6.0
  } else if biome == biome_forest {
    height_base = Float::from_int(base_height) + 3.0
    amplitude = 10.0
  } else if biome == biome_desert {
    height_base = Float::from_int(base_height) - 1.0
    amplitude = 5.0
  } else if biome == biome_mountains {
    height_base = Float::from_int(base_height) + 10.0
    amplitude = 22.0
  } else if biome == biome_tundra {
    height_base = Float::from_int(base_height) + 1.0
    amplitude = 8.0
  } else if biome == biome_swamp {
    height_base = Float::from_int(base_height) - 2.0
    amplitude = 3.0
  }
  let h = height_base + n * amplitude
  clampi(h.to_int(), 1, chunk_y - 10)
}

// ========== Terrain generation ==========

// Get height at a world position

///|
pub fn get_terrain_height(wx : Int, wz : Int) -> Int {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let n = terrain_noise(fx, fz)
  let h = Float::from_int(base_height) + n * terrain_amplitude
  let result = h.to_int()
  clampi(result, 1, chunk_y - 10)
}

// Determine if a tree should be placed at world position

///|
pub fn should_place_tree(wx : Int, wz : Int, biome : Int) -> Bool {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let v = @math.sinf(fx * 0.73 + 5.1) * @math.cosf(fz * 0.91 + 3.7)
  let v2 = @math.sinf(fx * 1.37 + fz * 0.53) * 0.5
  let combined = (v + v2) * 0.5
  let threshold : Float = if biome == biome_forest {
    0.35
  } else if biome == biome_plains {
    0.7
  } else if biome == biome_swamp {
    0.5
  } else if biome == biome_tundra {
    0.8
  } else {
    999.0
  }
  combined > threshold
}

// Check if this spot should have a cave opening

///|
pub fn is_cave(wx : Int, wy : Int, wz : Int) -> Bool {
  if wy < cave_min_height || wy > cave_max_height {
    return false
  }
  let fx = Float::from_int(wx)
  let fy = Float::from_int(wy)
  let fz = Float::from_int(wz)
  let n = cave_noise_3d(fx, fy, fz)
  let threshold = cave_threshold
  absf(n) > threshold
}

// Check if should generate ore at this position

///|
pub fn should_place_ore(
  wx : Int,
  wy : Int,
  wz : Int,
  ore_type : Int,
  rng : Int,
) -> Bool {
  let fx = Float::from_int(wx)
  let fy = Float::from_int(wy)
  let fz = Float::from_int(wz)
  let hash = hash_int(wx * 7919 + wy * 104729 + wz * 15485863 + rng)
  let r = Float::from_int(hash % 10000) / 10000.0
  if ore_type == block_ore_iron {
    if wy < ore_iron_min_y || wy > ore_iron_max_y {
      return false
    }
    let ore_n = @math.sinf(fx * 0.3 + fy * 0.2 + fz * 0.25) * 0.5 + 0.5
    r < ore_iron_chance && ore_n > 0.6
  } else if ore_type == block_ore_gold {
    if wy < ore_gold_min_y || wy > ore_gold_max_y {
      return false
    }
    let ore_n = @math.cosf(fx * 0.25 + fy * 0.3 + fz * 0.2) * 0.5 + 0.5
    r < ore_gold_chance && ore_n > 0.65
  } else if ore_type == block_ore_diamond {
    if wy < ore_diamond_min_y || wy > ore_diamond_max_y {
      return false
    }
    let ore_n = @math.sinf(fx * 0.35 + fy * 0.15 + fz * 0.3 + 1.0) * 0.5 + 0.5
    r < ore_diamond_chance && ore_n > 0.7
  } else {
    false
  }
}

// Generate terrain for a single chunk

///|
pub fn generate_chunk_terrain(chunk : Chunk, game : Game) -> Unit {
  let base_wx = chunk.cx * chunk_x
  let base_wz = chunk.cz * chunk_z
  // Determine biome for chunk center
  let center_wx = base_wx + chunk_x / 2
  let center_wz = base_wz + chunk_z / 2
  let biome = get_biome_at(center_wx, center_wz)
  chunk.biome = biome

  for lz in 0..<chunk_z {
    for lx in 0..<chunk_x {
      let wx = base_wx + lx
      let wz = base_wz + lz
      let local_biome = get_biome_at(wx, wz)
      let height = get_biome_terrain_height(wx, wz, local_biome)
      // Fill blocks from bottom to height
      for y in 0..<chunk_y {
        if y == 0 {
          chunk.set_block(lx, y, lz, block_bedrock)
        } else if y < height - 4 {
          // Check for caves
          if is_cave(wx, y, wz) {
            chunk.set_block(lx, y, lz, block_air)
            // Check for ores
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_diamond,
              game.rng_state,
            ) {
            chunk.set_block(lx, y, lz, block_ore_diamond)
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_gold,
              game.rng_state + 1,
            ) {
            chunk.set_block(lx, y, lz, block_ore_gold)
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_iron,
              game.rng_state + 2,
            ) {
            chunk.set_block(lx, y, lz, block_ore_iron)
          } else {
            chunk.set_block(lx, y, lz, block_stone)
          }
        } else if y < height - 1 {
          // Sub-surface layer depends on biome
          if local_biome == biome_desert {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == biome_tundra {
            chunk.set_block(lx, y, lz, block_gravel)
          } else {
            chunk.set_block(lx, y, lz, block_dirt)
          }
        } else if y == height - 1 {
          // Surface block varies by biome
          if local_biome == biome_desert {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == biome_tundra {
            chunk.set_block(lx, y, lz, block_snow)
          } else if local_biome == biome_swamp {
            if height < base_height {
              chunk.set_block(lx, y, lz, block_clay)
            } else {
              chunk.set_block(lx, y, lz, block_grass)
            }
          } else if height < base_height - 2 {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == biome_mountains && height > base_height + 18 {
            chunk.set_block(lx, y, lz, block_snow)
          } else {
            chunk.set_block(lx, y, lz, block_grass)
          }
        } else if y < base_height - 4 && y >= height {
          // Water fills low areas
          chunk.set_block(lx, y, lz, block_water)
        } else {
          chunk.set_block(lx, y, lz, block_air)
        }
      }
    }
  }

  // Place trees (second pass so we can check surface)
  for lz in 2..<(chunk_z - 2) {
    for lx in 2..<(chunk_x - 2) {
      let wx = base_wx + lx
      let wz = base_wz + lz
      let local_biome = get_biome_at(wx, wz)
      let height = get_biome_terrain_height(wx, wz, local_biome)
      let surface_block = chunk.get_block(lx, height - 1, lz)

      // Trees on grass
      if height >= base_height - 1 && should_place_tree(wx, wz, local_biome) {
        if surface_block == block_grass || surface_block == block_snow {
          // Place trunk (variable height)
          let trunk_height : Int = if local_biome == biome_forest {
            5
          } else if local_biome == biome_tundra {
            3
          } else {
            4
          }
          for ty in 0..<trunk_height {
            chunk.set_block(lx, height + ty, lz, block_wood)
          }
          // Place leaves (sphere-ish)
          let leaf_base = height + trunk_height - 1
          for ly in 0..<3 {
            let radius = if ly == 2 { 1 } else { 2 }
            let neg_r = -radius
            for dz in neg_r..<=radius {
              for dx in neg_r..<=radius {
                let dist = absf(Float::from_int(dx)) + absf(Float::from_int(dz))
                if dist.to_int() <= radius + 1 {
                  let tx = lx + dx
                  let tz = lz + dz
                  let ty = leaf_base + ly
                  if tx >= 0 &&
                    tx < chunk_x &&
                    tz >= 0 &&
                    tz < chunk_z &&
                    ty < chunk_y {
                    if chunk.get_block(tx, ty, tz) == block_air {
                      chunk.set_block(tx, ty, tz, block_leaves)
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Cactus in desert
      if local_biome == biome_desert && surface_block == block_sand {
        let cactus_check = @math.sinf(Float::from_int(wx) * 1.3 + 2.5) *
          @math.cosf(Float::from_int(wz) * 0.9 + 1.7)
        if cactus_check > 0.75 {
          // Place a cactus (2-3 blocks tall)
          let cactus_h = if cactus_check > 0.85 { 3 } else { 2 }
          for cy in 0..<cactus_h {
            if height + cy < chunk_y {
              chunk.set_block(lx, height + cy, lz, block_cactus)
            }
          }
        }
      }

      // Flowers and tall grass in plains/forest
      if (local_biome == biome_plains || local_biome == biome_forest) &&
        surface_block == block_grass {
        let flower_check = @math.sinf(Float::from_int(wx) * 2.1 + 3.3) *
          @math.cosf(Float::from_int(wz) * 1.7 + 4.1)
        if flower_check > 0.7 && height < chunk_y {
          if flower_check > 0.85 {
            chunk.set_block(lx, height, lz, block_flower_red)
          } else if flower_check > 0.77 {
            chunk.set_block(lx, height, lz, block_flower_yellow)
          } else {
            chunk.set_block(lx, height, lz, block_tall_grass)
          }
        }
      }
    }
  }
}

// ========== World access helpers ==========

// Get chunk from world

///|
pub fn get_chunk(game : Game, cx : Int, cz : Int) -> Chunk? {
  if cx < 0 || cx >= world_chunks_x || cz < 0 || cz >= world_chunks_z {
    None
  } else {
    Some(game.chunks[cz * world_chunks_x + cx])
  }
}

// Get block at world coordinates

///|
pub fn get_world_block(game : Game, wx : Int, wy : Int, wz : Int) -> Int {
  if wy < 0 || wy >= chunk_y {
    return block_air
  }
  let cx = if wx >= 0 { wx / chunk_x } else { (wx - chunk_x + 1) / chunk_x }
  let cz = if wz >= 0 { wz / chunk_z } else { (wz - chunk_z + 1) / chunk_z }
  if cx < 0 || cx >= world_chunks_x || cz < 0 || cz >= world_chunks_z {
    return block_air
  }
  let lx = wx - cx * chunk_x
  let lz = wz - cz * chunk_z
  game.chunks[cz * world_chunks_x + cx].get_block(lx, wy, lz)
}

// Set block at world coordinates

///|
pub fn set_world_block(
  game : Game,
  wx : Int,
  wy : Int,
  wz : Int,
  block : Int,
) -> Unit {
  if wy < 0 || wy >= chunk_y {
    return
  }
  let cx = if wx >= 0 { wx / chunk_x } else { (wx - chunk_x + 1) / chunk_x }
  let cz = if wz >= 0 { wz / chunk_z } else { (wz - chunk_z + 1) / chunk_z }
  if cx < 0 || cx >= world_chunks_x || cz < 0 || cz >= world_chunks_z {
    return
  }
  let lx = wx - cx * chunk_x
  let lz = wz - cz * chunk_z
  let chunk = game.chunks[cz * world_chunks_x + cx]
  chunk.set_block(lx, wy, lz, block)
}

// Check if a block is solid (not air, not water, not flowers/grass)

///|
pub fn is_solid(block : Int) -> Bool {
  block != block_air &&
  block != block_water &&
  block != block_flower_red &&
  block != block_flower_yellow &&
  block != block_tall_grass
}

// Check if a block is transparent (used for face culling)

///|
pub fn is_transparent(block : Int) -> Bool {
  block == block_air ||
  block == block_water ||
  block == block_glass ||
  block == block_leaves ||
  block == block_flower_red ||
  block == block_flower_yellow ||
  block == block_tall_grass ||
  block == block_torch
}

// Check if a block is a decoration (flower, grass, torch)

///|
pub fn is_decoration(block : Int) -> Bool {
  block == block_flower_red ||
  block == block_flower_yellow ||
  block == block_tall_grass ||
  block == block_torch
}

// Check if a block is affected by gravity

///|
pub fn is_gravity_block(block : Int) -> Bool {
  block == block_sand || block == block_gravel
}

// Block name for UI display

///|
pub fn block_name(kind : Int) -> String {
  if kind == block_air {
    "Air"
  } else if kind == block_dirt {
    "Dirt"
  } else if kind == block_grass {
    "Grass"
  } else if kind == block_stone {
    "Stone"
  } else if kind == block_wood {
    "Wood"
  } else if kind == block_leaves {
    "Leaves"
  } else if kind == block_water {
    "Water"
  } else if kind == block_sand {
    "Sand"
  } else if kind == block_glass {
    "Glass"
  } else if kind == block_brick {
    "Brick"
  } else if kind == block_ore_iron {
    "Iron Ore"
  } else if kind == block_ore_gold {
    "Gold Ore"
  } else if kind == block_ore_diamond {
    "Diamond Ore"
  } else if kind == block_snow {
    "Snow"
  } else if kind == block_gravel {
    "Gravel"
  } else if kind == block_planks {
    "Planks"
  } else if kind == block_cobblestone {
    "Cobblestone"
  } else if kind == block_torch {
    "Torch"
  } else if kind == block_bedrock {
    "Bedrock"
  } else if kind == block_flower_red {
    "Red Flower"
  } else if kind == block_flower_yellow {
    "Yellow Flower"
  } else if kind == block_tall_grass {
    "Tall Grass"
  } else if kind == block_cactus {
    "Cactus"
  } else if kind == block_clay {
    "Clay"
  } else {
    "Unknown"
  }
}

// Get tool name

///|
pub fn tool_name(kind : Int) -> String {
  if kind == tool_hand {
    "Hand"
  } else if kind == tool_wooden_pickaxe {
    "Wood Pick"
  } else if kind == tool_stone_pickaxe {
    "Stone Pick"
  } else if kind == tool_iron_pickaxe {
    "Iron Pick"
  } else if kind == tool_wooden_axe {
    "Wood Axe"
  } else if kind == tool_stone_axe {
    "Stone Axe"
  } else if kind == tool_iron_axe {
    "Iron Axe"
  } else if kind == tool_wooden_shovel {
    "Wood Shovel"
  } else if kind == tool_stone_shovel {
    "Stone Shovel"
  } else if kind == tool_iron_shovel {
    "Iron Shovel"
  } else if kind == tool_wooden_sword {
    "Wood Sword"
  } else if kind == tool_stone_sword {
    "Stone Sword"
  } else if kind == tool_iron_sword {
    "Iron Sword"
  } else {
    "Unknown"
  }
}

// Get entity type name

///|
pub fn entity_name(kind : Int) -> String {
  if kind == entity_pig {
    "Pig"
  } else if kind == entity_cow {
    "Cow"
  } else if kind == entity_chicken {
    "Chicken"
  } else if kind == entity_zombie {
    "Zombie"
  } else if kind == entity_skeleton {
    "Skeleton"
  } else if kind == entity_spider {
    "Spider"
  } else {
    "Unknown"
  }
}

// Get biome name

///|
pub fn biome_name(kind : Int) -> String {
  if kind == biome_plains {
    "Plains"
  } else if kind == biome_forest {
    "Forest"
  } else if kind == biome_desert {
    "Desert"
  } else if kind == biome_mountains {
    "Mountains"
  } else if kind == biome_tundra {
    "Tundra"
  } else if kind == biome_swamp {
    "Swamp"
  } else {
    "Unknown"
  }
}

// Get mining time for a block with a given tool

///|
pub fn get_mining_time(block : Int, tool : Int) -> Float {
  let base : Float = if block == block_dirt ||
    block == block_sand ||
    block == block_clay {
    mine_speed_dirt
  } else if block == block_grass || block == block_gravel {
    mine_speed_grass
  } else if block == block_stone || block == block_cobblestone {
    mine_speed_stone
  } else if block == block_wood || block == block_planks {
    mine_speed_wood
  } else if block == block_leaves {
    mine_speed_leaves
  } else if block == block_glass {
    mine_speed_glass
  } else if block == block_brick {
    mine_speed_brick
  } else if block == block_ore_iron ||
    block == block_ore_gold ||
    block == block_ore_diamond {
    mine_speed_ore
  } else if block == block_bedrock {
    mine_speed_bedrock
  } else if block == block_snow {
    mine_speed_dirt
  } else {
    1.0
  }
  // Tool multipliers
  let mult : Float = if tool == tool_hand {
    1.0
  } else if tool == tool_wooden_pickaxe ||
    tool == tool_wooden_axe ||
    tool == tool_wooden_shovel {
    0.6
  } else if tool == tool_stone_pickaxe ||
    tool == tool_stone_axe ||
    tool == tool_stone_shovel {
    0.4
  } else if tool == tool_iron_pickaxe ||
    tool == tool_iron_axe ||
    tool == tool_iron_shovel {
    0.25
  } else {
    1.0
  }
  base * mult
}

// Get drop from breaking a block

///|
pub fn get_block_drop(block : Int) -> Int {
  if block == block_stone {
    block_cobblestone
  } else if block == block_grass {
    block_dirt
  } else if block == block_leaves {
    // Small chance of getting sapling (just give air for now)
    block_air
  } else if block == block_bedrock {
    block_air
  } else if block == block_tall_grass ||
    block == block_flower_red ||
    block == block_flower_yellow {
    block_air
  } else {
    block
  }
}

// Check if entity is hostile

///|
pub fn is_hostile(kind : Int) -> Bool {
  kind == entity_zombie || kind == entity_skeleton || kind == entity_spider
}

// Get max health for entity type

///|
pub fn get_entity_max_health(kind : Int) -> Int {
  if kind == entity_pig {
    pig_health
  } else if kind == entity_cow {
    cow_health
  } else if kind == entity_chicken {
    chicken_health
  } else if kind == entity_zombie {
    zombie_health
  } else if kind == entity_skeleton {
    skeleton_health
  } else if kind == entity_spider {
    spider_health
  } else {
    10
  }
}

// RNG

///|
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

// Random float 0..1

///|
pub fn rand_float(game : Game) -> Float {
  let r = rand_next(game)
  Float::from_int(r % 10000) / 10000.0
}

// Random int in range [low, high)

///|
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    return low
  }
  let r = rand_next(game)
  low + r % (high - low)
}

// Show temporary message

///|
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}

// Check if a face of a block is visible (neighbor is transparent)

///|
pub fn is_face_visible(game : Game, wx : Int, wy : Int, wz : Int) -> Bool {
  let block = get_world_block(game, wx, wy, wz)
  is_transparent(block)
}

// Spawn a particle

///|
pub fn spawn_particle(
  game : Game,
  px : Float,
  py : Float,
  pz : Float,
  pvx : Float,
  pvy : Float,
  pvz : Float,
  r : Int,
  g : Int,
  b : Int,
  size : Float,
  lifetime : Float,
) -> Unit {
  for i in 0..<particle_max {
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = px
      p.y = py
      p.z = pz
      p.vx = pvx
      p.vy = pvy
      p.vz = pvz
      p.color_r = r
      p.color_g = g
      p.color_b = b
      p.size = size
      p.lifetime = lifetime
      p.max_lifetime = lifetime
      return
    }
  }
}

// Spawn block break particles (color provided by caller)

///|
pub fn spawn_break_particles(
  game : Game,
  wx : Int,
  wy : Int,
  wz : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let cx = Float::from_int(wx) + 0.5
  let cy = Float::from_int(wy) + 0.5
  let cz = Float::from_int(wz) + 0.5
  for i in 0..<8 {
    let angle = Float::from_int(i) * 0.785
    let speed : Float = 2.0 + Float::from_int(i % 3)
    let pvx = @math.cosf(angle) * speed
    let pvy : Float = 3.0 + Float::from_int(i % 2) * 2.0
    let pvz = @math.sinf(angle) * speed
    spawn_particle(game, cx, cy, cz, pvx, pvy, pvz, r, g, b, 0.12, 0.8)
  }
}

// Distance between two 3D points

///|
pub fn distance3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  let dx = x2 - x1
  let dy = y2 - y1
  let dz = z2 - z1
  (dx * dx + dy * dy + dz * dz).sqrt()
}

// Horizontal distance (xz plane)

///|
pub fn distance_xz(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x2 - x1
  let dz = z2 - z1
  (dx * dx + dz * dz).sqrt()
}

// Direction facing text

///|
pub fn facing_direction(yaw : Float) -> String {
  let normalized = fmodf(yaw + two_pi, two_pi)
  if normalized < 0.393 || normalized > 5.89 {
    "North"
  } else if normalized < 1.178 {
    "NE"
  } else if normalized < 1.963 {
    "East"
  } else if normalized < 2.749 {
    "SE"
  } else if normalized < 3.534 {
    "South"
  } else if normalized < 4.32 {
    "SW"
  } else if normalized < 5.105 {
    "West"
  } else {
    "NW"
  }
}
