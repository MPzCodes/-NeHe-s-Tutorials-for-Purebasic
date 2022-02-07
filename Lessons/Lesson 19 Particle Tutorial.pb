;NeHe's Particle Tutorial (Lesson 19)
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/particle_engine_using_triangle_strips/21001/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 05 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)


UsePNGImageDecoder() 

#MAX_PARTICLES=1000 ;Number Of Particles To Create

Global rainbow.b=#True ;Rainbow Mode?
Global sp.b ;Spacebar Pressed?
Global rp.b ;Enter Key Pressed?
Global tp.b ;Tab Pressed? Note: added code for cleaner particle burst

Global slowdown.f=2.0 ;Slow Down Particles
Global xspeed.f ;Base X Speed (To Allow Keyboard Direction Of Tail)
Global yspeed.f ;Base Y Speed (To Allow Keyboard Direction Of Tail)
Global zoom.f=-40.0 ;Used To Zoom Out

Global LOOP.l ;Misc Loop Variable
Global col.l ;Current Color Selection
Global delay.l ;Rainbow Effect Delay
Global Dim texture.l(1) ;Storage For Our Particle Texture

Structure PARTICLES ;Create A Structure For Particles
  active.b ;Active (Yes/No)
  life.f ;Particle Life
  fade.f ;Fade Speed
  r.f : g.f : b.f ;Red, Green, Blue Values
  x.f : y.f : z.f ;X, Y, Z Position
  xi.f : yi.f : zi.f ;X, Y, Z Direction (or increment)
  xg.f : yg.f : zg.f ;X, Y, Z Gravity
EndStructure

Global Dim particle.PARTICLES(#MAX_PARTICLES) ;Particle Array (Room For Particle Info)

Global Dim colors.f(12,3) ;Rainbow Of Colors
colors( 0,0)=1.0  : colors( 0,1)=0.5  : colors( 0,2)=0.5 ;red
colors( 1,0)=1.0  : colors( 1,1)=0.75 : colors( 1,2)=0.5
colors( 2,0)=1.0  : colors( 2,1)=1.0  : colors( 2,2)=0.5 ;yellow
colors( 3,0)=0.75 : colors( 3,1)=1.0  : colors( 3,2)=0.5
colors( 4,0)=0.5  : colors( 4,1)=1.0  : colors( 4,2)=0.5 ;green
colors( 5,0)=0.5  : colors( 5,1)=1.0  : colors( 5,2)=0.75
colors( 6,0)=0.5  : colors( 6,1)=1.0  : colors( 6,2)=1.0 ;cyan
colors( 7,0)=0.5  : colors( 7,1)=0.75 : colors( 7,2)=1.0
colors( 8,0)=0.5  : colors( 8,1)=0.5  : colors( 8,2)=1.0 ;blue
colors( 9,0)=0.75 : colors( 9,1)=0.5  : colors( 9,2)=1.0
colors(10,0)=1.0  : colors(10,1)=0.5  : colors(10,2)=1.0 ;purple
colors(11,0)=1.0  : colors(11,1)=0.5  : colors(11,2)=0.75

Procedure LoadGLTextures(Names.s)
  
  Define.i img = LoadImage(0, Names)
  
  If img
    
    *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
    FreeImage(0)
  	
    glGenTextures_(1, @Texture(0));                  // Create Three Textures

    ;// Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, Texture(0));
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
    glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer+18),PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer+54);
    
    FreeMemory(*pointer)
    
   Else
     MessageRequester("Error", "Konnte Textur "+names+" nicht laden", 0)
   EndIf

