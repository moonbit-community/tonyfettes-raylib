///|
pub type Image

///|
pub type Texture

///|
pub type RenderTexture

///|
pub type Font

///|
pub type Sound

///|
pub type Music

///|
pub type Model

///|
pub type Shader

///|
pub type Wave

///|
pub type AudioStream

///|
pub type Mesh

///|
pub type Material

///|
pub type ModelAnimations

///|
pub type FilePathList

///|
pub type GlyphInfoArray

///|
pub type AutomationEventList

///|
pub type VrStereoConfig

///|
pub type MaterialsArray

///|
pub type MaterialMap

///|
#external
pub type MaterialMapArray

///|
#external
pub type FloatPointer

///|
pub fn FloatPointer::to_pointer(self : FloatPointer) -> Pointer = "%identity"

///|
pub fn FloatPointer::from_pointer(pointer : Pointer) -> FloatPointer = "%identity"

///|
#external
pub type UBytePointer

///|
pub fn UBytePointer::to_pointer(self : UBytePointer) -> Pointer = "%identity"

///|
pub fn UBytePointer::from_pointer(pointer : Pointer) -> UBytePointer = "%identity"

///|
#external
pub type ShortPointer

///|
pub fn ShortPointer::to_pointer(self : ShortPointer) -> Pointer = "%identity"

///|
pub fn ShortPointer::from_pointer(pointer : Pointer) -> ShortPointer = "%identity"

///|
#external
pub type UShortPointer

///|
pub fn UShortPointer::to_pointer(self : UShortPointer) -> Pointer = "%identity"

///|
pub fn UShortPointer::from_pointer(pointer : Pointer) -> UShortPointer = "%identity"

///|
#external
pub type MatrixArray

///|
/// AudioBuffer, used in audio stream processor callbacks from C.
pub type AudioBuffer

///|
/// Opaque void pointer for passing typed data to rlgl buffer operations.
#external
pub type Pointer

///|
/// Allocate zero-initialized memory. Returns a Pointer to `count * element_size` bytes.
pub extern "c" fn Pointer::calloc(count : Int, element_size : Int) -> Pointer = "moonbit_raylib_calloc"

///|
/// Free memory previously allocated with `calloc`.
pub extern "c" fn Pointer::free(self : Pointer) = "moonbit_raylib_free"
