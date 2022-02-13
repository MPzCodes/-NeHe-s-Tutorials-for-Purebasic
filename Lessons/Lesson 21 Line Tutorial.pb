;NeHe's Blending Tutorial (Lesson 21) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/lines,_antialiasing,_timing,_ortho_view_and_simple_sounds/17003/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 13 Feb 2022
;Note: up-to-date with PB v6.00 (Windows/Linux)
; Testest with PI4000, now you can create a standalone Program

Global active.b=#True ;Window Active Flag Set To TRUE By Default

Global Dim vline.b(11,10) ;Keeps Track Of Vertical Lines
Global Dim hline.b(10,11) ;Keeps Track Of Horizontal Lines
Global ap.b ;A Key Pressed?
Global filled.b ;Done Filling In The Grid?
Global gameover.b ;Is The Game Over?
Global anti.b=#True ;Antialiasing?

Global loop1.l ;Generic Loop1
Global loop2.l ;Generic Loop2
Global delay.l ;Enemy Delay
Global adjust.l=3 ;Speed Adjustment For Really Slow Video Cards (0..5)
Global lives.l=5 ;Player Lives
Global level.l=1 ;Internal Game Level
Global level2.l=level ;Displayed Game Level
Global stage.l=1 ;Game Stage

Structure OBJECT ;Create A Structure For Our Player And Enemies
  fx.l : fy.l ;Fine Movement Position
  x.l : y.l ;Current Player Position
  spin.f ;Spin Direction
EndStructure

Global player.OBJECT ;Player Information
Global Dim enemy.OBJECT(9) ;Enemy Information
Global hourglass.OBJECT ;Hourglass Information

Structure TIMER ;Create A Structure For The Timer Information
  frequency.q ;Timer Frequency
  resolution.f ;Timer Resolution
  mm_timer_start.l ;Multimedia Timer Start Value
  mm_timer_elapsed.l ;Multimedia Timer Elapsed Time
  performance_timer.b ;Using The Performance Timer?
  performance_timer_start.q ;Performance Timer Start Value
  performance_timer_elapsed.q ;Performance Timer Elapsed Time
EndStructure

Global timer.TIMER ;timer information

Global Dim steps.l(6) ;Stepping Values For Slow Video Adjustment
steps(0)=1 : steps(1)=2  : steps(2)=4
steps(3)=5 : steps(4)=10 : steps(5)=20

Global Dim texture.l(2) ;Font Texture Storage Space
Global base.l ;Base Display List For The Font

Procedure ResetObjects() ;Reset Player And Enemies
  
  player\x=0 ;Reset Player X Position To Far Left Of The Screen
  player\y=0 ;Reset Player Y Position To The Top Of The Screen
  player\fx=0 ;Set Fine X Position To Match
  player\fy=0 ;Set Fine Y Position To Match
  
  For loop1=0 To (stage*level)-1 ;Loop Through All The Enemies
    enemy(loop1)\x=5+Random(5) ;Select A Random X Position
    enemy(loop1)\y=Random(10) ;Select A Random Y Position
    enemy(loop1)\fx=enemy(loop1)\x*60 ;Set Fine X To Match
    enemy(loop1)\fy=enemy(loop1)\y*40 ;Set Fine Y To Match
  Next
  
EndProcedure

