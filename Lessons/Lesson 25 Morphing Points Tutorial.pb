;Piotr Cieslak & NeHe's Morphing Points Tutorial (Lesson 25)
;http://nehe.gamedev.net
;https://nehe.gamedev.net/tutorial/morphing__loading_objects_from_a_file/16003/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 29 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)
;Note: requires vertex data text files in paths "Data/Sphere.txt",
;"Data/Torus.txt", "Data/Tube.txt"

Global xrot.f,yrot.f,zrot.f ;X, Y & Z Rotation
Global xspeed.f,yspeed.f,zspeed.f ;X, Y & Z Spin Speed
Global cx.f,cy.f,cz.f=-15 ;X, Y & Z Position

Global key.l=1 ;Used To Make Sure Same Morph Key Is Not Pressed
Global stepcount.l=0,steps.l=200 ;Step Counter And Maximum Number Of Steps
Global morph.b=#False ;Default morph To False (Not Morphing)

Structure VERTEX ;Structure For 3D Points
  x.f : y.f : z.f ;X, Y & Z Points
EndStructure

Structure OBJECT ;Structure For An Object
  verts.l ;Number Of Vertices For The Object
  points.i ;Address Of Vertice Data (x,y & z)
EndStructure

Global maxver.l ;Will Eventually Hold The Maximum Number Of Vertices
Global morph1.OBJECT,morph2.OBJECT,morph3.OBJECT,morph4.OBJECT ;Our 4 Morphable Objects
Global helper.OBJECT ;Helper Object
Global *sour.OBJECT,*dest.OBJECT ;Source Object, Destination Object

Procedure objallocate(*k.OBJECT,n.l) ;Allocate Memory For Each Object And Defines points
  
  *k\points=AllocateMemory(SizeOf(VERTEX)*n) ;Sets points Equal To VERTEX * Number Of Vertices (3 Points For Each Vertice)
  
EndProcedure

Procedure objfree(*k.OBJECT) ;Frees The Object (Releasing The Memory)
  
  FreeMemory(*k\points) ;Frees Points
  
EndProcedure

Procedure.s readstr(f.i) ;Reads A String From File (f)
  
  Protected string.s
  While Left(string,1)="/" Or Left(string,1)="" ;Until End Of Line Is Reached
    string=ReadString(f) ;Gets A String From f (File)
  Wend
  ProcedureReturn string ;return the line
  
EndProcedure

