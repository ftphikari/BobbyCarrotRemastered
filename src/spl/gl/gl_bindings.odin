package gl

import gl "vendor:OpenGL"

Viewport        :: gl.Viewport
ClearColor      :: gl.ClearColor
Clear           :: gl.Clear
Enable          :: gl.Enable
Disable         :: gl.Disable
BlendFunc       :: gl.BlendFunc
Flush           :: gl.Flush
Finish          :: gl.Finish
BindTexture     :: gl.BindTexture
GenTextures     :: gl.GenTextures
TexParameteri   :: gl.TexParameteri
TexImage2D      :: gl.TexImage2D
LineWidth       :: gl.LineWidth
PolygonMode     :: gl.PolygonMode
DrawArrays      :: gl.DrawArrays
GetIntegerv     :: gl.GetIntegerv

/* MatrixMode */
MODELVIEW  :: gl.MODELVIEW
PROJECTION :: gl.PROJECTION
TEXTURE    :: gl.TEXTURE

/* ClearBufferMask */
COLOR_BUFFER_BIT   :: gl.COLOR_BUFFER_BIT
ACCUM_BUFFER_BIT   :: gl.ACCUM_BUFFER_BIT
STENCIL_BUFFER_BIT :: gl.STENCIL_BUFFER_BIT
DEPTH_BUFFER_BIT   :: gl.DEPTH_BUFFER_BIT

/* Enable */
FOG                  :: gl.FOG
LIGHTING             :: gl.LIGHTING
TEXTURE_1D           :: gl.TEXTURE_1D
TEXTURE_2D           :: gl.TEXTURE_2D
LINE_STIPPLE         :: gl.LINE_STIPPLE
POLYGON_STIPPLE      :: gl.POLYGON_STIPPLE
CULL_FACE            :: gl.CULL_FACE
ALPHA_TEST           :: gl.ALPHA_TEST
BLEND                :: gl.BLEND
INDEX_LOGIC_OP       :: gl.INDEX_LOGIC_OP
COLOR_LOGIC_OP       :: gl.COLOR_LOGIC_OP
DITHER               :: gl.DITHER
STENCIL_TEST         :: gl.STENCIL_TEST
DEPTH_TEST           :: gl.DEPTH_TEST
CLIP_PLANE0          :: gl.CLIP_PLANE0
CLIP_PLANE1          :: gl.CLIP_PLANE1
CLIP_PLANE2          :: gl.CLIP_PLANE2
CLIP_PLANE3          :: gl.CLIP_PLANE3
CLIP_PLANE4          :: gl.CLIP_PLANE4
CLIP_PLANE5          :: gl.CLIP_PLANE5
LIGHT0               :: gl.LIGHT0
LIGHT1               :: gl.LIGHT1
LIGHT2               :: gl.LIGHT2
LIGHT3               :: gl.LIGHT3
LIGHT4               :: gl.LIGHT4
LIGHT5               :: gl.LIGHT5
LIGHT6               :: gl.LIGHT6
LIGHT7               :: gl.LIGHT7
TEXTURE_GEN_S        :: gl.TEXTURE_GEN_S
TEXTURE_GEN_T        :: gl.TEXTURE_GEN_T
TEXTURE_GEN_R        :: gl.TEXTURE_GEN_R
TEXTURE_GEN_Q        :: gl.TEXTURE_GEN_Q
MAP1_VERTEX_3        :: gl.MAP1_VERTEX_3
MAP1_VERTEX_4        :: gl.MAP1_VERTEX_4
MAP1_COLOR_4         :: gl.MAP1_COLOR_4
MAP1_INDEX           :: gl.MAP1_INDEX
MAP1_NORMAL          :: gl.MAP1_NORMAL
MAP1_TEXTURE_COORD_1 :: gl.MAP1_TEXTURE_COORD_1
MAP1_TEXTURE_COORD_2 :: gl.MAP1_TEXTURE_COORD_2
MAP1_TEXTURE_COORD_3 :: gl.MAP1_TEXTURE_COORD_3
MAP1_TEXTURE_COORD_4 :: gl.MAP1_TEXTURE_COORD_4
MAP2_VERTEX_3        :: gl.MAP2_VERTEX_3
MAP2_VERTEX_4        :: gl.MAP2_VERTEX_4
MAP2_COLOR_4         :: gl.MAP2_COLOR_4
MAP2_INDEX           :: gl.MAP2_INDEX
MAP2_NORMAL          :: gl.MAP2_NORMAL
MAP2_TEXTURE_COORD_1 :: gl.MAP2_TEXTURE_COORD_1
MAP2_TEXTURE_COORD_2 :: gl.MAP2_TEXTURE_COORD_2
MAP2_TEXTURE_COORD_3 :: gl.MAP2_TEXTURE_COORD_3
MAP2_TEXTURE_COORD_4 :: gl.MAP2_TEXTURE_COORD_4
POINT_SMOOTH         :: gl.POINT_SMOOTH
LINE_SMOOTH          :: gl.LINE_SMOOTH
POLYGON_SMOOTH       :: gl.POLYGON_SMOOTH
SCISSOR_TEST         :: gl.SCISSOR_TEST
COLOR_MATERIAL       :: gl.COLOR_MATERIAL
NORMALIZE            :: gl.NORMALIZE
AUTO_NORMAL          :: gl.AUTO_NORMAL
VERTEX_ARRAY         :: gl.VERTEX_ARRAY
NORMAL_ARRAY         :: gl.NORMAL_ARRAY
COLOR_ARRAY          :: gl.COLOR_ARRAY
INDEX_ARRAY          :: gl.INDEX_ARRAY
TEXTURE_COORD_ARRAY  :: gl.TEXTURE_COORD_ARRAY
EDGE_FLAG_ARRAY      :: gl.EDGE_FLAG_ARRAY
POLYGON_OFFSET_POINT :: gl.POLYGON_OFFSET_POINT
POLYGON_OFFSET_LINE  :: gl.POLYGON_OFFSET_LINE
POLYGON_OFFSET_FILL  :: gl.POLYGON_OFFSET_FILL

