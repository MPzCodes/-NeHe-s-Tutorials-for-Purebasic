;NeHe's Outline Font Tutorial (Lesson 14)
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/outline_fonts/15004/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global hDC.i ;Private GDI Device Context

Global base.l ;Base Display List For The Font Set
Global rot.f ;Used To Rotate The Text

#WGL_FONT_POLYGONS=1 ;for wglUseFontOutlines_()

Structure POINTFLOAT ;wingdi.h structure
  x.f : y.f
EndStructure

Structure GLYPHMETRICSFLOAT ;wingdi.h structure
  gmfBlackBoxX.f
  gmfBlackBoxY.f
  gmfptGlyphOrigin.POINTFLOAT
  gmfCellIncX.f
  gmfCellIncY.f
EndStructure

Global Dim gmf.GLYPHMETRICSFLOAT(256) ;Storage For Information About Our Outline Font Characters

Global swidth.l ;screen width (Note: added code to print window size)
Global sheight.l ;screen height

Global light.b=#True ;Lighting ON/OFF
Global lp.b ;L Pressed? Note: added L key code to toggle lighting

Procedure BuildFont(name.s,bold.l,italic.b,symbol.l,depth.f,blocky.f) ;Build Our Outline Font
  
  Protected font.l ;Windows Font ID
  Protected oldfont.l ;Used For Good House Keeping
  
  If bold : bold=#FW_BOLD : Else : bold=#FW_NORMAL : EndIf ;font weight
  If symbol : symbol=#SYMBOL_CHARSET : Else : symbol=#ANSI_CHARSET : EndIf ;character set
  If blocky : blocky=0.1 : Else : blocky=0.0 : EndIf ;blocky font shape
  
  base=glGenLists_(256) ;Storage For 256 Characters
  
  ;CreateFont_(Height, Width, Angle Of Escapement, Orientation Angle, Weight, Italic, Underline, Strikeout, Character Set, Output Precision, Clipping Precision, Output Quality, Family And Pitch, Name)
  font=CreateFont_(0,0,0,0,bold,italic,#False,#False,symbol,#OUT_TT_PRECIS,#CLIP_DEFAULT_PRECIS,#ANTIALIASED_QUALITY,#FF_DONTCARE | #DEFAULT_PITCH,name)
  
  oldfont=SelectObject_(hDC,font) ;Selects The Font We Created
  
  ;wglUseFontOutlines_(DC, Starting Character, Number Of Display Lists, Starting Display List, Deviation From True Outlines, Font Thickness, Use Polygons, Buffer To Receive Data)
  wglUseFontOutlines_(hDC,0,255,base,blocky,depth,#WGL_FONT_POLYGONS,gmf(0))
  
  SelectObject_(hDC,oldfont) ;reselect the old font again
  DeleteObject_(font) ;Delete The Font
  
EndProcedure

Procedure KillFont() ;Delete The Font List
  
  glDeleteLists_(base,256) ;Delete All 256 Characters
  
EndProcedure

Procedure glPrint(text.s) ;Custom GL "Print" Routine
  
  If text="" ;If There's No Text
    ProcedureReturn #False ;Do Nothing
  EndIf
  
  Protected length.f ;Used To Find The Length Of The Text
  Protected LOOP.l ;Loop Variable
  
  For LOOP=0 To Len(text)-1 ;Loop To Find Text Length
    length=length+gmf(Asc(Mid(text,LOOP+1,1)))\gmfCellIncX ;Increase Length By Each Characters Width
  Next
  
  glTranslatef_(-length/2,0.0,0.0) ;Center Our Text On The Screen
  
  glPushAttrib_(#GL_LIST_BIT) ;Pushes The Display List Bits
  glListBase_(base)           ;Sets The Base Character to 0
  
  *pointer = Ascii(text)
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

 ;BuildFont(name,bold,italic,symbol,depth,blocky)
 BuildFont("Comic Sans MS",1,0,0,0.2,0) ;Build The Outline Font
  
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  
 glEnable_(#GL_LIGHT0) ;Enable Default Light (Quick And Dirty)
 glEnable_(#GL_LIGHTING) ;Enable Lighting
 glEnable_(#GL_COLOR_MATERIAL) ;Enable Coloring Of Material
 
 ProcedureReturn #True ;Initialization Went OK
 
EndProcedure

Procedure DrawScene(Gadget)
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  glLoadIdentity_() ;Reset The Current Modelview Matrix
  
  glTranslatef_(0.0,0.0,-10.0) ;Move 10 Units Into The Screen
  
  glRotatef_(rot,1.0,0.0,0.0) ;Rotate On The X Axis
  glRotatef_(rot*1.5,0.0,1.0,0.0) ;Rotate On The Y Axis
  glRotatef_(rot*1.4,0.0,0.0,1.0) ;Rotate On The Z Axis
  
  ;Pulsing Colors Based On The Rotation
  glColor3f_(1.0*Cos(rot/20.0),1.0*Sin(rot/25.0),1.0-0.5*Cos(rot/17.0))
  glPrint("NeHe - "+StrF(rot/50,2)) ;Print GL Text To The Screen
  
  glLoadIdentity_() ;reset the current matrix
  glTranslatef_(3.0*Cos(rot/50.0),-2.5,-7.0) ;move -3..3 across, 2.5 down and 7 away
  glRotatef_(-30.0,1.0,0.0,0.0) ;tilt -30 degrees on the x axis
  glPrint(Str(WindowWidth(0))+"x"+Str(WindowHeight(0))) ;print window size at the bottom
  
  rot+0.1 ;Increase The Rotation Variable
  
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
CreateGLWindow("NeHe's Outline Font Tutorial (Lesson 14)",640,480,16,0)

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
     lp=#False ;If So, lp Becomes FALSE
  EndIf

  DrawScene(0)
  Delay(1)
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 96
; FirstLine = 92
; Folding = --
; EnableAsm
; EnableXP