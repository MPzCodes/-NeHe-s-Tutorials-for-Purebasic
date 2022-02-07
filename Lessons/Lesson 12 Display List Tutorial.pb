;NeHe's Collision Detection Tutorial (Lesson 12) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/display_lists/15003/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

UsePNGImageDecoder() 

Global Dim texture.l(1) ;Storage For One Texture

Global box.l ;Storage For The Box Display List
Global top.l ;Storage For The Top Display List
Global xloop.l ;Loop For X Axis
Global yloop.l ;Loop For Y Axis

Global xrot.f ;Rotates Cube On The X Axis
Global yrot.f ;Rotates Cube On The Y Axis

Global light.b=#True ;Lighting ON/OFF
Global lp.b ;L Pressed? Note: added L key code to toggle lighting

Structure RGB ;structure for color RGB floats
  r.f : g.f : b.f
EndStructure

Global Dim boxcol.RGB(5) ;Array For Box Colors
boxcol(0)\r=1.0 : boxcol(0)\g=0.0 : boxcol(0)\b=0.0 ;Bright Red
boxcol(1)\r=1.0 : boxcol(1)\g=0.5 : boxcol(1)\b=0.0 ;Bright Orange
boxcol(2)\r=1.0 : boxcol(2)\g=1.0 : boxcol(2)\b=0.0 ;Bright Yellow
boxcol(3)\r=0.0 : boxcol(3)\g=1.0 : boxcol(3)\b=0.0 ;Bright Green
boxcol(4)\r=0.0 : boxcol(4)\g=1.0 : boxcol(4)\b=1.0 ;Bright Blue

Global Dim topcol.RGB(5) ;Array For Top Colors
topcol(0)\r=0.5 : topcol(0)\g=0.0  : topcol(0)\b=0.0 ;Dark Red
topcol(1)\r=0.5 : topcol(1)\g=0.25 : topcol(1)\b=0.0 ;Dark Orange
topcol(2)\r=0.5 : topcol(2)\g=0.5  : topcol(2)\b=0.0 ;Dark Yellow
topcol(3)\r=0.0 : topcol(3)\g=0.5  : topcol(3)\b=0.0 ;Dark Green
topcol(4)\r=0.0 : topcol(4)\g=0.5  : topcol(4)\b=0.5 ;Dark Blue

Procedure BuildLists() ;Build Cube Display Lists
  
  box=glGenLists_(2) ;Generate 2 Different Lists
  
  glNewList_(box,#GL_COMPILE) ;New Compiled box Display List
  glBegin_(#GL_QUADS) ;Start Drawing Quads
  ;Bottom Face
  glNormal3f_( 0.0,-1.0, 0.0) ;Normal Pointing Down
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  ;Front Face
  glNormal3f_( 0.0, 0.0, 1.0) ;Normal Pointing Towards
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Top Left Of The Texture and Quad
  ;Back Face
  glNormal3f_( 0.0, 0.0,-1.0) ;Normal Pointing Away
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Bottom Left Of The Texture and Quad
  ;Right face
  glNormal3f_( 1.0, 0.0, 0.0) ;Normal Pointing Right
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  ;Left Face
  glNormal3f_(-1.0, 0.0, 0.0) ;Normal Pointing Left
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glEnd_() ;Done Drawing Quads
  glEndList_() ;Done Building The box List
  
  top=box+1 ;top List Value Is box List Value +1
  
  glNewList_(top,#GL_COMPILE) ;New Compiled top Display List
  glBegin_(#GL_QUADS) ;Start Drawing Quad
  ;Top Face
  glNormal3f_( 0.0, 1.0, 0.0) ;Normal Pointing Up
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  glEnd_() ;Done Drawing Quad
  glEndList_() ;Done Building The top Display List
  
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

  glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
  glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
  glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Nice Perspective Correction
  
  glEnable_(#GL_LIGHT0) ;Quick And Dirty Lighting (Assumes Light0 Is Set Up)
  glEnable_(#GL_LIGHTING) ;Enable Lighting
  glEnable_(#GL_COLOR_MATERIAL) ;Enable Material Coloring
 
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
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer+18), PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,*pointer+54);
  
  FreeMemory(*pointer)
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select The Texture
  
  For yloop=1 To 6-1 ;Loop Through The Y Plane
    For xloop=0 To yloop-1 ;Loop Through The X Plane
      glLoadIdentity_() ;Reset The View
      ;Position The Cubes On The Screen
      glTranslatef_(1.4+(xloop*2.8)-(yloop*1.4),((6.0-yloop)*2.4)-7.0,-20.0)
      glRotatef_(45.0-(2.0*yloop)+xrot,1.0,0.0,0.0) ;Tilt The Cubes Up And Down
      glRotatef_(45.0+yrot,0.0,1.0,0.0) ;Spin Cubes Left And Right
      
      glColor3fv_(boxcol(yloop-1)) ;Select A Box Color
      glCallList_(box) ;Draw The Box
      glColor3fv_(topcol(yloop-1)) ;Select The Top Color
      glCallList_(top) ;Draw The Top
    Next
  Next
  
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


CreateGLWindow("OpenGL Lesson 12",640,480,16,0)

InitGL()

BuildLists()

LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Caisse.png")
;LoadGLTextures("Data/Cube.bmp") ; -> Original from http://nehe.gamedev.net

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
  
  If KeyboardPushed(#PB_Key_L) And lp=0 ;L Key Being Pressed Not Held?
     lp=#True ;lp Becomes TRUE
     light=~light & 1 ;Toggle Light TRUE/FALSE
     If light=0 ;If Not Light
        glDisable_(#GL_LIGHTING) ;Disable Lighting
     Else ;Otherwise
        glEnable_(#GL_LIGHTING) ;Enable Lighting
     EndIf
  EndIf
  
  If Not KeyboardPushed(#PB_Key_L) ;Has L Key Been Released?
    lp=#False      ;If So, lp Becomes FALSE
  EndIf
        
  If KeyboardPushed(#PB_Key_Left) ;Left Arrow Being Pressed?
          yrot-0.2 ;If So Spin Cubes Left
  EndIf
  If KeyboardPushed(#PB_Key_Right) ;Right Arrow Being Pressed?
     yrot+0.2 ;If So Spin Cubes Right
  EndIf
  
  If KeyboardPushed(#PB_Key_Up) ;Up Arrow Being Pressed?
     xrot-0.2 ;If So Tilt Cubes Up
  EndIf
  If KeyboardPushed(#PB_Key_Down) ;Down Arrow Being Pressed?
    xrot+0.2        ;If So Tilt Cubes Down 
  EndIf

  DrawScene(0)
  Delay(10)
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 143
; FirstLine = 117
; Folding = --
; EnableAsm
; EnableXP