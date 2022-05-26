;NeHe's Loading Textures From A Resource File & Texturing Triangles Tutorial (Lesson 38) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/loading_textures_from_a_resource_file__texturing_triangles/26001/
;Credits:  Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz 
;Date: 26.05.22
;Note: up-to-date with PB v5.73 (Windows)

Structure object							;// Create A Structure Called Object
	tex.i                       ;// Integer Used To Select Our Texture
	x.f													;// X Position
	y.f													;// Y Position
	z.f													;// Z Position
	yi.f												;// Y Increase Speed (Fall Speed)
	spinz.f											;// Z Axis Spin
	spinzi.f										;// Z Axis Spin Speed
	flap.f											;// Flapping Triangles :)
	fi.f												;// Flap Direction (Increase Value)
EndStructure


Global Dim obj.object(50)    ;// Create 50 Objects Using The Object Structure
Global Dim Texture.l(2)      ;// Storage For 3 Textures


Procedure SetObject(Loopi)										;// SETS The Initial Value Of Each Object (Random)

	obj(Loopi)\tex = Random(2)                  ;// Texture Can Be One Of 3 Textures
	obj(Loopi)\x = Random(33) - 17              ;// Random x Value From -17.0f To 17.0f
	obj(Loopi)\y = 18                           ;// Set y Position To 18 (Off Top Of Screen)
	obj(Loopi)\z = -Random(29999)/1000+ 1       ;// z Is A Random Value From -10.0f To -40.0f
	obj(Loopi)\spinzi = Random(9999)/5000 - 1.0 ;// spinzi Is A Random Value From -1.0f To 1.0f
	obj(Loopi)\flap = 0                         ;// flap Starts Off At 0.0f;
	obj(Loopi)\fi = 0.05 + Random(99)/1000      ;// fi Is A Random Value From 0.05f To 0.15f
	obj(Loopi)\yi = 0.001 + Random(999)/10000   ;// yi Is A Random Value From 0.001f To 0.101f
	
EndProcedure

Procedure LoadGLTextures()
  
  CatchImage(0, ?Pic1)     ;// Load Picture1
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  CatchImage(0, ?Pic2)     ;// Load Picture2
  *pointer2 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  CatchImage(0, ?Pic3)     ;// Load Picture3
  *pointer3 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  
  ; ----- Generate texture
  glGenTextures_(3, @Texture(0));                  // Create Three Textures
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(0))
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer1+18),  PeekL(*pointer1+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer1+54);
  FreeMemory(*pointer1)
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(1))
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer2+18),  PeekL(*pointer2+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer2+54);
  FreeMemory(*pointer2)
  
  glBindTexture_(#GL_TEXTURE_2D, Texture(2))
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer3+18),  PeekL(*pointer3+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer3+54);
  FreeMemory(*pointer3)
  
  ProcedureReturn #True
  
  DataSection
    Pic1:
      IncludeBinary "Data\Butterfly1.bmp"
    Pic2:
      IncludeBinary "Data\Butterfly2.bmp"
    Pic3:
      IncludeBinary "Data\Butterfly3.bmp"
  EndDataSection