/* BlendingFactorDest */
ZERO                :: gl.ZERO
ONE                 :: gl.ONE
SRC_COLOR           :: gl.SRC_COLOR
ONE_MINUS_SRC_COLOR :: gl.ONE_MINUS_SRC_COLOR
SRC_ALPHA           :: gl.SRC_ALPHA
ONE_MINUS_SRC_ALPHA :: gl.ONE_MINUS_SRC_ALPHA
DST_ALPHA           :: gl.DST_ALPHA
ONE_MINUS_DST_ALPHA :: gl.ONE_MINUS_DST_ALPHA

/* BlendingFactorSrc */
/* ZERO */
/* ONE */
DST_COLOR           :: gl.DST_COLOR
ONE_MINUS_DST_COLOR :: gl.ONE_MINUS_DST_COLOR
SRC_ALPHA_SATURATE  :: gl.SRC_ALPHA_SATURATE
/* SRC_ALPHA */
/* ONE_MINUS_SRC_ALPHA */
/* DST_ALPHA */
/* ONE_MINUS_DST_ALPHA */

/* AlphaFunction */
NEVER    :: gl.NEVER
LESS     :: gl.LESS
EQUAL    :: gl.EQUAL
LEQUAL   :: gl.LEQUAL
GREATER  :: gl.GREATER
NOTEQUAL :: gl.NOTEQUAL
GEQUAL   :: gl.GEQUAL
ALWAYS   :: gl.ALWAYS

/* TextureParameterName */
TEXTURE_MAG_FILTER :: gl.TEXTURE_MAG_FILTER
TEXTURE_MIN_FILTER :: gl.TEXTURE_MIN_FILTER
TEXTURE_WRAP_S     :: gl.TEXTURE_WRAP_S
TEXTURE_WRAP_T     :: gl.TEXTURE_WRAP_T
/* TEXTURE_BORDER_COLOR */
/* TEXTURE_PRIORITY */

