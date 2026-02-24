///|
const EmojiPerWidth : Int = 8

///|
const EmojiPerHeight : Int = 4

// Array of individual emoji strings (180 emojis)

///|
let emoji_codepoints : Array[String] = [
  // Row 1: faces and smileys
  "\u{1F300}", "\u{1F600}", "\u{1F602}", "\u{1F923}", "\u{1F603}", "\u{1F606}", "\u{1F609}",
  "\u{1F60B}", "\u{1F60E}", "\u{1F60D}", "\u{1F618}", "\u{1F617}", "\u{1F619}", "\u{1F61A}",
  "\u{1F642}", "\u{1F917}", "\u{1F929}", "\u{1F914}", "\u{1F928}", "\u{1F610}", "\u{1F611}",
  "\u{1F636}", "\u{1F644}", "\u{1F60F}", "\u{1F623}", "\u{1F625}", "\u{1F62E}", "\u{1F910}",
  "\u{1F62F}", "\u{1F62A}", "\u{1F62B}", "\u{1F634}", "\u{1F60C}", "\u{1F61B}", "\u{1F61D}",
  "\u{1F924}", "\u{1F612}", "\u{1F615}", "\u{1F643}", "\u{1F911}", "\u{1F632}", "\u{1F641}",
  "\u{1F616}", "\u{1F61E}", "\u{1F61F}", "\u{1F624}", "\u{1F622}", "\u{1F62D}", "\u{1F626}",
  "\u{1F629}", "\u{1F92F}", "\u{1F62C}", "\u{1F630}", "\u{1F631}", "\u{1F633}", "\u{1F92A}",
  "\u{1F635}", "\u{1F621}", "\u{1F620}", "\u{1F92C}", "\u{1F637}", "\u{1F912}", "\u{1F915}",
  "\u{1F922}", "\u{1F92E}", "\u{1F927}", "\u{1F607}", "\u{1F920}", "\u{1F92B}", "\u{1F92D}",
  "\u{1F9D0}", "\u{1F913}", "\u{1F608}", "\u{1F47F}", "\u{1F479}", "\u{1F47A}", "\u{1F480}",
  "\u{1F47B}", "\u{1F47D}", "\u{1F47E}", "\u{1F916}", "\u{1F4A9}", "\u{1F63A}", "\u{1F638}",
  "\u{1F639}", "\u{1F63B}", "\u{1F63D}", "\u{1F640}", "\u{1F63F}",
  // Row 2: plants, food, etc.
   "\u{1F33E}", "\u{1F33F}", "\u{1F340}", "\u{1F343}", "\u{1F347}", "\u{1F353}",
  "\u{1F95D}", "\u{1F345}", "\u{1F965}", "\u{1F951}", "\u{1F346}", "\u{1F954}", "\u{1F955}",
  "\u{1F33D}", "\u{1F336}", "\u{1F952}", "\u{1F966}", "\u{1F344}", "\u{1F95C}", "\u{1F330}",
  "\u{1F35E}", "\u{1F950}", "\u{1F956}", "\u{1F968}", "\u{1F95E}", "\u{1F9C0}", "\u{1F356}",
  "\u{1F357}", "\u{1F969}", "\u{1F953}", "\u{1F354}", "\u{1F35F}", "\u{1F355}", "\u{1F32D}",
  "\u{1F96A}", "\u{1F32E}", "\u{1F32F}", "\u{1F959}", "\u{1F95A}", "\u{1F373}", "\u{1F958}",
  "\u{1F372}", "\u{1F963}", "\u{1F957}", "\u{1F37F}", "\u{1F96B}", "\u{1F371}", "\u{1F358}",
  "\u{1F35D}", "\u{1F360}", "\u{1F362}", "\u{1F365}", "\u{1F361}", "\u{1F95F}", "\u{1F961}",
  "\u{1F366}", "\u{1F36A}", "\u{1F382}", "\u{1F370}", "\u{1F967}", "\u{1F36B}", "\u{1F36F}",
  "\u{1F37C}", "\u{1F95B}", "\u{1F375}", "\u{1F376}", "\u{1F37E}", "\u{1F377}", "\u{1F37B}",
  "\u{1F942}", "\u{1F943}", "\u{1F964}", "\u{1F962}",
  // Row 3: body parts, hearts, misc
   "\u{1F441}", "\u{1F445}", "\u{1F444}", "\u{1F48B}", "\u{1F498}", "\u{1F493}",
  "\u{1F497}", "\u{1F499}", "\u{1F49B}", "\u{1F9E1}", "\u{1F49C}", "\u{1F5A4}", "\u{1F49D}",
  "\u{1F49F}", "\u{1F48C}", "\u{1F4A4}", "\u{1F4A2}", "\u{1F4A3}",
]

