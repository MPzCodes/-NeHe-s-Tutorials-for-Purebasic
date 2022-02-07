;NeHe & TipTup's Environment Mapping Tutorial (Lesson 23)
;http://nehe.gamedev.net and http://www.tiptup.com
;https://nehe.gamedev.net/tutorial/sphere_mapping_quadrics_in_opengl/15005/
;Note: requires bitmaps in paths "Data/BG.bmp", "Data/Reflect.bmp"
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 21 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

#GLU_SMOOTH = 100000

Global light.b ;Lighting ON/OFF
Global lp.b ;L Pressed?
Global fp.b ;F Pressed?
Global sp.b ;Spacebar Pressed?

Global part1.l ;Start Of Disc
Global part2.l ;End Of Disc
Global p1.l=0 ;Increase 1
Global p2.l=1 ;Increase 2

Global xrot.f ;X Rotation
Global yrot.f ;Y Rotation
Global xspeed.f ;X Rotation Speed
Global yspeed.f ;Y Rotation Speed
Global z.f=-10.0 ;Depth Into The Screen

Global quadratic.i ;Storage For Our Quadratic Objects

Global Dim LightAmbient.f(4) ;Ambient Light Values
LightAmbient(0)=0.5 ;red
LightAmbient(1)=0.5 ;green
LightAmbient(2)=0.5 ;blue
LightAmbient(3)=1.0 ;alpha

Global Dim LightDiffuse.f(4) ;Diffuse Light Values
LightDiffuse(0)=1.0 ;red
LightDiffuse(1)=1.0 ;green
LightDiffuse(2)=1.0 ;blue
LightDiffuse(3)=1.0 ;alpha

Global Dim LightPosition.f(4) ;Light Position
LightPosition(0)=0.0 ;x
LightPosition(1)=0.0 ;y
LightPosition(2)=2.0 ;z
LightPosition(3)=1.0 ;w

Global filter.l ;Which Filter To Use
Global Dim texture.l(6) ;Storage For 6 Textures (MODIFIED)
Global object.l=1 ;Which Object To Draw