/* TextureMagFilter */
NEAREST :: gl.NEAREST
LINEAR  :: gl.LINEAR

/* TextureMinFilter */
/* NEAREST */
/* LINEAR */
NEAREST_MIPMAP_NEAREST :: gl.NEAREST_MIPMAP_NEAREST
LINEAR_MIPMAP_NEAREST  :: gl.LINEAR_MIPMAP_NEAREST
NEAREST_MIPMAP_LINEAR  :: gl.NEAREST_MIPMAP_LINEAR
LINEAR_MIPMAP_LINEAR   :: gl.LINEAR_MIPMAP_LINEAR

/* texture */
ALPHA4                 :: gl.ALPHA4
ALPHA8                 :: gl.ALPHA8
ALPHA12                :: gl.ALPHA12
ALPHA16                :: gl.ALPHA16
LUMINANCE4             :: gl.LUMINANCE4
LUMINANCE8             :: gl.LUMINANCE8
LUMINANCE12            :: gl.LUMINANCE12
LUMINANCE16            :: gl.LUMINANCE16
LUMINANCE4_ALPHA4      :: gl.LUMINANCE4_ALPHA4
LUMINANCE6_ALPHA2      :: gl.LUMINANCE6_ALPHA2
LUMINANCE8_ALPHA8      :: gl.LUMINANCE8_ALPHA8
LUMINANCE12_ALPHA4     :: gl.LUMINANCE12_ALPHA4
LUMINANCE12_ALPHA12    :: gl.LUMINANCE12_ALPHA12
LUMINANCE16_ALPHA16    :: gl.LUMINANCE16_ALPHA16
INTENSITY              :: gl.INTENSITY
INTENSITY4             :: gl.INTENSITY4
INTENSITY8             :: gl.INTENSITY8
INTENSITY12            :: gl.INTENSITY12
INTENSITY16            :: gl.INTENSITY16
R3_G3_B2               :: gl.R3_G3_B2
RGB4                   :: gl.RGB4
RGB5                   :: gl.RGB5
RGB8                   :: gl.RGB8
RGB10                  :: gl.RGB10
RGB12                  :: gl.RGB12
RGB16                  :: gl.RGB16
RGBA2                  :: gl.RGBA2
RGBA4                  :: gl.RGBA4
RGB5_A1                :: gl.RGB5_A1
RGBA8                  :: gl.RGBA8
RGB10_A2               :: gl.RGB10_A2
RGBA12                 :: gl.RGBA12
RGBA16                 :: gl.RGBA16
TEXTURE_RED_SIZE       :: gl.TEXTURE_RED_SIZE
TEXTURE_GREEN_SIZE     :: gl.TEXTURE_GREEN_SIZE
TEXTURE_BLUE_SIZE      :: gl.TEXTURE_BLUE_SIZE
TEXTURE_ALPHA_SIZE     :: gl.TEXTURE_ALPHA_SIZE
TEXTURE_LUMINANCE_SIZE :: gl.TEXTURE_LUMINANCE_SIZE
TEXTURE_INTENSITY_SIZE :: gl.TEXTURE_INTENSITY_SIZE
PROXY_TEXTURE_1D       :: gl.PROXY_TEXTURE_1D
PROXY_TEXTURE_2D       :: gl.PROXY_TEXTURE_2D

/* EXT_bgra */
BGR_EXT  :: 0x80E0
BGRA_EXT :: 0x80E1

/* DataType */
BYTE           :: gl.BYTE
UNSIGNED_BYTE  :: gl.UNSIGNED_BYTE
SHORT          :: gl.SHORT
UNSIGNED_SHORT :: gl.UNSIGNED_SHORT
INT            :: gl.INT
UNSIGNED_INT   :: gl.UNSIGNED_INT
FLOAT          :: gl.FLOAT
_2_BYTES       :: gl._2_BYTES
_3_BYTES       :: gl._3_BYTES
_4_BYTES       :: gl._4_BYTES
DOUBLE         :: gl.DOUBLE

