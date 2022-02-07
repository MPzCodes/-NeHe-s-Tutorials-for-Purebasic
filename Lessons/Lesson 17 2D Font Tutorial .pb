;NeHe & Giuseppe D'Agata's 2D Font Tutorial (Lesson 17)
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/2d_texture_font/18002/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 05 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global hDC.i ;Private GDI Device Context

Global Dim texture.l(2) ;Storage For Our Font Texture
Global base.l ;Base Display List For The Font
Global LOOP.l ;Generic Loop Variable

Global cnt1.f ;1st Counter Used To Move Text & For Coloring
Global cnt2.f ;2nd Counter Used To Move Text & For Coloring

Procedure LoadGLTextures(Names.s,Names2.s)
  
  LoadImage(0, Names) ; Load texture with name
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  
  LoadImage(0, Names2) ; Load texture with name
  *pointer2 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  
  glGenTextures_(2, @Texture(0)) ;Create Two Textures
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(0));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer1+18),PeekL(*pointer1+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer1+54);
  FreeMemory(*pointer1)
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(1));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer2+18),PeekL(*pointer2+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer2+54);
  FreeMemory(*pointer2)
  
EndProcedure

Procedure BuildFont() ;Build Our Font Display List
  
  Protected cx.f ;Holds Our X Character Coord
  Protected cy.f ;Holds Our Y Character Coord
  Protected modx.l ;modulus for x coord
  
  base=glGenLists_(256) ;Creating 256 Display Lists
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Font Texture
  
  For LOOP=0 To 256-1 ;Loop Through All 256 Lists
    modx=LOOP % 16 ;Note: can't use % with floats
    cx=modx/16.0 ;X Position Of Current Character
    cy=Int(LOOP/16)/16.0 ;Y Position Of Current Character
    
    glNewList_(base+LOOP,#GL_COMPILE) ;Start Building A List
    glBegin_(#GL_QUADS) ;Use A Quad For Each Character
    glTexCoord2f_(cx,1-cy-0.0625) ;Texture Coord (Bottom Left)
    glVertex2i_(0,0) ;Vertex Coord (Bottom Left)
    glTexCoord2f_(cx+0.0625,1-cy-0.0625) ;Texture Coord (Bottom Right)
    glVertex2i_(16,0) ;Vertex Coord (Bottom Right)
    glTexCoord2f_(cx+0.0625,1-cy) ;Texture Coord (Top Right)
    glVertex2i_(16,16) ;Vertex Coord (Top Right)
    glTexCoord2f_(cx,1-cy) ;Texture Coord (Top Left)
    glVertex2i_(0,16) ;Vertex Coord (Top Left)
    glEnd_() ;Done Building Our Quad (Character)
    glTranslated_(10,0,0) ;Move To The Right Of The Character
    glEndList_() ;Done Building The Display List
  Next ;Loop Until All 256 Are Built
  
EndProcedure

Procedure KillFont() ;Delete The Font From Memory
  
  glDeleteLists_(base,256) ;Delete All 256 Display Lists
  
EndProcedure

Procedure glPrint(x.l,y.l,string.s,set.l) ;Where The Printing Happens
  
  If set : set=1 : EndIf ;Is set True? If So, Make set Equal One
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Font Texture
  
  glDisable_(#GL_DEPTH_TEST) ;Disables Depth Testing
  glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
  glPushMatrix_() ;Store The Projection Matrix
  glLoadIdentity_() ;Reset The Projection Matrix
  glOrtho_(0,640,0,480,-1,1) ;Set Up An Ortho Screen
  glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
  glPushMatrix_() ;Store The Modelview Matrix
  glLoadIdentity_() ;Reset The Modelview Matrix
  glTranslated_(x,y,0) ;Position The Text (0,0 - Bottom Left)
  glListBase_(base-32+(128*set)) ;Choose The Font Set (0 or 1)
  
  *pointer = Ascii(string)
  ;glCallLists_(Len(string),#GL_UNSIGNED_BYTE,string) ;Write The Text To The Screen
  glCallLists_(Len(string),#GL_BYTE,*pointer) ;Write The Text To The Screen
  FreeMemory(*pointer)
  
  
  glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
  glPopMatrix_() ;Restore The Old Projection Matrix
  glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
  glPopMatrix_() ;Restore The Old Projection Matrix
  glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
  
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

  BuildFont() ;Build The Font
  
  glClearColor_(0.0,0.0,0.0,0.0) ;Clear The Background Color To Black
  glClearDepth_(1.0) ;Enables Clearing Of The Depth Buffer
  glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Test To Do
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Select The Type Of Blending
  glShadeModel_(#GL_SMOOTH) ;Enables Smooth Color Shading
  glEnable_(#GL_TEXTURE_2D) ;Enable 2D Texture Mapping
 
 ProcedureReturn #True ;Initialization Went OK
 
EndProcedure

Procedure DrawScene(Gadget)
   SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The Modelview Matrix
  
  glBindTexture_(#GL_TEXTURE_2D,texture(1)) ;Select Our Second Texture
  
  glTranslatef_(0.0,0.0,-5.0) ;Move Into The Screen 5 Units
  
  glRotatef_(45.0,0.0,0.0,1.0) ;Rotate On The Z Axis 45 Degrees (Clockwise)
  glRotatef_(cnt1*30.0,1.0,1.0,0.0) ;Rotate On The X & Y Axis By cnt1 (Left To Right)
  
  glDisable_(#GL_BLEND) ;Disable Blending Before We Draw In 3D
  
  glColor3f_(1.0,1.0,1.0) ;Bright White
  
  glBegin_(#GL_QUADS) ;Draw Our First Texture Mapped Quad
  glTexCoord2f_(0.0,0.0) : glVertex2f_(-1.0, 1.0) ;First Texture Coord and Vertex
  glTexCoord2f_(1.0,0.0) : glVertex2f_( 1.0, 1.0) ;Second Texture Coord and Vertex
  glTexCoord2f_(1.0,1.0) : glVertex2f_( 1.0,-1.0) ;Third Texture Coord and Vertex
  glTexCoord2f_(0.0,1.0) : glVertex2f_(-1.0,-1.0) ;Fourth Texture Coord and Vertex
  glEnd_() ;Done Drawing The First Quad
  
  glRotatef_(90.0,1.0,1.0,0.0) ;Rotate On The X & Y Axis By 90 Degrees (Left To Right)
  
  glBegin_(#GL_QUADS) ;Draw Our Second Texture Mapped Quad
  glTexCoord2f_(0.0,0.0) : glVertex2f_(-1.0, 1.0) ;First Texture Coord and Vertex
  glTexCoord2f_(1.0,0.0) : glVertex2f_( 1.0, 1.0) ;Second Texture Coord and Vertex
  glTexCoord2f_(1.0,1.0) : glVertex2f_( 1.0,-1.0) ;Third Texture Coord and Vertex
  glTexCoord2f_(0.0,1.0) : glVertex2f_(-1.0,-1.0) ;Fourth Texture Coord and Vertex
  glEnd_() ;Done Drawing Our Second Quad
  
  glEnable_(#GL_BLEND) ;Enable Blending
  
  glLoadIdentity_() ;Reset The View
  
  ;Pulsing Colors Based On Text Position
  glColor3f_(1.0*Cos(cnt1),1.0*Sin(cnt2),1.0-0.5*Cos(cnt1+cnt2))
  glPrint((280+250*Cos(cnt1)),235+200*Sin(cnt2),"NeHe - "+StrF(cnt1,2),0) ;Print GL Text To The Screen
  
  glColor3f_(1.0*Sin(cnt2),1.0-0.5*Cos(cnt1+cnt2),1.0*Cos(cnt1));

  glPrint((280+230*Cos(cnt2)),235+200*Sin(cnt1),"OpenGL",1) ;Print GL Text To The Screen
  
  glColor3f_(0.0,0.0,1.0) ;Set Color To Blue
  glPrint(240+200*Cos((cnt2+cnt1)/5),2,"Giuseppe D'Agata",0)
  glColor3f_(1.0,1.0,1.0) ;Set Color To White
  glPrint(242+200*Cos((cnt2+cnt1)/5),2,"Giuseppe D'Agata",0)
  
  cnt1+0.002 ;Increase The First Counter
  cnt2+0.0016 ;Increase The Second Counter
 
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

CreateGLWindow("NeHe & Giuseppe D'Agata's 2D Font Tutorial (Lesson 17)",640,480,16,0)

InitGL()

LoadGLTextures("Data/Font.bmp","Data/Bumps.bmp")

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
    Quit = 1                              ; // This is the end
  EndIf
  
  DrawScene(0)
  Delay(10)
Until Quit = 1
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 255
; FirstLine = 219
; Folding = --
; EnableAsm
; EnableXP