Procedure objload(name.s,*k.OBJECT) ;Loads Object From File (name)
  
  Protected ver.l ;Will Hold Vertice Count
  Protected filein.i ;Filename To Open
  Protected oneline.s ;Holds One Line Of Text (255 Chars Max)
  Protected i.l,char.s,pos.l,count.l
  
  filein=ReadFile(#PB_Any,name) ;Opens The File For Reading Text In Translated Mode
  
  oneline=readstr(filein) ;Jumps To Code That Reads One Line Of Text From The File
  
  For pos=1 To Len(oneline) ;parse the line, instead of sscanf()
    If Asc(Mid(oneline,pos,1))>48 And Asc(Mid(oneline,pos,1))<58 ;numeric char
      char=Mid(oneline,pos,Len(oneline)-pos+1)
      ver=Val(char) ;Number Is Stored In ver
      Break ;exit loop
    EndIf
  Next
  
  *k\verts=ver ;Sets Objects verts Variable To Equal The Value Of ver
  objallocate(*k,ver) ;Jumps To Code That Allocates Ram To Hold The Object
  
  For i=0 To ver-1 ;Loops Through The Vertices
    oneline=readstr(filein) ;Reads In The Next Line Of Text
    
    count=0 : char="" ;reset for each line
    For pos=1 To Len(oneline) ;parse the line, instead of sscanf()
      If Mid(oneline,pos,1)<>" " ;if not space
        char=char+Mid(oneline,pos,1) ;add char
      EndIf
      If Len(char)>0 And (Mid(oneline,pos,1)=" " Or pos=Len(oneline)) ;if char and space or end-of-line
        Select count ;Store Values Into Respective Vertices
          Case 0 : PokeF(*k\points+(i*SizeOf(VERTEX)),ValF(char)) ;Sets Objects (k) points x Value
          Case 1 : PokeF(*k\points+(i*SizeOf(VERTEX))+4,ValF(char)) ;Sets Objects (k) points y Value
          Case 2 : PokeF(*k\points+(i*SizeOf(VERTEX))+8,ValF(char)) ;Sets Objects (k) points z Value
        EndSelect
        count=count+1 ;next VERTEX member
        char="" ;reset for next
      EndIf
    Next
    
  Next
  
  CloseFile(filein) ;Close The File
  
  If ver>maxver ;If ver Is Greater Than maxver Set maxver Equal To ver
    maxver=ver ;Keeps Track Of Highest Number Of Vertices Used In Any Of The Objects
  EndIf
  
EndProcedure

Procedure calculate(i.l) ;Calculates Movement Of Points During Morphing
  
  ;This Makes Points Move At A Speed So They All Get To Their Destination At The Same Time
  Static a.VERTEX ;Static Vertex Called a
  a\x=(PeekF(*sour\points+(i*SizeOf(VERTEX)))-PeekF(*dest\points+(i*SizeOf(VERTEX))))/steps ;a\x Value Equals Source x - Destination x Divided By Steps
  a\y=(PeekF(*sour\points+(i*SizeOf(VERTEX))+4)-PeekF(*dest\points+(i*SizeOf(VERTEX))+4))/steps ;a\y Value Equals Source y - Destination y Divided By Steps
  a\z=(PeekF(*sour\points+(i*SizeOf(VERTEX))+8)-PeekF(*dest\points+(i*SizeOf(VERTEX))+8))/steps ;a\z Value Equals Source z - Destination z Divided By Steps
  ProcedureReturn a ;Return Pointer To The Results
  
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

Protected i.l
  
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Set The Blending Function For Translucency
  glClearColor_(0.0,0.0,0.0,0.0) ;This Will Clear The Background Color To Black
  glClearDepth_(1.0) ;Enables Clearing Of The Depth Buffer
  glDepthFunc_(#GL_LESS) ;The Type Of Depth Test To Do
  glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
  glShadeModel_(#GL_SMOOTH) ;Enables Smooth Color Shading
  glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
  
  maxver=0 ;Sets Max Vertices To 0 By Default
  objload("Data/Sphere.txt",morph1) ;Load The First Object Into morph1 From File Sphere.txt
  objload("Data/Torus.txt",morph2) ;Load The Second Object Into morph2 From File Torus.txt
  objload("Data/Tube.txt",morph3) ;Load The Third Object Into morph3 From File Tube.txt
  
  objallocate(morph4,486) ;Manually Reserver Ram For A 4th 486 Vertice Object (morph4)
  For i=0 To 486-1 ;Loop Through All 486 Vertices
    PokeF(morph4\points+(i*SizeOf(VERTEX)),(Random(14000)/1000)-7) ;morph4 x Point Becomes A Random Float Value From -7 to 7
    PokeF(morph4\points+(i*SizeOf(VERTEX))+4,(Random(14000)/1000)-7) ;morph4 y Point Becomes A Random Float Value From -7 to 7
    PokeF(morph4\points+(i*SizeOf(VERTEX))+8,(Random(14000)/1000)-7) ;morph4 z Point Becomes A Random Float Value From -7 to 7
  Next
  
  objload("Data/Sphere.txt",helper) ;Load Sphere.txt Object Into Helper (Used As Starting Point)
  *sour=morph1 ;Source & Destination Are Set To Equal First Object (morph1)
  *dest=morph1
  
  ProcedureReturn #True ;Initialization Went OK
 
EndProcedure


Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The View
  glTranslatef_(cx,cy,cz) ;Translate The The Current Position To Start Drawing
  glRotatef_(xrot,1.0,0.0,0.0) ;Rotate On The X Axis By xrot
  glRotatef_(yrot,0.0,1.0,0.0) ;Rotate On The Y Axis By yrot
  glRotatef_(zrot,0.0,0.0,1.0) ;Rotate On The Z Axis By zrot
  
  xrot+xspeed : yrot+yspeed : zrot+zspeed ;Increase xrot,yrot & zrot by xspeed, yspeed & zspeed
  
  Protected tx.f,ty.f,tz.f ;Temp X, Y & Z Variables
  Protected *q.VERTEX ;Holds Returned Calculated Values For One Vertex
  Protected i.l,t.VERTEX
  
  glBegin_(#GL_POINTS) ;Begin Drawing Points
  For i=0 To morph1\verts-1 ;Loop Through All The Verts Of morph1 (All Objects Have The Same Amount Of Verts For Simplicity, Could Use maxver Also)
    If morph ;If morph Is True Calculate Movement Otherwise Movement=0
      *q=calculate(i) ;*q points to a.VERTEX
    Else
      *q=t.VERTEX ;*q points to t.VERTEX, t fields are always zero
    EndIf
    tx=PeekF(helper\points+(i*SizeOf(VERTEX)))-*q\x
    ty=PeekF(helper\points+(i*SizeOf(VERTEX))+4)-*q\y
    tz=PeekF(helper\points+(i*SizeOf(VERTEX))+8)-*q\z
    PokeF(helper\points+(i*SizeOf(VERTEX)),tx) ;Subtract q\x Units From helper\points x (Move On X Axis)
    PokeF(helper\points+(i*SizeOf(VERTEX))+4,ty) ;Subtract q\y Units From helper\points y (Move On Y Axis)
    PokeF(helper\points+(i*SizeOf(VERTEX))+8,tz) ;Subtract q\z Units From helper\points z (Move On Z Axis)
    tx=PeekF(helper\points+(i*SizeOf(VERTEX))) ;Make Temp X Variable Equal To Helper's X Variable
    ty=PeekF(helper\points+(i*SizeOf(VERTEX))+4) ;Make Temp Y Variable Equal To Helper's Y Variable
    tz=PeekF(helper\points+(i*SizeOf(VERTEX))+8) ;Make Temp Z Variable Equal To Helper's Z Variable
    
    glColor3f_(0.0,1.0,1.0) ;Set Color To A Bright Shade Of Off Blue
    glVertex3f_(tx,ty,tz) ;Draw A Point At The Current Temp Values (Vertex)
    glColor3f_(0.0,0.5,1.0) ;Darken Color A Bit
    tx-2**q\x : ty-2**q\y : tz-2**q\z ;Calculate Two Positions Ahead
    glVertex3f_(tx,ty,tz) ;Draw A Second Point At The Newly Calculate Position
    glColor3f_(0.0,0.0,1.0) ;Set Color To A Very Dark Blue
    tx-2**q\x : ty-2**q\y : tz-2**q\z ;Calculate Two More Positions Ahead
    glVertex3f_(tx,ty,tz) ;Draw A Third Point At The Second New Position
  Next ;This Creates A Ghostly Tail As Points Move
  glEnd_() ;Done Drawing Points
  
  ;If We're Morphing And We Haven't Gone Through All 200 Steps Increase Our Step Counter
  ;Otherwise Set Morphing To False, Make Source=Destination And Set The Step Counter Back To Zero.
  If morph And stepcount<=steps
    stepcount+1
  Else
    morph=#False : *sour=*dest : stepcount=0
  EndIf
  
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

CreateGLWindow("Piotr Cieslak & NeHe's Morphing Points Tutorial (Lesson 25), push key 1-4",640,480,16,0)

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
  
  
   If KeyboardPushed(#PB_Key_PageUp) And zspeed<0.5 ;Is Page Up Being Pressed?
          zspeed+0.01 ;Increase zspeed
        EndIf
        If KeyboardPushed(#PB_Key_PageDown) And zspeed>-0.5 ;Is Page Down Being Pressed?
          zspeed-0.01 ;Decrease zspeed
        EndIf
        If KeyboardPushed(#PB_Key_Down) And xspeed<0.5 ;Is Page Up Being Pressed?
          xspeed+0.01 ;Increase xspeed
        EndIf
        If KeyboardPushed(#PB_Key_Up) And xspeed>-0.5 ;Is Page Up Being Pressed?
          xspeed-0.01 ;Decrease xspeed
        EndIf
        If KeyboardPushed(#PB_Key_Right) And yspeed<0.5 ;Is Page Up Being Pressed?
          yspeed+0.01 ;Increase yspeed
        EndIf
        If KeyboardPushed(#PB_Key_Left) And yspeed>-0.5 ;Is Page Up Being Pressed?
          yspeed-0.01 ;Decrease yspeed
        EndIf
        
        If KeyboardPushed(#PB_Key_Q) ;Is Q Key Being Pressed?
          cz-0.01 ;Move Object Away From Viewer
        EndIf
        If KeyboardPushed(#PB_Key_Z) ;Is Z Key Being Pressed?
          cz+0.01 ;Move Object Towards Viewer
        EndIf
        If KeyboardPushed(#PB_Key_W) ;Is W Key Being Pressed?
          cy+0.01 ;Move Object Up
        EndIf
        If KeyboardPushed(#PB_Key_S) ;Is S Key Being Pressed?
          cy-0.01 ;Move Object Down
        EndIf
        If KeyboardPushed(#PB_Key_D) ;Is D Key Being Pressed?
          cx+0.01 ;Move Object Right
        EndIf
        If KeyboardPushed(#PB_Key_A) ;Is A Key Being Pressed?
          cx-0.01 ;Move Object Left
        EndIf
        
        If KeyboardPushed(#PB_Key_1) And key<>1 And morph=0 ;Is 1 Pressed, key Not Equal To 1 And Morph False?
          key=1 ;Sets key To 1 (To Prevent Pressing 1 2x In A Row)
          morph=#True ;Set morph To True (Starts Morphing Process)
          *dest=morph1 ;Destination Object To Morph To Becomes morph1
        EndIf
        If KeyboardPushed(#PB_Key_2) And key<>2 And morph=0 ;Is 2 Pressed, key Not Equal To 2 And Morph False?
          key=2 ;Sets key To 2 (To Prevent Pressing 2 2x In A Row)
          morph=#True ;Set morph To True (Starts Morphing Process)
          *dest=morph2 ;Destination Object To Morph To Becomes morph2
        EndIf
        If KeyboardPushed(#PB_Key_3) And key<>3 And morph=0 ;Is 3 Pressed, key Not Equal To 3 And Morph False?
          key=3 ;Sets key To 3 (To Prevent Pressing 3 2x In A Row)
          morph=#True ;Set morph To True (Starts Morphing Process)
          *dest=morph3 ;Destination Object To Morph To Becomes morph3
        EndIf
        If KeyboardPushed(#PB_Key_4) And key<>4 And morph=0 ;Is 4 Pressed, key Not Equal To 4 And Morph False?
          key=4 ;Sets key To 4 (To Prevent Pressing 4 2x In A Row)
          morph=#True ;Set morph To True (Starts Morphing Process)
          *dest=morph4 ;Destination Object To Morph To Becomes morph4
        EndIf


        

  DrawScene(0)
  Delay(4)
  
Until Quit = 1

; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 57
; FirstLine = 12
; Folding = --
; EnableAsm
; EnableXP