/* BeginMode */
POINTS         :: gl.POINTS
LINES          :: gl.LINES
LINE_LOOP      :: gl.LINE_LOOP
LINE_STRIP     :: gl.LINE_STRIP
TRIANGLES      :: gl.TRIANGLES
TRIANGLE_STRIP :: gl.TRIANGLE_STRIP
TRIANGLE_FAN   :: gl.TRIANGLE_FAN
QUADS          :: gl.QUADS
QUAD_STRIP     :: gl.QUAD_STRIP
POLYGON        :: gl.POLYGON

/* TextureWrapMode */
CLAMP  :: gl.CLAMP
REPEAT :: gl.REPEAT

/* DrawBufferMode */
NONE           :: gl.NONE
FRONT_LEFT     :: gl.FRONT_LEFT
FRONT_RIGHT    :: gl.FRONT_RIGHT
BACK_LEFT      :: gl.BACK_LEFT
BACK_RIGHT     :: gl.BACK_RIGHT
FRONT          :: gl.FRONT
BACK           :: gl.BACK
LEFT           :: gl.LEFT
RIGHT          :: gl.RIGHT
FRONT_AND_BACK :: gl.FRONT_AND_BACK
AUX0           :: gl.AUX0
AUX1           :: gl.AUX1
AUX2           :: gl.AUX2
AUX3           :: gl.AUX3

/* PolygonMode */
POINT :: gl.POINT
LINE  :: gl.LINE
FILL  :: gl.FILL

/* PixelFormat */
COLOR_INDEX     :: gl.COLOR_INDEX
STENCIL_INDEX   :: gl.STENCIL_INDEX
DEPTH_COMPONENT :: gl.DEPTH_COMPONENT
RED             :: gl.RED
GREEN           :: gl.GREEN
BLUE            :: gl.BLUE
ALPHA           :: gl.ALPHA
RGB             :: gl.RGB
RGBA            :: gl.RGBA
LUMINANCE       :: gl.LUMINANCE
LUMINANCE_ALPHA :: gl.LUMINANCE_ALPHA

