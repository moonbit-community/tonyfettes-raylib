# MoonBit AI 软件工厂实现批量生产 150+ 跨平台游戏

## 从编译器到游戏：软件工厂的广度验证

此前，MoonBit 团队展示了 AI 软件工厂的**深度**能力：AI Agent 在 10 天内从零生成了一个 3.5 万行的 C 编译器（[Fastcc.mbt](https://github.com/moonbit-community/fastcc)），能编译 tcc、QuickJS、SQLite 并通过对应测试，编译速度是 `clang -O0` 的 4 倍。

这里会产生一个疑问：「这种能力是只适用于单个重型项目的特例，还是可以规模化复制的通用产能？」

我们用一个实验解答这个疑问：几乎是 100% 由 AI 批量生产 150 个游戏，游戏类型包括太空交易（Space Trader）到武侠屋顶决斗（Wuxia Rooftop Duel），从塔防（Tower Defense Frontier）到弹球工坊（Pinball Workshop）——覆盖射击、策略、动作、解谜等多种类型。

先公布实验结果：

- **全部可玩**：游戏全部拥有完整的游戏循环、碰撞检测、计分系统和触摸支持，全部不崩溃
- **零 segfault**——没有一个游戏出现内存错误导致的崩溃
- **三端部署**——同一份代码运行在桌面（gcc/clang）、Web（emcc → WASM）和 Android（NDK）上。Raylib 的 MoonBit 绑定库本身，也是 AI 生成的

游戏下载链接：<https://moonbit-community.github.io/tonyfettes-raylib-android-games>

## 生产过程：像工厂一样造软件

### 并行生产：子 Agent 流水线

传统的 AI 编程是"一对一"的：一个开发者坐在 IDE 前，和一个 AI 助手对话，一次写一个项目。这种模式下，150 个游戏意味着 150 次独立的开发会话——即使每个只需要 30 分钟，也要 75 小时。

软件工厂的做法不同。我们利用 AI Agent 的**子 Agent（subagent）** 机制，将游戏生产并行化：主 Agent 接收一批游戏概念（太空交易、塔防、弹球……），然后派生出多个子 Agent，每个子 Agent 独立负责一个游戏的完整生成。这些子 Agent 同时工作，各自编写代码、调用编译器、修复错误，互不干扰。

![子 Agent 工作流](./diagrams/agent_workflow.png)

这就是"工厂"而非"作坊"的核心区别：**生产能力不再受限于单个 Agent 的串行速度，而是取决于你能同时启动多少条生产线**。

每个子 Agent 的工作流程是相同的：

1. 接收游戏概念描述（如"一个太空交易模拟游戏"）
2. 生成完整的 MoonBit 游戏代码
3. 调用 `moon check` / `moon build` 编译，获取类型错误反馈
4. 根据编译错误修正代码，循环直到编译通过
5. 确认游戏可以启动、不崩溃

整个过程中，人类的角色是**工厂操作员**：定义需要生产什么（游戏概念列表），启动生产线（派发子 Agent），然后抽查产出物的质量（试玩几个游戏）。人类不需要审查每一行代码——150 个游戏、每个几百行，逐行审计既不现实也没必要。代码质量由编译器的类型系统和运行时的零崩溃来保证。

### 从桌面到三端：渐进式移植

150 个游戏不是一次性在三个平台上生成的——它遵循了一个渐进式的工厂流程：

**第一阶段：桌面游戏生产。** 子 Agent 并行生成 150+ 个桌面游戏，用 MoonBit 工具链直接运行。这一阶段的验收标准是：编译通过、启动不崩溃。随机抽查若干个，发现大多数都可以正常游玩。

**第二阶段：Web 移植。** 因为 MoonBit 编译到标准 C 代码，从桌面到 Web 的移植几乎是免费的——用 emcc（Emscripten）替代 gcc 即可将同一份 C 代码编译为 WASM，在浏览器中运行。游戏逻辑代码本身不需要任何修改。

链接：<https://bobzhang.github.io/raylib-moonbit-web-games/>

**第三阶段：Android 移植。** 通过 Android NDK 将 C 代码交叉编译为 `.so` 共享库，打包进 APK。这一步借助脚手架工具自动生成 Gradle 配置和 Kotlin 入口点，AI Agent 只需要将游戏代码放入正确的目录结构。

链接：<https://moonbit-community.github.io/tonyfettes-raylib-android-games/>

**第四阶段：触摸适配。** Android 移植后，人工抽查发现部分游戏只支持键盘输入——毕竟它们最初是为桌面生成的。于是再次启动 AI Agent，批量为这些游戏添加触摸支持。Raylib 的 `is_gesture_detected(GestureTap)` 同时响应触屏和鼠标点击，这使得触摸适配通常只需要将键盘事件替换为手势检测，无需重写游戏逻辑。

这个渐进式流程揭示了软件工厂的一个重要特性：**生产不是一次性的，而是可以在已有产出物上持续迭代的**。先生产桌面版本，验证核心逻辑；再移植到 Web 和 Android，扩大分发渠道；最后针对特定平台做适配优化。每一阶段都在前一阶段的基础上增量推进，而非推倒重来。

## 为什么能做到：从 60% 到 100%

### 软件完成率的三个关键节点

AI 生成代码并不难——难的是让生成的代码**真正可用**。在软件工厂的实践中，我们观察到三个关键的完成率节点：

- **60%**：AI 生成了"看起来像代码"的文本，但无法通过编译。模块之间的接口不匹配，类型不一致，函数签名对不上。Cursor 用 AI 生成 300 万行浏览器代码就停在了这个节点——代码量巨大，但无法编译，功能为零。
- **90%**：代码可以编译运行，但存在逻辑错误、边界条件遗漏、平台兼容性问题。游戏能启动但会在特定操作下崩溃，或者在不同设备上表现不一致。
- **100%**：代码在所有目标平台上稳定运行，逻辑正确，用户体验完整。

MoonBit 软件工厂的核心能力，就是把 AI 的产出从 60% 推进到 100%。

### 从 60% 到 90%：类型系统即质量门禁

大多数 AI 编程工具卡在 60% 节点的原因是：AI 生成的代码"看起来对"但实际有结构性错误，而编程语言没有提供足够强的编译期检查来捕获这些错误。

Python 和 JavaScript 没有编译期检查，错误要到运行时才暴露。C/C++ 有编译检查但类型系统太弱——隐式类型转换、指针算术、未定义行为，这些都是编译器无法拦截的错误来源。

MoonBit 的设计从根本上不同。强类型系统 + 模式匹配 + 无隐式转换，意味着 AI 生成的每一行代码都必须通过编译器的严格检查：

- **类型不匹配**：传入了 `Int` 但函数期望 `Float`——编译错误
- **遗漏的分支**：`match` 表达式没有覆盖所有情况——编译警告
- **未初始化的字段**：结构体构造时缺少字段——编译错误
- **无隐式转换**：不会出现 JavaScript 式的 `"1" + 1 = "11"` 意外行为

这意味着在 150 个游戏的批量生产中，即使人类无法审查每一行代码，编译器也会自动拦截结构性错误。AI Agent 每次编译都会获得即时、明确的反馈，并据此修正——这个循环在每个子 Agent 内部自动执行，不需要人类介入。

这就是 150 个游戏零 segfault 的根本原因：**不安全的代码根本无法通过编译**。

### 从 90% 到 100%：编译速度与反馈回路

代码能编译不等于代码正确。从 90% 到 100% 的跨越，靠的是快速的**验证反馈回路**：AI 修改代码 → 编译 → 运行测试 → 看结果 → 再修改。这个循环执行得越快，AI 越能有效地收敛到正确的实现。

在批量生产 150 个游戏的场景下，编译速度的重要性被放大了数十倍。AI 一天可能跑上千次编译——如果每次编译需要 30 秒（如 Rust），一千次就是 8 小时的纯等待；而 MoonBit 的编译速度快于 Rust 10 到 100 倍，这意味着同样的迭代次数只需要几分钟。

**编译速度不是开发体验的细节优化，而是软件工厂的产能瓶颈**。当生产规模从 1 个项目扩展到 150 个时，每一毫秒的编译时间差异都会被放大到可感知的产能差距。

## 编译到 C：跨平台的工厂密码

MoonBit 编译到标准 C 代码——这个设计决策是跨平台规模化的关键。

### 一份代码，三个平台

同一份 AI 生成的 MoonBit 代码：

- 用 **gcc/clang** 编译，在桌面运行
- 用 **emcc** 编译到 WASM，在浏览器运行
- 用 **Android NDK** 交叉编译为 `.so`，在手机运行

不需要为每个平台重写代码，不需要平台特定的适配层。AI 只需要生成一次，工厂的构建流水线负责把它变成三个平台的可执行程序。这就是 150 个游戏能同时跨三端的原因——**工厂的复用能力来自编译目标的可移植性**。

### 全链 AI 生成

值得强调的是：不仅游戏代码是 AI 生成的，连基础设施——Raylib 的 MoonBit 绑定库（[tonyfettes/raylib](https://mooncakes.io/docs/tonyfettes/raylib/)）——也是 AI 生成的。这意味着从底层库到上层应用，整条链路都是软件工厂的产出物。基础设施本身也可以被工厂化生产，这是一种自举式的能力积累。

### 构建链路

![Compilation pipeline](diagrams/compile.png)

从 MoonBit 源码到手机上的 APK，是一条确定性的流水线：

1. **MoonBit → C**：MoonBit 编译器将 `.mbt` 源文件编译为标准 C 代码
2. **C → .so**：Android NDK 的交叉编译器将 C 代码连同 Raylib 源码编译为共享库
3. **打包 APK**：Gradle 将 `.so` 打包进 APK

MoonBit 生态提供了脚手架工具，一键生成完整的 Android 项目：

```bash
moon install tonyfettes/create-moonbit-raylib-android-app
create-moonbit-raylib-android-app MyFlappyBird
```

生成的项目中，AI Agent 只需关心一个目录：**`app/src/main/moonbit/`**。Gradle 配置、CMake 构建、Kotlin 入口点全部由脚手架处理。构建和部署也只需一行命令：

```bash
cd MyFlappyBird && ./gradlew assembleDebug --no-daemon
```

![Architecture of a MoonBit Raylib Android app](diagrams/call-chain.png)

在运行时，轻量的 `MainActivity` 加载 `.so` 库，NDK 胶水代码启动原生端，Raylib 初始化 OpenGL ES 上下文，然后调用 `main()`——即 MoonBit 的 `fn main` 编译成的 C 函数。

## 产出物剖析：以 Flappy Bird 为例

让我们打开 150 个工厂产出物中的一个——Flappy Bird——看看 AI 生成的代码是什么样的。

AI 将游戏状态拆分为三个结构体——`Bird`（动态状态）、`Pipe`（障碍物）和 `Game`（全局容器）：

```moonbit
///|
priv struct Bird {
  mut y : Float
  mut velocity : Float
}

///|
priv struct Pipe {
  mut x : Float
  mut gap_y : Float
  mut scored : Bool
}

///|
priv struct Game {
  sw : Float
  sh : Float
  bird_x : Float
  bird : Bird
  bird_radius : Float
  gravity : Float
  jump_force : Float
  pipes : Array[Pipe]
  pipe_width : Float
  gap_size : Float
  pipe_speed : Float
  pipe_spacing : Float
  mut score : Int
  mut game_over : Bool
}
```

值得注意的设计决策——全部由 AI 自主做出：最小化可变状态（`Bird` 只有两个 `mut` 字段）；所有大小从屏幕尺寸派生（适配任何分辨率）；只用 4 个 `Pipe` 对象实现无限滚动（滚出左边缘的水管被重置坐标到右侧）。

核心的 `update` 函数包含物理模拟、碰撞检测和计分逻辑：

```moonbit
///|
fn update(game : Game, dt : Float) -> Unit {
  if game.game_over {
    if @raylib.is_gesture_detected(@raylib.GestureTap) {
      reset(game)
    }
    return
  }

  if @raylib.is_gesture_detected(@raylib.GestureTap) {
    game.bird.velocity = game.jump_force
  }
  game.bird.velocity += game.gravity * dt
  game.bird.y += game.bird.velocity * dt

  if game.bird.y < game.bird_radius || game.bird.y > game.sh - game.bird_radius {
    game.game_over = true
  }

  for pipe in game.pipes {
    pipe.x -= game.pipe_speed * dt
    if pipe.x < -game.pipe_width {
      pipe.x += Float::from_int(game.pipes.length()) * game.pipe_spacing
      pipe.gap_y = random_gap_y(game)
      pipe.scored = false
    }

    // AABB 碰撞检测
    if game.bird_x + game.bird_radius > pipe.x &&
      game.bird_x - game.bird_radius < pipe.x + game.pipe_width {
      if game.bird.y - game.bird_radius < pipe.gap_y - game.gap_size / 2.0 ||
        game.bird.y + game.bird_radius > pipe.gap_y + game.gap_size / 2.0 {
        game.game_over = true
      }
    }

    if not(pipe.scored) && pipe.x + game.pipe_width < game.bird_x {
      game.score += 1
      pipe.scored = true
    }
  }
}
```

所有运动量乘以 `dt`（帧率无关物理）；`is_gesture_detected(GestureTap)` 同时响应触屏和鼠标——同一份代码从桌面移植到手机无需修改游戏逻辑。

完整的 Flappy Bird——重力、水管、碰撞、计分、游戏结束和重启——约 200 行代码。AI 生成，直接可玩。

![Flappy Bird gameplay](screenshots/step3.gif)

## 总结

从 C 编译器（3.5 万行、10 天）到 150+ 个游戏（子 Agent 并行生产、三端部署），MoonBit AI 软件工厂展示了两种互补的能力：

- **深度**：AI 能在严谨的工程约束下完成复杂系统（编译器、PDF 工具、Wasm 虚拟机）
- **广度**：同一套工厂基础设施能规模化量产——150 个游戏，100% AI 生成代码，零崩溃

这背后的关键不是某个 AI 模型特别强，而是 MoonBit 提供了一套让 AI 能可靠工作的工程基础设施：

1. **AI 原生语言设计**——强类型系统在编译期拦截错误，AI 每次生成都能获得即时、结构化的反馈
2. **编译到 C 的可移植性**——一份代码自动适配桌面、Web、Android 三个平台
3. **极速编译**——AI 可以在短时间内执行大量编译-修正循环，快速收敛到正确实现
4. **可编程工具链**——脚手架、构建系统、IDE 工具全部可被 Agent 程序化调用，形成自动化的生产流水线

当 Cursor 用 AI 生成 300 万行浏览器代码却无法编译时，MoonBit 的 150 个游戏全部通过编译、全部可以运行。差距不在 AI 模型，而在工厂基础设施。

软件工厂的意义不止于"AI 能写代码"，而在于它把软件生产变成了一条**可重复、可验证、可规模化的流水线**。人类定义需求和方向，AI 在工程约束下完成构建与迭代。从编译器到游戏，这条流水线已经在运转。

- [tonyfettes/raylib](https://mooncakes.io/docs/tonyfettes/raylib/) —— MoonBit 的 Raylib 绑定库（AI 生成）
- [Selene](https://github.com/moonbit-community/selene) —— MoonBit 实验性游戏引擎，支持 Canvas2D 和 Raylib 后端
- [MoonBit 文档](https://docs.moonbitlang.com/) —— 语言详细文档
