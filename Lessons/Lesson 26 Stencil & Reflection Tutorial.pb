;Banu Octavian & NeHe's Stencil & Reflection Tutorial (Lesson 26)
;http://nehe.gamedev.net and http://www.tiptup.com
;https://nehe.gamedev.net/tutorial/clipping__reflections_using_the_stencil_buffer/17004/
;Note: requires bitmaps in paths "Data/EnvWall.bmp", "Data/Ball.bmp",
;"Data/EnvRoll.bmp"
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 30 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

;Light Parameters
Global Dim LightAmb.f(4) ;Ambient Light
LightAmb(0)=0.7 : LightAmb(1)=0.7 : LightAmb(2)=0.7 : LightAmb(3)=1.0
Global Dim LightDif.f(4) ;Diffuse Light
LightDif(0)=1.0 : LightDif(1)=1.0 : LightDif(2)=1.0 : LightDif(3)=1.0
Global Dim LightPos.f(4) ;Light Position
LightPos(0)=4.0 : LightPos(1)=4.0 : LightPos(2)=6.0 : LightPos(3)=1.0

Global q.i ;Quadratic For Drawing A Sphere

Global xrot.f=0.0 ;X Rotation
Global yrot.f=0.0 ;Y Rotation
Global xrotspeed.f=0.0 ;X Rotation Speed
Global yrotspeed.f=0.0 ;Y Rotation Speed
Global zoom.f=-7.0 ;Depth Into The Screen
Global height.f=0.5 ;Height Of Ball From Floor

Global Dim texture.l(3) ;3 Textures