Procedure.l LoadGLTextures() ;Load Bitmaps And Convert To Textures

  Protected Status.l=#False ;Status Indicator
  Protected Dim *pointer(2) ;Create Storage Space For The Texture
  Protected LOOP.l
  
  ;Load The Bitmap, Check For Errors, If Bitmap's Not Found Quit
  
  Define.i img1 = LoadImage(0,"Data/BG.bmp") ; Load texture with name
  Define.i img2 = LoadImage(1, "Data/Reflect.bmp") ; Load texture with name
  
  If img1 And img2
  
    *pointer(0) = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(0)
    *pointer(1) = EncodeImage(1, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(1)

    Status=#True ;Set The Status To TRUE
    
    glGenTextures_(6,@texture(0)) ;Create Three Textures
    
    For LOOP=0 To 2-1
      ;Create Nearest Filtered Texture
      glBindTexture_(#GL_TEXTURE_2D,texture(LOOP)) ;Gen Tex 0 and 1
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
      glTexImage2D_(#GL_TEXTURE_2D,0,3, PeekL(*pointer(LOOP)+18), PeekL(*pointer(LOOP)+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE,*pointer(LOOP)+54)
      
      ;Create Linear Filtered Texture
      glBindTexture_(#GL_TEXTURE_2D,texture(LOOP+2)) ;Gen Tex 2 and 3
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
      glTexImage2D_(#GL_TEXTURE_2D,0,3,PeekL(*pointer(LOOP)+18),PeekL(*pointer(LOOP)+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE,*pointer(LOOP)+54)
      
      ;Create MipMapped Texture
      glBindTexture_(#GL_TEXTURE_2D,texture(LOOP+4)) ;Gen Tex 4 and 5
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
      glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST)
      gluBuild2DMipmaps_(#GL_TEXTURE_2D,3,PeekL(*pointer(LOOP)+18), PeekL(*pointer(LOOP)+22),#GL_BGR_EXT,#GL_UNSIGNED_BYTE,*pointer(LOOP)+54)
    Next
  EndIf
  
  For LOOP=0 To 2-1
    If *pointer(LOOP) ;If Texture Exists
       FreeMemory(*pointer(LOOP)) ;Free The Texture Image Memory
    EndIf
  Next
  
  ProcedureReturn Status ;Return The Status
  
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

  If LoadGLTextures()=0 ;Jump To Texture Loading Routine
    ProcedureReturn #False ;If Texture Didn't Load Return FALSE
  EndIf
  
  glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
  glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
  glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  
  glLightfv_(#GL_LIGHT1,#GL_AMBIENT,LightAmbient()) ;Setup The Ambient Light
  glLightfv_(#GL_LIGHT1,#GL_DIFFUSE,LightDiffuse()) ;Setup The Diffuse Light
  glLightfv_(#GL_LIGHT1,#GL_POSITION,LightPosition()) ;Position The Light
  glEnable_(#GL_LIGHT1) ;Enable Light One
  
  quadratic=gluNewQuadric_() ;Create A Pointer To The Quadric Object, returns 0 if failed
  gluQuadricNormals_(quadratic,#GLU_SMOOTH) ;Create Smooth Normals
  gluQuadricTexture_(quadratic,#GL_TRUE) ;Create Texture Coords
  
  glTexGeni_(#GL_S,#GL_TEXTURE_GEN_MODE,#GL_SPHERE_MAP) ;Set The Texture Generation Mode For S To Sphere Mapping ( NEW )
  glTexGeni_(#GL_T,#GL_TEXTURE_GEN_MODE,#GL_SPHERE_MAP) ;Set The Texture Generation Mode For T To Sphere Mapping ( NEW )
  
  ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure glDrawCube() ;Draw A Cube
  
  glBegin_(#GL_QUADS) ;Start Drawing Quads
  ;Front Face
  glNormal3f_( 0.0, 0.0, 0.5) ;Normal Facing Towards
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Top Left Of The Texture and Quad
  ;Back Face
  glNormal3f_( 0.0, 0.0,-0.5) ;Normal Facing Away
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Bottom Left Of The Texture and Quad
  ;Top Face
  glNormal3f_( 0.0, 0.5, 0.0) ;Normal Facing Up
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  ;Bottom Face
  glNormal3f_( 0.0,-0.5, 0.0) ;Normal Facing Down
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  ;Right Face
  glNormal3f_( 0.5, 0.0, 0.0) ;Normal Facing Right
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0) ;Top Left Of The Texture and Quad
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0) ;Bottom Left Of The Texture and Quad
  ;Left Face
  glNormal3f_(-0.5, 0.0, 0.0) ;Normal Facing Left
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0) ;Bottom Left Of The Texture and Quad
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0) ;Bottom Right Of The Texture and Quad
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0) ;Top Right Of The Texture and Quad
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0) ;Top Left Of The Texture and Quad
  glEnd_() ;Done Drawing Quads
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The View
  
  glTranslatef_(0.0,0.0,z) ;Translate Into/Out Of The Screen By z
  
  glEnable_(#GL_TEXTURE_GEN_S) ;Enable Texture Coord Generation For S ( NEW )
  glEnable_(#GL_TEXTURE_GEN_T) ;Enable Texture Coord Generation For T ( NEW )
  
  glBindTexture_(#GL_TEXTURE_2D,texture((filter*2)+1)) ;Select The Sphere Map
  glPushMatrix_()
  
  glRotatef_(xrot,1.0,0.0,0.0) ;Rotate On The X Axis By xrot
  glRotatef_(yrot,0.0,1.0,0.0) ;Rotate On The Y Axis By yrot
  
  Select object ;Check object To Find Out What To Draw
      
    Case 0 ;Drawing Object 1
      glDrawCube() ;Draw Our Cube
      
    Case 1 ;Drawing Object 2
      glTranslatef_(0.0,0.0,-1.5) ;Center The Cylinder
      gluCylinder_(quadratic,1.0,1.0,3.0,32,32) ;Draw A Cylinder With Radius Of 1 And Height Of 3
      
    Case 2 ;Drawing Object 3
      gluSphere_(quadratic,1.3,32,32) ;Draw A Sphere With Radius Of 1.3 And 32 Longitude And Latitude Segments
      
    Case 3 ;Drawing Object 4
      glTranslatef_(0.0,0.0,-1.5) ;Center The Cone
      gluCylinder_(quadratic,1.0,0.0,3.0,32,32) ;Draw A Cone With Bottom Radius Of 1 And Height Of 3
      
  EndSelect
  
  glPopMatrix_()
  glDisable_(#GL_TEXTURE_GEN_S)
  glDisable_(#GL_TEXTURE_GEN_T)
  
  glBindTexture_(#GL_TEXTURE_2D,texture(filter*2)) ;Select The BG Texture ( NEW )
  glPushMatrix_()
  glTranslatef_(0.0,0.0,-24.0)
  glBegin_(#GL_QUADS)
  glNormal3f_( 0.0, 0.0, 1.0)
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-13.3,-10.0, 10.0)
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 13.3,-10.0, 10.0)
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 13.3, 10.0, 10.0)
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-13.3, 10.0, 10.0)
  glEnd_()
  glPopMatrix_()
  
  xrot+xspeed ;Add xspeed To xrot
  yrot+yspeed ;Add yspeed To yrot
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
  
  ProcedureReturn #True ;Keep Going

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

CreateGLWindow("NeHe & TipTup's Environment Mapping Tutorial (Lesson 23)",640,480,16,0)

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
        
        If KeyboardPushed(#PB_Key_F) And fp=0 ;Is F Key Being Pressed?
          fp=#True ;fp Becomes TRUE
          filter+1 ;filter Value Increases By One
          If filter>2 ;Is Value Greater Than 2?
            filter=0 ;If So, Set filter To 0
          EndIf
        EndIf
        If Not KeyboardPushed(#PB_Key_F) ;Has F Key Been Released?
          fp=#False ;If So, fp Becomes FALSE
        EndIf
        
        If KeyboardPushed(#PB_Key_PageUp) ;Is Page Up Being Pressed?
          z-0.02 ;If So, Move Into The Screen
        EndIf
        If KeyboardPushed(#PB_Key_PageDown) ;Is Page Down Being Pressed?
          z+0.02 ;If So, Move Towards The Viewer
        EndIf
        
        If KeyboardPushed(#PB_Key_Up) And xspeed>-0.5 ;Is Up Arrow Being Pressed?
          xspeed-0.01 ;If So, Decrease xspeed
        EndIf
        If KeyboardPushed(#PB_Key_Down) And xspeed<0.5 ;Is Down Arrow Being Pressed?
          xspeed+0.01 ;If So, Increase xspeed
        EndIf
        If KeyboardPushed(#PB_Key_Right) And yspeed<0.5 ;Is Right Arrow Being Pressed?
          yspeed+0.01 ;If So, Increase yspeed
        EndIf
        If KeyboardPushed(#PB_Key_Left) And yspeed>-0.5 ;Is Left Arrow Being Pressed?
          yspeed-0.01 ;If So, Decrease yspeed
        EndIf
        
        If KeyboardPushed(#PB_Key_Space) And sp=0 ;Is Spacebar Being Pressed?
          sp=#True ;If So, Set sp To TRUE
          object+1 ;Cycle Through The Objects
          If object>3 ;Is object Greater Than 3?
            object=0 ;If So, Set To Zero
          EndIf
        EndIf
        If Not KeyboardPushed(#PB_Key_Space) ;Has The Spacebar Been Released?
          sp=#False ;If So, Set sp To FALSE
        EndIf

  DrawScene(0)
  
  Delay(2)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 288
; FirstLine = 274
; Folding = --
; EnableAsm
; EnableXP
; DisableDebugger