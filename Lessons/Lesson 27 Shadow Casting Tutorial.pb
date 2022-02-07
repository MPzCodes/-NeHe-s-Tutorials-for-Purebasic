;Banu Octavian & NeHe's Shadow Casting Tutorial (Lesson 27)
;http://nehe.gamedev.net
;https://nehe.gamedev.net/tutorial/shadows/16010/
;Note: requires a vertex data text file in path "Data/Object2.txt"
;Alternative files to try "Object.txt", "Object1.txt", "SimpleObject.txt"
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 1 Nov 2021
;Note: up-to-date with PB v5.73 (Windows)

;Start of Lesson 27

XIncludeFile "3dobject.pb" ;Include File For 3D Object Handling

Global obj.SHADOWEDOBJECT ;Object
Global xrot.f=0,xspeed.f=0 ;X Rotation & X Speed
Global yrot.f=0,yspeed.f=0 ;Y Rotation & Y Speed

Global Dim LightPos.f(4) ;Light Position
 LightPos(0)= 0.0 : LightPos(1)= 5.0 : LightPos(2)=-4.0 : LightPos(3)= 1.0
Global Dim LightAmb.f(4) ;Ambient Light Values
 LightAmb(0)= 0.2 : LightAmb(1)= 0.2 : LightAmb(2)= 0.2 : LightAmb(3)= 1.0
Global Dim LightDif.f(4) ;Diffuse Light Values
 LightDif(0)= 0.6 : LightDif(1)= 0.6 : LightDif(2)= 0.6 : LightDif(3)= 1.0
Global Dim LightSpc.f(4) ;Specular Light Values
 LightSpc(0)=-0.2 : LightSpc(1)=-0.2 : LightSpc(2)=-0.2 : LightSpc(3)= 1.0
 
Global Dim MatAmb.f(4) ;Material - Ambient Values
 MatAmb(0)= 0.4 : MatAmb(1)= 0.4 : MatAmb(2)= 0.4 : MatAmb(3)= 1.0
Global Dim MatDif.f(4) ;Material - Diffuse Values
 MatDif(0)= 0.2 : MatDif(1)= 0.6 : MatDif(2)= 0.9 : MatDif(3)= 1.0
Global Dim MatSpc.f(4) ;Material - Specular Values
 MatSpc(0)= 0.0 : MatSpc(1)= 0.0 : MatSpc(2)= 0.0 : MatSpc(3)= 1.0
Global Dim MatShn.f(1) ;Material - Shininess
 MatShn(0)= 0.0
 
Global Dim ObjPos.f(3) ;Object Position
 ObjPos(0)=-2.0 : ObjPos(1)=-2.0 : ObjPos(2)=-5.0
 
Global q.i ;Quadratic For Drawing A Sphere

Global Dim SpherePos.f(3) ;Sphere Position
 SpherePos(0)=-4.0 : SpherePos(1)=-5.0 : SpherePos(2)=-6.0
 

Procedure VMatMult(Array M.f(1), Array v.f(1))

 Protected Dim res.f(4) ;Hold Calculated Results
 res(0)=M( 0)*v(0)+M( 4)*v(1)+M( 8)*v(2)+M(12)*v(3)
 res(1)=M( 1)*v(0)+M( 5)*v(1)+M( 9)*v(2)+M(13)*v(3)
 res(2)=M( 2)*v(0)+M( 6)*v(1)+M(10)*v(2)+M(14)*v(3)
 res(3)=M( 3)*v(0)+M( 7)*v(1)+M(11)*v(2)+M(15)*v(3)
 v(0)=res(0) ;Results Are Stored Back In v()
 v(1)=res(1)
 v(2)=res(2)
 v(3)=res(3) ;Homogenous Coordinate
 
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

Procedure.l InitGLObjects() ;Initialize Objects

 If readObject("Data/Object2.txt",obj)=0 ;Read Object2 Into obj
  ProcedureReturn #False ;If Failed Return False
 EndIf
 
 setConnectivity(obj) ;Set Face To Face Connectivity
 
 Protected i.l
 For i=0 To obj\nFaces-1 ;Loop Through All Object Planes
  calculatePlane(obj,i) ;Compute Plane Equations For All Faces
 Next
 
 ProcedureReturn #True ;Return True
 
EndProcedure

