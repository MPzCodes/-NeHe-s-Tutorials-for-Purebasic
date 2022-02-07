;NeHe's Rotation Tutorial (Lesson 4) 
;http://nehe.gamedev.net 
;http://nehe.gamedev.net/tutorial/rotation/14001/
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


Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
 
  glLoadIdentity_();                   // Reset The View
  glTranslatef_(-1.5,0.0,-6.0);             // Move Into The Screen And Left
  glRotatef_(rtri,0.0,1.0,0.0);             // Rotate The Triangle On The Y axis ( NEW )
  
  glBegin_(#GL_TRIANGLES);
    glColor3f_(1.0,0.0,0.0);          // Set Top Point Of Triangle To Red
    glVertex3f_( 0.0, 1.0, 0.0);          // First Point Of The Triangle
    glColor3f_(0.0,1.0,0.0);          // Set Left Point Of Triangle To Green
    glVertex3f_(-1.0,-1.0, 0.0);          // Second Point Of The Triangle
    glColor3f_(0.0,0.0,1.0);          // Set Right Point Of Triangle To Blue
    glVertex3f_( 1.0,-1.0, 0.0);          // Third Point Of The Triangle
  glEnd_();                            // Finished Drawing The Triangle
  
  glLoadIdentity_();                   // Reset The Current Modelview Matrix
  glTranslatef_(1.5,0.0,-6.0);              // Move Right 1.5 Units And Into The Screen 6.0  
  glRotatef_(rquad,1.0,0.0,0.0);            // Rotate The Quad On The X axis ( NEW )
  
  glBegin_(#GL_QUADS);                      // Draw A Quad
    glVertex3f_( 1.0, 1.0, 0.0);          // Top Right Of The Quad
    glVertex3f_(-1.0, 1.0, 0.0);          // Top Left Of The Quad
    glVertex3f_(-1.0,-1.0, 0.0);          // Bottom Left Of The Quad
    glVertex3f_( 1.0,-1.0, 0.0);          // Bottom Right Of The Quad
  glEnd_();
  
  rtri + 0.2;                     // Increase The Rotation Variable For The Triangle
  rquad - 0.15;                       // Decrease The Rotation Variable For The Quad 

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


CreateGLWindow("OpenGL Lesson 4",640,480,16,0)

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
; CursorPosition = 14
; FirstLine = 10
; Folding = -
; EnableAsm
; EnableXP
; DisableDebugger