// Message struct with text and language

///|
struct Message {
  text : String
  language : String
}

///|
let messages : Array[Message] = [
  // German
  {
    text: "Falsches \u{00DC}ben von Xylophonmusik qu\u{00E4}lt jeden gr\u{00F6}\u{00DF}eren Zwerg",
    language: "German",
  },
  {
    text: "Bei\u{00DF} nicht in die Hand, die dich f\u{00FC}ttert.",
    language: "German",
  },
  {
    text: "Au\u{00DF}erordentliche \u{00DC}bel erfordern au\u{00DF}erordentliche Mittel.",
    language: "German",
  },
  // Armenian
  {
    text: "\u{053F}\u{0580}\u{0576}\u{0561}\u{0574} \u{0561}\u{057A}\u{0561}\u{056F}\u{056B} \u{0578}\u{0582}\u{057F}\u{0565}\u{056C} \u{0587} \u{056B}\u{0576}\u{056E}\u{056B} \u{0561}\u{0576}\u{0570}\u{0561}\u{0576}\u{0563}\u{056B}\u{057D}\u{057F} \u{0579}\u{0568}\u{0576}\u{0565}\u{0580}",
    language: "Armenian",
  },
  {
    text: "\u{0535}\u{0580}\u{0562} \u{0578}\u{0580} \u{056F}\u{0561}\u{0581}\u{056B}\u{0576}\u{0568} \u{0565}\u{056F}\u{0561}\u{0582} \u{0561}\u{0576}\u{057F}\u{0561}\u{057C}, \u{056E}\u{0561}\u{057C}\u{0565}\u{0580}\u{0568} \u{0561}\u{057D}\u{0561}\u{0581}\u{056B}\u{0576}... \u{00AB}\u{053F}\u{0578}\u{057F}\u{0568} \u{0574}\u{0565}\u{0580}\u{0578}\u{0576}\u{0581}\u{056B}\u{0581} \u{0567}:\u{00BB}",
    language: "Armenian",
  },
  {
    text: "\u{0533}\u{0561}\u{057C}\u{0568}\u{055D} \u{0563}\u{0561}\u{0580}\u{0576}\u{0561}\u{0576}, \u{0571}\u{056B}\u{0582}\u{0576}\u{0568}\u{055D} \u{0571}\u{0574}\u{057C}\u{0561}\u{0576}",
    language: "Armenian",
  },
  // Polish
  {
    text: "Je\u{017C}u kl\u{0105}tw, sp\u{0142}\u{00F3}d\u{017A} Finom cz\u{0119}\u{015B}\u{0107} gry ha\u{0144}b!",
    language: "Polish",
  },
  {
    text: "Dobrymi ch\u{0119}ciami jest piek\u{0142}o wybrukowane.",
    language: "Polish",
  },
  // Romanian
  {
    text: "\u{00CE}\u{021B}i mul\u{021B}umesc c\u{0103} ai ales raylib.\n\u{0218}i sper s\u{0103} ai o zi bun\u{0103}!",
    language: "Romanian",
  },
  // Russian
  {
    text: "\u{042D}\u{0445}, \u{0447}\u{0443}\u{0436}\u{0430}\u{043A}, \u{043E}\u{0431}\u{0449}\u{0438}\u{0439} \u{0441}\u{044A}\u{0451}\u{043C} \u{0446}\u{0435}\u{043D} \u{0448}\u{043B}\u{044F}\u{043F} (\u{044E}\u{0444}\u{0442}\u{044C}) \u{0432}\u{0434}\u{0440}\u{044B}\u{0437}\u{0433}!",
    language: "Russian",
  },
  {
    text: "\u{042F} \u{043B}\u{044E}\u{0431}\u{043B}\u{044E} raylib!",
    language: "Russian",
  },
  {
    text: "\u{041C}\u{043E}\u{043B}\u{0447}\u{0438}, \u{0441}\u{043A}\u{0440}\u{044B}\u{0432}\u{0430}\u{0439}\u{0441}\u{044F} \u{0438} \u{0442}\u{0430}\u{0438}\n\u{0418} \u{0447}\u{0443}\u{0432}\u{0441}\u{0442}\u{0432}\u{0430} \u{0438} \u{043C}\u{0435}\u{0447}\u{0442}\u{044B} \u{0441}\u{0432}\u{043E}\u{0438} \u{2013}\n\u{041F}\u{0443}\u{0441}\u{043A}\u{0430}\u{0439} \u{0432} \u{0434}\u{0443}\u{0448}\u{0435}\u{0432}\u{043D}\u{043E}\u{0439} \u{0433}\u{043B}\u{0443}\u{0431}\u{0438}\u{043D}\u{0435}\n\u{0418} \u{0432}\u{0441}\u{0445}\u{043E}\u{0434}\u{044F}\u{0442} \u{0438} \u{0437}\u{0430}\u{0439}\u{0434}\u{0443}\u{0442} \u{043E}\u{043D}\u{0435}\n\u{041A}\u{0430}\u{043A} \u{0437}\u{0432}\u{0435}\u{0437}\u{0434}\u{044B} \u{044F}\u{0441}\u{043D}\u{044B}\u{0435} \u{0432} \u{043D}\u{043E}\u{0447}\u{0438}-\n\u{041B}\u{044E}\u{0431}\u{0443}\u{0439}\u{0441}\u{044F} \u{0438}\u{043C}\u{0438} \u{2013} \u{0438} \u{043C}\u{043E}\u{043B}\u{0447}\u{0438}.",
    language: "Russian",
  },
  // French
  {
    text: "Voix ambigu\u{00EB} d\u{2019}un c\u{0153}ur qui au z\u{00E9}phyr pr\u{00E9}f\u{00E8}re les jattes de kiwi",
    language: "French",
  },
  // Spanish
  {
    text: "Benjam\u{00ED}n pidi\u{00F3} una bebida de kiwi y fresa; No\u{00E9}, sin verg\u{00FC}enza, la m\u{00E1}s exquisita champa\u{00F1}a del men\u{00FA}.",
    language: "Spanish",
  },
  // Greek
  {
    text: "\u{03A4}\u{03B1}\u{03C7}\u{03AF}\u{03C3}\u{03C4}\u{03B7} \u{03B1}\u{03BB}\u{03CE}\u{03C0}\u{03B7}\u{03BE} \u{03B2}\u{03B1}\u{03C6}\u{03AE}\u{03C2} \u{03C8}\u{03B7}\u{03BC}\u{03AD}\u{03BD}\u{03B7} \u{03B3}\u{03B7}, \u{03B4}\u{03C1}\u{03B1}\u{03C3}\u{03BA}\u{03B5}\u{03BB}\u{03AF}\u{03B6}\u{03B5}\u{03B9} \u{03C5}\u{03C0}\u{03AD}\u{03C1} \u{03BD}\u{03C9}\u{03B8}\u{03C1}\u{03BF}\u{03CD} \u{03BA}\u{03C5}\u{03BD}\u{03CC}\u{03C2}",
    language: "Greek",
  },
  {
    text: "\u{0397} \u{03BA}\u{03B1}\u{03BB}\u{03CD}\u{03C4}\u{03B5}\u{03C1}\u{03B7} \u{03AC}\u{03BC}\u{03C5}\u{03BD}\u{03B1} \u{03B5}\u{03AF}\u{03BD}\u{03B1}\u{03B9} \u{03B7} \u{03B5}\u{03C0}\u{03AF}\u{03B8}\u{03B5}\u{03C3}\u{03B7}.",
    language: "Greek",
  },
  {
    text: "\u{03A7}\u{03C1}\u{03CC}\u{03BD}\u{03B9}\u{03B1} \u{03BA}\u{03B1}\u{03B9} \u{03B6}\u{03B1}\u{03BC}\u{03AC}\u{03BD}\u{03B9}\u{03B1}!",
    language: "Greek",
  },
  {
    text: "\u{03A0}\u{03CE}\u{03C2} \u{03C4}\u{03B1} \u{03C0}\u{03B1}\u{03C2} \u{03C3}\u{03AE}\u{03BC}\u{03B5}\u{03C1}\u{03B1};",
    language: "Greek",
  },
  // Chinese
  {
    text: "\u{6211}\u{80FD}\u{541E}\u{4E0B}\u{73BB}\u{7483}\u{800C}\u{4E0D}\u{4F24}\u{8EAB}\u{4F53}\u{3002}",
    language: "Chinese",
  },
  { text: "\u{4F60}\u{5403}\u{4E86}\u{5417}\u{FF1F}", language: "Chinese" },
  { text: "\u{4E0D}\u{4F5C}\u{4E0D}\u{6B7B}\u{3002}", language: "Chinese" },
  { text: "\u{6700}\u{8FD1}\u{597D}\u{5417}\u{FF1F}", language: "Chinese" },
  {
    text: "\u{585E}\u{7FC1}\u{5931}\u{9A6C}\u{FF0C}\u{7109}\u{77E5}\u{975E}\u{798F}\u{3002}",
    language: "Chinese",
  },
  {
    text: "\u{5343}\u{519B}\u{6613}\u{5F97}, \u{4E00}\u{5C06}\u{96BE}\u{6C42}",
    language: "Chinese",
  },
  {
    text: "\u{4E07}\u{4E8B}\u{5F00}\u{5934}\u{96BE}\u{3002}",
    language: "Chinese",
  },
  {
    text: "\u{98CE}\u{65E0}\u{5E38}\u{987A}\u{FF0C}\u{5175}\u{65E0}\u{5E38}\u{80DC}\u{3002}",
    language: "Chinese",
  },
  {
    text: "\u{6D3B}\u{5230}\u{8001}\u{FF0C}\u{5B66}\u{5230}\u{8001}\u{3002}",
    language: "Chinese",
  },
  {
    text: "\u{4E00}\u{8A00}\u{65E2}\u{51FA}\u{FF0C}\u{9A77}\u{9A6C}\u{96BE}\u{8FFD}\u{3002}",
    language: "Chinese",
  },
  {
    text: "\u{8DEF}\u{9065}\u{77E5}\u{9A6C}\u{529B}\u{FF0C}\u{65E5}\u{4E45}\u{89C1}\u{4EBA}\u{5FC3}",
    language: "Chinese",
  },
  {
    text: "\u{6709}\u{7406}\u{8D70}\u{904D}\u{5929}\u{4E0B}\u{FF0C}\u{65E0}\u{7406}\u{5BF8}\u{6B65}\u{96BE}\u{884C}\u{3002}",
    language: "Chinese",
  },
  // Japanese
  {
    text: "\u{731F}\u{3082}\u{6728}\u{304B}\u{3089}\u{843D}\u{3061}\u{308B}",
    language: "Japanese",
  },
  {
    text: "\u{4E80}\u{306E}\u{7532}\u{3088}\u{308A}\u{5E74}\u{306E}\u{529F}",
    language: "Japanese",
  },
  {
    text: "\u{3046}\u{3089}\u{3084}\u{307E}\u{3057}  \u{601D}\u{3072}\u{5207}\u{308B}\u{6642}  \u{732B}\u{306E}\u{604B}",
    language: "Japanese",
  },
  {
    text: "\u{864E}\u{7A74}\u{306B}\u{5165}\u{3089}\u{305A}\u{3093}\u{3070}\u{864E}\u{5B50}\u{3092}\u{5F97}\u{305A}\u{3002}",
    language: "Japanese",
  },
  {
    text: "\u{4E8C}\u{5154}\u{3092}\u{8FFD}\u{3046}\u{8005}\u{306F}\u{4E00}\u{5154}\u{3092}\u{3082}\u{5F97}\u{305A}\u{3002}",
    language: "Japanese",
  },
  {
    text: "\u{99AC}\u{9E7F}\u{306F}\u{6B7B}\u{306A}\u{306A}\u{304D}\u{3083}\u{6CBB}\u{3089}\u{306A}\u{3044}\u{3002}",
    language: "Japanese",
  },
  {
    text: "\u{67AF}\u{91CE}\u{8DEF}\u{306B}\u{3000}\u{5F71}\u{304B}\u{3055}\u{306A}\u{308A}\u{3066}\u{3000}\u{308F}\u{304B}\u{308C}\u{3051}\u{308A}",
    language: "Japanese",
  },
  {
    text: "\u{7E70}\u{308A}\u{8FD4}\u{3057}\u{9EA6}\u{306E}\u{7560}\u{7E2B}\u{3075}\u{80E1}\u{8776}\u{54C9}",
    language: "Japanese",
  },
  // Korean
  {
    text: "\u{C544}\u{B4DD}\u{D55C} \u{BC14}\u{B2E4} \u{C704}\u{C5D0} \u{AC08}\u{B9E4}\u{AE30} \u{B450}\u{C5C7} \u{B0A0}\u{C544} \u{B3C8}\u{B2E4}.\n\u{B108}\u{D6CC}\u{B108}\u{D6CC} \u{C2DC}\u{B97C} \u{C4F4}\u{B2E4}. \u{BAA8}\u{B974}\u{B294} \u{B098}\u{B77C} \u{AE00}\u{C790}\u{B2E4}.\n\u{B110}\u{B530}\u{B780} \u{D558}\u{B298} \u{BCD5}\u{D310}\u{C5D0} \u{B098}\u{B3C4} \u{AC19}\u{C774} \u{C2DC}\u{B97C} \u{C4F4}\u{B2E4}.",
    language: "Korean",
  },
  {
    text: "\u{C81C} \u{B208}\u{C5D0} \u{C548}\u{ACBD}\u{C774}\u{B2E4}",
    language: "Korean",
  },
  {
    text: "\u{AFE9} \u{BA39}\u{ACE0} \u{C54C} \u{BA39}\u{B294}\u{B2E4}",
    language: "Korean",
  },
  {
    text: "\u{B85C}\u{B9C8}\u{B294} \u{D558}\u{B8E8}\u{C544}\u{CE68}\u{C5D0} \u{C774}\u{B8E8}\u{C5B4}\u{C9C4} \u{AC83}\u{C774} \u{C544}\u{B2C8}\u{B2E4}",
    language: "Korean",
  },
  {
    text: "\u{ACE0}\u{C0DD} \u{B05D}\u{C5D0} \u{B099}\u{C774} \u{C628}\u{B2E4}",
    language: "Korean",
  },
  {
    text: "\u{AC1C}\u{CC9C}\u{C5D0}\u{C11C} \u{C6A9} \u{B09C}\u{B2E4}",
    language: "Korean",
  },
  { text: "\u{C548}\u{B155}\u{D558}\u{C138}\u{C694}?", language: "Korean" },
  {
    text: "\u{B9CC}\u{B098}\u{C11C} \u{BC18}\u{AC11}\u{C2B5}\u{B2C8}\u{B2E4}",
    language: "Korean",
  },
  {
    text: "\u{D55C}\u{AD6D}\u{B9D0} \u{D558}\u{C2E4} \u{C904} \u{C544}\u{C138}\u{C694}?",
    language: "Korean",
  },
]