Procedure.l LoadGLTextures() ;Load Bitmaps And Convert To Textures

  ;Load The Bitmap, Check For Errors, If Bitmap's Not Found Quit
  
  Define.i img1 = LoadImage(0,"Data/Envwall.bmp") ; Load texture with name
  Define.i img2 = LoadImage(1,"Data/Ball.bmp") ; Load texture with name
  Define.i img3 = LoadImage(2,"Data/Envroll.bmp") ; Load texture with name
  
  If img1 And img2 And img3
    
    Dim *Pointer(3)
    
    *pointer(0) = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(0)
    *pointer(1) = EncodeImage(1, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(1)
    *pointer(2) = EncodeImage(2, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(2)
    
    Status=#True ;Set The Status To TRUE
    
    glGenTextures_(3,@texture(0)) ;Create The Texture
    
    For LOOP=0 To 3-1 ;Loop Through 5 Textures
      glBindTexture_(#GL_TEXTURE_2D,texture(LOOP))
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
      glTexImage2D_(#GL_TEXTURE_2D,0,3,PeekL(*pointer(LOOP)+18),PeekL(*pointer(LOOP)+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE,*pointer(LOOP)+54)
    Next

  EndIf
  
  For LOOP=0 To 3-1
    If *pointer(LOOP) ;If Texture Exists
       FreeMemory(*pointer(LOOP)) ;Free The Texture Image Memory
    EndIf
  Next
  
  ProcedureReturn Status ;Return The Status
  
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

  If LoadGLTextures()=0 ;If Loading The Textures Failed
    ProcedureReturn #False ;Return False
  EndIf
  
  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.2,0.5,1.0,1.0) ;Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glClearStencil_(0) ;Clear The Stencil Buffer To 0
  glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
  glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
  glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  glEnable_(#GL_TEXTURE_2D) ;Enable 2D Texture Mapping
  
  glLightfv_(#GL_LIGHT0,#GL_AMBIENT,LightAmb()) ;Set The Ambient Lighting For Light0
  glLightfv_(#GL_LIGHT0,#GL_DIFFUSE,LightDif()) ;Set The Diffuse Lighting For Light0
  glLightfv_(#GL_LIGHT0,#GL_POSITION,LightPos()) ;Set The Position For Light0
  
  glEnable_(#GL_LIGHT0) ;Enable Light 0
  glEnable_(#GL_LIGHTING) ;Enable Lighting
  
  q=gluNewQuadric_() ;Create A New Quadratic
  gluQuadricNormals_(q,#GL_SMOOTH) ;Generate Smooth Normals For The Quad
  gluQuadricTexture_(q,#GL_TRUE) ;Enable Texture Coords For The Quad
  
  glTexGeni_(#GL_S,#GL_TEXTURE_GEN_MODE,#GL_SPHERE_MAP) ;Set Up Sphere Mapping
  glTexGeni_(#GL_T,#GL_TEXTURE_GEN_MODE,#GL_SPHERE_MAP) ;Set Up Sphere Mapping
  
  ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawObject() ;Draw Our Ball
  
  glColor3f_(1.0,1.0,1.0) ;Set Color To White
  glBindTexture_(#GL_TEXTURE_2D,texture(1)) ;Select Texture 2 (Ball.bmp)
  gluSphere_(q,0.35,32,16) ;Draw First Sphere
  
  glBindTexture_(#GL_TEXTURE_2D,texture(2)) ;Select Texture 3 (EnvRoll.bmp)
  glColor4f_(1.0,1.0,1.0,0.4) ;Set Color To White With 40% Alpha
  glEnable_(#GL_BLEND) ;Enable Blending
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Set Blending Mode To Mix Based On SRC Alpha
  glEnable_(#GL_TEXTURE_GEN_S) ;Enable Sphere Mapping
  glEnable_(#GL_TEXTURE_GEN_T) ;Enable Sphere Mapping
  
  gluSphere_(q,0.35,32,16) ;Draw Another Sphere Using New Texture
  ;Textures Will Mix Creating A MultiTexture Effect (Reflection)
  glDisable_(#GL_TEXTURE_GEN_S) ;Disable Sphere Mapping
  glDisable_(#GL_TEXTURE_GEN_T) ;Disable Sphere Mapping
  glDisable_(#GL_BLEND) ;Disable Blending
  
EndProcedure

Procedure DrawFloor() ;Draws The Floor
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Texture 1 (EnvWall.bmp)
  glBegin_(#GL_QUADS) ;Begin Drawing A Quad
  glNormal3f_(0.0, 1.0, 0.0) ;Normal Pointing Up
  glTexCoord2f_(0.0, 1.0) ;Top Left Of Texture
  glVertex3f_(-2.0, 0.0, 2.0) ;Top Left Corner Of Floor
  
  glTexCoord2f_(0.0, 0.0) ;Bottom Left Of Texture
  glVertex3f_(-2.0, 0.0,-2.0) ;Bottom Left Corner Of Floor
  
  glTexCoord2f_(1.0, 0.0) ;Bottom Right Of Texture
  glVertex3f_( 2.0, 0.0,-2.0) ;Bottom Right Corner Of Floor
  
  glTexCoord2f_(1.0, 1.0) ;Top Right Of Texture
  glVertex3f_( 2.0, 0.0, 2.0) ;Top Right Corner Of Floor
  glEnd_() ;Done Drawing The Quad
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  ;Clear Screen, Depth Buffer & Stencil Buffer
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT)
  
  ;Clip Plane Equations
  Protected Dim eqr.d(4) ;Plane Equation To Use For The Reflected Objects
  eqr(0)=0.0 : eqr(1)=-1.0 : eqr(2)=0.0 : eqr(3)=0.0
  
  glLoadIdentity_() ;Reset The Modelview Matrix
  glTranslatef_( 0.0,-0.6, zoom) ;Zoom And Raise Camera Above The Floor (Up 0.6 Units)
  glColorMask_(0,0,0,0) ;Set Color Mask
  
  glEnable_(#GL_STENCIL_TEST) ;Enable Stencil Buffer For "marking" The Floor
  glStencilFunc_(#GL_ALWAYS,1,1) ;Always Passes, 1 Bit Plane, 1 As Mask (We Set The Stencil Buffer To 1 Where We Draw Any Polygon)
  glStencilOp_(#GL_KEEP,#GL_KEEP,#GL_REPLACE) ;Keep If Test Fails, Keep If Test Passes But Buffer Test Fails, Replace If Test Passes
  glDisable_(#GL_DEPTH_TEST) ;Disable Depth Testing
  DrawFloor() ;Draw The Floor (Draws To The Stencil Buffer) We Only Want To Mark It In The Stencil Buffer
  
  glEnable_(#GL_DEPTH_TEST) ;Enable Depth Testing
  glColorMask_(1,1,1,1) ;Set Color Mask to TRUE, TRUE, TRUE, TRUE
  glStencilFunc_(#GL_EQUAL,1,1) ;We Draw Only Where The Stencil Is 1 (I.E. Where The Floor Was Drawn)
  glStencilOp_(#GL_KEEP,#GL_KEEP,#GL_KEEP) ;Don't Change The Stencil Buffer
  
  glEnable_(#GL_CLIP_PLANE0) ;Enable Clip Plane For Removing Artifacts (When The Object Crosses The Floor)
  glClipPlane_(#GL_CLIP_PLANE0, eqr()) ;Equation For Reflected Objects
  glPushMatrix_() ;Push The Matrix Onto The Stack
  glScalef_( 1.0,-1.0, 1.0) ;Mirror Y Axis
  glLightfv_(#GL_LIGHT0,#GL_POSITION,LightPos()) ;Set Up Light0
  glTranslatef_( 0.0, height, 0.0) ;Position The Object
  glRotatef_(xrot,1.0,0.0,0.0) ;Rotate Local Coordinate System On X Axis
  glRotatef_(yrot,0.0,1.0,0.0) ;Rotate Local Coordinate System On Y Axis
  DrawObject() ;Draw The Sphere (Reflection)
  glPopMatrix_() ;Pop The Matrix Off The Stack
  glDisable_(#GL_CLIP_PLANE0) ;Disable Clip Plane For Drawing The Floor
  glDisable_(#GL_STENCIL_TEST) ;We Don't Need The Stencil Buffer Any More (Disable)
  
  glLightfv_(#GL_LIGHT0,#GL_POSITION,LightPos()) ;Set Up Light0 Position
  glEnable_(#GL_BLEND) ;Enable Blending (Otherwise The Reflected Object Wont Show)
  glDisable_(#GL_LIGHTING) ;Since We Use Blending, We Disable Lighting
  glColor4f_(1.0,1.0,1.0,0.8) ;Set Color To White With 80% Alpha
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA) ;Blending Based On Source Alpha And 1 Minus Dest Alpha
  DrawFloor() ;Draw The Floor To The Screen
  
  glEnable_(#GL_LIGHTING) ;Enable Lighting
  glDisable_(#GL_BLEND) ;Disable Blending
  glTranslatef_( 0.0, height, 0.0) ;Position The Ball At Proper Height
  glRotatef_(xrot,1.0,0.0,0.0) ;Rotate On The X Axis
  glRotatef_(yrot,0.0,1.0,0.0) ;Rotate On The Y Axis
  DrawObject() ;Draw The Ball
  
  xrot+xrotspeed ;Update X Rotation Angle By xrotspeed
  yrot+yrotspeed ;Update Y Rotation Angle By yrotspeed
  glFlush_() ;Flush The GL Pipeline
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
  
  ProcedureReturn #True ;Keep Going

EndProcedure

Procedure ProcessKeyboard() ;Process Keyboard Results
  
  If KeyboardPushed(#PB_Key_Right) And yrotspeed<2.5 ;Right Arrow Pressed
    yrotspeed+0.08 ;Increase yrotspeed
  EndIf
  If KeyboardPushed(#PB_Key_Left) And yrotspeed>-2.5 ;Left Arrow Pressed
    yrotspeed-0.08 ;Decrease yrotspeed
  EndIf
  If KeyboardPushed(#PB_Key_Down) And xrotspeed<2.5 ;Down Arrow Pressed
    xrotspeed+0.08 ;Increase xrotspeed
  EndIf
  If KeyboardPushed(#PB_Key_Up) And xrotspeed>-2.5 ;Up Arrow Pressed
    xrotspeed-0.08 ;Decrease xrotspeed
  EndIf
  
  If KeyboardPushed(#PB_Key_A) ;'A' Key Pressed
    zoom+0.05 ;Zoom In
  EndIf
  If KeyboardPushed(#PB_Key_Z) ;'Z' Key Pressed
    zoom-0.05 ;Zoom Out
  EndIf
  
  If KeyboardPushed(#PB_Key_PageDown) ;Page Up Key Pressed
    height+0.03 ;Move Ball Up
  EndIf
  If KeyboardPushed(#PB_Key_PageUp) ;Page Down Key Pressed
    height-0.03 ;Move Ball Down
  EndIf
  
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
  
  If bits = 32
    OpenGlFlags + #PB_OpenGL_24BitDepthBuffer + #PB_OpenGL_8BitStencilBuffer
  EndIf
  
  If Vsync = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0) 
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  ;hDC = GetDC_(hWnd)
  
EndProcedure

CreateGLWindow("Banu Octavian & NeHe's Stencil & Reflection Tutorial (Lesson 26)",640,480,32,0) ; important 24Bit for Stencil-Puffer 

InitGL() 

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
  
  If KeyboardPushed(#PB_Key_Escape) ;  Esc key to exit
    Quit = 1
  EndIf 
  
  ProcessKeyboard() ;Processed Keyboard Presses 

  DrawScene(0)
  
  Delay(2)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 35
; FirstLine = 17
; Folding = --
; EnableAsm
; EnableXP
; DisableDebugger