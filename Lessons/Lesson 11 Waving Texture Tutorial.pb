;NeHe's Flag Effect (Waving Texture) Tutorial (Lesson 11) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/flag_effect_(waving_texture)/16002/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global Dim points.f(44,44,2) ;The Array For The Points On The Grid Of Our "Wave"
Global wiggle_count.l=0 ;Counter Used To Control How Fast Flag Waves

Global xrot.f ;X Rotation
Global yrot.f ;Y Rotation
Global zrot.f ;Z Rotation
Global hold.f ;Temporarily Holds A Floating Point Value

Global Dim Texture.l(1) ;Storage For One Texture

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

 glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  
 glPolygonMode_(#GL_BACK,#GL_FILL) ;Back Face Is Solid
 glPolygonMode_(#GL_FRONT,#GL_LINE);Front Face Is Made Of Lines
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure LoadGLTextures(Names.s)
  
  LoadImage(0, Names) ; Load texture with name
  *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  
  glGenTextures_(1,@Texture(0)) ;Create The Texture
    
  ;Typical Texture Generation Using Data From The Bitmap
  glBindTexture_(#GL_TEXTURE_2D, Texture(0));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,PeekL(*pointer+18),PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54);
  
  FreeMemory(*pointer)
  
EndProcedure

Procedure SetupWorld() ;Setup Our World
  
  Protected x.l,y.l ;Loop Variables
  
  For x=0 To 45-1 ;Loop Through The X Plane (45 Points)
    For y=0 To 45-1 ;Loop Through The Y Plane (45 Points)
      ;Apply The Wave To Our Mesh
      points(x,y,0)=(x/5.0)-4.5 ;vertex x position
      points(x,y,1)=(y/5.0)-4.5 ;vertex y position
      points(x,y,2)=Sin((((x/5.0)*40.0)/360.0)*3.141592654*2.0) ;vertex z position
    Next
  Next
  
  ProcedureReturn #True ;Jump Back
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  Protected x.l,y.l ;Loop Variables
  Protected float_x.f,float_y.f,float_xb.f,float_yb.f ;Used To Break The Flag Into Tiny Quads
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The Current Matrix
  
  glTranslatef_(0.0,0.0,-12.0) ;Translate 12 Units Into The Screen
  
  glRotatef_(xrot,1.0,0.0,0.0) ;Rotate On The X Axis
  glRotatef_(yrot,0.0,1.0,0.0) ;Rotate On The Y Axis
  glRotatef_(zrot,0.0,0.0,1.0) ;Rotate On The Z Axis
  
  glBindTexture_(#GL_TEXTURE_2D,Texture(0)) ;Select Our Texture
  
  glBegin_(#GL_QUADS) ;Start Drawing Our Quads
  For x=0 To 44-1 ;Loop Through The X Plane (44 Points)
    For y=0 To 44-1 ;Loop Through The Y Plane (44 Points)
      float_x=x/44.0 ;Create A Floating Point X Value
      float_y=y/44.0 ;Create A Floating Point Y Value
      float_xb=(x+1)/44.0 ;Create A Floating Point Y Value+0.0227
      float_yb=(y+1)/44.0 ;Create A Floating Point Y Value+0.0227
      
      glTexCoord2f_( float_x, float_y) ;First Texture Coordinate (Bottom Left)
      glVertex3f_( points(x,y,0), points(x,y,1), points(x,y,2))
      
      glTexCoord2f_( float_x, float_yb) ;Second Texture Coordinate (Top Left)
      glVertex3f_( points(x,y+1,0), points(x,y+1,1), points(x,y+1,2))
      
      glTexCoord2f_( float_xb, float_yb) ;Third Texture Coordinate (Top Right)
      glVertex3f_( points(x+1,y+1,0), points(x+1,y+1,1), points(x+1,y+1,2))
      
      glTexCoord2f_( float_xb, float_y) ;Fourth Texture Coordinate (Bottom Right)
      glVertex3f_( points(x+1,y,0), points(x+1,y,1), points(x+1,y,2))
    Next
  Next
  glEnd_() ;Done Drawing Our Quads
  
  If wiggle_count=2 ;Used To Slow Down The Wave (Every 2nd Frame Only)
    For y=0 To 45-1 ;Loop Through The Y Plane (45 Points)
      hold=points(0,y,2) ;Store Current Value One Left Side Of Wave
      For x=0 To 44-1 ;Loop Through The X Plane (44 Points)
        ;Current Wave Value Equals Value To The Right
        points(x,y,2)=points(x+1,y,2)
      Next
      points(44,y,2)=hold ;Last Value Becomes The Far Left Stored Value
    Next
    wiggle_count=0 ;Set Counter Back To Zero
  EndIf
  
  wiggle_count+1 ;Increase The Counter
  
  xrot+0.3 ;Increase The X Rotation Variable
  yrot+0.2 ;Increase The Y Rotation Variable
  zrot+0.4 ;Increase The Z Rotation Variable

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

CreateGLWindow("OpenGL Lesson 11",640,480,16,0)

InitGL()

setupworld()

LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")
;LoadGLTextures("Data/Tim.bmp") ; -> Original from http://nehe.gamedev.net

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
   
  DrawScene(0)
  
  Delay(10)
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 65
; FirstLine = 53
; Folding = --
; EnableAsm
; EnableXP