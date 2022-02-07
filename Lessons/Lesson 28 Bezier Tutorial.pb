;David Nikdel & NeHe's Bezier Tutorial (Lesson 28)
;http://nehe.gamedev.net and http://www.tiptup.com
;https://nehe.gamedev.net/tutorial/bezier_patches__fullscreen_fix/18003/
;Note: requires a bitmap in path "Data/NeHe.bmp"
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 1 Nov 2021
;Note: up-to-date with PB v5.73 (Windows)

UsePNGImageDecoder() 

;Start of Lesson 28

Structure POINT_3D ;Structure For A 3-Dimensional Point ( NEW )
 x.d : y.d : z.d
EndStructure

Structure BEZIER_PATCH ;Structure For A 3rd Degree Bezier Patch ( NEW )
 anchors.POINT_3D[4*4] ;4x4 Grid Of Anchor Points
 dlBPatch.i ;Display List For Bezier Patch
 texture.i ;Texture For The Patch
EndStructure

Global hDC.l ;Private GDI Device Context
Global hRC.l ;Permanent Rendering Context
Global hWnd.l ;Holds Our Window Handle
Global hInstance.l ;Holds The Instance Of The Application


Global Dim keys.b(256) ;Array Used For The Keyboard Routine
Global active.b=#True ;Window Active Flag Set To TRUE By Default
Global fullscreen.b=#True ;Fullscreen Flag Set To Fullscreen Mode By Default

Global rotz.f=180.0 ;Rotation About The Z Axis
Global mybezier.BEZIER_PATCH ;The Bezier Patch We're Going To Use ( NEW )
Global showCPoints.b=#True ;Toggles Displaying The Control Point Grid ( NEW )
Global divs.l=7 ;Number Of Intrapolations (Controls Poly Resolution) ( NEW )

Procedure pointAdd(*p.POINT_3D,*q.POINT_3D) ;Adds 2 Points

 Static r.POINT_3D
 r\x=*p\x+*q\x : r\y=*p\y+*q\y : r\z=*p\z+*q\z
 ProcedureReturn r
 
EndProcedure

Procedure pointTimes(c.d,*p.POINT_3D) ;Multiplies A Point And A Constant

 Static r.POINT_3D
 r\x=*p\x*c : r\y=*p\y*c : r\z=*p\z*c
 ProcedureReturn r
 
EndProcedure

Procedure makePoint(*p.POINT_3D,a.d,b.d,c.d) ;Function For Quick Point Creation

 *p\x=a : *p\y=b : *p\z=c
 
EndProcedure

Procedure setPoint(*p.POINT_3D,*q.POINT_3D) ;Set p.point equal to q.point

 *p\x=*q\x : *p\y=*q\y : *p\z=*q\z
 
EndProcedure

;Calculates 3rd Degree Polynomial Based On Array Of 4 Points
;And A Single Variable (u) Which Is Generally Between 0 And 1

Procedure Bernstein(u.f, Array p.POINT_3D(1))

 Protected a.POINT_3D,b.POINT_3D,c.POINT_3D,d.POINT_3D
 Static r.POINT_3D
 
 setPoint(a,pointTimes(Pow(u,3),p(0)))
 setPoint(b,pointTimes(3*Pow(u,2)*(1-u),p(1)))
 setPoint(c,pointTimes(3*u*Pow((1-u),2),p(2)))
 setPoint(d,pointTimes(Pow((1-u),3),p(3)))
 
 setPoint(a,pointAdd(a,b))
 setPoint(c,pointAdd(c,d))
 setPoint(r,pointAdd(a,c))
 
 ProcedureReturn r
 
EndProcedure

;Generates A Display List Based On The Data In The Patch
;And The Number Of Divisions