EndProcedure


Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

 If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
 
 ResizeGadget(0, 0, 0, width, height)
 
 glViewport_(0,0,width,height) ;Reset The Current Viewport
 
 glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
 glLoadIdentity_() ;Reset The Projection Matrix
 
 gluPerspective_(45.0,Abs(width/height),0.1,100.0) ;Calculate The Aspect Ratio Of The Window
 
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
 glLoadIdentity_() ;Reset The Modelview Matrix
 
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here

  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.0,0.0,0.0,0.0) ;Black Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glDisable_(#GL_DEPTH_TEST) ;Disable Depth Testing
  glEnable_(#GL_BLEND) ;Enable Blending
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Type Of Blending To Perform
  glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  glHint_(#GL_POINT_SMOOTH_HINT,#GL_NICEST) ;Really Nice Point Smoothing
  glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Texture
  
  For LOOP=0 To #MAX_PARTICLES-1 ;Initializes All The Particles
    particle(LOOP)\active=#True ;Make All The Particles Active
    particle(LOOP)\life=1.0 ;Give All The Particles Full Life
    particle(LOOP)\fade=Random(100)/1000.0+0.003 ;Random Fade Speed
    particle(LOOP)\r=colors((LOOP*12)/#MAX_PARTICLES,0) ;Select Red Rainbow Color
    particle(LOOP)\g=colors((LOOP*12)/#MAX_PARTICLES,1) ;Select Green Rainbow Color
    particle(LOOP)\b=colors((LOOP*12)/#MAX_PARTICLES,2) ;Select Blue Rainbow Color
    particle(LOOP)\xi=(Random(50)-25.0)*10.0 ;Random Speed On X Axis
    particle(LOOP)\yi=(Random(50)-25.0)*10.0 ;Random Speed On Y Axis
    particle(LOOP)\zi=(Random(50)-25.0)*10.0 ;Random Speed On Z Axis
    particle(LOOP)\xg=0.0 ;Set Horizontal Pull To Zero
    particle(LOOP)\yg=-0.8 ;Set Vertical Pull Downward
    particle(LOOP)\zg=0.0 ;Set Pull On Z Axis To Zero
  Next
 
 ProcedureReturn #True ;Initialization Went OK
 
EndProcedure


Procedure DrawScene(Gadget)
  
 SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
 Protected x.f,y.f,z.f ;particle positions
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  glLoadIdentity_() ;Reset The Modelview Matrix
  
  For LOOP=0 To #MAX_PARTICLES-1 ;Loop Through All The Particles
    If particle(LOOP)\active ;If The Particle Is Active
      
      x=particle(LOOP)\x ;Grab Our Particle X Position
      y=particle(LOOP)\y ;Grab Our Particle Y Position
      z=particle(LOOP)\z+zoom ;Particle Z Pos + Zoom
      
      ;Draw The Particle Using Our RGB Values, Fade The Particle Based On It's Life
      glColor4f_(particle(LOOP)\r,particle(LOOP)\g,particle(LOOP)\b,particle(LOOP)\life)
      
      glBegin_(#GL_TRIANGLE_STRIP) ;Build Quad From A Triangle Strip
      glTexCoord2f_(1.0,1.0) : glVertex3f_(x+0.5,y+0.5,z) ;Top Right (v0)
      glTexCoord2f_(0.0,1.0) : glVertex3f_(x-0.5,y+0.5,z) ;Top Left (v1)
      glTexCoord2f_(1.0,0.0) : glVertex3f_(x+0.5,y-0.5,z) ;Bottom Right (v2)
      glTexCoord2f_(0.0,0.0) : glVertex3f_(x-0.5,y-0.5,z) ;Bottom Left (v3)
      glEnd_() ;Done Building Triangle Strip
      
      particle(LOOP)\x+particle(LOOP)\xi/(slowdown*1000) ;Move On The X Axis By X Speed
      particle(LOOP)\y+particle(LOOP)\yi/(slowdown*1000) ;Move On The Y Axis By Y Speed
      particle(LOOP)\z+particle(LOOP)\zi/(slowdown*1000) ;Move On The Z Axis By Z Speed
      
      particle(LOOP)\xi+particle(LOOP)\xg ;Take Pull On X Axis Into Account
      particle(LOOP)\yi+particle(LOOP)\yg ;Take Pull On Y Axis Into Account
      particle(LOOP)\zi+particle(LOOP)\zg ;Take Pull On Z Axis Into Account
      
      particle(LOOP)\life-particle(LOOP)\fade ;Reduce Particles Life By 'Fade'
      
      If particle(LOOP)\life<0.0 ;If Particle Is Burned Out
        particle(LOOP)\life=1.0 ;Give It New Life
        particle(LOOP)\fade=Random(100)/1000.0+0.003 ;Random Fade Value
        particle(LOOP)\x=0.0 ;Center On X Axis
        particle(LOOP)\y=0.0 ;Center On Y Axis
        particle(LOOP)\z=0.0 ;Center On Z Axis
        particle(LOOP)\xi=xspeed+(Random(60)-30.0) ;X Axis Speed And Direction
        particle(LOOP)\yi=yspeed+(Random(60)-30.0) ;Y Axis Speed And Direction
        particle(LOOP)\zi=(Random(60)-30.0) ;Z Axis Speed And Direction
        particle(LOOP)\r=colors(col,0) ;Select Red From Color Table
        particle(LOOP)\g=colors(col,1) ;Select Green From Color Table
        particle(LOOP)\b=colors(col,2) ;Select Blue From Color Table
      EndIf
      
      If KeyboardPushed(#PB_Key_Pad8) And particle(LOOP)\yg<1.5 ;NumPad 8 And Y Gravity Less Than 1.5
        particle(LOOP)\yg+0.01 ;Increase Pull Upwards
      EndIf
      If KeyboardPushed(#PB_Key_Pad2) And particle(LOOP)\yg>-1.5 ;NumPad 2 And Y Gravity Greater Than -1.5
        particle(LOOP)\yg-0.01 ;Increase Pull Downwards
      EndIf
      If KeyboardPushed(#PB_Key_Pad6) And particle(LOOP)\xg<1.5 ;NumPad 6 And X Gravity Less Than 1.5
        particle(LOOP)\xg+0.01 ;Increase Pull Right
      EndIf
      If KeyboardPushed(#PB_Key_Pad4) And particle(LOOP)\xg>-1.5 ;NumPad 4 And X Gravity Greater Than -1.5
        particle(LOOP)\xg-0.01 ;Increase Pull Left
      EndIf
      
    EndIf
  Next
  
  If KeyboardPushed(#PB_Key_Tab) And tp=0 ;Tab Key Causes A Burst
    tp=#True ;Set Flag
    For LOOP=0 To #MAX_PARTICLES-1 ;Loop Through All The Particles
      particle(LOOP)\life=1.0 ;Give It New Life
      particle(LOOP)\x=0.0 ;Center On X Axis
      particle(LOOP)\y=0.0 ;Center On Y Axis
      particle(LOOP)\z=0.0 ;Center On Z Axis
      particle(LOOP)\xi=(Random(50)-25.0)*10.0 ;Random Speed On X Axis
      particle(LOOP)\yi=(Random(50)-25.0)*10.0 ;Random Speed On Y Axis
      particle(LOOP)\zi=(Random(50)-25.0)*10.0 ;Random Speed On Z Axis
    Next
  EndIf
  If Not KeyboardPushed(#PB_Key_Tab) ;If Tab Is Released
    tp=#False ;Clear Flag
  EndIf
  
 SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
EndProcedure

Procedure CreateGLWindow(title.s,WindowWidth.l,WindowHeight.l,bits.l=16,fullscreenflag.b=0,Vsync.b=0)
  
  If InitKeyboard() = 0 Or InitSprite() = 0 Or InitMouse() = 0
    MessageRequester("Error", "Can't initialize Keyboards or Mouse", 0)
    End
  EndIf

  If fullscreenflag
    hWnd = OpenWindow(0, 0, 0, WindowWidth, WindowHeight, title, #PB_Window_BorderLess|#PB_Window_Maximize )
    OpenWindowedScreen(WindowID(0), 0, 0,WindowWidth(0),WindowHeight(0)) 
  Else  
    hWnd = OpenWindow(0, 1, 1, WindowWidth, WindowHeight, title,#PB_Window_MinimizeGadget |  #PB_Window_MaximizeGadget | #PB_Window_SizeGadget ) 
    OpenWindowedScreen(WindowID(0), 1, 1, WindowWidth,WindowHeight) 
  EndIf
  
  If bits = 24
    OpenGlFlags + #PB_OpenGL_24BitDepthBuffer
  EndIf
  
  If Vsync = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0) 
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  ;hDC = GetDC_(hWnd)
  
EndProcedure
CreateGLWindow("NeHe's Particle Tutorial (Lesson 19)",640,480,16,0)

InitGL()

;LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/flare.png")
LoadGLTextures("Data/Particle.bmp"); -> Original from http://nehe.gamedev.net


Repeat

  Repeat 
    Event = WindowEvent()
    
    Select Event
      Case #PB_Event_CloseWindow
        Quit = 1
      Case #PB_Event_SizeWindow  
        ReSizeGLScene(WindowWidth(0),WindowHeight(0)) ;LoWord=Width, HiWord=Height
    EndSelect
  
  Until Event = 0
  
  ExamineKeyboard()
        
  If KeyboardPushed(#PB_Key_Escape)    ; // push ESC key
    Quit = 1                               ; // This is the end
  EndIf
  
  If KeyboardPushed(#PB_Key_Add) And slowdown>1.0 ;NumPad + Pressed
     slowdown-0.01 ;Speed Up Particles
  EndIf
  
  If KeyboardPushed(#PB_Key_Subtract) And slowdown<4.0 ;NumPad - Pressed
     slowdown+0.01 ;Slow Down Particles
  EndIf
        
  If KeyboardPushed(#PB_Key_PageUp) ;Page Up Pressed
     zoom+0.1 ;Zoom In
  EndIf
  
  If KeyboardPushed(#PB_Key_PageDown) ;Page Down Pressed
     zoom-0.1 ;Zoom Out
  EndIf
        
  If KeyboardPushed(#PB_Key_Return) And rp=0 ;Return Key Pressed
     rp=#True ;Set Flag Telling Us It's Pressed
     rainbow=~rainbow & 1 ;Toggle Rainbow Mode On / Off
  EndIf
  
  If Not KeyboardPushed(#PB_Key_Return)=0 ;If Return Is Released
     rp=#False ;Clear Flag
  EndIf
        
  If (KeyboardPushed(#PB_Key_Space) And sp=0) Or (rainbow And delay>25) ;Space Or Rainbow Mode
     If KeyboardPushed(#PB_Key_Space) ;If Spacebar Is Pressed
        sp=#True ;Set Flag Telling Us Space Is Pressed
        rainbow=#False ;Disable Rainbow Mode
      EndIf
      
     delay=0 ;Reset The Rainbow Color Cycling Delay
     col+1 ;Change The Particle Color
     If col>11 : col=0 : EndIf ;If Color Is Too High Reset It
  EndIf
  
  If Not KeyboardPushed(#PB_Key_Space) ;If Spacebar Is Released Clear Flag
     sp=#False
  EndIf
        
  If KeyboardPushed(#PB_Key_Up) And yspeed<200 ;Up Arrow And Y Speed Less Than 200
     yspeed+1.0 ;Increase Upward Speed
  EndIf
  
  If KeyboardPushed(#PB_Key_Down) And yspeed>-200 ;Down Arrow And Y Speed Greater Than -200
     yspeed-1.0 ;Increase Downward Speed
  EndIf
  
  If KeyboardPushed(#PB_Key_Right) And xspeed<200 ;Right Arrow And X Speed Less Than 200
     xspeed+1.0 ;Increase Speed To The Right
  EndIf
  
  If KeyboardPushed(#PB_Key_Left) And xspeed>-200 ;Left Arrow And X Speed Greater Than -200
     xspeed-1.0 ;Increase Speed To The Left
  EndIf
        
  delay+1 ;Increase Rainbow Mode Color Cycling Delay Counter
  
  DrawScene(0)
  Delay(1)
Until Quit = 1
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 252
; FirstLine = 234
; Folding = -
; EnableAsm
; EnableXP