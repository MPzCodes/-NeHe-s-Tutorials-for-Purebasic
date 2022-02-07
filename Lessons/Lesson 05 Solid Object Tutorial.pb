;NeHe's 3D Shapes (Lesson 5) 
;http://nehe.gamedev.net 
;http://nehe.gamedev.net/tutorial/your_first_polygon/13005/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global rtri.f, rquad.f

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
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations  
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
 
  glLoadIdentity_();                   // Reset The View
  glTranslatef_(-1.5,0.0,-6.0);             // Move Left And Into The Screen
 
  glRotatef_(rtri,0.0,1.0,0.0);             // Rotate The Pyramid On It's Y Axis
    
  glBegin_(#GL_TRIANGLES);
    glColor3f_(1.0,0.0,0.0);          // Red
    glVertex3f_( 0.0, 1.0, 0.0);          // Top Of Triangle (Front)
    glColor3f_(0.0,1.0,0.0);          // Green
    glVertex3f_(-1.0,-1.0, 1.0);          // Left Of Triangle (Front)
    glColor3f_(0.0,0.0,1.0);          // Blue
    glVertex3f_( 1.0,-1.0, 1.0);          // Right Of Triangle (Front)
    
    glColor3f_(1.0,0.0,0.0);          // Red
    glVertex3f_( 0.0, 1.0, 0.0);          // Top Of Triangle (Right)
    glColor3f_(0.0,0.0,1.0);          // Blue
    glVertex3f_( 1.0,-1.0, 1.0);          // Left Of Triangle (Right)
    glColor3f_(0.0,1.0,0.0);          // Green
    glVertex3f_( 1.0,-1.0, -1.0);         // Right Of Triangle (Right)
    
    glColor3f_(1.0,0.0,0.0);          // Red    
    glVertex3f_( 0.0, 1.0, 0.0);          // Top Of Triangle (Back)
    glColor3f_(0.0,1.0,0.0);          // Green
    glVertex3f_( 1.0,-1.0, -1.0);         // Left Of Triangle (Back)
    glColor3f_(0.0,0.0,1.0);          // Blue
    glVertex3f_(-1.0,-1.0, -1.0);         // Right Of Triangle (Back)
    
    glColor3f_(1.0,0.0,0.0);          // Red
    glVertex3f_( 0.0, 1.0, 0.0);          // Top Of Triangle (Left)
    glColor3f_(0.0,0.0,1.0);          // Blue
    glVertex3f_(-1.0,-1.0,-1.0);          // Left Of Triangle (Left)
    glColor3f_(0.0,1.0,0.0);          // Green
    glVertex3f_(-1.0,-1.0, 1.0);          // Right Of Triangle (Left)
  glEnd_();                            // Finished Drawing The Triangle
  
  glLoadIdentity_();
  glTranslatef_(1.5,0.0,-7.0);              // Move Right And Into The Screen
  glRotatef_(rquad,1.0,1.0,1.0);            // Rotate The Cube On X, Y & Z
  
  glBegin_(#GL_QUADS);                      // Draw A Quad
    glColor3f_(0.0,1.0,0.0);          // Set The Color To Green
    glVertex3f_( 1.0, 1.0,-1.0);          // Top Right Of The Quad (Top)
    glVertex3f_(-1.0, 1.0,-1.0);          // Top Left Of The Quad (Top)
    glVertex3f_(-1.0, 1.0, 1.0);          // Bottom Left Of The Quad (Top)
    glVertex3f_( 1.0, 1.0, 1.0);          // Bottom Right Of The Quad (Top)

    glColor3f_(1.0,0.5,0.0);          // Set The Color To Orange
    glVertex3f_( 1.0,-1.0, 1.0);          // Top Right Of The Quad (Bottom)
    glVertex3f_(-1.0,-1.0, 1.0);          // Top Left Of The Quad (Bottom)
    glVertex3f_(-1.0,-1.0,-1.0);          // Bottom Left Of The Quad (Bottom)
    glVertex3f_( 1.0,-1.0,-1.0);          // Bottom Right Of The Quad (Bottom)
    
    glColor3f_(1.0,0.0,0.0);          // Set The Color To Red
    glVertex3f_( 1.0, 1.0, 1.0);          // Top Right Of The Quad (Front)
    glVertex3f_(-1.0, 1.0, 1.0);          // Top Left Of The Quad (Front)
    glVertex3f_(-1.0,-1.0, 1.0);          // Bottom Left Of The Quad (Front)
    glVertex3f_( 1.0,-1.0, 1.0);          // Bottom Right Of The Quad (Front)

    glColor3f_(1.0,1.0,0.0);          // Set The Color To Yellow
    glVertex3f_( 1.0,-1.0,-1.0);          // Bottom Left Of The Quad (Back)
    glVertex3f_(-1.0,-1.0,-1.0);          // Bottom Right Of The Quad (Back)
    glVertex3f_(-1.0, 1.0,-1.0);          // Top Right Of The Quad (Back)
    glVertex3f_( 1.0, 1.0,-1.0);          // Top Left Of The Quad (Back)

    glColor3f_(0.0,0.0,1.0);          // Set The Color To Blue
    glVertex3f_(-1.0, 1.0, 1.0);          // Top Right Of The Quad (Left)
    glVertex3f_(-1.0, 1.0,-1.0);          // Top Left Of The Quad (Left)
    glVertex3f_(-1.0,-1.0,-1.0);          // Bottom Left Of The Quad (Left)
    glVertex3f_(-1.0,-1.0, 1.0);          // Bottom Right Of The Quad (Left)

    glColor3f_(1.0,0.0,1.0);          // Set The Color To Violet
    glVertex3f_( 1.0, 1.0,-1.0);          // Top Right Of The Quad (Right)
    glVertex3f_( 1.0, 1.0, 1.0);          // Top Left Of The Quad (Right)
    glVertex3f_( 1.0,-1.0, 1.0);          // Bottom Left Of The Quad (Right)
    glVertex3f_( 1.0,-1.0,-1.0);          // Bottom Right Of The Quad (Right)
        
  glEnd_();
  
  rtri + 0.2;                     // Increase The Rotation Variable For The Triangle
  rquad - 0.15;                       // Decrease The Rotation Variable For The Quad 

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

CreateGLWindow("OpenGL Lesson 5",640,480,16,0)

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
  
  DrawScene(0)
  Delay(20)
Until Quit = 1
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 162
; FirstLine = 51
; Folding = -
; EnableAsm
; EnableXP
; DisableDebugger