Procedure genBezier(*patch.BEZIER_PATCH,divs.l)

 Protected u.l=0,v.l
 Protected py.f,px.f,pyold.f
 Protected drawlist.i
 Protected Dim anchors.POINT_3D(4)
 Protected Dim temp.POINT_3D(4)
 Protected Dim last.POINT_3D(divs+1) ;Array Of Points To Mark The First Line Of Polys
 
 drawlist=glGenLists_(1) ;Make The Display List
 
 If *patch\dlBPatch<>0 ;Get Rid Of Any Old Display Lists
  glDeleteLists_(*patch\dlBPatch,1)
 EndIf
 
 ;The First Derived Curve (Along X-Axis)
 setPoint(temp(0),*patch\anchors[(0*4)+3])
 setPoint(temp(1),*patch\anchors[(1*4)+3])
 setPoint(temp(2),*patch\anchors[(2*4)+3])
 setPoint(temp(3),*patch\anchors[(3*4)+3])
 
 For v=0 To divs ;Create The First Line Of Points
  px=v/divs ;Percent Along Y-Axis
  ;Use The 4 Points From The Derived Curve To Calculate The Points Along That Curve
  setPoint(last(v),Bernstein(px,temp()))
 Next
 
 glNewList_(drawlist,#GL_COMPILE) ;Start A New Display List
 glBindTexture_(#GL_TEXTURE_2D,*patch\texture) ;Bind The Texture
 
 For u=1 To divs
  py=u/divs ;Percent Along Y-Axis
  pyold=(u-1.0)/divs ;Percent Along Old Y Axis
 
  ;Calculate New Bezier Points
  setPoint(anchors(0),*patch\anchors[(0*4)+0])
  setPoint(anchors(1),*patch\anchors[(0*4)+1])
  setPoint(anchors(2),*patch\anchors[(0*4)+2])
  setPoint(anchors(3),*patch\anchors[(0*4)+3])
  setPoint(temp(0),Bernstein(py,anchors())) ;Note: can't pass static array as parameter
 
  setPoint(anchors(0),*patch\anchors[(1*4)+0])
  setPoint(anchors(1),*patch\anchors[(1*4)+1])
  setPoint(anchors(2),*patch\anchors[(1*4)+2])
  setPoint(anchors(3),*patch\anchors[(1*4)+3])
  setPoint(temp(1),Bernstein(py,anchors()))
 
  setPoint(anchors(0),*patch\anchors[(2*4)+0])
  setPoint(anchors(1),*patch\anchors[(2*4)+1])
  setPoint(anchors(2),*patch\anchors[(2*4)+2])
  setPoint(anchors(3),*patch\anchors[(2*4)+3])
  setPoint(temp(2),Bernstein(py,anchors()))
 
  setPoint(anchors(0),*patch\anchors[(3*4)+0])
  setPoint(anchors(1),*patch\anchors[(3*4)+1])
  setPoint(anchors(2),*patch\anchors[(3*4)+2])
  setPoint(anchors(3),*patch\anchors[(3*4)+3])
  setPoint(temp(3),Bernstein(py,anchors()))
 
  glBegin_(#GL_TRIANGLE_STRIP) ;Begin A New Triangle Strip
  For v=0 To divs
   px=v/divs ;Percent Along The X-Axis
   
   glTexCoord2f_(pyold,px) ;Apply The Old Texture Coords
   glVertex3d_(last(v)\x,last(v)\y,last(v)\z) ;Old Point
   
   setPoint(last(v),Bernstein(px,temp())) ;Generate New Point
   glTexCoord2f_(py,px) ;Apply The New Texture Coords
   glVertex3d_(last(v)\x,last(v)\y,last(v)\z) ;New Point
  Next
  glEnd_() ;End The Triangle Strip
 
 Next
 
 glEndList_() ;End The List
 
 Dim last.POINT_3D(0) ;Free The Old Vertices Array
 ProcedureReturn drawlist ;Return The Display List
 
EndProcedure

Procedure initBezier() ;Set The Bezier Vertices

 makePoint(mybezier\anchors[(0*4)+0],-0.75,-0.75,-0.5 )
 makePoint(mybezier\anchors[(0*4)+1],-0.25,-0.75, 0.0 )
 makePoint(mybezier\anchors[(0*4)+2], 0.25,-0.75, 0.0 )
 makePoint(mybezier\anchors[(0*4)+3], 0.75,-0.75,-0.5 )
 makePoint(mybezier\anchors[(1*4)+0],-0.75,-0.25,-0.75)
 makePoint(mybezier\anchors[(1*4)+1],-0.25,-0.25, 0.5 )
 makePoint(mybezier\anchors[(1*4)+2], 0.25,-0.25, 0.5 )
 makePoint(mybezier\anchors[(1*4)+3], 0.75,-0.25,-0.75)
 makePoint(mybezier\anchors[(2*4)+0],-0.75, 0.25, 0.0 )
 makePoint(mybezier\anchors[(2*4)+1],-0.25, 0.25,-0.5 )
 makePoint(mybezier\anchors[(2*4)+2], 0.25, 0.25,-0.5 )
 makePoint(mybezier\anchors[(2*4)+3], 0.75, 0.25, 0.0 )
 makePoint(mybezier\anchors[(3*4)+0],-0.75, 0.75,-0.5 )
 makePoint(mybezier\anchors[(3*4)+1],-0.25, 0.75,-1.0 )
 makePoint(mybezier\anchors[(3*4)+2], 0.25, 0.75,-1.0 )
 makePoint(mybezier\anchors[(3*4)+3], 0.75, 0.75,-0.5 )
 mybezier\dlBPatch=0 ;Go Ahead And Initialize This To NULL
 
EndProcedure

Procedure LoadGLTexture(*texPntr.INTEGER,name.s) ;Load Bitmaps And Convert To Textures

 Protected success.b=#False
 Protected TEST.i=#Null
 
 If *texPntr=0 ;invalid pointer
  ProcedureReturn #False
 EndIf
 
 glGenTextures_(1,@*texPntr\i) ;Generate 1 Texture
 
 TEST=ReadFile(#PB_Any,name) ;Test To See If The File Exists
 
 If TEST<>#Null ;If It Does
   CloseFile(TEST) ;Close The File
   
    LoadImage(0,name) ; Load texture with name
    *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(0)

 EndIf
 
 If *pointer<>#Null ;If It Loaded
  success=#True
 
  ;Typical Texture Generation Using Data From The Bitmap
  glBindTexture_(#GL_TEXTURE_2D,*texPntr\i)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D,0,3,PeekL(*pointer+18),PeekL(*pointer+22),0,#GL_RGB,#GL_UNSIGNED_BYTE,*pointer+54)
  FreeMemory(*pointer)
 EndIf
 
 
 ProcedureReturn success
 
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

 glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
 glClearColor_(0.05,0.05,0.05,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
 
 initBezier() ;Initialize the Bezier's Control Grid
 
 ;If LoadGLTexture(@mybezier\texture,"Data/NeHe.bmp")=0 ; Load The Texture
 ;  ProcedureReturn #False
 ;EndIf
 
 mybezier\dlBPatch=genBezier(mybezier,divs) ;Generate The Patch
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
 glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
 glLoadIdentity_() ;Reset The Current Modelview Matrix
 glTranslatef_(0.0,0.0,-4.0) ;Move Into The Screen 4.0
 glRotatef_(-75.0,1.0,0.0,0.0)
 glRotatef_(rotz,0.0,0.0,1.0) ;Rotate The Triangle On The Z-Axis
 
 glCallList_(mybezier\dlBPatch) ;Call The Bezier's Display List (This Need Only Be Updated When The Patch Changes)
 
 If showCPoints ;If Drawing The Grid Is Toggled On
  glDisable_(#GL_TEXTURE_2D)
  glColor3f_(1.0,0.0,0.0)
  For i=0 To 4-1 ;Draw The Horizontal Lines
   glBegin_(#GL_LINE_STRIP)
   For j=0 To 4-1
    glVertex3d_(mybezier\anchors[(i*4)+j]\x,mybezier\anchors[(i*4)+j]\y,mybezier\anchors[(i*4)+j]\z)
   Next
   glEnd_()
  Next
  For i=0 To 4-1 ;Draw The Vertical Lines
   glBegin_(#GL_LINE_STRIP)
   For j=0 To 4-1
    glVertex3d_(mybezier\anchors[(j*4)+i]\x,mybezier\anchors[(j*4)+i]\y,mybezier\anchors[(j*4)+i]\z)
   Next
   glEnd_()
  Next
  glColor3f_(1.0,1.0,1.0)
  glEnable_(#GL_TEXTURE_2D)
 EndIf
  
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

CreateGLWindow("David Nikdel & NeHe's Bezier Tutorial (Lesson 28)",640,480,16,0)


LoadGLTexture(@mybezier\texture,#PB_Compiler_Home + "examples/3d/Data/Textures/DosCarte.png")
;LoadGLTexture(@mybezier\texture,"Data/NeHe.bmp")=0 ;Load The Texture original
 
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
    
   If KeyboardPushed(#PB_Key_Left) ;Left Arrow
    rotz-0.8 ;Rotate Left
  EndIf
  
   If KeyboardPushed(#PB_Key_Right) ;Right Arrow
    rotz+0.8 ;Rotate Right
   EndIf
   
   If KeyboardPushed(#PB_Key_Up) And divs<32 And lUp=0;Up Arrow
      lUp=#True
     divs+1 ;Resolution Up
    mybezier\dlBPatch=genBezier(mybezier,divs) ;Update The Patch
   ElseIf Not KeyboardPushed(#PB_Key_Up) ;Has L Key Been Released?
      lUp=#False ;If So, lp Becomes FALSE
   EndIf
   
   If KeyboardPushed(#PB_Key_Down) And divs>1 And ldown=0;Down Arrow
     ldown=#True
     divs-1 ;Resolution Down
    mybezier\dlBPatch=genBezier(mybezier,divs) ;Update The Patch
   ElseIf Not KeyboardPushed(#PB_Key_Down) ;Has L Key Been Released?
      ldown=#False ;If So, lp Becomes FALSE
   EndIf
   
   If KeyboardPushed(#PB_Key_Space) And lspace = 0;Spacebar
     lspace=#True
     showCPoints=~showCPoints & 1 ;Toggles showCPoints
   ElseIf Not KeyboardPushed(#PB_Key_Space) ;Has L Key Been Released?
      lspace=#False ;If So, lp Becomes FALSE
   EndIf
   
  DrawScene(0)
  
  Delay(5)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 26
; FirstLine = 24
; Folding = ---
; EnableAsm
; EnableXP