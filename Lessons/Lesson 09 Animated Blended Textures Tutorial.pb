;NeHe's Moving Bitmaps In 3D Space Tutorial (Lesson 9) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/moving_bitmaps_in_3d_space/17001/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

UsePNGImageDecoder() 

Global twinkle.b ;Twinkling Stars
Global tp.b ;'T' Key Pressed?

#NUM=50 ;Number Of Stars To Draw

Structure STARS ;Create A Structure For Star
  r.l : g.l : b.l ;Stars Color
  dist.f ;Stars Distance From Center
  angle.f ;Stars Current Angle
EndStructure

Global Dim star.STARS(#NUM) ;Need To Keep Track Of 'num' Stars

Global zoom.f=-15.0 ;Distance Away From Stars
Global tilt.f=90.0 ;Tilt The View
Global spin.f ;Spin Stars

Global LOOP.l ;General Loop Variable
Global Dim Texture.i(1) ;Storage For One Texture

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
 glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
 glClearDepth_(1.0) ;Depth Buffer Setup
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations
 glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Set The Blending Function For Translucency
 glEnable_(#GL_BLEND) ;Enable Blending
 
 ;glEnable_(#GL_DEPTH_TEST)   ; Enabled, it slowdown a lot the rendering. It's to be sure than the
                            ; rendered objects are inside the z-buffer.

glEnable_(#GL_CULL_FACE)    ; This will enhance the rendering speed as all the back face will be
                            ; ignored. This works only with CLOSED objects like a cube... Singles
                            ; planes surfaces will be visibles only on one side. 
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure


Procedure LoadGLTextures(Names.s)
  
  img = LoadImage(0, Names) ; Load texture with name
  
  *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  	
  glGenTextures_(1, @Texture(0));                  // Create Three Textures

  ;// Create Nearest Filtered Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(0));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer+18), PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,*pointer+54);
  
  FreeMemory(*pointer)
  
  ProcedureReturn  Texture()

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  
  glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Select Our Texture
  
  For LOOP=0 To #NUM-1 ;Loop Through All The Stars
    
    glLoadIdentity_() ;Reset The View Before We Draw Each Star
    glTranslatef_(0.0,0.0,zoom) ;Zoom Into The Screen (Using The Value In 'zoom')
    glRotatef_(tilt,1.0,0.0,0.0) ;Tilt The View (Using The Value In 'tilt')
    
    glRotatef_(star(LOOP)\angle,0.0,1.0,0.0) ;Rotate To The Current Stars Angle
    glTranslatef_(star(LOOP)\dist,0.0,0.0) ;Move Forward On The X Plane
    
    glRotatef_(-star(LOOP)\angle,0.0,1.0,0.0) ;Cancel The Current Stars Angle
    glRotatef_(-tilt,1.0,0.0,0.0) ;Cancel The Screen Tilt
    
    If twinkle ;Twinkling Stars Enabled
      ;Assign A Color Using Bytes
      glColor4ub_(star(#NUM-LOOP-1)\r,star(#NUM-LOOP-1)\g,star(#NUM-LOOP-1)\b,255)
      glBegin_(#GL_QUADS) ;Begin Drawing The Textured Quad
      glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0, 0.0)
      glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0, 0.0)
      glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0, 0.0)
      glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0, 0.0)
      glEnd_() ;Done Drawing The Textured Quad
    EndIf
    
    glRotatef_(spin,0.0,0.0,1.0) ;Rotate The Star On The Z Axis
    ;Assign A Color Using Bytes
    glColor4ub_(star(LOOP)\r,star(LOOP)\g,star(LOOP)\b,255)
    glBegin_(#GL_QUADS) ;Begin Drawing The Textured Quad
    glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0, 0.0)
    glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0, 0.0)
    glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0, 0.0)
    glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0, 0.0)
    glEnd_() ;Done Drawing The Textured Quad
    
    spin+0.01 ;Used To Spin The Stars
    star(LOOP)\angle+LOOP/#NUM ;Changes The Angle Of A Star
    star(LOOP)\dist-0.01 ;Changes The Distance Of A Star
    
    If star(LOOP)\dist<0.0 ;Is The Star In The Middle Yet
      star(LOOP)\dist+5.0 ;Move The Star 5 Units From The Center
      star(LOOP)\r=Random(255) ;Give It A New Red Value
      star(LOOP)\g=Random(255) ;Give It A New Green Value
      star(LOOP)\b=Random(255) ;Give It A New Blue Value
    EndIf
    
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

CreateGLWindow("OpenGL Lesson 9",640,480,16,0)

InitGL()
Debug GetCurrentDirectory()

LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/flare.png")
;LoadGLTextures("Data/Star.bmp") ; -> Original from http://nehe.gamedev.net

For LOOP=0 To #NUM-1 ;Create A Loop That Goes Through All The Stars
  star(LOOP)\angle=0.0 ;Start All The Stars At Angle Zero
  star(LOOP)\dist=(LOOP/#NUM)*5.0 ;Calculate Distance From The Center
  star(LOOP)\r=Random(255) ;Give star(loop) A Random Red Intensity
  star(LOOP)\g=Random(255) ;Give star(loop) A Random Green Intensity
  star(LOOP)\b=Random(255) ;Give star(loop) A Random Blue Intensity
Next

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
  If KeyboardPushed(#PB_Key_PageUp)
     zoom-0.2 ;Zoom Out
  EndIf             
  If KeyboardPushed(#PB_Key_PageDown) 
     zoom+0.2 ;Zoom In
  EndIf      
  If KeyboardPushed(#PB_Key_Up)
     tilt-0.5 ;Tilt The Screen Up
  EndIf    
  If KeyboardPushed(#PB_Key_Down)
     tilt+0.5 ;Tilt The Screen Down
  EndIf 
  If KeyboardPushed(#PB_Key_T)  And Not tp               ;// L Key Being Pressed Not Held?              ;
     tp=#True                                        ;
     twinkle ! 1;         // Toggle Light TRUE/FALSE
  EndIf
           
  If Not KeyboardPushed(#PB_Key_T);                 // Has L Key Been Released?
     tp=#False;               // If So, lp Becomes FALSE
  EndIf
  
  Delay (1)
  
  DrawScene(0)
Until Quit = 1
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 73
; FirstLine = 71
; Folding = -
; EnableAsm
; EnableXP