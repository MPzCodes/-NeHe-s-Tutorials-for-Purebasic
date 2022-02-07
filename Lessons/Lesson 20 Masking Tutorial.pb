;NeHe's Masking Tutorial (Lesson 20)
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/masking/15006/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 29 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global masking.b=#True ;Masking On/Off
Global mp.b ;M Key Pressed?
Global sp.b ;Spacebar Pressed?
Global scene.b ;Which Scene To Draw

Global Dim texture.l(5) ;Storage For Our Five Textures
Global LOOP.l ;Generic Loop Variable

Global roll.f ;Rolling Texture
Procedure LoadGLTextures()
  
  Dim *pointer (5)
  LoadImage(0, "Data/Logo.bmp")
  *pointer(0) = EncodeImage(0, #PB_ImagePlugin_BMP,0,24); 
  LoadImage(1, "Data/Mask1.bmp")
  *pointer(1) = EncodeImage(1, #PB_ImagePlugin_BMP,0,24); 
  LoadImage(2, "Data/Image1.bmp")
  *pointer(2) = EncodeImage(2, #PB_ImagePlugin_BMP,0,24); 
  LoadImage(3, "Data/Mask2.bmp")
  *pointer(3) = EncodeImage(3, #PB_ImagePlugin_BMP,0,24); 
  LoadImage(4, "Data/Image2.bmp")
  *pointer(4) = EncodeImage(4, #PB_ImagePlugin_BMP,0,24); 
  
  FreeImage(0)
  FreeImage(1)
  FreeImage(2)
  FreeImage(3)
  FreeImage(4)
  
  glGenTextures_(5,@texture(0)) ;Create Five Textures
    
  For LOOP=0 To 5-1 ;Loop Through All 5 Textures
     glBindTexture_(#GL_TEXTURE_2D,texture(LOOP))
     glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
     glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
     glTexImage2D_(#GL_TEXTURE_2D,0,3, PeekL(*pointer(LOOP)+18), PeekL(*pointer(LOOP)+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,*pointer(LOOP)+54);
  Next
 
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

  glClearColor_(0.0,0.0,0.0,0.0) ;Clear The Background Color To Black
  glClearDepth_(1.0) ;Enables Clearing Of The Depth Buffer
  glEnable_(#GL_DEPTH_TEST) ;Enable Depth Testing
  glShadeModel_(#GL_SMOOTH) ;Enables Smooth Color Shading
  glEnable_(#GL_TEXTURE_2D) ;Enable 2D Texture Mapping
 
 ProcedureReturn #True ;Initialization Went OK
 
EndProcedure


Procedure DrawScene(Gadget)
   SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
 glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  glLoadIdentity_() ;Reset The Modelview Matrix
  
  glTranslatef_(0.0,0.0,-2.0) ;Move Into The Screen 2 Units
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Logo Texture
  glBegin_(#GL_QUADS) ;Start Drawing A Textured Quad
  glTexCoord2f_(0.0,-roll+0.0) : glVertex3f_(-1.1,-1.1, 0.0) ;Bottom Left
  glTexCoord2f_(3.0,-roll+0.0) : glVertex3f_( 1.1,-1.1, 0.0) ;Bottom Right
  glTexCoord2f_(3.0,-roll+3.0) : glVertex3f_( 1.1, 1.1, 0.0) ;Top Right
  glTexCoord2f_(0.0,-roll+3.0) : glVertex3f_(-1.1, 1.1, 0.0) ;Top Left
  glEnd_() ;Done Drawing The Quad
  
  glEnable_(#GL_BLEND) ;Enable Blending
  glDisable_(#GL_DEPTH_TEST) ;Disable Depth Testing
  
  If masking ;Is Masking Enabled?
    glBlendFunc_(#GL_DST_COLOR,#GL_ZERO) ;Blend Screen Color With Zero (Black)
  EndIf
  
  If scene ;Are We Drawing The Second Scene?
    
    glTranslatef_(0.0,0.0,-1.0) ;Translate Into The Screen One Unit
    glRotatef_(roll*360,0.0,0.0,1.0) ;Rotate On The Z Axis 360 Degrees
    
    If masking ;Is Masking On?
      glBindTexture_(#GL_TEXTURE_2D,texture(3)) ;Select The Second Mask Texture
      glBegin_(#GL_QUADS) ;Start Drawing A Textured Quad
      glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.1,-1.1, 0.0) ;Bottom Left
      glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.1,-1.1, 0.0) ;Bottom Right
      glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.1, 1.1, 0.0) ;Top Right
      glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.1, 1.1, 0.0) ;Top Left
      glEnd_() ;Done Drawing The Quad
    EndIf
    
    glBlendFunc_(#GL_ONE,#GL_ONE) ;Copy Image 2 Color To The Screen
    
    glBindTexture_(#GL_TEXTURE_2D,texture(4)) ;Select The Second Image Texture
    glBegin_(#GL_QUADS) ;Start Drawing A Textured Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.1,-1.1, 0.0) ;Bottom Left
    glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.1,-1.1, 0.0) ;Bottom Right
    glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.1, 1.1, 0.0) ;Top Right
    glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.1, 1.1, 0.0) ;Top Left
    glEnd_() ;Done Drawing The Quad
    
  Else ;Otherwise
    
    If masking ;Is Masking On?
      glBindTexture_(#GL_TEXTURE_2D,texture(1)) ;Select The First Mask Texture
      glBegin_(#GL_QUADS) ;Start Drawing A Textured Quad
      glTexCoord2f_(roll+0.0, 0.0) : glVertex3f_(-1.1,-1.1, 0.0) ;Bottom Left
      glTexCoord2f_(roll+4.0, 0.0) : glVertex3f_( 1.1,-1.1, 0.0) ;Bottom Right
      glTexCoord2f_(roll+4.0, 4.0) : glVertex3f_( 1.1, 1.1, 0.0) ;Top Right
      glTexCoord2f_(roll+0.0, 4.0) : glVertex3f_(-1.1, 1.1, 0.0) ;Top Left
      glEnd_() ;Done Drawing The Quad
    EndIf
    
    glBlendFunc_(#GL_ONE,#GL_ONE) ;Copy Image 1 Color To The Screen
    
    glBindTexture_(#GL_TEXTURE_2D,texture(2)) ;Select The First Image Texture
    glBegin_(#GL_QUADS) ;Start Drawing A Textured Quad
    glTexCoord2f_(roll+0.0, 0.0) : glVertex3f_(-1.1,-1.1, 0.0) ;Bottom Left
    glTexCoord2f_(roll+4.0, 0.0) : glVertex3f_( 1.1,-1.1, 0.0) ;Bottom Right
    glTexCoord2f_(roll+4.0, 4.0) : glVertex3f_( 1.1, 1.1, 0.0) ;Top Right
    glTexCoord2f_(roll+0.0, 4.0) : glVertex3f_(-1.1, 1.1, 0.0) ;Top Left
    glEnd_() ;Done Drawing The Quad
    
  EndIf
  
  glEnable_(#GL_DEPTH_TEST) ;Enable Depth Testing
  glDisable_(#GL_BLEND) ;Disable Blending
  
  roll+0.002 ;Increase Our Texture Roll Variable
  If roll>1.0 ;Is Roll Greater Than One
    roll-1.0 ;Subtract 1 From Roll
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
CreateGLWindow("NeHe's Masking Tutorial (Lesson 20)",640,480,16,0)

InitGL()

LoadGLTextures()

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
  
  
  If KeyboardPushed(#PB_Key_Space) And sp=0 ;Is Spacebar Being Pressed?
     sp=#True ;Spacebar Is Being Held
     scene=~scene & 1 ;Toggle Scene To The Other
  EndIf
  
  If Not KeyboardPushed(#PB_Key_Space) ;Has Spacebar Been Released?
     sp=#False ;Spacebar Is Released
  EndIf
        
  If KeyboardPushed(#PB_Key_M) And mp=0 ;Is M Key Being Pressed?
     mp=#True ;M Key Is Being Held
     masking=~masking & 1 ;Toggle Masking Mode OFF/ON
  EndIf
  
  If Not KeyboardPushed(#PB_Key_M) ;Has M Key Been Released?
     mp=#False ;M Key Is Released
  EndIf
        

  DrawScene(0)
  Delay(4)
  
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableAsm
; EnableXP