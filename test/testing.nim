import core, graphics, batch, common, audio, polymorph, math, random, font

registerComponents(defaultComponentOptions):
  type
    Pos = object
      x, y: float32
    Bouncer = object
      vel: Vec2
    Render = object

const hsize = 70.0
const scl = 4.0

var texture: Texture
var cam: Cam
var draw: Batch
var patch: Patch
var buffer: Framebuffer
var screenm: Mesh
var screensp: Shader
var sounded = false
var ffont: Gfont

makeSystem("bounce", [Pos, Bouncer]):
  all: 
    item.pos.x += item.bouncer.vel.x
    item.pos.y += item.bouncer.vel.y
    if item.pos.x > screenW/2.0 - hsize/2.0 or item.pos.x < -screenW/2.0 + hsize/2.0: item.bouncer.vel *= vec2(-1.0, 1.0)
    if item.pos.y > screenH/2.0 - hsize/2.0 or item.pos.y < -screenH/2.0 + hsize/2.0: item.bouncer.vel *= vec2(1.0, -1.0)

makeSystem("render", [Pos, Render]):

  init:

    screenm = newScreenMesh()
    cam = newCam()
    draw = newBatch()
    buffer = newFramebuffer()
    texture = loadTextureStatic("/home/anuke/Projects/fuse/test/test.png")
    ffont = loadFont("/home/anuke/Documents/font.ttf", textureSize = 128)
    patch = texture

    screensp = newShader(
      """
      attribute vec4 a_position;
      attribute vec2 a_texc;

      varying vec2 v_texc;

      void main(){
          v_texc = a_texc;
          gl_Position = a_position;
      }
      """,

      """
      uniform sampler2D u_texture;

      varying vec2 v_texc;

      void main(){
        //vec2 coords = v_texc + vec2(sin(v_texc.y * 50.0) / 60.0, sin(v_texc.x * 50.0) / 60.0);
        //gl_FragColor = texture2D(u_texture, coords) + vec4(v_texc, 1.0, 1.0);
        gl_FragColor = texture2D(u_texture, v_texc);
      }
      """
    )

    #let music = loadMusicStatic("/home/anuke/Music/music.ogg")
    #music.filterEcho(0.4, 0.8, 0.5)
    #music.play(pitch = 0.7)

    randomize()

    const speed = 3

    for i in 0..1000:
      discard newEntityWith(Render(), Pos(x: rand(-500..500).float32, y: rand(-500..500).float32), Bouncer(vel: vec2(rand(-speed..speed).float32, rand(-speed..speed).float32)))

  start:
    if keyEscape.tapped: quitApp()

    buffer.resize(screenW.int, screenH.int)
    buffer.start(rgba(0, 0, 0, 1))
    
    cam.resize(screenW / scl, screenH / scl)
    cam.update()

    draw.mat = cam.mat
    
  all: discard
    #draw.draw(patch, item.pos.x - hsize/2.0, item.pos.y - hsize/2.0, hsize, hsize)
  
  finish:
    ffont.draw(draw, vec2(0, 0), "rather strange font rendering")
    
    draw.flush()
    buffer.stop()
    
    buffer.texture.use()
    screenm.render(screensp)

makeEcs()
commitSystems("run")
initCore(run, windowTitle = "cats")