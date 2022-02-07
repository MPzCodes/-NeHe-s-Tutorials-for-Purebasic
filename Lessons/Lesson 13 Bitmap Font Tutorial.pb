;Nehe's Bitmap Font Tutorial (Lesson 13)
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/bitmap_fonts/17002/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global hDC.i ;Private GDI Device Context
Global base.l ;Base Display List For The Font Set
Global cnt1.f ;1st Counter Used To Move Text & For Coloring
Global cnt2.f ;2nd Counter Used To Move Text & For Coloring

Global swidth.l ;screen width (Note: added code to print window size)
Global sheight.l ;screen height

Procedure BuildFont(name.s,height.l,bold.l,italic.b,symbol.l) ;Build Our Bitmap Font

 Protected font.l ;Windows Font ID
 Protected oldfont.l ;Used For Good House Keeping
 
 If bold : bold=#FW_BOLD : Else : bold=#FW_NORMAL : EndIf ;font weight
 If symbol : symbol=#SYMBOL_CHARSET : Else : symbol=#ANSI_CHARSET : EndIf ;character set
 
 base=glGenLists_(96) ;Storage For 96 Characters
 
 ;CreateFont_(Height, Width, Angle Of Escapement, Orientation Angle, Weight, Italic, Underline, Strikeout, Character Set, Output Precision, Clipping Precision, Output Quality, Family And Pitch, Name)
 font=CreateFont_(-height,0,0,0,bold,italic,#False,#False,symbol,#OUT_TT_PRECIS,#CLIP_DEFAULT_PRECIS,#ANTIALIASED_QUALITY,#FF_DONTCARE | #DEFAULT_PITCH,name)
 
 oldfont=SelectObject_(hDC,font) ;Selects The Font We Want
 wglUseFontBitmaps_(hDC,32,96,base) ;Builds 96 Characters Starting At Character 32
 SelectObject_(hDC,oldfont) ;reselect the old font again
 DeleteObject_(font) ;Delete The Font
 
EndProcedure

Procedure KillFont() ;Delete The Font List

 glDeleteLists_(base,96) ;Delete All 96 Characters
 
EndProcedure

Procedure glPrint(text.s) ;Custom GL "Print" Routine

 If text="" ;If There's No Text
  ProcedureReturn #False ;Do Nothing
 EndIf
 
 glPushAttrib_(#GL_LIST_BIT) ;Pushes The Display List Bits
 glListBase_(base-32)        ;Sets The Base Character to 32
 *pointer = Ascii(text)      ;Unicode Problem
 ;glCallLists_(Len(text),#GL_UNSIGNED_BYTE,text) ;Draws The Display List Text
 glCallLists_(Len(text),#GL_UNSIGNED_BYTE,*pointer) ;Draws The Display List Text
 FreeMemory(*pointer)
 glPopAttrib_() ;Pops The Display List Bits
 
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

Procedure.l InitGL() ;All Setup For OpenGL Goes Here

 ;BuildFont(name,height,bold,italic,symbol)
 BuildFont("Courier New",24,1,0,0) ;Build The Font
 
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
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  glLoadIdentity_() ;Reset The View
 
  glTranslatef_(0.0,0.0,-1.0) ;Move One Unit Into The Screen
 
  ;Pulsing Colors Based On Text Position
  glColor3f_(1.0*(Cos(cnt1)),1.0*(Sin(cnt2)),1.0-0.5*(Cos(cnt1+cnt2)))
 
  ;Position The Text On The Screen
  glRasterPos2f_(-0.45+0.05*Cos(cnt1),0.4*Sin(cnt2))
  glPrint("Active OpenGL Text With NeHe - "+StrF(cnt1,2)) ;Print GL Text To The Screen
 
  glRasterPos2f_(-0.08+0.45*Sin(cnt2),-0.4) ;position text -0.53..0.37 across, 0.4 down
  glPrint(Str(WindowWidth(0))+"x"+Str(WindowHeight(0))) ;print window size at the bottom
 
  cnt1+0.051 ;Increase The 1st Counter
  cnt2+0.005 ;Increase The 2nd Counter
  
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
  hDC = GetDC_(hWnd)
  
EndProcedure

CreateGLWindow("Nehe's Bitmap Font Tutorial (Lesson 13)",640,480,16,0)

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
        
  If KeyboardPushed(#PB_Key_Escape)    ; // push ESC key
     Quit = 1                               ; // This is the end
  EndIf
  
  DrawScene(0)
  Delay(10)
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 146
; FirstLine = 100
; Folding = --
; EnableAsm
; EnableXP