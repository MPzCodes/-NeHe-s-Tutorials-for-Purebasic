;NeHe's Texture Mapping Tutorial (Lesson 6) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/texture_mapping/12038/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)


Global xrot.f, yrot.f, zrot.f, Texture.i

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

 glEnable_(#GL_TEXTURE_2D);                        // Enable Texture Mapping ( NEW )
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations  
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure LoadGLTextures(Names.s)
  
  LoadImage(0, Names) ; Load texture with name
  *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  
  ; ----- Generate texture
  glGenTextures_(1, @TextureID.i)
  glBindTexture_(#GL_TEXTURE_2D, TextureID)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer+18),  PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer+54);
  
  FreeMemory(*pointer)
  
  ProcedureReturn TextureID

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
 
  glLoadIdentity_();                   // Reset The View
  glTranslatef_(0.0,0.0,-5.0);                      // Move Into The Screen 5 Units
  
  glRotatef_(xrot,1.0,0.0,0.0);                     // Rotate On The X Axis
  glRotatef_(yrot,0.0,1.0,0.0);                     // Rotate On The Y Axis
  glRotatef_(zrot,0.0,0.0,1.0);                     // Rotate On The Z Axis
  
  glBindTexture_(#GL_TEXTURE_2D, Texture);               // Select Our Texture
  
  glBegin_(#GL_QUADS);                      // Draw A Quad
    ;// Front Face
    glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    ;// Back Face
    glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    ;// Top Face
    glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,  1.0,  1.0);  // Bottom Left Of The Texture and Quad
    glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,  1.0,  1.0);  // Bottom Right Of The Texture and Quad
    glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    ;// Bottom Face
    glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, -1.0, -1.0);  // Top Right Of The Texture and Quad
    glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, -1.0, -1.0);  // Top Left Of The Texture and Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    ;// Right face
    glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0, -1.0, -1.0);  // Bottom Right Of The Texture and Quad
    glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0,  1.0, -1.0);  // Top Right Of The Texture and Quad
    glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0,  1.0,  1.0);  // Top Left Of The Texture and Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0, -1.0,  1.0);  // Bottom Left Of The Texture and Quad
    ;// Left Face
    glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0, -1.0, -1.0);  // Bottom Left Of The Texture and Quad
    glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0, -1.0,  1.0);  // Bottom Right Of The Texture and Quad
    glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0,  1.0,  1.0);  // Top Right Of The Texture and Quad
    glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0,  1.0, -1.0);  // Top Left Of The Texture and Quad
        
  glEnd_();
  
  ;glutSolidTeapot_(1.0)
  
  xrot + 0.3;                             // X Axis Rotation
  yrot + 0.2;                             // Y Axis Rotation
  zrot + 0.4;                             // Z Axis Rotation

   SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
EndProcedure

Procedure HandleError (Result, Text$)
  If Result = 0
    MessageRequester("Error", Text$, 0)
    End
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
  
  If Vsync = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0) 
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  ;hDC = GetDC_(hWnd)
  
EndProcedure


CreateGLWindow("OpenGL Lesson 6",640,480,16,0)

InitGL() 
  
Texture.i = LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")
;Texture.i = LoadGLTextures("Data/NeHe.bmp")

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
  Delay(20)
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 39
; FirstLine = 23
; Folding = --
; EnableAsm
; EnableXP