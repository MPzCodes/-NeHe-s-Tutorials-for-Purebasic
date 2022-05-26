;NeHe's Radial Blur & Rendering To A Texture Tutorial (Lesson 36) 
;http://nehe.gamedev.net 
;https://nehe.gamedev.net/tutorial/radial_blur__rendering_to_a_texture/18004/
;Credits:  Nico Gruener, Dreglor, traumatic, hagibaba
;Author: threedslider 2021-12-31
;customization: MPz
;Date: 12 April 2022
;Note: up-to-date with PB v5.73 (Windows)

Global angle.f 
Global BlurTexture 

Declare.i ViewOrtho()
Declare.i ViewPerspective()
Declare.i EmptyTexture()

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

  BlurTexture = EmptyTexture()								 	   ; Create Our Empty Texture
  
  glViewport_(0 , 0,640 ,480) 	              							   ; Set Up A Viewport
	glMatrixMode_(#GL_PROJECTION)	 						   ; Select The Projection Matrix
	glLoadIdentity_();									           ; Reset The Projection Matrix
	gluPerspective_(50, 640/480, 5,  2000)        					   ; Set Our Perspective
	glMatrixMode_(#GL_MODELVIEW);							   ; Select The Modelview Matrix
	glLoadIdentity_();	

	glEnable_(#GL_DEPTH_TEST)   								   ; Enable Depth Testing
	
  Dim global_ambient.f(4)		                  						   ; Set Ambient Lighting To Fairly Dark Light (No Color)
	global_ambient(0) = 0.2
	global_ambient(1) = 0.2
	global_ambient(2) = 0.2
	global_ambient(3) = 1.0
	
	Dim light0pos.f(4)     		              						   ; Set The Light Position
	light0pos(0) = 0.0
	light0pos(1) = 5.0
	light0pos(2) = 10.0
	light0pos(3) = 1.0
	
	Dim light0ambient.f(4)  		                					   ; More Ambient Light
	light0ambient(0) = 0.2
	light0ambient(1) = 0.2
	light0ambient(2) = 0.2
	light0ambient(3) = 1.0
	
	Dim light0diffuse.f(4) 		                   					   ; Set The Diffuse Light A Bit Brighter
	light0diffuse(0) = 0.3
	light0diffuse(1) = 0.3
	light0diffuse(2) = 0.3
	light0diffuse(3) = 1.0
	
	Dim light0specular.f(4)	                    						  ; Fairly Bright Specular Lighting
	light0specular(0) = 0.8
	light0specular(1) = 0.8
	light0specular(2) = 0.8
	light0specular(3) = 1.0

	Dim lmodel_ambient.f(4)   			          				   ; And More Ambient Light
	lmodel_ambient(0) = 0.2
	lmodel_ambient(1) = 0.2
	lmodel_ambient(2) = 0.2
	lmodel_ambient(3) = 1.0
	glLightModelfv_(#GL_LIGHT_MODEL_AMBIENT,lmodel_ambient())	   ; Set The Ambient Light Model

	glLightModelfv_(#GL_LIGHT_MODEL_AMBIENT, global_ambient())	   ; Set The Global Ambient Light Model
	glLightfv_(#GL_LIGHT0, #GL_POSITION, light0pos())				   ; Set The Lights Position
	glLightfv_(#GL_LIGHT0, #GL_AMBIENT, light0ambient())			   ; Set The Ambient Light
	glLightfv_(#GL_LIGHT0, #GL_DIFFUSE, light0diffuse())			   ; Set The Diffuse Light
	glLightfv_(#GL_LIGHT0, #GL_SPECULAR, light0specular())		   	   ; Set Up Specular Lighting
	glEnable_(#GL_LIGHTING)									   ; Enable Lighting
	glEnable_(#GL_LIGHT0)									   ; Enable Light0

	glShadeModel_(#GL_SMOOTH)								   ; Select Smooth Shading

	glMateriali_(#GL_FRONT, #GL_SHININESS, 128)
	glClearColor_(0.0, 0.0, 0.0, 0.5)               						   ; Set The Clear Color To Black

 ProcedureReturn #True ;Initialization Went OK

EndProcedure

Procedure EmptyTexture()
  ;txtnumber = 0
  ;result = 0
  Dim pdata(128*128*4)
   
  glGenTextures_(1, @txtnumber)                         		; Create 1 Texture
  glBindTexture_(#GL_TEXTURE_2D, txtnumber)        		; Bind The Texture
  glTexImage2D_(#GL_TEXTURE_2D, 0, 4, 128, 128, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, pdata())
  
    
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
  
  ;Debug txtnumber
  result  = txtnumber
  FreeArray(pdata())
  ProcedureReturn result   
EndProcedure

Procedure ReduceToUnit(Array vector.f(1))	    			 ; Reduces A Normal Vector (3 Coordinates)
	; Calculates The Length Of The Vector
	length.f = Sqr( (vector(0)*vector(0)) + (vector(1)*vector(1)) + (vector(2)*vector(2)) )
	
	;Debug "length " + length
	
	If length = 0								  ; Prevents Divide By 0 Error By Providing
	  length = 1.0                            				  ; An Acceptable Value For Vectors To Close To 0.
	EndIf
	

	vector(0) = vector(0) / length					  ; Dividing Each Element By
	vector(1) = vector(1) / length  					  ; The Length Results In A
	vector(2) = vector(2) / length              			  ; Unit Normal Vector.	
EndProcedure

Procedure calcNormal(Array v.f(2), Array OUT.f(1))		   ; Calculates Normal For A Quad Using 3 Points

  Dim v1.f(3)              							   ; Vector 1 (x,y,z)
  Dim v2.f(3)									   ; Vector 2 (x,y,z)
	x = 0									   ; Define X Coord
	y = 1										   ; Define Y Coord
	z = 2										   ; Define Z Coord

	; Finds The Vector Between 2 Points By Subtracting
	; The x,y,z Coordinates From One Point To Another.

	; Calculate The Vector From Point 1 To Point 0
	v1(x) = v.f(0,x) - v.f(1,x)									; Vector 1.x=Vertex[0].x-Vertex[1].x
	v1(y) = v.f(0,y) - v.f(1,y)									; Vector 1.y=Vertex[0].y-Vertex[1].y
	v1(z) = v.f(0,z) - v.f(1,z)									; Vector 1.z=Vertex[0].y-Vertex[1].z
	; Calculate The Vector From Point 2 To Point 1
	v2(x) = v.f(1,x) - v.f(2,x)									; Vector 2.x=Vertex[0].x-Vertex[1].x
	v2(y) = v.f(1,y) - v.f(2,y)									; Vector 2.y=Vertex[0].y-Vertex[1].y
	v2(z) = v.f(1,z) - v.f(2,z)									; Vector 2.z=Vertex[0].z-Vertex[1].z
	; Compute The Cross Product To Give Us A Surface Normal
	out(x) = v1(y)*v2(z) - v1(z)*v2(y)							; Cross Product For Y - Z
	out(y) = v1(z)*v2(x) - v1(x)*v2(z)							; Cross Product For X - Z
	out(z) = v1(x)*v2(y) - v1(y)*v2(x)							; Cross Product For X - Y

	ReduceToUnit(out())										; Normalize The Vectors
EndProcedure

Procedure ProcessHelix()										; Draws A Helix    
  Dim vertexes.f(4,3)
  Dim normal.f(3)

  x.f = 0.0											; Helix x Coordinate
	y.f = 0.0											; Helix y Coordinate
	z.f	= 0.0											; Helix z Coordinate
	phi = 0	  			 						  ; Angle
	theta = 0	  									; Angle
	v.f = 0                       ; Angles v And u
	u.f = 0							          	
	r.f	= 0.0											; Radius Of Twist
	twists = 5										; 5 Twists

	Dim glMaterialColor.f(4)									; Set The Material Color
	glMaterialColor(0) = 0.4
	glMaterialColor(1) = 0.2
	glMaterialColor(2) = 0.8
	glMaterialColor(3) = 1.0	
	
	Dim specular.f(4)         									 ; Sets Up Specular Lighting
	specular(0) = 1.0
	specular(1) = 1.0
	specular(2) = 1.0
	specular(3) = 1.0

	glLoadIdentity_()										 ; Reset The Modelview Matrix
	gluLookAt_(0, 5, 35, 0, 0, 0, 0, 1, 0)							 ; Eye Position (0,5,50) Center Of Scene (0,0,0), Up On Y Axis

	glPushMatrix_()										         ; Push The Modelview Matrix

	glTranslatef_(0,0,-50);									 ; Translate 50 Units Into The Screen
	glRotatef_(angle/2.0,1,0,0)						  		 ; Rotate By angle/2 On The X-Axis
	glRotatef_(angle/3.0,0,1,0)						  	         ; Rotate By angle/3 On The Y-Axis

  glMaterialfv_(#GL_FRONT_AND_BACK,#GL_AMBIENT_AND_DIFFUSE,glMaterialColor());
	glMaterialfv_(#GL_FRONT_AND_BACK,#GL_SPECULAR,specular());
	
	r=1.5												  ; Radius

	glBegin_(#GL_QUADS);								          ; Begin Drawing Quads
	For phi=0 To 360 Step 20						     			  ; 360 Degrees In Steps Of 20
	
		For theta=0 To 360*twists Step 20						  ; 360 Degrees * Number Of Twists In Steps Of 20
		
			v=(phi/180.0*3.142)								  ; Calculate Angle Of First Point	(  0 )
			u=(theta/180.0*3.142)							  ; Calculate Angle Of First Point	(  0 )

			x=(Cos(u)*(2.0+Cos(v) ))*r				   			  ; Calculate x Position (1st Point)
			y=(Sin(u)*(2.0+Cos(v) ))*r				  	                  ; Calculate y Position (1st Point)
			z=((( u-(2.0*3.142)) + Sin(v) ) * r)					  ; Calculate z Position (1st Point)

			vertexes(0,0)=x							     	  ; Set x Value Of First Vertex
			vertexes(0,1)=y								  ; Set y Value Of First Vertex
			vertexes(0,2)=z								  ; Set z Value Of First Vertex

			v=(phi/180.0*3.142)							    	  ; Calculate Angle Of Second Point	(  0 )
			u=((theta+20)/180.0*3.142)						  ; Calculate Angle Of Second Point	( 20 )

			x=(Cos(u)*(2.0+Cos(v) ))*r				   			  ; Calculate x Position (2nd Point)
			y=(Sin(u)*(2.0+Cos(v) ))*r					 		  ; Calculate y Position (2nd Point)
			z=((( u-(2.0*3.142)) + Sin(v) ) * r)					  ; Calculate z Position (2nd Point)

			vertexes(1,0)=x							          ; Set x Value Of Second Vertex
			vertexes(1,1)=y								  ; Set y Value Of Second Vertex
			vertexes(1,2)=z								  ; Set z Value Of Second Vertex

			v=((phi+20)/180.0*3.142);							  ; Calculate Angle Of Third Point	( 20 )
			u=((theta+20)/180.0*3.142);						  ; Calculate Angle Of Third Point	( 20 )

			x=(Cos(u)*(2.0+Cos(v) ))*r				  			  ; Calculate x Position (3rd Point)
			y=(Sin(u)*(2.0+Cos(v) ))*r				  	 		  ; Calculate y Position (3rd Point)
			z=((( u-(2.0*3.142)) + Sin(v) ) * r)					  ; Calculate z Position (3rd Point)

			vertexes(2,0)=x								  ; Set x Value Of Third Vertex
			vertexes(2,1)=y								  ; Set y Value Of Third Vertex
			vertexes(2,2)=z							          ; Set z Value Of Third Vertex

			v=((phi+20)/180.0*3.142)					  		  ; Calculate Angle Of Fourth Point	( 20 )
			u=((theta)/180.0*3.142)						  	  ; Calculate Angle Of Fourth Point	(  0 )

			x=(Cos(u)*(2.0+Cos(v) ))*r				  	                  ; Calculate x Position (4th Point)
			y=(Sin(u)*(2.0+Cos(v) ))*r					 		  ; Calculate y Position (4th Point)
			z=((( u-(2.0*3.142)) + Sin(v) ) * r)	 				  ; Calculate z Position (4th Point)

			vertexes(3,0)=x								  ; Set x Value Of Fourth Vertex
			vertexes(3,1)=y								  ; Set y Value Of Fourth Vertex
			vertexes(3,2)=z								  ; Set z Value Of Fourth Vertex

			calcNormal(vertexes(),normal())					  ; Calculate The Quad Normal

			glNormal3f_(normal(0),normal(1),normal(2))			  ; Set The Normal

			; Render The Quad
			glVertex3f_(vertexes(0,0),vertexes(0,1),vertexes(0,2))
			glVertex3f_(vertexes(1,0),vertexes(1,1),vertexes(1,2))
			glVertex3f_(vertexes(2,0),vertexes(2,1),vertexes(2,2))
			glVertex3f_(vertexes(3,0),vertexes(3,1),vertexes(3,2))
		Next theta 
	Next phi 
	glEnd_()											           ; Done Rendering Quads
	
	glPopMatrix_()									             	   ; Pop The Matrix
EndProcedure

Procedure DrawBlur(times, Incsp.f)								     ; Draw The Blurred Image
  spost.f = 0.0											             ; Starting Texture Coordinate Offset
	alphainc.f = 0.9 / times						          		     ; Fade Speed For Alpha Blending
	alpha.f = 0.2                                							     ; Starting Alpha Value
	
	;Shared BlurTexture

	; Disable AutoTexture Coordinates
	glDisable_(#GL_TEXTURE_GEN_S)
	glDisable_(#GL_TEXTURE_GEN_T)

	glEnable_(#GL_TEXTURE_2D)								      ; Enable 2D Texture Mapping
	glDisable_(#GL_DEPTH_TEST)								      ; Disable Depth Testing
	glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE)						      ; Set Blending Mode
	glEnable_(#GL_BLEND);									      ; Enable Blending
	glBindTexture_(#GL_TEXTURE_2D,BlurTexture)	; Bind To The Blur Texture
	ViewOrtho()											      ; Switch To An Ortho View

	alphainc = alpha / times									      ; alphainc=0.2f / Times To Render Blur

	glBegin_(#GL_QUADS)									      ; Begin Drawing Quads
		For num = 0 To times-1	Step 1					          	      ; Number Of Times To Render Blur
		
			glColor4f_(1.0, 1.0, 1.0, alpha)						      ; Set The Alpha Value (Starts At 0.2)
			glTexCoord2f_(0+spost,1-spost)						      ; Texture Coordinate	( 0, 1 )
			glVertex2f_(0,0)								        ; First Vertex		(   0,   0 )

			glTexCoord2f_(0+spost,0+spost)							; Texture Coordinate	( 0, 0 )
			glVertex2f_(0,480)									; Second Vertex	(   0, 480 )

			glTexCoord2f_(1-spost,0+spost)							; Texture Coordinate	( 1, 0 )
			glVertex2f_(640,480)									; Third Vertex		( 640, 480 )

			glTexCoord2f_(1-spost,1-spost)							; Texture Coordinate	( 1, 1 )
			glVertex2f_(640,0)									; Fourth Vertex	( 640,   0 )

			spost = spost + Incsp									; Gradually Increase spost (Zooming Closer To Texture Center)
			alpha = alpha - alphainc							 	; Gradually Decrease Alpha (Gradually Fading Image Out)
		Next num
	glEnd_()													; Done Drawing Quads

	ViewPerspective()											; Switch To A Perspective View

	glEnable_(#GL_DEPTH_TEST)								  	; Enable Depth Testing
	glDisable_(#GL_TEXTURE_2D)									; Disable 2D Texture Mapping
	glDisable_(#GL_BLEND)										; Disable Blending
	glBindTexture_(#GL_TEXTURE_2D,0)								; Unbind The Blur Texture
EndProcedure

Procedure ViewOrtho()										   ; Set Up An Ortho View
	glMatrixMode_(#GL_PROJECTION)							   ; Select Projection
	glPushMatrix_()										           ; Push The Matrix
	glLoadIdentity_()									           ; Reset The Matrix
	glOrtho_( 0, 640 , 480 , 0, -1, 1 )							   ; Select Ortho Mode (640x480)
	glMatrixMode_(#GL_MODELVIEW)							   ; Select Modelview Matrix
	glPushMatrix_()										           ; Push The Matrix
	glLoadIdentity_()										   ; Reset The Matrix
EndProcedure

Procedure ViewPerspective()								           ; Set Up A Perspective View
	glMatrixMode_( #GL_PROJECTION )							   ; Select Projection
	glPopMatrix_()											   ; Pop The Matrix
	glMatrixMode_( #GL_MODELVIEW )							   ; Select Modelview
	glPopMatrix_()											   ; Pop The Matrix
EndProcedure

Procedure RenderToTexture()									    ; Renders To A Texture
  ;Shared Blurtexture
  
	glViewport_(0,0,128,128);									    ; Set Our Viewport (Match Texture Size)

	ProcessHelix()											    ; Render The Helix

	glBindTexture_(#GL_TEXTURE_2D,BlurTexture)		  			    ; Bind To The Blur Texture

	; Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
	glCopyTexImage2D_(#GL_TEXTURE_2D, 0, #GL_LUMINANCE, 0, 0, 128, 128, 0);

	glClearColor_(0.0, 0.0, 0.5, 0.5)						 	     ; Set The Clear Color To Medium Blue
	glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)		     ; Clear The Screen And Depth Buffer
	
	glViewport_(0 , 0,WindowWidth(0) ,WindowHeight(0))								     ; Set Viewport (0,0 To 640x480)
EndProcedure

Procedure DrawScene(Gadget)												; Draw The Scene
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClearColor_(0.0, 0.0, 0.0, 0.5)						          	; Set The Clear Color To Black
	glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)			; Clear Screen And Depth Buffer
	glLoadIdentity_()        	
  RenderToTexture()											        ; Render To A Texture                          
	ProcessHelix()                                        							; Draw Our Helix	
	DrawBlur(20,0.02)											; Draw The Blur Effect	
	;Deinitialize()		
	glFlush_()													; Flush The GL Rendering Pipeline
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

CreateGLWindow("Blur & Rendering To a Texture Tutorial (Lesson 36)",640,480,16,0)

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
  angle = angle + 1
   
  If angle = 360
     angle = 0
  Else
     angle = angle + 1    
  EndIf 
  
Until Quit = 1


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 175
; FirstLine = 157
; Folding = ---
; EnableAsm
; EnableXP