EndProcedure

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

 If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
 
 ResizeGadget(0, 0, 0, width, height)
 
 glViewport_(0,0,width,height) ;Reset The Current Viewport
 
 glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
 glLoadIdentity_() ;Reset The Projection Matrix
 
 gluPerspective_(45, width/height,1,1000)
 
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
 glLoadIdentity_() ;Reset The Modelview Matrix
 
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here
  
 LoadGLTextures()
  
 glViewport_(0 , 0,640 ,480) 	              	       ; Set Up A Viewport
 glMatrixMode_(#GL_PROJECTION)	 						           ; Select The Projection Matrix
 glLoadIdentity_();									                 ; Reset The Projection Matrix
 gluPerspective_(45,640/480,1,1000);		
 glMatrixMode_(#GL_MODELVIEW);										// Select The Modelview Matrix
 glLoadIdentity_();
 
 glClearColor_(0, 0, 0, 0.5)                           ;// Black Background
 glClearDepth_(1)                                     ;// Depth Buffer Setup
 glDepthFunc_(#GL_LEQUAL)                             ;// The Type Of Depth Testing (Less Or Equal)
 glDisable_(#GL_DEPTH_TEST)                           ;// Disable Depth Testing
 glShadeModel_(#GL_SMOOTH)                            ;// Select Smooth Shading
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT, #GL_NICEST) ;// Set Perspective Calculations To Most Accurate
 glEnable_(#GL_TEXTURE_2D)                            ;// Enable Texture Mapping
 glBlendFunc_(#GL_ONE,#GL_SRC_ALPHA)                  ;// Set Blending Mode (Cheap / Quick)
 glEnable_(#GL_BLEND)                                 ;// Enable Blending

 For n = 0 To 49          							               ;// LOOP To Initialize 50 Objects
  	SetObject(n)                                       ;// Call SetObject To Assign New Random Values
 Next
 
 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure DrawScene(Gadget)												      ; Draw The Scene
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClearColor_(0.0, 0.0, 0.0, 0.5)						          	; Set The Clear Color To Black
	glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)		; Clear Screen And Depth Buffer
	;glLoadIdentity_()        	
	
  For n = 0 To 49                                        ;// LOOP Of 50 (Draw 50 Objects)
		glLoadIdentity_()                                     ;// Reset The Modelview Matrix
		glBindTexture_(#GL_TEXTURE_2D, texture(obj(n)\tex))   ;// Bind Our Texture
		glTranslatef_(obj(n)\x,obj(n)\y,obj(n)\z)            ;// Position The Object
		glRotatef_(45,1,0,0)                                  ;// Rotate On The X-Axis
		glRotatef_((obj(n)\spinz),0,0,1)                      ;// Spin On The Z-Axis

		glBegin_(#GL_TRIANGLES)                               ;// Begin Drawing Triangles
			;// First Triangle														    _____
			glTexCoord2f_(1,1) : glVertex3f_( 1, 1, 0)          ;//	(2)|    / (1)
			glTexCoord2f_(0,1) : glVertex3f_(-1, 1, obj(n)\flap);//	   |  /
			glTexCoord2f_(0,0) : glVertex3f_(-1,-1, 0)          ;//	(3)|/

			;// Second Triangle
			glTexCoord2f_(1,1) : glVertex3f_( 1, 1, 0)          ;//	       /|(1)
			glTexCoord2f_(0,0) : glVertex3f_(-1,-1, 0)          ;//	     /  |
			glTexCoord2f_(1,0) : glVertex3f_( 1,-1, obj(n)\flap);//	(2)/____|(3)

		glEnd_()                                              ;// Done Drawing Triangles

		obj(n)\y - obj(n)\yi                                  ;// Move Object Down The Screen
		obj(n)\spinz + obj(n)\spinzi                          ;// Increase Z Rotation By spinzi
		obj(n)\flap + obj(n)\fi                               ;// Increase flap Value By fi

		If obj(n)\y < -18									                    ;// Is Object Off The Screen?
			SetObject(n)                                        ;// If So, Reassign New Values
		EndIf

		If ((obj(n)\flap > 1) Or (obj(n)\flap < -1))	        ;// Time To Change Flap Direction?
			obj(n)\fi=-obj(n)\fi                                ;// Change Direction By Making fi = -fi
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

CreateGLWindow("NeHe's Loading Textures From A Resource File & Texturing Triangles Tutorial (Lesson 38) ",640,480,16,0)

InitGL() 

LoadGLTextures()

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
  DrawScene(0)
  Delay(13)
    
Until Quit = 1


; IDE Options = PureBasic 6.00 Beta 8 (Windows - x64)
; Folding = --
; EnableAsm
; EnableXP
; DPIAware