// Emoji data structure

///|
struct EmojiData {
  mut index : Int // Index into emoji_codepoints array
  mut message : Int // Message index
  mut color : @raylib.Color // Emoji color
}

///|
fn draw_text_boxed(
  font : @raylib.Font,
  text : String,
  rec : @raylib.Rectangle,
  font_size : Float,
  spacing : Float,
  word_wrap : Bool,
  tint : @raylib.Color,
) -> Unit {
  // Convert text to codepoints for proper iteration
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  let base_size_info = @raylib.measure_text_ex(font, "A", font_size, spacing)
  let scale_factor = font_size / base_size_info.y
  let base_size = base_size_info.y / scale_factor
  let mut text_offset_y : Float = 0.0
  let mut text_offset_x : Float = 0.0
  let measure_state = 0
  let draw_state = 1
  let mut state = if word_wrap { measure_state } else { draw_state }
  let mut start_line = -1
  let mut end_line = -1
  let mut lastk = -1
  let mut i = 0
  let mut k = 0
  while i < length {
    let codepoint = codepoints[i]
    let glyph_info = @raylib.get_glyph_info(font, codepoint)
    let glyph_rec = @raylib.get_glyph_atlas_rec(font, codepoint)
    let mut glyph_width : Float = 0.0
    if codepoint != '\n'.to_int() {
      glyph_width = if glyph_info.advance_x == 0 {
        glyph_rec.width * scale_factor
      } else {
        Float::from_int(glyph_info.advance_x) * scale_factor
      }
      if i + 1 < length {
        glyph_width = glyph_width + spacing
      }
    }
    if state == measure_state {
      if codepoint == ' '.to_int() ||
        codepoint == '\t'.to_int() ||
        codepoint == '\n'.to_int() {
        end_line = i
      }
      if text_offset_x + glyph_width > rec.width {
        end_line = if end_line < 1 { i } else { end_line }
        if i == end_line {
          end_line = end_line - 1
        }
        if start_line + 1 == end_line {
          end_line = i - 1
        }
        state = draw_state
      } else if i + 1 == length {
        end_line = i
        state = draw_state
      } else if codepoint == '\n'.to_int() {
        state = draw_state
      }
      if state == draw_state {
        text_offset_x = 0.0
        i = start_line
        glyph_width = 0.0
        let tmp = lastk
        lastk = k - 1
        k = tmp
      }
    } else {
      if codepoint == '\n'.to_int() {
        if not(word_wrap) {
          text_offset_y += (base_size + base_size / (2.0 : Float)) *
            scale_factor
          text_offset_x = 0.0
        }
      } else {
        if not(word_wrap) && text_offset_x + glyph_width > rec.width {
          text_offset_y += (base_size + base_size / (2.0 : Float)) *
            scale_factor
          text_offset_x = 0.0
        }
        if text_offset_y + base_size * scale_factor > rec.height {
          break
        }
        if codepoint != ' '.to_int() && codepoint != '\t'.to_int() {
          @raylib.draw_text_codepoint(
            font,
            codepoint,
            @raylib.Vector2::new(rec.x + text_offset_x, rec.y + text_offset_y),
            font_size,
            tint,
          )
        }
      }
      if word_wrap && i == end_line {
        text_offset_y += (base_size + base_size / (2.0 : Float)) * scale_factor
        text_offset_x = 0.0
        start_line = end_line
        end_line = -1
        glyph_width = 0.0
        k = lastk
        state = measure_state
      }
    }
    if text_offset_x != 0.0 || codepoint != ' '.to_int() {
      text_offset_x += glyph_width
    }
    i += 1
    k += 1
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_unicode")
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint | @raylib.FlagVsyncHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - unicode",
  )

  // Load font resources
  let font_default = @raylib.load_font("resources/dejavu.fnt")
  let font_asian = @raylib.load_font("resources/noto_cjk.fnt")
  let font_emoji = @raylib.load_font("resources/symbola.fnt")

  let mut hovered_pos = @raylib.Vector2::new(0.0, 0.0)
  let mut selected_pos = @raylib.Vector2::new(0.0, 0.0)

  // Initialize emoji array
  let emoji_count = EmojiPerWidth * EmojiPerHeight
  let emoji : Array[EmojiData] = Array::make(emoji_count, {
    index: 0,
    message: 0,
    color: @raylib.lightgray,
  })
  // Initialize with distinct objects
  for i = 0; i < emoji_count; i = i + 1 {
    emoji[i] = { index: 0, message: 0, color: @raylib.lightgray }
  }

  let mut hovered = -1
  let mut selected = -1

  // Randomize initial emojis
  fn randomize_emoji() {
    hovered = -1
    selected = -1
    let start = @raylib.get_random_value(45, 360)
    for i = 0; i < emoji_count; i = i + 1 {
      emoji[i].index = @raylib.get_random_value(
        0,
        emoji_codepoints.length() - 1,
      )
      let hue = Float::from_int(start * (i + 1) % 360)
      emoji[i].color = @raylib.fade(@raylib.color_from_hsv(hue, 0.6, 0.85), 0.8)
      emoji[i].message = @raylib.get_random_value(0, messages.length() - 1)
    }
  }

  randomize_emoji()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      randomize_emoji()
    }

    // Set the selected emoji
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
      hovered != -1 &&
      hovered != selected {
      selected = hovered
      selected_pos = hovered_pos
    }

    let mouse = @raylib.get_mouse_position()
    let mut position = @raylib.Vector2::new(28.8, 10.0)
    hovered = -1

    let font_emoji_base_size = @raylib.get_font_base_size(font_emoji)
    let base_size_f : Float = Float::from_int(font_emoji_base_size)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw random emojis in the background
    for i = 0; i < emoji_count; i = i + 1 {
      let txt = emoji_codepoints[emoji[i].index]
      let emoji_rect = @raylib.Rectangle::new(
        position.x,
        position.y,
        base_size_f,
        base_size_f,
      )
      if not(@raylib.check_collision_point_rec(mouse, emoji_rect)) {
        let tint = if selected == i {
          emoji[i].color
        } else {
          @raylib.fade(@raylib.lightgray, 0.4)
        }
        @raylib.draw_text_ex(font_emoji, txt, position, base_size_f, 1.0, tint)
      } else {
        @raylib.draw_text_ex(
          font_emoji,
          txt,
          position,
          base_size_f,
          1.0,
          emoji[i].color,
        )
        hovered = i
        hovered_pos = position
      }
      if i != 0 && i % EmojiPerWidth == 0 {
        position = @raylib.Vector2::new(28.8, position.y + base_size_f + 24.25)
      } else {
        position = @raylib.Vector2::new(
          position.x + base_size_f + 28.8,
          position.y,
        )
      }
    }

    // Draw the message when an emoji is selected
    if selected != -1 {
      let message_idx = emoji[selected].message
      let horizontal_padding : Float = 20.0
      let vertical_padding : Float = 30.0

      // Set correct font for asian languages
      let lang = messages[message_idx].language
      let font = if lang == "Chinese" || lang == "Korean" || lang == "Japanese" {
        font_asian
      } else {
        font_default
      }

      let font_base_size = @raylib.get_font_base_size(font)
      let font_base_size_f : Float = Float::from_int(font_base_size)

      // Calculate size for the message box
      let sz = @raylib.measure_text_ex(
        font,
        messages[message_idx].text,
        font_base_size_f,
        1.0,
      )
      let mut sz_x = sz.x
      let mut sz_y = sz.y
      if sz_x > (300.0 : Float) {
        sz_y = sz_y * sz_x / (300.0 : Float)
        sz_x = (300.0 : Float)
      } else if sz_x < (160.0 : Float) {
        sz_x = (160.0 : Float)
      }

      let mut msg_rect_x : Float = selected_pos.x - (38.8 : Float)
      let mut msg_rect_y : Float = selected_pos.y
      let msg_rect_w : Float = (2.0 : Float) * horizontal_padding + sz_x
      let msg_rect_h : Float = (2.0 : Float) * vertical_padding + sz_y
      msg_rect_y = msg_rect_y - msg_rect_h

      // Coordinates for the chat bubble triangle
      let mut a_x : Float = selected_pos.x
      let mut a_y : Float = msg_rect_y + msg_rect_h
      let mut b_x : Float = a_x + (8.0 : Float)
      let mut b_y : Float = a_y + (10.0 : Float)
      let c_x : Float = a_x + (10.0 : Float)
      let mut c_y : Float = a_y

      // Don't go outside the screen
      if msg_rect_x < (10.0 : Float) {
        msg_rect_x = msg_rect_x + (28.0 : Float)
      }
      if msg_rect_y < (10.0 : Float) {
        msg_rect_y = selected_pos.y + (84.0 : Float)
        a_y = msg_rect_y
        c_y = a_y
        b_y = a_y - (10.0 : Float)
        // Swap a and b so we can render the triangle correctly
        let tmp_x = a_x
        let tmp_y = a_y
        a_x = b_x
        a_y = b_y
        b_x = tmp_x
        b_y = tmp_y
      }
      let screen_width_f : Float = Float::from_int(screen_width)
      if msg_rect_x + msg_rect_w > screen_width_f {
        msg_rect_x = msg_rect_x -
          (msg_rect_x + msg_rect_w - screen_width_f + (10.0 : Float))
      }

      // Draw chat bubble
      let msg_rect = @raylib.Rectangle::new(
        msg_rect_x, msg_rect_y, msg_rect_w, msg_rect_h,
      )
      @raylib.draw_rectangle_rec(msg_rect, emoji[selected].color)
      @raylib.draw_triangle(
        @raylib.Vector2::new(a_x, a_y),
        @raylib.Vector2::new(b_x, b_y),
        @raylib.Vector2::new(c_x, c_y),
        emoji[selected].color,
      )

      // Draw the main text message
      let text_rect = @raylib.Rectangle::new(
        msg_rect_x + horizontal_padding / (2.0 : Float),
        msg_rect_y + vertical_padding / (2.0 : Float),
        msg_rect_w - horizontal_padding,
        msg_rect_h,
      )
      draw_text_boxed(
        font,
        messages[message_idx].text,
        text_rect,
        font_base_size_f,
        1.0,
        true,
        @raylib.white,
      )

      // Draw the info text below the main message
      let msg_text = messages[message_idx].text
      let char_count = @raylib.get_codepoint_count(msg_text)
      let byte_count = @utf8.encode(msg_text).length()
      let info = messages[message_idx].language +
        " " +
        char_count.to_string() +
        " characters " +
        byte_count.to_string() +
        " bytes"
      let info_sz = @raylib.measure_text_ex(
        @raylib.get_font_default(),
        info,
        10.0,
        1.0,
      )
      @raylib.draw_text(
        info,
        (text_rect.x + text_rect.width - info_sz.x).to_int(),
        (msg_rect_y + msg_rect_h - info_sz.y - (2.0 : Float)).to_int(),
        10,
        @raylib.raywhite,
      )
    }

    // Draw the info text
    @raylib.draw_text(
      "These emojis have something to tell you, click each to find out!",
      (screen_width - 650) / 2,
      screen_height - 40,
      20,
      @raylib.gray,
    )
    @raylib.draw_text(
      "Each emoji is a unicode character from a font, not a texture... Press [SPACEBAR] to refresh",
      (screen_width - 484) / 2,
      screen_height - 16,
      10,
      @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font_default)
  @raylib.unload_font(font_asian)
  @raylib.unload_font(font_emoji)
  @raylib.close_window()
}
