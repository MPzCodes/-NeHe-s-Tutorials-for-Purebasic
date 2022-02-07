;NeHe's Loading And Moving Through A 3D World Tutorial (Lesson 10) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/loading_and_moving_through_a_3d_world/22003/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

UseJPEGImageDecoder() 

Global blend.b ;Blending ON/OFF
Global bp.b ;B Pressed?
Global fp.b ;F Pressed?

#PIOVER180=0.0174532925 ;constant for sin/cos

Global heading.f ;Y rotation
Global xpos.f ;position
Global zpos.f

Global yrot.f ;Y Rotation
Global walkbias.f=0 ;walk bounce
Global walkbiasangle.f=0
Global lookupdown.f=0 ;tilt

Global filter.l ;Which Filter To Use
Global Dim texture.l(3) ;Storage For 3 Textures

Structure VERTEX ;Build Our Vertex Structure
  x.f : y.f : z.f ;3D Coordinates
  u.f : v.f ;Texture Coordinates
EndStructure

Structure TRIANGLE ;Build Our Triangle Structure
  vertex.VERTEX[3] ;Array Of Three Vertices
EndStructure

Global Dim numtriangles.l(1) ;Number Of Triangles In Sector
Global Dim sector1.TRIANGLE(1) ;Array Of Triangles, Our Model Goes Here

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
 glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Set The Blending Function For Translucency
 glClearColor_(0.0,0.0,0.0,0.0) ;This Will Clear The Background Color To Black
 glClearDepth_(1.0) ;Enables Clearing Of The Depth Buffer
 glDepthFunc_(#GL_LESS) ;The Type Of Depth Test To Do
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glShadeModel_(#GL_SMOOTH) ;Enables Smooth Color Shading
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure LoadGLTextures(Names.s)
  
  LoadImage(0, Names) ; Load texture with name
  *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  	
  glGenTextures_(3, @Texture(0));                  // Create Three Textures

  ;// Create Nearest Filtered Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(0));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST); // ( NEW )
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST); // ( NEW )
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer+18), PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54);
  ;// Create Linear Filtered Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(1));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer+18), PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54);
  ;// Create MipMapped Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(2));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST); // ( NEW )
  gluBuild2DMipmaps_(#GL_TEXTURE_2D, 3,  PeekL(*pointer+18), PeekL(*pointer+22), #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54); // ( NEW )
  
  FreeMemory(*pointer)
  
EndProcedure

Procedure Fps()
  
  Global Now = ElapsedMilliseconds()
  Global Ticks , FrameCounter
     If (Now-Ticks) > 999
        Ticks = Now
        SetWindowTitle(0,"OpenGL Lesson 10 - FPS: "+ Str( FrameCounter )) 
        FrameCounter = 0
      EndIf
  FrameCounter + 1
      
EndProcedure

Procedure.s readstr(f.i) ;Read In A String
  
  Protected string.s
  While Left(string,1)="/" Or Left(string,1)="" ;See If It Is Worthy Of Processing
    string=ReadString(f) ;Read One Line
  Wend
  ProcedureReturn string ;return the line
  
EndProcedure

Procedure SetupWorld(Filename.s) ;Setup Our World
  
  Protected filein.i ;File To Work With
  Protected oneline.s,char.s ;Strings To Store Data In
  Protected triloop.l,vertloop.l,pos.l,count.l
  
  filein=ReadFile(#PB_Any,Filename) ;Open Our File
  If filein=0 ;file can't be opened
    ProcedureReturn #False
  EndIf
  
  oneline=readstr(filein) ;Get Single Line Of Data, 1st line is numtriangles
  
  For pos=1 To Len(oneline) ;parse the line, instead of sscanf()
    If Asc(Mid(oneline,pos,1))>48 And Asc(Mid(oneline,pos,1))<58 ;numeric char
      char=Mid(oneline,pos,Len(oneline)-pos+1)
      numtriangles(0)=Val(char) ;Read In Number Of Triangles
      Break ;exit loop
    EndIf
  Next
  
  ReDim sector1.TRIANGLE(numtriangles(0)) ;Allocate Memory For Sector
  
  For triloop=0 To numtriangles(0)-1 ;Loop Through All The Triangles
    For vertloop=0 To 2 ;Loop Through All The Vertices
      oneline=readstr(filein) ;Read String To Work With
      
      count=0 : char="" ;reset for each line
      For pos=1 To Len(oneline) ;parse the line, instead of sscanf()
        If Mid(oneline,pos,1)<>" " ;if not space
          char=char+Mid(oneline,pos,1) ;add char
        EndIf
        If Len(char)>0 And (Mid(oneline,pos,1)=" " Or pos=Len(oneline)) ;if char and space or end-of-line
          Select count ;Store Values Into Respective Vertices
            Case 0 : sector1(triloop)\vertex[vertloop]\x=ValF(char)
            Case 1 : sector1(triloop)\vertex[vertloop]\y=ValF(char)
            Case 2 : sector1(triloop)\vertex[vertloop]\z=ValF(char)
            Case 3 : sector1(triloop)\vertex[vertloop]\u=ValF(char)
            Case 4 : sector1(triloop)\vertex[vertloop]\v=ValF(char)
          EndSelect
          count=count+1 ;next VERTEX member
          char="" ;reset for next
        EndIf
      Next
      
    Next
  Next
  
  CloseFile(filein) ;Close Our File
  
  ProcedureReturn #True ;Jump Back
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  Protected x_m.f,y_m.f,z_m.f,u_m.f,v_m.f ;Floating Point For Temp X, Y, Z, U And V Vertices
  Protected xtrans.f=-xpos ;Used For Player Translation On The X Axis
  Protected ztrans.f=-zpos ;Used For Player Translation On The Z Axis
  Protected ytrans.f=-walkbias-0.25 ;Used For Bouncing Motion Up And Down
  Protected sceneroty.f=360.0-yrot ;360 Degree Angle For Player Direction
  Protected loop_m.l
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The View
  
  glRotatef_(lookupdown,1.0,0,0) ;Rotate Up And Down To Look Up And Down
  glRotatef_(sceneroty,0,1.0,0) ;Rotate Depending On Direction Player Is Facing
  
  glTranslatef_(xtrans,ytrans-0.25,ztrans) ;Translate The Scene Based On Player Position
  glBindTexture_(#GL_TEXTURE_2D,texture(filter)) ;Select A Texture Based On filter
  
  ;Process Each Triangle
  For loop_m=0 To numtriangles(0)-1 ;Loop Through All The Triangles
    glBegin_(#GL_TRIANGLES) ;Start Drawing Triangles
    glNormal3f_( 0.0, 0.0, 1.0) ;Normal Pointing Forward
    x_m=sector1(loop_m)\vertex[0]\x ;X Vertex Of 1st Point
    y_m=sector1(loop_m)\vertex[0]\y ;Y Vertex Of 1st Point
    z_m=sector1(loop_m)\vertex[0]\z ;Z Vertex Of 1st Point
    u_m=sector1(loop_m)\vertex[0]\u ;U Texture Coord Of 1st Point
    v_m=sector1(loop_m)\vertex[0]\v ;V Texture Coord Of 1st Point
    glTexCoord2f_(u_m,v_m) : glVertex3f_(x_m,y_m,z_m) ;Set The TexCoord And Vertice
    
    x_m=sector1(loop_m)\vertex[1]\x ;X Vertex Of 2nd Point
    y_m=sector1(loop_m)\vertex[1]\y ;Y Vertex Of 2nd Point
    z_m=sector1(loop_m)\vertex[1]\z ;Z Vertex Of 2nd Point
    u_m=sector1(loop_m)\vertex[1]\u ;U Texture Coord Of 2nd Point
    v_m=sector1(loop_m)\vertex[1]\v ;V Texture Coord Of 2nd Point
    glTexCoord2f_(u_m,v_m) : glVertex3f_(x_m,y_m,z_m) ;Set The TexCoord And Vertice
    
    x_m=sector1(loop_m)\vertex[2]\x ;X Vertex Of 3rd Point
    y_m=sector1(loop_m)\vertex[2]\y ;Y Vertex Of 3rd Point
    z_m=sector1(loop_m)\vertex[2]\z ;Z Vertex Of 3rd Point
    u_m=sector1(loop_m)\vertex[2]\u ;U Texture Coord Of 3rd Point
    v_m=sector1(loop_m)\vertex[2]\v ;V Texture Coord Of 3rd Point
    glTexCoord2f_(u_m,v_m) : glVertex3f_(x_m,y_m,z_m) ;Set The TexCoord And Vertice
    glEnd_() ;Done Drawing Triangles
  Next

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

CreateGLWindow("OpenGL Lesson 10",640,480,16,0)

InitGL() 

SetupWorld("Data/world.txt") ;File To Load World Data From

;LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Grass.jpg")
LoadGLTextures("Data/mud.bmp") ; -> Original from http://nehe.gamedev.net

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
  ElseIf KeyboardPushed(#PB_Key_PageUp) 
     lookupdown-0.16 ;Tilt The Scene Up
  ElseIf KeyboardPushed(#PB_Key_PageDown) 
     lookupdown+0.16 ;Tilt The Scene Down 
  ElseIf KeyboardPushed(#PB_Key_Right)
     heading-0.32 ;Rotate The Scene To The Left
     yrot=heading
  ElseIf KeyboardPushed(#PB_Key_Left)
    heading+0.32 ;Rotate The Scene To The Right
    yrot=heading
  EndIf  
 
  If KeyboardPushed (#PB_Key_B)   And Not bp;               // Is F Key Being Pressed?                 
    bp=#True;                // fp Becomes TRUE
    blend=Bool(Not blend);         // Toggle Blend TRUE/FALSE 
    If blend             ;             // If Not Light
       glEnable_(#GL_BLEND);     // Turn Blending On
  Global Ticks , FrameCounter
       glDisable_(#GL_DEPTH_TEST);   // Turn Depth Testing Off
    Else                      ;                    // Otherwise
       glDisable_(#GL_BLEND);        // Turn Blending Off
       glEnable_(#GL_DEPTH_TEST);    // Turn Depth Testing On
    EndIf
  EndIf 
          
  If Not KeyboardPushed (#PB_Key_B);                 // Has F Key Been Released?
     bp=#False;               // If So, fp Becomes FALSE
  EndIf 
  
  If KeyboardPushed(#PB_Key_F)  And Not fp;               // Is F Key Being Pressed?
     fp=#True;                // fp Becomes TRUE
     filter+1;              // filter Value Increases By One
     If filter>2;                // Is Value Greater Than 2?
        filter=0;           // If So, Set filter To 0
     EndIf
  EndIf
            
  If Not KeyboardPushed(#PB_Key_F);                 // Has F Key Been Released?
     fp=#False;               // If So, fp Becomes FALSE
  EndIf
  
  If KeyboardPushed(#PB_Key_Up) ;Is The Up Arrow Being Pressed?
     xpos-Sin(heading*#PIOVER180)*0.006 ;Move On The X-Plane Based On Player Direction
     zpos-Cos(heading*#PIOVER180)*0.006 ;Move On The Z-Plane Based On Player Direction
     If walkbiasangle>=359.0 ;Is walkbiasangle>=359?
        walkbiasangle=0.0 ;Make walkbiasangle Equal 0
     Else ;Otherwise
        walkbiasangle+2 ;If walkbiasangle<359 Increase It
  Global Ticks , FrameCounter
     EndIf
     walkbias=Sin(walkbiasangle*#PIOVER180)/40.0 ;Causes The Player To Bounce
  EndIf
  
  If KeyboardPushed(#PB_Key_Down) ;Is The Down Arrow Being Pressed?
      xpos+Sin(heading*#PIOVER180)*0.004 ;Move On The X-Plane Based On Player Direction
      zpos+Cos(heading*#PIOVER180)*0.004 ;Move On The Z-Plane Based On Player Direction
      If walkbiasangle<=1.0 ;Is walkbiasangle<=1?
         walkbiasangle=359.0 ;Make walkbiasangle Equal 359
      Else ;Otherwise
         walkbiasangle-2 ;If walkbiasangle>1 Decrease It
      EndIf
      walkbias=Sin(walkbiasangle*#PIOVER180)/40.0 ;Causes The Player To Bounce
  EndIf

  DrawScene(0)
  FPS ()
  Delay(2)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 101
; FirstLine = 101
; Folding = --
; EnableAsm
; EnableXP