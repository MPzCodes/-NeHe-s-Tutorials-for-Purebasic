;NeHe's Blending Tutorial (Lesson 8) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/blending/16001/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 04 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

UsePNGImageDecoder() 
UseJPEGImageDecoder() 

Global hDC.i ;Private GDI Device Context

Global light.b;                                  // Lighting ON / OFF
Global blend.b=1;                                // Blending OFF/ON? ( NEW )
Global lp.b;                                     // L Pressed?
Global fp.b;                                     // F Pressed?
Global bp.b;                                     // B Pressed? ( NEW )

Global xrot.f;                                   // X Rotation
Global yrot.f;                                   // Y Rotation
Global xspeed.f;                                 // X Rotation Speed
Global yspeed.f = 0.1;                                 // Y Rotation Speed
Global z.f=-5.0;                                   // Depth Into The Screen

Global filter.i;                                 // Which Filter To Use
Global Dim Texture.l(3) ;Stores Texture Objects 

Global Dim LightAmbient.f(4)  : LightAmbient(0) = 0.5  : LightAmbient(1) = 0.5  : LightAmbient(2) = 0.5  : LightAmbient(3) = 1.0
Global Dim LightDiffuse.f(4)  : LightDiffuse(0) = 1.0  : LightDiffuse(1) = 1.0  : LightDiffuse(2) = 1.0  : LightDiffuse(3) = 1.0
Global Dim LightPosition.f(4) : LightPosition(0) = 0.0 : LightPosition(1) = 0.0 : LightPosition(2) = 2.0 : LightPosition(3) = 1.0

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

 glEnable_(#GL_TEXTURE_2D);                        // Enable Texture Mapping
 glShadeModel_(#GL_SMOOTH);                        // Enable Smooth Shading
 glClearColor_(0.0, 0.0, 0.0, 0.5);                   // Black Background
 glClearDepth_(1.0);                         // Depth Buffer Setup
 glEnable_(#GL_DEPTH_TEST);                        // Enables Depth Testing
 glDepthFunc_(#GL_LEQUAL);                         // The Type Of Depth Testing To Do
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT, #GL_NICEST);          // Really Nice Perspective 

 glLightfv_(#GL_LIGHT1, #GL_AMBIENT, LightAmbient());             // Setup The Ambient Light
 glLightfv_(#GL_LIGHT1, #GL_DIFFUSE, LightDiffuse());             // Setup The Diffuse Light
 glLightfv_(#GL_LIGHT1, #GL_POSITION,LightPosition());            // Position The Light
 glEnable_(#GL_LIGHT1)                                   ; 

 glColor4f_(1.0,1.0,1.0,0.5);               // Full Brightness, 50% Alpha ( NEW )
 glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE);       // Blending Function For Translucency Based On Source Alpha                                   ; 
 
 glEnable_(#GL_BLEND);     // Turn Blending On
 glDisable_(#GL_DEPTH_TEST)
 
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
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer+18),  PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54);
  ;// Create Linear Filtered Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(1));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3, PeekL(*pointer+18), PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer+54);
  ;// Create MipMapped Texture
  glBindTexture_(#GL_TEXTURE_2D, Texture(2));
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST); // ( NEW )
  gluBuild2DMipmaps_(#GL_TEXTURE_2D, 3, PeekL(*pointer+18), PeekL(*pointer+22), #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *pointer+54); // ( NEW )
  
  FreeMemory(*pointer)
  
  ProcedureReturn Texture()
  
EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_ (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
  
  glLoadIdentity_();                   // Reset The View
  
  glTranslatef_(0.0,0.0,z);                      // Translate Into/Out Of The Screen By z
 
  glRotatef_(xrot,1.0,0.0,0.0);                     // Rotate On The X Axis By xrot
  glRotatef_(yrot,0.0,1.0,0.0);                     // Rotate On The Y Axis By yrot
  
  glColor4f_(1.0,1.0,1.0,0.5);               // Full Brightness, 50% Alpha ( NEW )
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE);       // Blending Function For Translucency Based On Source Alpha 
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(filter));              // Select A Texture Based On filter
  
  glBegin_(#GL_QUADS);                      // Draw A Quad
  
    ;// Front Face
    glNormal3f_( 0.0, 0.0, 1.0);                  // Normal Pointing Towards Viewer
    glTexCoord2f_(0.0, 0.0): glVertex3f_(-1.0, -1.0,  1.0);  // Point 1 (Front)
    glTexCoord2f_(1.0, 0.0): glVertex3f_( 1.0, -1.0,  1.0);  // Point 2 (Front)
    glTexCoord2f_(1.0, 1.0): glVertex3f_( 1.0,  1.0,  1.0);  // Point 3 (Front)
    glTexCoord2f_(0.0, 1.0): glVertex3f_(-1.0,  1.0,  1.0);  // Point 4 (Front)
    ;// Back Face
    glNormal3f_( 0.0, 0.0,-1.0);                  // Normal Pointing Away From Viewer
    glTexCoord2f_(1.0, 0.0): glVertex3f_(-1.0, -1.0, -1.0);  // Point 1 (Back)
    glTexCoord2f_(1.0, 1.0): glVertex3f_(-1.0,  1.0, -1.0);  // Point 2 (Back)
    glTexCoord2f_(0.0, 1.0): glVertex3f_( 1.0,  1.0, -1.0);  // Point 3 (Back)
    glTexCoord2f_(0.0, 0.0): glVertex3f_( 1.0, -1.0, -1.0);  // Point 4 (Back)
    ;// Top Face
    glNormal3f_(0.0, 1.0, 0.0);                  // Normal Pointing Up
    glTexCoord2f_(0.0, 1.0): glVertex3f_(-1.0,  1.0, -1.0);  // Point 1 (Top)
    glTexCoord2f_(0.0, 0.0): glVertex3f_(-1.0,  1.0,  1.0);  // Point 2 (Top)
    glTexCoord2f_(1.0, 0.0): glVertex3f_( 1.0,  1.0,  1.0);  // Point 3 (Top)
    glTexCoord2f_(1.0, 1.0): glVertex3f_( 1.0,  1.0, -1.0);  // Point 4 (Top)
    ;// Bottom Face
    glNormal3f_( 0.0,-1.0, 0.0);                  // Normal Pointing Down
    glTexCoord2f_(1.0, 1.0): glVertex3f_(-1.0, -1.0, -1.0);  // Point 1 (Bottom)
    glTexCoord2f_(0.0, 1.0): glVertex3f_( 1.0, -1.0, -1.0);  // Point 2 (Bottom)
    glTexCoord2f_(0.0, 0.0): glVertex3f_( 1.0, -1.0,  1.0);  // Point 3 (Bottom)
    glTexCoord2f_(1.0, 0.0): glVertex3f_(-1.0, -1.0,  1.0);  // Point 4 (Bottom)
    ;// Right face
    glNormal3f_( 1.0, 0.0, 0.0);                  // Normal Pointing Right
    glTexCoord2f_(1.0, 0.0): glVertex3f_( 1.0, -1.0, -1.0);  // Point 1 (Right)
    glTexCoord2f_(1.0, 1.0): glVertex3f_( 1.0,  1.0, -1.0);  // Point 2 (Right)
    glTexCoord2f_(0.0, 1.0): glVertex3f_( 1.0,  1.0,  1.0);  // Point 3 (Right)
    glTexCoord2f_(0.0, 0.0): glVertex3f_( 1.0, -1.0,  1.0);  // Point 4 (Right)
    ;// Left Face
    glNormal3f_(-1.0, 0.0, 0.0);                  // Normal Pointing Left
    glTexCoord2f_(0.0, 0.0): glVertex3f_(-1.0, -1.0, -1.0);  // Point 1 (Left)
    glTexCoord2f_(1.0, 0.0): glVertex3f_(-1.0, -1.0,  1.0);  // Point 2 (Left)
    glTexCoord2f_(1.0, 1.0): glVertex3f_(-1.0,  1.0,  1.0);  // Point 3 (Left)
    glTexCoord2f_(0.0, 1.0): glVertex3f_(-1.0,  1.0, -1.0);  // Point 4 (Left)
        
  glEnd_();

  xrot+xspeed;                               // Add xspeed To xrot
  yrot+yspeed;                               // Add yspeed To yrot
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
    
EndProcedure

Procedure HandleError (Result, Text$)
  If Result = 0
    MessageRequester("Error", Text$, 0)
    End
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
  
  If Vsync = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0) 
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  ;hDC = GetDC_(hWnd)
  
EndProcedure


CreateGLWindow("OpenGL Lesson 8",640,480,16,0)

InitGL() 

LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Caisse.png")
;LoadGLTextures("Data/glass.bmp") ; -> Original from http://nehe.gamedev.net

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
     z-0.02;               // If So, Move Into The Screen
  EndIf             
  If KeyboardPushed(#PB_Key_PageDown) 
     z+0.02;
  EndIf      
  If KeyboardPushed(#PB_Key_Up)
     xspeed-0.01   ;              // If So, Decrease xspeed
  EndIf    
  If KeyboardPushed(#PB_Key_Down)
     xspeed+0.01;              // If So, Increase xspeed
  EndIf      
  If KeyboardPushed(#PB_Key_Right)
     yspeed+0.01;              // If So, Increase yspeed
  EndIf             
  If KeyboardPushed(#PB_Key_Left)
     yspeed-0.01;               // If So, Decrease yspeed
  EndIf  
  
  If KeyboardPushed(#PB_Key_L)  And Not lp               ;// L Key Being Pressed Not Held?              ; 
    lp=#True                                                  ;
    light ! 1;         // Toggle Light TRUE/FALSE
    If light;             // If Not Light
       glEnable_(#GL_LIGHTING);      // Enable Lighting
    Else;                    // Otherwise
       glDisable_(#GL_LIGHTING);     // Disable Lighting
    EndIf
  EndIf
           
  If Not KeyboardPushed(#PB_Key_L);                 // Has L Key Been Released?
     lp=#False;               // If So, lp Becomes FALSE
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
  
  If KeyboardPushed(#PB_Key_B)   And Not bp;               // Is F Key Being Pressed?                 
     bp=#True;                // fp Becomes TRUE
     blend=Bool(Not blend);         // Toggle Blend TRUE/FALSE 
     If blend             ;             // If Not Light
        glEnable_(#GL_BLEND);     // Turn Blending On
        glDisable_(#GL_DEPTH_TEST);   // Turn Depth Testing Off
     Else                      ;                    // Otherwise
        glDisable_(#GL_BLEND);        // Turn Blending Off
        glEnable_(#GL_DEPTH_TEST);    // Turn Depth Testing On
     EndIf
  EndIf
  
  If Not KeyboardPushed(#PB_Key_B);                 // Has F Key Been Released?
     bp=#False;               // If So, fp Becomes FALSE
  EndIf
           
  DrawScene(0)
  Delay(4)
Until Quit = 1



; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 97
; FirstLine = 75
; Folding = --
; EnableAsm
; EnableXP