Procedure KillGLObjects()

 killObject(obj) ;Delete The Object
 gluDeleteQuadric_(q) ;Delete The Quadratic
 
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here

 If InitGLObjects()=0 ;Function For Initializing Our Object(s)
  ProcedureReturn #False
 EndIf
 
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glClearStencil_(0) ;Stencil Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
 
 glLightfv_(#GL_LIGHT1,#GL_POSITION,LightPos()) ;Set Light1 Position
 glLightfv_(#GL_LIGHT1,#GL_AMBIENT,LightAmb()) ;Set Light1 Ambience
 glLightfv_(#GL_LIGHT1,#GL_DIFFUSE,LightDif()) ;Set Light1 Diffuse
 glLightfv_(#GL_LIGHT1,#GL_SPECULAR,LightSpc()) ;Set Light1 Specular
 glEnable_(#GL_LIGHT1) ;Enable Light1
 glEnable_(#GL_LIGHTING) ;Enable Lighting
 
 glMaterialfv_(#GL_FRONT,#GL_AMBIENT,MatAmb()) ;Set Material Ambience
 glMaterialfv_(#GL_FRONT,#GL_DIFFUSE,MatDif()) ;Set Material Diffuse
 glMaterialfv_(#GL_FRONT,#GL_SPECULAR,MatSpc()) ;Set Material Specular
 glMaterialfv_(#GL_FRONT,#GL_SHININESS,MatShn()) ;Set Material Shininess
 
 glCullFace_(#GL_BACK) ;Set Culling Face To Back Face
 glEnable_(#GL_CULL_FACE) ;Enable Culling
 glClearColor_(0.1,1.0,0.5,1.0) ;Set Clear Color (Greenish Color)
 
 q=gluNewQuadric_() ;Initialize Quadratic
 gluQuadricNormals_(q,#GL_SMOOTH) ;Enable Smooth Normal Generation
 gluQuadricTexture_(q,#GL_FALSE) ;Disable Auto Texture Coords
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawGLRoom() ;Draw The Room (Box)

 glBegin_(#GL_QUADS) ;Begin Drawing Quads
  ;Floor
  glNormal3f_(0.0, 1.0, 0.0) ;Normal Pointing Up
  glVertex3f_(-10.0,-10.0,-20.0) ;Back Left
  glVertex3f_(-10.0,-10.0, 20.0) ;Front Left
  glVertex3f_( 10.0,-10.0, 20.0) ;Front Right
  glVertex3f_( 10.0,-10.0,-20.0) ;Back Right
  ;Ceiling
  glNormal3f_(0.0,-1.0, 0.0) ;Normal Point Down
  glVertex3f_(-10.0, 10.0, 20.0) ;Front Left
  glVertex3f_(-10.0, 10.0,-20.0) ;Back Left
  glVertex3f_( 10.0, 10.0,-20.0) ;Back Right
  glVertex3f_( 10.0, 10.0, 20.0) ;Front Right
  ;Front Wall
  glNormal3f_(0.0, 0.0, 1.0) ;Normal Pointing Away From Viewer
  glVertex3f_(-10.0, 10.0,-20.0) ;Top Left
  glVertex3f_(-10.0,-10.0,-20.0) ;Bottom Left
  glVertex3f_( 10.0,-10.0,-20.0) ;Bottom Right
  glVertex3f_( 10.0, 10.0,-20.0) ;Top Right
  ;Back Wall
  glNormal3f_(0.0, 0.0,-1.0) ;Normal Pointing Towards Viewer
  glVertex3f_( 10.0, 10.0, 20.0) ;Top Right
  glVertex3f_( 10.0,-10.0, 20.0) ;Bottom Right
  glVertex3f_(-10.0,-10.0, 20.0) ;Bottom Left
  glVertex3f_(-10.0, 10.0, 20.0) ;Top Left
  ;Left Wall
  glNormal3f_(1.0, 0.0, 0.0) ;Normal Pointing Right
  glVertex3f_(-10.0, 10.0, 20.0) ;Top Front
  glVertex3f_(-10.0,-10.0, 20.0) ;Bottom Front
  glVertex3f_(-10.0,-10.0,-20.0) ;Bottom Back
  glVertex3f_(-10.0, 10.0,-20.0) ;Top Back
  ;Right Wall
  glNormal3f_(-1.0, 0.0, 0.0) ;Normal Pointing Left
  glVertex3f_( 10.0, 10.0,-20.0) ;Top Back
  glVertex3f_( 10.0,-10.0,-20.0) ;Bottom Back
  glVertex3f_( 10.0,-10.0, 20.0) ;Bottom Front
  glVertex3f_( 10.0, 10.0, 20.0) ;Top Front
 glEnd_() ;Done Drawing Quads
 
EndProcedure

Procedure DrawScene(Gadget)
  
 Protected Dim Minv.f(16)
 Protected Dim wlp.f(4)
 Protected Dim lp.f(4)
 
 SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
 
 ;Clear Color Buffer, Depth Buffer, Stencil Buffer
 glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT);
 
 glLoadIdentity_() ;Reset Modelview Matrix
 glTranslatef_( 0.0, 0.0,-20.0) ;Zoom Into Screen 20 Units
 glLightfv_(#GL_LIGHT1,#GL_POSITION,LightPos()) ;Position Light1
 glTranslatef_(SpherePos(0),SpherePos(1),SpherePos(2)) ;Position The Sphere
 gluSphere_(q,1.5,32,16) ;Draw A Sphere
 
 ;Calculate light's position relative to local coordinate system
 ;Dunno if this is the best way to do it, but it actually works
 
 glLoadIdentity_() ;Reset Modelview Matrix
 glRotatef_(-yrot,0.0,1.0,0.0) ;Rotate By -yrot On Y Axis
 glRotatef_(-xrot,1.0,0.0,0.0) ;Rotate By -xrot On X Axis
 glGetFloatv_(#GL_MODELVIEW_MATRIX,Minv()) ;Retrieve ModelView Matrix (Stores In Minv)
 lp(0)=LightPos(0) ;Store Light Position X In lp[0]
 lp(1)=LightPos(1) ;Store Light Position Y In lp[1]
 lp(2)=LightPos(2) ;Store Light Position Z In lp[2]
 lp(3)=LightPos(3) ;Store Light Direction In lp[3]
 VMatMult(Minv(),lp()) ;We Store Rotated Light Vector In 'lp' Array
 glTranslatef_(-ObjPos(0),-ObjPos(1),-ObjPos(2)) ;Move Negative On All Axis Based On ObjPos[] Values (X, Y, Z)
 glGetFloatv_(#GL_MODELVIEW_MATRIX,Minv()) ;Retrieve ModelView Matrix From Minv
 wlp(0)=0.0 ;World Local Coord X To 0
 wlp(1)=0.0 ;World Local Coord Y To 0
 wlp(2)=0.0 ;World Local Coord Z To 0
 wlp(3)=1.0
 VMatMult(Minv(),wlp()) ;We Store The Position Of The World Origin Relative To The Local Coord. System In 'wlp' Array
 lp(0)+wlp(0) ;Adding These Two Gives Us The
 lp(1)+wlp(1) ;Position Of The Light Relative To
 lp(2)+wlp(2) ;The Local Coordinate System
 
 glLoadIdentity_() ;Reset Modelview Matrix
 glTranslatef_( 0.0, 0.0,-20.0) ;Zoom Into The Screen 20 Units
 DrawGLRoom() ;Draw The Room
 glTranslatef_(ObjPos(0),ObjPos(1),ObjPos(2)) ;Position The Object
 glRotatef_(xrot,1.0,0.0,0.0) ;Spin It On The X Axis By xrot
 glRotatef_(yrot,0.0,1.0,0.0) ;Spin It On The Y Axis By yrot
 drawObject(obj) ;Procedure For Drawing The Loaded Object
 castShadow(obj,lp()) ;Procedure For Casting The Shadow Based On The Silhouette
 
 glColor4f_(0.7,0.4,0.0,1.0) ;Set Color To An Orange
 glDisable_(#GL_LIGHTING) ;Disable Lighting
 glDepthMask_(#GL_FALSE) ;Disable Depth Mask
 glTranslatef_(lp(0),lp(1),lp(2)) ;Translate To Light's Position (Notice We're Still In Local Coordinate System)
 gluSphere_(q,0.2,16,8) ;Draw A Little Yellow Sphere (Represents Light)
 glEnable_(#GL_LIGHTING) ;Enable Lighting
 glDepthMask_(#GL_TRUE) ;Enable Depth Mask
 
 xrot+xspeed ;Increase xrot By xspeed
 yrot+yspeed ;Increase yrot By yspeed
 glFlush_() ;Flush The OpenGL Pipeline
 
 SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
  
 ProcedureReturn #True ;Everything Went OK
  
EndProcedure

Procedure ProcessKeyboard() ;Process Keyboard Results
  

;Spin Object
 If KeyboardPushed(#PB_Key_Left) And yspeed>-2.5
  yspeed-0.1 ;'Arrow Left' Decrease yspeed
 EndIf
 If KeyboardPushed(#PB_Key_Right) And yspeed<2.5
  yspeed+0.1 ;'Arrow Right' Increase yspeed
 EndIf
 If KeyboardPushed(#PB_Key_Up) And xspeed>-2.5
  xspeed-0.1 ;'Arrow Up' Decrease xspeed
 EndIf
 If KeyboardPushed(#PB_Key_Down) And xspeed<2.5
  xspeed+0.1 ;'Arrow Down' Increase xspeed
 EndIf
 
 ;Adjust Light's Position (U,I,O,J,K,L Keys)
 If KeyboardPushed(#PB_Key_L)
  LightPos(0)+0.05 ;'L' Moves Light Right
 EndIf
 If KeyboardPushed(#PB_Key_J)
  LightPos(0)-0.05 ;'J' Moves Light Left
 EndIf
 If KeyboardPushed(#PB_Key_I)
  LightPos(1)+0.05 ;'I' Moves Light Up
 EndIf
 If KeyboardPushed(#PB_Key_K)
  LightPos(1)-0.05 ;'K' Moves Light Down
 EndIf
 If KeyboardPushed(#PB_Key_O)
  LightPos(2)+0.05 ;'O' Moves Light Toward Viewer
 EndIf
 If KeyboardPushed(#PB_Key_U)
  LightPos(2)-0.05 ;'U' Moves Light Away From Viewer
 EndIf
 
 ;Adjust Object's Position (Numpad 7,8,9,4,5,6 Keys)
 If KeyboardPushed(#PB_Key_Pad6)
  ObjPos(0)+0.05 ;'Numpad6' Move Object Right
 EndIf
 If KeyboardPushed(#PB_Key_Pad4)
  ObjPos(0)-0.05 ;'Numpad4' Move Object Left
 EndIf
 If KeyboardPushed(#PB_Key_Pad8)
  ObjPos(1)+0.05 ;'Numpad8' Move Object Up
 EndIf
 If KeyboardPushed(#PB_Key_Pad5)
  ObjPos(1)-0.05 ;'Numpad5' Move Object Down
 EndIf
 If KeyboardPushed(#PB_Key_Pad9)
  ObjPos(2)+0.05 ;'Numpad9' Move Object Toward Viewer
 EndIf
 If KeyboardPushed(#PB_Key_Pad7)
  ObjPos(2)-0.05 ;'Numpad7' Move Object Away From Viewer
 EndIf
 
 ;Adjust Ball's Position (Q,W,E,A,S,D Keys)
 If KeyboardPushed(#PB_Key_D)
  SpherePos(0)+0.05 ;'D' Move Ball Right
 EndIf
 If KeyboardPushed(#PB_Key_A)
  SpherePos(0)-0.05 ;'A' Move Ball Left
 EndIf
 If KeyboardPushed(#PB_Key_W)
  SpherePos(1)+0.05 ;'W' Move Ball Up
 EndIf
 If KeyboardPushed(#PB_Key_S)
  SpherePos(1)-0.05 ;'S' Move Ball Down
 EndIf
 If KeyboardPushed(#PB_Key_E)
  SpherePos(2)+0.05 ;'E' Move Ball Toward Viewer
 EndIf
 If KeyboardPushed(#PB_Key_Q)
  SpherePos(2)-0.05 ;'Q' Move Ball Away From Viewer
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
  
  If bits = 32
    OpenGlFlags + #PB_OpenGL_24BitDepthBuffer + #PB_OpenGL_8BitStencilBuffer
  EndIf
  
  If Vsync = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0) 
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  ;hDC = GetDC_(hWnd)
  
EndProcedure

CreateGLWindow("Banu Octavian & NeHe's Shadow Casting Tutorial (Lesson 27)",640,480,32,0) ; 24 Bit for Shadow 

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
  
  ProcessKeyboard() ;Processed Keyboard Presses 

  DrawScene(0)
  
  Delay(2)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 13
; FirstLine = 11
; Folding = --
; EnableAsm
; EnableXP
; DisableDebugger