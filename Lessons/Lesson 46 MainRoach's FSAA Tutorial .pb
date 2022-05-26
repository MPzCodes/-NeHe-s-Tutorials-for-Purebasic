;NeHe & MainRoach's FSAA Tutorial (Lesson 46) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/radial_blur__rendering_to_a_texture/18004/
;Credits:  Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date:   26.5.2022
;Note: up-to-date with PB v5.73 (Windows)

Global angle.f

Global mp.b ;M Key Pressed?
Global turn.b = #True ;Turn On/Off

Global sp.b ;Spacebar Pressed?
Global domulti.b = #True;Multisample On/Off

#GL_MULTISAMPLE_ARB                = $809D

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

 If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
 
 ResizeGadget(0, 0, 0, width, height)
 
 glViewport_(0,0,width,height) ;Reset The Current Viewport
 glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
 glLoadIdentity_() ;Reset The Projection Matrix
 gluPerspective_(50,width/height,5,2000) ;Calculate The Aspect Ratio Of The Window
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
 glLoadIdentity_() ;Reset The Modelview Matrix
 
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here

  angle		= 0                                 ;// Set Starting Angle To Zero
  
	glEnable_(#GL_DEPTH_TEST)                   ;// Enable Depth Testing

	glShadeModel_(#GL_SMOOTH)                   ;// Select Smooth Shading

	glClearColor_(0, 0, 0, 0.5);			
	
 ProcedureReturn #True                      ;Initialization Went OK

EndProcedure

Procedure DrawScene(Gadget)												; Draw The Scene
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClearColor_(0.0, 0.0, 0.0, 0.5)						          	; Set The Clear Color To Black
	glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)			; Clear Screen And Depth Buffer
	glLoadIdentity_()        	
	
	If multi
	   glEnable_(#GL_MULTISAMPLE_ARB);	//Enable our multisampleing
	EndIf   
	
	For i = -10 To 9
		For j = -10 To 9
		  glPushMatrix_();
			glTranslatef_(i*2,j*2,-5);
			glRotatef_(angle,0,0,1);
			  glBegin_(#GL_QUADS);
				glColor3f_(1,0,0) : glVertex3f_(i,j,0);
				glColor3f_(0,1,0) : glVertex3f_(i + 2,j,0);
				glColor3f_(0,0,1) : glVertex3f_(i + 2,j + 2,0);
				glColor3f_(1,1,1) : glVertex3f_(i,j + 2,0);
				glEnd_();
			glPopMatrix_();
		Next
	Next	
	
	If turn
		angle + 0.05
	EndIf 

	If domulti
	   glDisable_(#GL_MULTISAMPLE_ARB);
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

CreateGLWindow("NeHe & MainRoach's FSAA Tutorial (Lesson 46) ",640,480,24,0)

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
  
  DrawScene(0)
  Delay(13)
  
  If KeyboardPushed(#PB_Key_Space) And sp=0 ;Is Spacebar Being Pressed?
     sp=#True ;Spacebar Is Being Held
     domulti=~domulti & 1 ;Toggle multisample To The Other
  EndIf
  
  If Not KeyboardPushed(#PB_Key_Space) ;Has Spacebar Been Released?
     sp=#False ;Spacebar Is Released
  EndIf
        
  If KeyboardPushed(#PB_Key_M) And mp=0 ;Is M Key Being Pressed?
     mp=#True ;M Key Is Being Held
     turn=~turn & 1 ;Toggle turning OFF/ON
  EndIf
  
  If Not KeyboardPushed(#PB_Key_M) ;Has M Key Been Released?
     mp=#False ;M Key Is Released
  EndIf
  
  
  
Until Quit = 1


; IDE Options = PureBasic 6.00 Beta 8 (Windows - x64)
; Folding = -
; EnableAsm
; EnableXP
; DPIAware