;NeHe's Your First Polygon Tutorial (Lesson 2) 
;http://nehe.gamedev.net 
;http://nehe.gamedev.net/tutorial/your_first_polygon/13002/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

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
  
  glPushMatrix_()                  ; Save the original Matrix coordinates
  glMatrixMode_(#GL_MODELVIEW)
  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
 
  glTranslatef_(-1.5,0.0,-6.0)
  
  glBegin_(#GL_TRIANGLES);                      // Drawing Using Triangles
    glVertex3f_( 0.0, 1.0, 0.0);              // Top
    glVertex3f_(-1.0,-1.0, 0.0);              // Bottom Left
    glVertex3f_( 1.0,-1.0, 0.0);              // Bottom Right
  glEnd_();                            // Finished Drawing The Triangle
  
  glTranslatef_(3,0.0,0.0);                   // Move Right 3 Units
  
  glBegin_(#GL_QUADS);                      // Draw A Quad
    glVertex3f_( 1.0, 1.0, 0.0);              // Top Right
    glVertex3f_(-1.0, 1.0, 0.0);              // Top Left
    glVertex3f_(-1.0,-1.0, 0.0);              // Bottom Left
    glVertex3f_( 1.0,-1.0, 0.0);              // Bottom Right
  glEnd_();

  glPopMatrix_()

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

CreateGLWindow("OpenGL Lesson 2",640,480,16)

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
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 46
; FirstLine = 46
; Folding = -
; EnableAsm
; EnableXP