Procedure LoadGLTextures()
    
  CatchImage(0, ?Font)
  CatchImage(1, ?Image)
  
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  *pointer2 = EncodeImage(1, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(1)
  
  glGenTextures_(2,@texture(0)) ;Create The Texture
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0))
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D,0,3,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE, *pointer1+54)
  
  glBindTexture_(#GL_TEXTURE_2D,texture(1))
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D,0,3,PeekL(*pointer2+18), PeekL(*pointer2+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE, *pointer2+54)
  
  FreeMemory(*pointer1)
  FreeMemory(*pointer2)
  
  DataSection
    Font:
      IncludeBinary "Data/Font.bmp"
    Image:
      IncludeBinary "Data/Image.bmp"    
  EndDataSection

  
EndProcedure

Procedure LoadMySound()
    
  CatchSound(0, ?Die)
  CatchSound(1, ?Complete)
  CatchSound(2, ?Freeze)  
  CatchSound(3, ?Hourglass)  
  
  DataSection
    Die:
      IncludeBinary "Data/Die.wav"
    Complete:
      IncludeBinary "Data/Complete.wav"
    Freeze:
      IncludeBinary "Data/Freeze.wav"
    Hourglass:
      IncludeBinary "Data/Hourglass.wav"
    EndDataSection
EndProcedure

Procedure BuildFont() ;Build Our Font Display List
  
  Protected cx.f,cy.f,modx.l
  
  base=glGenLists_(256) ;Creating 256 Display Lists
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Font Texture
  
  For loop1=0 To 256-1 ;Loop Through All 256 Lists
    modx=loop1 % 16 ;Note: can't use % with floats
    cx=modx/16.0 ;X Position Of Current Character
    cy=Int(loop1/16)/16.0 ;Y Position Of Current Character
    
    glNewList_(base+loop1,#GL_COMPILE) ;Start Building A List
    glBegin_(#GL_QUADS) ;Use A Quad For Each Character
    glTexCoord2f_(cx,1.0-cy-0.0625) ;Texture Coord (Bottom Left)
    glVertex2i_(0,16) ;Vertex Coord (Bottom Left)
    glTexCoord2f_(cx+0.0625,1.0-cy-0.0625) ;Texture Coord (Bottom Right)
    glVertex2i_(16,16) ;Vertex Coord (Bottom Right)
    glTexCoord2f_(cx+0.0625,1.0-cy) ;Texture Coord (Top Right)
    glVertex2i_(16,0) ;Vertex Coord (Top Right)
    glTexCoord2f_(cx,1.0-cy) ;Texture Coord (Top Left)
    glVertex2i_(0,0) ;Vertex Coord (Top Left)
    glEnd_() ;Done Building Our Quad (Character)
    glTranslated_(15,0,0) ;Move To The Right Of The Character
    glEndList_() ;Done Building The Display List
  Next ;Loop Until All 256 Are Built
  
EndProcedure


Procedure KillFont() ;Delete The Font From Memory
  
  glDeleteLists_(base,256) ;Delete All 256 Display Lists
  
EndProcedure

Procedure glPrint(x.l,y.l,set.l,text.s) ;Where The Printing Happens
  
  If text="" ;If There's No Text
    ProcedureReturn #False ;Do Nothing
  EndIf
  
  If set ;Did User Choose An Invalid Character Set?
    set=1 ;If So, Select Set 1 (Italic)
  EndIf
  
  glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
  glLoadIdentity_() ;Reset The Modelview Matrix
  glTranslated_(x,y,0) ;Position The Text (0,0 - Bottom Left)
  glListBase_(base-32+(128*set)) ;Choose The Font Set (0 or 1)
  
  If set=0 ;If Set 0 Is Being Used Enlarge Font
    glScalef_(1.5,2.0,1.0) ;Enlarge Font Width And Height
  EndIf
  
  *pointer = Ascii(text)
  glCallLists_(Len(text),#GL_UNSIGNED_BYTE,*pointer) ;Draws The Display List Text
  FreeMemory(*pointer)
  
  glDisable_(#GL_TEXTURE_2D) ;Disable Texture Mapping
  
EndProcedure

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

  If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
  
  ResizeGadget(0, 0, 0, width, height)
  
  glViewport_(0,0,width,height) ;Reset The Current Viewport
  
  glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
  glLoadIdentity_() ;Reset The Projection Matrix
  
  glOrtho_(0.0,width,height,0.0,-1.0,1.0) ;Create Ortho 640x480 View (0,0 At Top Left)
  
  glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
  glLoadIdentity_()            ;Reset The Modelview Matrix
  
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here

  BuildFont() ;Build The Font
  
  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glHint_(#GL_LINE_SMOOTH_HINT,#GL_NICEST) ;Set Line Antialiasing
  glEnable_(#GL_BLEND) ;Enable Blending
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA) ;Type Of Blending To Use
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Font Texture
  
  glColor3f_(1.0,0.5,1.0) ;Set Color To Purple
  glPrint(207,24,0,"GRID CRAZY") ;Write GRID CRAZY On The Screen
  glColor3f_(1.0,1.0,0.0) ;Set Color To Yellow
  glPrint(20,20,1,"Level:"+Str(level2)) ;Write Actual Level Stats
  glPrint(20,40,1,"Stage:"+Str(stage)) ;Write Stage Stats
  
  If gameover ;Is The Game Over?
    glColor3ub_(Random(255),Random(255),Random(255)) ;Pick A Random Color
    glPrint(472,20,1,"GAME OVER") ;Write GAME OVER To The Screen
    glPrint(456,40,1,"PRESS SPACE") ;Write PRESS SPACE To The Screen
  EndIf
  
  For loop1=0 To (lives-1)-1 ;Loop Through Lives Minus Current Life
    glLoadIdentity_() ;Reset The View
    glTranslatef_(490+(loop1*40.0),40.0,0.0) ;Move To The Right Of Our Title Text
    glRotatef_(-player\spin,0.0,0.0,1.0) ;Rotate Counter Clockwise
    glColor3f_(0.0,1.0,0.0) ;Set Player Color To Light Green
    glBegin_(#GL_LINES) ;Start Drawing Our Player Using Lines
    glVertex2i_(-5,-5) ;Top Left Of Player
    glVertex2i_( 5, 5) ;Bottom Right Of Player
    glVertex2i_( 5,-5) ;Top Right Of Player
    glVertex2i_(-5, 5) ;Bottom Left Of Player
    glEnd_() ;Done Drawing The Player
    glRotatef_(-player\spin*0.5,0.0,0.0,1.0) ;Rotate Counter Clockwise
    glColor3f_(0.0,0.75,0.0) ;Set Player Color To Dark Green
    glBegin_(#GL_LINES) ;Start Drawing Our Player Using Lines
    glVertex2i_(-7, 0) ;Left Center Of Player
    glVertex2i_( 7, 0) ;Right Center Of Player
    glVertex2i_( 0,-7) ;Top Center Of Player
    glVertex2i_( 0, 7) ;Bottom Center Of Player
    glEnd_() ;Done Drawing The Player
  Next
  
  filled=#True ;Set Filled To True Before Testing
  glLineWidth_(2.0) ;Set Line Width For Cells To 2.0
  glDisable_(#GL_LINE_SMOOTH) ;Disable Antialiasing
  glLoadIdentity_() ;Reset The Current Modelview Matrix
  
  For loop1=0 To 11-1 ;Loop From Left To Right
    For loop2=0 To 11-1 ;Loop From Top To Bottom
      
      glColor3f_(0.0,0.5,1.0) ;Set Line Color To Blue
      If hline(loop1,loop2) ;Has The Horizontal Line Been Traced
        glColor3f_(1.0,1.0,1.0) ;If So, Set Line Color To White
      EndIf
      If loop1<10 ;Dont Draw To Far Right
        If hline(loop1,loop2)=0 ;If A Horizontal Line Isn't Filled
          filled=#False ;filled Becomes False
        EndIf
        glBegin_(#GL_LINES) ;Start Drawing Horizontal Cell Borders
        glVertex2i_(20+(loop1*60),70+(loop2*40)) ;Left Side Of Horizontal Line
        glVertex2i_(80+(loop1*60),70+(loop2*40)) ;Right Side Of Horizontal Line
        glEnd_() ;Done Drawing Horizontal Cell Borders
      EndIf
      
      glColor3f_(0.0,0.5,1.0) ;Set Line Color To Blue
      If vline(loop1,loop2) ;Has The Horizontal Line Been Traced
        glColor3f_(1.0,1.0,1.0) ;If So, Set Line Color To White
      EndIf
      If loop2<10 ;Dont Draw To Far Down
        If vline(loop1,loop2)=0 ;If A Vertical Line Isn't Filled
          filled=#False ;filled Becomes False
        EndIf
        glBegin_(#GL_LINES) ;Start Drawing Vertical Cell Borders
        glVertex2i_(20+(loop1*60),70+(loop2*40)) ;Left Side Of Horizontal Line
        glVertex2i_(20+(loop1*60),110+(loop2*40)) ;Right Side Of Horizontal Line
        glEnd_() ;Done Drawing Vertical Cell Borders
      EndIf
      
      glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
      glColor3f_(1.0,1.0,1.0) ;Bright White Color
      glBindTexture_(#GL_TEXTURE_2D,texture(1)) ;Select The Tile Image
      If loop1<10 And loop2<10 ;If In Bounds, Fill In Traced Boxes
        ;Are All Sides Of The Box Traced?
        If hline(loop1,loop2) And hline(loop1,loop2+1) And vline(loop1,loop2) And vline(loop1+1,loop2)
          glBegin_(#GL_QUADS) ;Draw A Textured Quad
          glTexCoord2f_((loop1/10.0)+0.1,1.0-(loop2/10.0)) ;Top Right (1,1)
          glVertex2i_(79+(loop1*60),71+(loop2*40)) ;Top Right
          glTexCoord2f_((loop1/10.0),1.0-(loop2/10.0)) ;Top Left (0,1)
          glVertex2i_(21+(loop1*60),71+(loop2*40)) ;Top Left
          glTexCoord2f_((loop1/10.0),1.0-(loop2/10.0)-0.1) ;Bottom Left (0,0)
          glVertex2i_(21+(loop1*60),109+(loop2*40)) ;Bottom Left
          glTexCoord2f_((loop1/10.0)+0.1,1.0-(loop2/10.0)-0.1) ;Bottom Right (1,0)
          glVertex2i_(79+(loop1*60),109+(loop2*40)) ;Bottom Right
          glEnd_() ;Done Texturing The Box
        EndIf
      EndIf
      glDisable_(#GL_TEXTURE_2D) ;Disable Texture Mapping
      
    Next
  Next
  
  glLineWidth_(1.0) ;Set The Line Width To 1.0
  
  If anti ;Is Anti TRUE?
    glEnable_(#GL_LINE_SMOOTH) ;If So, Enable Antialiasing
  EndIf
  
  If hourglass\fx=1 ;If fx=1 (visible) Draw The Hourglass
    glLoadIdentity_() ;Reset The Modelview Matrix
    glTranslatef_(20.0+(hourglass\x*60),70.0+(hourglass\y*40),0.0) ;Move To The Fine Hourglass Position
    glRotatef_(hourglass\spin,0.0,0.0,1.0) ;Rotate Clockwise
    glColor3ub_(Random(255),Random(255),Random(255)) ;Set Hourglass Color To Random Color
    glBegin_(#GL_LINES) ;Start Drawing Our Hourglass Using Lines
    glVertex2i_(-5,-5) ;Top Left Of Hourglass
    glVertex2i_( 5, 5) ;Bottom Right Of Hourglass
    glVertex2i_( 5,-5) ;Top Right Of Hourglass
    glVertex2i_(-5, 5) ;Bottom Left Of Hourglass
    glVertex2i_(-5, 5) ;Bottom Left Of Hourglass
    glVertex2i_( 5, 5) ;Bottom Right Of Hourglass
    glVertex2i_(-5,-5) ;Top Left Of Hourglass
    glVertex2i_( 5,-5) ;Top Right Of Hourglass
    glEnd_() ;Done Drawing The Hourglass
  EndIf
  
  glLoadIdentity_() ;Reset The Modelview Matrix
  glTranslatef_(player\fx+20.0,player\fy+70.0,0.0); Move To The Fine Player Position
  glRotatef_(player\spin,0.0,0.0,1.0) ;Rotate Clockwise
  glColor3f_(0.0,1.0,0.0) ;Set Player Color To Light Green
  glBegin_(#GL_LINES) ;Start Drawing Our Player Using Lines
  glVertex2i_(-5,-5) ;Top Left Of Player
  glVertex2i_( 5, 5) ;Bottom Right Of Player
  glVertex2i_( 5,-5) ;Top Right Of Player
  glVertex2i_(-5, 5) ;Bottom Left Of Player
  glEnd_() ;Done Drawing The Player
  glRotatef_(player\spin*0.5,0.0,0.0,1.0) ;Rotate Clockwise
  glColor3f_(0.0,0.75,0.0) ;Set Player Color To Dark Green
  glBegin_(#GL_LINES) ;Start Drawing Our Player Using Lines
  glVertex2i_(-7, 0) ;Left Center Of Player
  glVertex2i_( 7, 0) ;Right Center Of Player
  glVertex2i_( 0,-7) ;Top Center Of Player
  glVertex2i_( 0, 7) ;Bottom Center Of Player
  glEnd_() ;Done Drawing The Player
  
  For loop1=0 To (stage*level)-1 ;Loop To Draw Enemies
    glLoadIdentity_() ;Reset The Modelview Matrix
    glTranslatef_(enemy(loop1)\fx+20.0,enemy(loop1)\fy+70.0,0.0)
    glColor3f_(1.0,0.5,0.5) ;Make Enemy Body Pink
    glBegin_(#GL_LINES) ;Start Drawing Enemy
    glVertex2i_( 0,-7) ;Top Point Of Body
    glVertex2i_(-7, 0) ;Left Point Of Body
    glVertex2i_(-7, 0) ;Left Point Of Body
    glVertex2i_( 0, 7) ;Bottom Point Of Body
    glVertex2i_( 0, 7) ;Bottom Point Of Body
    glVertex2i_( 7, 0) ;Right Point Of Body
    glVertex2i_( 7, 0) ;Right Point Of Body
    glVertex2i_( 0,-7) ;Top Point Of Body
    glEnd_() ;Done Drawing Enemy Body
    glRotatef_(enemy(loop1)\spin,0.0,0.0,1.0) ;Rotate The Enemy Blade
    glColor3f_(1.0,0.0,0.0) ;Make Enemy Blade Red
    glBegin_(#GL_LINES) ;Start Drawing Enemy Blade
    glVertex2i_(-7,-7) ;Top Left Of Enemy
    glVertex2i_( 7, 7) ;Bottom Right Of Enemy
    glVertex2i_(-7, 7) ;Bottom Left Of Enemy
    glVertex2i_( 7,-7) ;Top Right Of Enemy
    glEnd_() ;Done Drawing Enemy Blade
  Next

  
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
    
EndProcedure
Procedure CreateGLWindow(title.s,WindowWidth.l,WindowHeight.l,bits.l,fullscreenflag.b=0,Vsync.b=0)
  
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


InitSound()

CreateGLWindow("NeHe's Blending Tutorial (Lesson 21)",640,480,16,0,1)

LoadGLTextures()

LoadMySound()

InitGL() 


ResetObjects() ;Set Player / Enemy Starting Positions

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
  
  StartTime.q = ElapsedMilliseconds()     ; ermittelt den aktuellen Wert
  
  While ElapsedMilliseconds() < (StartTime+(steps(adjust)*2.0))
  Wend ;Waste Cycles On Fast Systems
  
  If KeyboardPushed(#PB_Key_A) And ap=0 ;If 'A' Key Is Pressed And Not Held
     ap=#True ;ap Becomes TRUE
     anti=~anti & 1 ;Toggle Antialiasing
  EndIf
      
  If Not KeyboardPushed(#PB_Key_A);If 'A' Key Has Been Released
     ap=#False ;ap Becomes FALSE
  EndIf
      
      
      
  If gameover=0 And active ;If Game Isn't Over And Programs Active Move Objects
        
     For loop1=0 To (stage*level)-1 ;Loop Through All The Enemies
          
          If enemy(loop1)\x<player\x And enemy(loop1)\fy=enemy(loop1)\y*40
            enemy(loop1)\x+1 ;Move The Enemy Right
          EndIf
          If enemy(loop1)\x>player\x And enemy(loop1)\fy=enemy(loop1)\y*40
            enemy(loop1)\x-1 ;Move The Enemy Left
          EndIf
          If enemy(loop1)\y<player\y And enemy(loop1)\fx=enemy(loop1)\x*60
            enemy(loop1)\y+1 ;Move The Enemy Down
          EndIf
          If enemy(loop1)\y>player\y And enemy(loop1)\fx=enemy(loop1)\x*60
            enemy(loop1)\y-1 ;Move The Enemy Up
          EndIf
          
          If delay>3-level And hourglass\fx<>2 ;If Our Delay Is Done And Player Doesn't Have Hourglass
            delay=0 ;Reset The Delay Counter Back To Zero
            For loop2=0 To (stage*level)-1 ;Loop Through All The Enemies
              If enemy(loop2)\fx<enemy(loop2)\x*60 ;Is Fine Position On X Axis Lower Than Intended Position?
                enemy(loop2)\fx+steps(adjust) ;If So, Increase Fine Position On X Axis
                enemy(loop2)\spin+steps(adjust) ;Spin Enemy Clockwise
              EndIf
              If enemy(loop2)\fx>enemy(loop2)\x*60 ;Is Fine Position On X Axis Higher Than Intended Position?
                enemy(loop2)\fx-steps(adjust) ;If So, Decrease Fine Position On X Axis
                enemy(loop2)\spin-steps(adjust) ;Spin Enemy Counter Clockwise
              EndIf
              If enemy(loop2)\fy<enemy(loop2)\y*40 ;Is Fine Position On Y Axis Lower Than Intended Position?
                enemy(loop2)\fy+steps(adjust) ;If So, Increase Fine Position On Y Axis
                enemy(loop2)\spin+steps(adjust) ;Spin Enemy Clockwise
              EndIf
              If enemy(loop2)\fy>enemy(loop2)\y*40 ;Is Fine Position On Y Axis Higher Than Intended Position?
                enemy(loop2)\fy-steps(adjust) ;If So, Decrease Fine Position On Y Axis
                enemy(loop2)\spin-steps(adjust) ;Spin Enemy Counter Clockwise
              EndIf
            Next
          EndIf
          
          ;Are Any Of The Enemies On Top Of The Player?
          If enemy(loop1)\fx=player\fx And enemy(loop1)\fy=player\fy
            lives-1 ;If So, Player Loses A Life
            If lives=0 ;Are We Out Of Lives?
              gameover=#True ;If So, gameover Becomes TRUE
            EndIf
            ResetObjects() ;Reset Player / Enemy Positions
            ;PlaySound_("Data/Die.wav",#Null,#SND_SYNC) ;Play The Death Sound
            PlaySound(0)
          EndIf
          
        Next
        
        If KeyboardPushed(#PB_Key_Right) And player\x<10 And player\fx=player\x*60 And player\fy=player\y*40
          hline(player\x,player\y)=#True ;Mark The Current Horizontal Border As Filled
          player\x+1 ;Move The Player Right
        EndIf
        If KeyboardPushed(#PB_Key_Left) And player\x>0 And player\fx=player\x*60 And player\fy=player\y*40
          player\x-1 ;Move The Player Left
          hline(player\x,player\y)=#True ;Mark The Current Horizontal Border As Filled
        EndIf
        If KeyboardPushed(#PB_Key_Down) And player\y<10 And player\fx=player\x*60 And player\fy=player\y*40
          vline(player\x,player\y)=#True ;Mark The Current Vertical Border As Filled
          player\y+1 ;Move The Player Down
        EndIf
        If KeyboardPushed(#PB_Key_Up) And player\y>0 And player\fx=player\x*60 And player\fy=player\y*40
          player\y-1 ;Move The Player Up
          vline(player\x,player\y)=#True ;Mark The Current Vertical Border As Filled
        EndIf
        
        If player\fx<player\x*60 ;Is Fine Position On X Axis Lower Than Intended Position?
          player\fx+steps(adjust) ;If So, Increase The Fine X Position
        EndIf
        If player\fx>player\x*60 ;Is Fine Position On X Axis Greater Than Intended Position?
          player\fx-steps(adjust) ;If So, Decrease The Fine X Position
        EndIf
        If player\fy<player\y*40 ;Is Fine Position On Y Axis Lower Than Intended Position?
          player\fy+steps(adjust) ;If So, Increase The Fine Y Position
        EndIf
        If player\fy>player\y*40 ;Is Fine Position On Y Axis Lower Than Intended Position?
          player\fy-steps(adjust) ;If So, Decrease The Fine Y Position
        EndIf
        
      Else ;Otherwise
        
        If KeyboardPushed(#PB_Key_Space) ;If Spacebar Is Being Pressed
          gameover=#False ;gameover Becomes FALSE
          filled=#True ;filled Becomes TRUE
          level=1 ;Starting Level Is Set Back To One
          level2=1 ;Displayed Level Is Also Set To One
          stage=0 ;Game Stage Is Set To Zero
          lives=5 ;Lives Is Set To Five
        EndIf
        
      EndIf
      
      If filled ;Is The Grid Filled In?
        
        ;PlaySound_("Data/Complete.wav",#Null,#SND_SYNC) ;If So, Play The Level Complete Sound
        PlaySound(1)
        stage+1 ;Increase The Stage
        If stage>3 ;Is The Stage Higher Than 3?
          stage=1 ;If So, Set The Stage To One
          level+1 ;Increase The Level
          level2+1 ;Increase The Displayed Level
          If level>3 ;Is The Level Greater Than 3?
            level=3 ;If So, Set The Level To 3
            lives+1 ;Give The Player A Free Life
            If lives>5 ;Does The Player Have More Than 5 Lives?
              lives=5 ;If So, Set Lives To Five
            EndIf
          EndIf
        EndIf
        
        ResetObjects() ;Reset Player / Enemy Positions
        
        For loop1=0 To 11-1 ;Loop Through The Grid X Coordinates
          For loop2=0 To 11-1 ;Loop Through The Grid Y Coordinates
            If loop1<10 ;If X Coordinate Is Less Than 10
              hline(loop1,loop2)=#False ;Set The Current Horizontal Value To FALSE
            EndIf
            If loop2<10 ;If Y Coordinate Is Less Than 10
              vline(loop1,loop2)=#False ;Set The Current Vertical Value To FALSE
            EndIf
          Next
        Next
        
      EndIf
      
      ;If The Player Hits The Hourglass While It's Being Displayed On The Screen
      If player\fx=hourglass\x*60 And player\fy=hourglass\y*40 And hourglass\fx=1
        ;PlaySound_("Data/Freeze.wav",#Null,#SND_ASYNC | #SND_LOOP) ;Play Freeze Enemy Sound
        PlaySound(2, #PB_Sound_Loop )
        hourglass\fx=2 ;Set The hourglass fx Variable To Two
        hourglass\fy=0 ;Set The hourglass fy Variable To Zero
      EndIf
      
      player\spin+0.5*steps(adjust) ;Spin The Player Clockwise
      If player\spin>360.0 ;Is The spin Value Greater Than 360?
        player\spin-360 ;If So, Subtract 360
      EndIf
      
      hourglass\spin-0.25*steps(adjust) ;Spin The Hourglass Counter Clockwise
      If hourglass\spin<0.0 ;Is The spin Value Less Than 0?
        hourglass\spin+360.0 ;If So, Add 360
      EndIf
      
      hourglass\fy+steps(adjust) ;Increase The hourglass fy Variable
      
      ;Is The hourglass fx Variable Equal To 0 (invisible) And The fy
      ;Variable Greater Than 6000 Divided By The Current Level?
      If hourglass\fx=0 And hourglass\fy>6000/level
        ;PlaySound_("Data/Hourglass.wav",#Null,#SND_ASYNC) ;If So, Play The Hourglass Appears Sound
        PlaySound(3)
        hourglass\x=Random(9)+1 ;Give The Hourglass A Random X Value
        hourglass\y=Random(10) ;Give The Hourglass A Random Y Value
        hourglass\fx=1 ;Set hourglass fx Variable To One (Hourglass Stage)
        hourglass\fy=0 ;Set hourglass fy Variable To Zero (Counter)
      EndIf
      
      ;Is The hourglass fx Variable Equal To 1 (visible) And The fy
      ;Variable Greater Than 6000 Divided By The Current Level?
      If hourglass\fx=1 And hourglass\fy>6000/level
        hourglass\fx=0 ;If So, Set fx To Zero (Hourglass Will Vanish)
        hourglass\fy=0 ;Set fy to Zero (Counter Is Reset)
      EndIf
      
      ;Is The hourglass fx Variable Equal To 2 (activated) And The fy
      ;Variable Greater Than 500 Plus 500 Times The Current Level?
      If hourglass\fx=2 And hourglass\fy>500+(500*level)
        ;PlaySound_(#Null,#Null,0) ;If So, Kill The Freeze Sound
        StopSound(2)
        hourglass\fx=0 ;Set hourglass fx Variable To Zero
        hourglass\fy=0 ;Set hourglass fy Variable To Zero
      EndIf
      
      delay+1 ;Increase The Enemy Delay Counter
      
      
      DrawScene(0)
      
  ;start=TimerGetTime() ;Grab Timer Value Before We Draw
  ;aa +1   
  ;Debug  aa 
  ;DrawScene2 (0)
      
  ;While TimerGetTime()<start+(steps(adjust)*2.0)
  ;Wend ;Waste Cycles On Fast Systems
  
Until Quit = 1

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 7
; Folding = --
; EnableAsm
; EnableXP