/* GetTarget */
CURRENT_COLOR                 :: gl.CURRENT_COLOR
CURRENT_INDEX                 :: gl.CURRENT_INDEX
CURRENT_NORMAL                :: gl.CURRENT_NORMAL
CURRENT_TEXTURE_COORDS        :: gl.CURRENT_TEXTURE_COORDS
CURRENT_RASTER_COLOR          :: gl.CURRENT_RASTER_COLOR
CURRENT_RASTER_INDEX          :: gl.CURRENT_RASTER_INDEX
CURRENT_RASTER_TEXTURE_COORDS :: gl.CURRENT_RASTER_TEXTURE_COORDS
CURRENT_RASTER_POSITION       :: gl.CURRENT_RASTER_POSITION
CURRENT_RASTER_POSITION_VALID :: gl.CURRENT_RASTER_POSITION_VALID
CURRENT_RASTER_DISTANCE       :: gl.CURRENT_RASTER_DISTANCE
POINT_SIZE                    :: gl.POINT_SIZE
POINT_SIZE_RANGE              :: gl.POINT_SIZE_RANGE
POINT_SIZE_GRANULARITY        :: gl.POINT_SIZE_GRANULARITY
LINE_WIDTH                    :: gl.LINE_WIDTH
LINE_WIDTH_RANGE              :: gl.LINE_WIDTH_RANGE
LINE_WIDTH_GRANULARITY        :: gl.LINE_WIDTH_GRANULARITY
LINE_STIPPLE_PATTERN          :: gl.LINE_STIPPLE_PATTERN
LINE_STIPPLE_REPEAT           :: gl.LINE_STIPPLE_REPEAT
LIST_MODE                     :: gl.LIST_MODE
MAX_LIST_NESTING              :: gl.MAX_LIST_NESTING
LIST_BASE                     :: gl.LIST_BASE
LIST_INDEX                    :: gl.LIST_INDEX
POLYGON_MODE                  :: gl.POLYGON_MODE
EDGE_FLAG                     :: gl.EDGE_FLAG
CULL_FACE_MODE                :: gl.CULL_FACE_MODE
FRONT_FACE                    :: gl.FRONT_FACE
LIGHT_MODEL_LOCAL_VIEWER      :: gl.LIGHT_MODEL_LOCAL_VIEWER
LIGHT_MODEL_TWO_SIDE          :: gl.LIGHT_MODEL_TWO_SIDE
LIGHT_MODEL_AMBIENT           :: gl.LIGHT_MODEL_AMBIENT
SHADE_MODEL                   :: gl.SHADE_MODEL
COLOR_MATERIAL_FACE           :: gl.COLOR_MATERIAL_FACE
COLOR_MATERIAL_PARAMETER      :: gl.COLOR_MATERIAL_PARAMETER
FOG_INDEX                     :: gl.FOG_INDEX
FOG_DENSITY                   :: gl.FOG_DENSITY
FOG_START                     :: gl.FOG_START
FOG_END                       :: gl.FOG_END
FOG_MODE                      :: gl.FOG_MODE
FOG_COLOR                     :: gl.FOG_COLOR
DEPTH_RANGE                   :: gl.DEPTH_RANGE
DEPTH_WRITEMASK               :: gl.DEPTH_WRITEMASK
DEPTH_CLEAR_VALUE             :: gl.DEPTH_CLEAR_VALUE
DEPTH_FUNC                    :: gl.DEPTH_FUNC
ACCUM_CLEAR_VALUE             :: gl.ACCUM_CLEAR_VALUE
STENCIL_CLEAR_VALUE           :: gl.STENCIL_CLEAR_VALUE
STENCIL_FUNC                  :: gl.STENCIL_FUNC
STENCIL_VALUE_MASK            :: gl.STENCIL_VALUE_MASK
STENCIL_FAIL                  :: gl.STENCIL_FAIL
STENCIL_PASS_DEPTH_FAIL       :: gl.STENCIL_PASS_DEPTH_FAIL
STENCIL_PASS_DEPTH_PASS       :: gl.STENCIL_PASS_DEPTH_PASS
STENCIL_REF                   :: gl.STENCIL_REF
STENCIL_WRITEMASK             :: gl.STENCIL_WRITEMASK
MATRIX_MODE                   :: gl.MATRIX_MODE
VIEWPORT                      :: gl.VIEWPORT
MODELVIEW_STACK_DEPTH         :: gl.MODELVIEW_STACK_DEPTH
PROJECTION_STACK_DEPTH        :: gl.PROJECTION_STACK_DEPTH
TEXTURE_STACK_DEPTH           :: gl.TEXTURE_STACK_DEPTH
MODELVIEW_MATRIX              :: gl.MODELVIEW_MATRIX
PROJECTION_MATRIX             :: gl.PROJECTION_MATRIX
TEXTURE_MATRIX                :: gl.TEXTURE_MATRIX
ATTRIB_STACK_DEPTH            :: gl.ATTRIB_STACK_DEPTH
CLIENT_ATTRIB_STACK_DEPTH     :: gl.CLIENT_ATTRIB_STACK_DEPTH
ALPHA_TEST_FUNC               :: gl.ALPHA_TEST_FUNC
ALPHA_TEST_REF                :: gl.ALPHA_TEST_REF
BLEND_DST                     :: gl.BLEND_DST
BLEND_SRC                     :: gl.BLEND_SRC
LOGIC_OP_MODE                 :: gl.LOGIC_OP_MODE
AUX_BUFFERS                   :: gl.AUX_BUFFERS
DRAW_BUFFER                   :: gl.DRAW_BUFFER
READ_BUFFER                   :: gl.READ_BUFFER
SCISSOR_BOX                   :: gl.SCISSOR_BOX
INDEX_CLEAR_VALUE             :: gl.INDEX_CLEAR_VALUE
INDEX_WRITEMASK               :: gl.INDEX_WRITEMASK
COLOR_CLEAR_VALUE             :: gl.COLOR_CLEAR_VALUE
COLOR_WRITEMASK               :: gl.COLOR_WRITEMASK
INDEX_MODE                    :: gl.INDEX_MODE
RGBA_MODE                     :: gl.RGBA_MODE
DOUBLEBUFFER                  :: gl.DOUBLEBUFFER
STEREO                        :: gl.STEREO
RENDER_MODE                   :: gl.RENDER_MODE
PERSPECTIVE_CORRECTION_HINT   :: gl.PERSPECTIVE_CORRECTION_HINT
POINT_SMOOTH_HINT             :: gl.POINT_SMOOTH_HINT
LINE_SMOOTH_HINT              :: gl.LINE_SMOOTH_HINT
POLYGON_SMOOTH_HINT           :: gl.POLYGON_SMOOTH_HINT
FOG_HINT                      :: gl.FOG_HINT
PIXEL_MAP_I_TO_I              :: gl.PIXEL_MAP_I_TO_I
PIXEL_MAP_S_TO_S              :: gl.PIXEL_MAP_S_TO_S
PIXEL_MAP_I_TO_R              :: gl.PIXEL_MAP_I_TO_R
PIXEL_MAP_I_TO_G              :: gl.PIXEL_MAP_I_TO_G
PIXEL_MAP_I_TO_B              :: gl.PIXEL_MAP_I_TO_B
PIXEL_MAP_I_TO_A              :: gl.PIXEL_MAP_I_TO_A
PIXEL_MAP_R_TO_R              :: gl.PIXEL_MAP_R_TO_R
PIXEL_MAP_G_TO_G              :: gl.PIXEL_MAP_G_TO_G
PIXEL_MAP_B_TO_B              :: gl.PIXEL_MAP_B_TO_B
PIXEL_MAP_A_TO_A              :: gl.PIXEL_MAP_A_TO_A
PIXEL_MAP_I_TO_I_SIZE         :: gl.PIXEL_MAP_I_TO_I_SIZE
PIXEL_MAP_S_TO_S_SIZE         :: gl.PIXEL_MAP_S_TO_S_SIZE
PIXEL_MAP_I_TO_R_SIZE         :: gl.PIXEL_MAP_I_TO_R_SIZE
PIXEL_MAP_I_TO_G_SIZE         :: gl.PIXEL_MAP_I_TO_G_SIZE
PIXEL_MAP_I_TO_B_SIZE         :: gl.PIXEL_MAP_I_TO_B_SIZE
PIXEL_MAP_I_TO_A_SIZE         :: gl.PIXEL_MAP_I_TO_A_SIZE
PIXEL_MAP_R_TO_R_SIZE         :: gl.PIXEL_MAP_R_TO_R_SIZE
PIXEL_MAP_G_TO_G_SIZE         :: gl.PIXEL_MAP_G_TO_G_SIZE
PIXEL_MAP_B_TO_B_SIZE         :: gl.PIXEL_MAP_B_TO_B_SIZE
PIXEL_MAP_A_TO_A_SIZE         :: gl.PIXEL_MAP_A_TO_A_SIZE
UNPACK_SWAP_BYTES             :: gl.UNPACK_SWAP_BYTES
UNPACK_LSB_FIRST              :: gl.UNPACK_LSB_FIRST
UNPACK_ROW_LENGTH             :: gl.UNPACK_ROW_LENGTH
UNPACK_SKIP_ROWS              :: gl.UNPACK_SKIP_ROWS
UNPACK_SKIP_PIXELS            :: gl.UNPACK_SKIP_PIXELS
UNPACK_ALIGNMENT              :: gl.UNPACK_ALIGNMENT
PACK_SWAP_BYTES               :: gl.PACK_SWAP_BYTES
PACK_LSB_FIRST                :: gl.PACK_LSB_FIRST
PACK_ROW_LENGTH               :: gl.PACK_ROW_LENGTH
PACK_SKIP_ROWS                :: gl.PACK_SKIP_ROWS
PACK_SKIP_PIXELS              :: gl.PACK_SKIP_PIXELS
PACK_ALIGNMENT                :: gl.PACK_ALIGNMENT
MAP_COLOR                     :: gl.MAP_COLOR
MAP_STENCIL                   :: gl.MAP_STENCIL
INDEX_SHIFT                   :: gl.INDEX_SHIFT
INDEX_OFFSET                  :: gl.INDEX_OFFSET
RED_SCALE                     :: gl.RED_SCALE
RED_BIAS                      :: gl.RED_BIAS
ZOOM_X                        :: gl.ZOOM_X
ZOOM_Y                        :: gl.ZOOM_Y
GREEN_SCALE                   :: gl.GREEN_SCALE
GREEN_BIAS                    :: gl.GREEN_BIAS
BLUE_SCALE                    :: gl.BLUE_SCALE
BLUE_BIAS                     :: gl.BLUE_BIAS
ALPHA_SCALE                   :: gl.ALPHA_SCALE
ALPHA_BIAS                    :: gl.ALPHA_BIAS
DEPTH_SCALE                   :: gl.DEPTH_SCALE
DEPTH_BIAS                    :: gl.DEPTH_BIAS
MAX_EVAL_ORDER                :: gl.MAX_EVAL_ORDER
MAX_LIGHTS                    :: gl.MAX_LIGHTS
MAX_CLIP_PLANES               :: gl.MAX_CLIP_PLANES
MAX_TEXTURE_SIZE              :: gl.MAX_TEXTURE_SIZE
MAX_PIXEL_MAP_TABLE           :: gl.MAX_PIXEL_MAP_TABLE
MAX_ATTRIB_STACK_DEPTH        :: gl.MAX_ATTRIB_STACK_DEPTH
MAX_MODELVIEW_STACK_DEPTH     :: gl.MAX_MODELVIEW_STACK_DEPTH
MAX_NAME_STACK_DEPTH          :: gl.MAX_NAME_STACK_DEPTH
MAX_PROJECTION_STACK_DEPTH    :: gl.MAX_PROJECTION_STACK_DEPTH
MAX_TEXTURE_STACK_DEPTH       :: gl.MAX_TEXTURE_STACK_DEPTH
MAX_VIEWPORT_DIMS             :: gl.MAX_VIEWPORT_DIMS
MAX_CLIENT_ATTRIB_STACK_DEPTH :: gl.MAX_CLIENT_ATTRIB_STACK_DEPTH
SUBPIXEL_BITS                 :: gl.SUBPIXEL_BITS
INDEX_BITS                    :: gl.INDEX_BITS
RED_BITS                      :: gl.RED_BITS
GREEN_BITS                    :: gl.GREEN_BITS
BLUE_BITS                     :: gl.BLUE_BITS
ALPHA_BITS                    :: gl.ALPHA_BITS
DEPTH_BITS                    :: gl.DEPTH_BITS
STENCIL_BITS                  :: gl.STENCIL_BITS
ACCUM_RED_BITS                :: gl.ACCUM_RED_BITS
ACCUM_GREEN_BITS              :: gl.ACCUM_GREEN_BITS
ACCUM_BLUE_BITS               :: gl.ACCUM_BLUE_BITS
ACCUM_ALPHA_BITS              :: gl.ACCUM_ALPHA_BITS
NAME_STACK_DEPTH              :: gl.NAME_STACK_DEPTH
MAP1_GRID_DOMAIN              :: gl.MAP1_GRID_DOMAIN
MAP1_GRID_SEGMENTS            :: gl.MAP1_GRID_SEGMENTS
MAP2_GRID_DOMAIN              :: gl.MAP2_GRID_DOMAIN
MAP2_GRID_SEGMENTS            :: gl.MAP2_GRID_SEGMENTS
FEEDBACK_BUFFER_POINTER       :: gl.FEEDBACK_BUFFER_POINTER
FEEDBACK_BUFFER_SIZE          :: gl.FEEDBACK_BUFFER_SIZE
FEEDBACK_BUFFER_TYPE          :: gl.FEEDBACK_BUFFER_TYPE
SELECTION_BUFFER_POINTER      :: gl.SELECTION_BUFFER_POINTER
SELECTION_BUFFER_SIZE         :: gl.SELECTION_BUFFER_SIZE
