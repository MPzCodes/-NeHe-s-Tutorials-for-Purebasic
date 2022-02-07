;NeHe's GL_ARB_multitexture & Bump Mapping Tutorial (Lesson 22)
;http://nehe.gamedev.net
;https://nehe.gamedev.net/tutorial/bump-mapping,_multi-texturing_&_extensions/16009/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 29 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)
;Note: requires bitmaps in paths "Data/Base.bmp", "Data/Bump.bmp",
;"Data/OpenGL.bmp", "Data/OpenGL_Alpha.bmp", "Data/Multi_On.bmp",
;"Data/Multi_On_Alpha.bmp"


;glext.h constants
#GL_MAX_TEXTURE_UNITS_ARB=$84E2
#GL_COMBINE_EXT=$8570
#GL_COMBINE_RGB_EXT=$8571
#GL_TEXTURE0_ARB=$84C0
#GL_TEXTURE1_ARB=$84C1

;Maximum Emboss-Translate. Increase To Get Higher Immersion
;At A Cost Of Lower Quality (More Artifacts Will Occur!)
#MAX_EMBOSS=0.008

;Here Comes The ARB-Multitexture Support.
;There Are (Optimally) 6 New Commands To The OpenGL Set:
;glMultiTexCoordifARB i=1..4 : Sets Texture-Coordinates For Texel-Pipeline #i
;glActiveTextureARB : Sets Active Texel-Pipeline
;glClientActiveTextureARB : Sets Active Texel-Pipeline For The Pointer-Array-Commands
;There Are Even More For The Various Formats Of glMultiTexCoordi{f,fv,d,i} But We Don't Need Them.

#__ARB_ENABLE=#True ;Used To Disable ARB Extensions Entirely
#EXT_INFO=#False ;Do You Want To See Your Extensions At Start-Up?

Global multitextureSupported.b=#False ;Flag Indicating Whether Multitexturing Is Supported
Global useMultitexture.b;=#True ;Use It If It Is Supported?
Global maxTexelUnits.l=1 ;Number Of Texel-Pipelines. This Is At Least 1.

Global glMultiTexCoord1fARB.i
Global glMultiTexCoord2fARB.i
Global glMultiTexCoord3fARB.i
Global glMultiTexCoord4fARB.i
Global glActiveTextureARB.i
Global glClientActiveTextureARB.i

Global emboss.b=#False ;Emboss Only, No Basetexture?
Global bumps.b=#True ;Do Bumpmapping?

Global xrot.f ;X Rotation
Global yrot.f ;Y Rotation
Global xspeed.f ;X Rotation Speed
Global yspeed.f ;Y Rotation Speed
Global z.f=-5.0 ;Depth Into The Screen

Global filter.l=1 ;Which Filter To Use
Global Dim texture.l(3) ;Storage For 3 Textures
Global Dim bump.l(3) ;Our Bumpmappings
Global Dim invbump.l(3) ;Inverted Bumpmaps
Global glLogo.l ;Handle For OpenGL-Logo
Global multiLogo.l ;Handle For Multitexture-Enabled-Logo

Global Dim LightAmbient.f(3) ;Ambient Light is 20% white
LightAmbient(0)=0.2 ;red
LightAmbient(1)=0.2 ;green
LightAmbient(2)=0.2 ;blue

Global Dim LightDiffuse.f(3) ;Diffuse Light is white
LightDiffuse(0)=1.0 ;red
LightDiffuse(1)=1.0 ;green
LightDiffuse(2)=1.0 ;blue

Global Dim LightPosition.f(3) ;Position is somewhat in front of screen
LightPosition(0)=0.0 ;x
LightPosition(1)=0.0 ;y
LightPosition(2)=2.0 ;z

Global Dim Gray.f(4)
Gray(0)=0.5 ;red
Gray(1)=0.5 ;green
Gray(2)=0.5 ;blue
Gray(3)=1.0 ;alpha

;Data Contains The Faces For The Cube In Format 2xTexCoord, 3xVertex;
;Note That The Tesselation Of The Cube Is Only Absolute Minimum.
Global Dim dat.f(120)
;Front Face
dat(  0)=0.0: dat(  1)=0.0: dat(  2)=-1.0: dat(  3)=-1.0: dat(  4)= 1.0
dat(  5)=1.0: dat(  6)=0.0: dat(  7)= 1.0: dat(  8)=-1.0: dat(  9)= 1.0
dat( 10)=1.0: dat( 11)=1.0: dat( 12)= 1.0: dat( 13)= 1.0: dat( 14)= 1.0
dat( 15)=0.0: dat( 16)=1.0: dat( 17)=-1.0: dat( 18)= 1.0: dat( 19)= 1.0
;Back Face
dat( 20)=1.0: dat( 21)=0.0: dat( 22)=-1.0: dat( 23)=-1.0: dat( 24)=-1.0
dat( 25)=1.0: dat( 26)=1.0: dat( 27)=-1.0: dat( 28)= 1.0: dat( 29)=-1.0
dat( 30)=0.0: dat( 31)=1.0: dat( 32)= 1.0: dat( 33)= 1.0: dat( 34)=-1.0
dat( 35)=0.0: dat( 36)=0.0: dat( 37)= 1.0: dat( 38)=-1.0: dat( 39)=-1.0
;Top Face
dat( 40)=0.0: dat( 41)=1.0: dat( 42)=-1.0: dat( 43)= 1.0: dat( 44)=-1.0
dat( 45)=0.0: dat( 46)=0.0: dat( 47)=-1.0: dat( 48)= 1.0: dat( 49)= 1.0
dat( 50)=1.0: dat( 51)=0.0: dat( 52)= 1.0: dat( 53)= 1.0: dat( 54)= 1.0
dat( 55)=1.0: dat( 56)=1.0: dat( 57)= 1.0: dat( 58)= 1.0: dat( 59)=-1.0
;Bottom Face
dat( 60)=1.0: dat( 61)=1.0: dat( 62)=-1.0: dat( 63)=-1.0: dat( 64)=-1.0
dat( 65)=0.0: dat( 66)=1.0: dat( 67)= 1.0: dat( 68)=-1.0: dat( 69)=-1.0
dat( 70)=0.0: dat( 71)=0.0: dat( 72)= 1.0: dat( 73)=-1.0: dat( 74)= 1.0
dat( 75)=1.0: dat( 76)=0.0: dat( 77)=-1.0: dat( 78)=-1.0: dat( 79)= 1.0
;Right Face
dat( 80)=1.0: dat( 81)=0.0: dat( 82)= 1.0: dat( 83)=-1.0: dat( 84)=-1.0
dat( 85)=1.0: dat( 86)=1.0: dat( 87)= 1.0: dat( 88)= 1.0: dat( 89)=-1.0
dat( 90)=0.0: dat( 91)=1.0: dat( 92)= 1.0: dat( 93)= 1.0: dat( 94)= 1.0
dat( 95)=0.0: dat( 96)=0.0: dat( 97)= 1.0: dat( 98)=-1.0: dat( 99)= 1.0
;Left Face
dat(100)=0.0: dat(101)=0.0: dat(102)=-1.0: dat(103)=-1.0: dat(104)=-1.0
dat(105)=1.0: dat(106)=0.0: dat(107)=-1.0: dat(108)=-1.0: dat(109)= 1.0
dat(110)=1.0: dat(111)=1.0: dat(112)=-1.0: dat(113)= 1.0: dat(114)= 1.0
dat(115)=0.0: dat(116)=1.0: dat(117)=-1.0: dat(118)= 1.0: dat(119)=-1.0

Procedure.b initMultitexture()
  
  Protected extensions.s
  extensions=PeekS(glGetString_(#GL_EXTENSIONS),-1,#PB_Ascii  ) ;Fetch Extension String
  
  If #EXT_INFO=#True
    MessageRequester(extensions,"supported GL extensions",#PB_MessageRequester_Ok )
  EndIf
  
  ;Is Multitexturing Supported? And Override-Flag And Is texture_env_combining Supported?
  If FindString(extensions,"GL_ARB_multitexture",1) And #__ARB_ENABLE And FindString(extensions,"GL_EXT_texture_env_combine",1)
    glGetIntegerv_(#GL_MAX_TEXTURE_UNITS_ARB,@maxTexelUnits)
    glMultiTexCoord1fARB=wglGetProcAddress_("glMultiTexCoord1fARB")
    glMultiTexCoord2fARB=wglGetProcAddress_("glMultiTexCoord2fARB")
    glMultiTexCoord3fARB=wglGetProcAddress_("glMultiTexCoord3fARB")
    glMultiTexCoord4fARB=wglGetProcAddress_("glMultiTexCoord4fARB")
    glActiveTextureARB=wglGetProcAddress_("glActiveTextureARB")
    glClientActiveTextureARB=wglGetProcAddress_("glClientActiveTextureARB")
    If #EXT_INFO
      MessageRequester("The GL_ARB_multitexture extension will be used.","feature supported!",#PB_MessageRequester_Ok )
    EndIf
    ProcedureReturn #True
  EndIf
  
  useMultitexture=#False ;We Can't Use It If It Isn't Supported!
  ProcedureReturn #False
  
EndProcedure

Procedure initLights()
  
  ;Load Light-Parameters Into GL_LIGHT1
  glLightfv_(#GL_LIGHT1,#GL_AMBIENT,LightAmbient())
  glLightfv_(#GL_LIGHT1,#GL_DIFFUSE,LightDiffuse())
  glLightfv_(#GL_LIGHT1,#GL_POSITION,LightPosition())
  
  glEnable_(#GL_LIGHT1)
  
EndProcedure


Procedure LoadGLTextures()
  
  Protected status.b=#True ;Status Indicator
  Protected Dim alpha2.b(4)
  Protected i.l
  
  LoadImage(0,"Data/Base.bmp") ; Load texture with name
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  
  If *pointer1
    glGenTextures_(3,@texture(0)) ;Create Three Textures
    
    ;Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,texture(0))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE, *pointer1+54)
    
    ;Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,texture(1))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_BGR_EXT,#GL_UNSIGNED_BYTE, *pointer1+54)
    
    ;Create MipMapped Texture
    glBindTexture_(#GL_TEXTURE_2D,texture(2))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST)
    gluBuild2DMipmaps_(#GL_TEXTURE_2D,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),#GL_BGR_EXT,#GL_UNSIGNED_BYTE, *pointer1+54)
    FreeMemory(*pointer1)
  
  Else
    status=#False
  EndIf
  
  LoadImage(0,"Data/Bump.bmp") ; Load texture with name
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)
  
  If *pointer1
    glPixelTransferf_(#GL_RED_SCALE,0.5) ;Scale RGB By 50%, So That We Have Only   
    glPixelTransferf_(#GL_GREEN_SCALE,0.5) ;Half Intenstity
    glPixelTransferf_(#GL_BLUE_SCALE,0.5)
    
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_CLAMP) ;No Wrapping, Please!
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_CLAMP)
    glTexParameterfv_(#GL_TEXTURE_2D,#GL_TEXTURE_BORDER_COLOR,Gray())
    
    glGenTextures_(3,@bump(0)) ;Create Three Textures
    
    ;Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,bump(0))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    ;Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,bump(1))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    ;Create MipMapped Texture
    glBindTexture_(#GL_TEXTURE_2D,bump(2))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST)
    gluBuild2DMipmaps_(#GL_TEXTURE_2D,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    For i=0 To (3*PeekL(*pointer1+18)*PeekL(*pointer1+22))-1 ;Invert The Bumpmap
      PokeB(*pointer1+54+i,255-PeekB(*pointer1+54+i))
    Next
    
    glGenTextures_(3,@invbump(0)) ;Create Three Textures
    
    ;Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,invbump(0))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    ;Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D,invbump(1))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    ;Create MipMapped Texture
    glBindTexture_(#GL_TEXTURE_2D,invbump(2))
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST)
    gluBuild2DMipmaps_(#GL_TEXTURE_2D,#GL_RGB8,PeekL(*pointer1+18), PeekL(*pointer1+22),#GL_RGB,#GL_UNSIGNED_BYTE,*pointer1+54)
    
    glPixelTransferf_(#GL_RED_SCALE,1.0) ;Scale RGB Back To 100% Again 
    glPixelTransferf_(#GL_GREEN_SCALE,1.0)
    glPixelTransferf_(#GL_BLUE_SCALE,1.0)
    FreeMemory(*pointer1)
  Else
    status=#False
  EndIf
  
  LoadImage(0,"Data/OpenGL_Alpha.bmp") ; Load texture with name
  *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)

  ;Load The Logo-Bitmaps
  If *pointer1 
    
    ReDim alpha2.b(4*PeekL(*pointer1+18)* PeekL(*pointer1+22)) ;Create Memory For RGBA8-Texture
    
    For i=0 To (PeekL(*pointer1+18)* PeekL(*pointer1+22))-1
      Alpha2((4*i)+3)=PeekB(*pointer1+54+(i*3)) ;Pick Only Red Value As Alpha!
    Next
    FreeMemory(*pointer1)
    
    LoadImage(0,"Data/OpenGL.bmp") ; Load texture with name
    *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(0)
    
    For i=0 To (PeekL(*pointer1+18)* PeekL(*pointer1+22))-1
      Alpha2(4*i)=PeekB(*pointer1+54+(i*3)) ;Red
      Alpha2((4*i)+1)=PeekB(*pointer1+54+(i*3)+1) ;Green
      Alpha2((4*i)+2)=PeekB(*pointer1+54+(i*3)+2) ;Blue
    Next
    
    glGenTextures_(1,@glLogo) ;Create One Textures
    
    ;Create Linear Filtered RGBA8-Texture
    glBindTexture_(#GL_TEXTURE_2D,glLogo)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGBA8,PeekL(*pointer1+18), PeekL(*pointer1+22),0,#GL_RGBA,#GL_UNSIGNED_BYTE,Alpha2())
    Dim alpha2.b(0)
    FreeMemory(*pointer1)
  
  Else
    status=#False
  EndIf
  
  LoadImage(0,"Data/Multi_On_Alpha.bmp") ; Load texture with name
     *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
  FreeImage(0)

  If *pointer1
    ReDim alpha2.b(4*PeekL(*pointer1+18)*PeekL(*pointer1+22)) ;Create Memory For RGBA8-Texture
    
    For i=0 To (PeekL(*pointer1+18)*PeekL(*pointer1+22))-1
      Alpha2((4*i)+3)=PeekB(*pointer1+54+(i*3)) ;Pick Only Red Value As Alpha!
    Next
    FreeMemory(*pointer1)
    
    LoadImage(0,"Data/Multi_On.bmp") ; Load texture with name
     *pointer1 = EncodeImage(0, #PB_ImagePlugin_BMP,0,24 );  
    FreeImage(0)

    If *pointer1=0
      status=#False
    EndIf
    
    For i=0 To (PeekL(*pointer1+18)*PeekL(*pointer1+22))-1
      Alpha2(4*i)=PeekB(*pointer1+54+(i*3)+2) ;Red
      Alpha2((4*i)+1)=PeekB(*pointer1+54+(i*3)+1) ;Green
      Alpha2((4*i)+2)=PeekB(*pointer1+54+(i*3)) ;Blue
    Next
    
    glGenTextures_(1,@multiLogo) ;Create One Textures
    
    ;Create Linear Filtered RGBA8-Texture
    glBindTexture_(#GL_TEXTURE_2D,multiLogo)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
    glTexImage2D_(#GL_TEXTURE_2D,0,#GL_RGBA8,PeekL(*pointer1+18),PeekL(*pointer1+22),0,#GL_RGBA, #GL_UNSIGNED_BYTE,Alpha2())
    Dim alpha2.b(0)
    
  Else
    status=#False
  EndIf
  
  ProcedureReturn status ;Return The Status
  
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

Procedure doCube()
  
  Protected i.l
  
  glBegin_(#GL_QUADS)
  ;Front Face
  glNormal3f_( 0.0, 0.0, 1.0)
  For i=0 To 4-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  ;Back Face
  glNormal3f_( 0.0, 0.0,-1.0)
  For i=4 To 8-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  ;Top Face
  glNormal3f_( 0.0, 1.0, 0.0)
  For i=8 To 12-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  ;Bottom Face
  glNormal3f_( 0.0,-1.0, 0.0)
  For i=12 To 16-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  ;Right face
  glNormal3f_( 1.0, 0.0, 0.0)
  For i=16 To 20-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  ;Left Face
  glNormal3f_(-1.0, 0.0, 0.0)
  For i=20 To 24-1
    glTexCoord2f_(dat(5*i),dat(5*i+1))
    glVertex3f_(dat(5*i+2),dat(5*i+3),dat(5*i+4))
  Next
  glEnd_()
  
EndProcedure

Procedure InitGL() ;All Setup For OpenGL Goes Here

  multitextureSupported=initMultitexture()
  
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
  
  initLights() ;Initialize OpenGL Light
  
  ProcedureReturn #True ;Initialization Went OK

EndProcedure

;Calculates v=vM, M Is 4x4 In Column-Major, v Is 4dim. Row (i.e. "Transposed")
Procedure VMatMult(Array M.f(1), Array v.f(1))
  
  Protected Dim res.f(3)
  res(0)=M( 0)*v(0)+M( 1)*v(1)+M( 2)*v(2)+M( 3)*v(3)
  res(1)=M( 4)*v(0)+M( 5)*v(1)+M( 6)*v(2)+M( 7)*v(3)
  res(2)=M( 8)*v(0)+M( 9)*v(1)+M(10)*v(2)+M(11)*v(3)
  v(0)=res(0)
  v(1)=res(1)
  v(2)=res(2)
  v(3)=M(15) ;Homogenous Coordinate
  
EndProcedure

Procedure SetUpBumps(Array n.f(1), Array c.f(1), Array l.f(1), Array s.f(1), Array t.f(1))
  
  Protected Dim v.f(3) ;Vertex From Current Position To Light
  Protected lenQ.f ;Used To Normalize 
  
  ;Calculate v From Current Vector c To Lightposition And Normalize v
  v(0)=l(0)-c(0)
  v(1)=l(1)-c(1)
  v(2)=l(2)-c(2)
  lenQ=Sqr(v(0)*v(0)+v(1)*v(1)+v(2)*v(2))
  v(0)/lenQ : v(1)/lenQ : v(2)/lenQ
  ;Project v Such That We Get Two Values Along Each Texture-Coordinate Axis.
  c(0)=(s(0)*v(0)+s(1)*v(1)+s(2)*v(2))*#MAX_EMBOSS
  c(1)=(t(0)*v(0)+t(1)*v(1)+t(2)*v(2))*#MAX_EMBOSS
  
EndProcedure

Procedure doLogo() ;MUST CALL THIS LAST!!!, Billboards The Two Logos.
  
  glDepthFunc_(#GL_ALWAYS)
  glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glEnable_(#GL_BLEND)
  glDisable_(#GL_LIGHTING)
  glLoadIdentity_()
  glBindTexture_(#GL_TEXTURE_2D,glLogo)
  glBegin_(#GL_QUADS)
  glTexCoord2f_(0.0,0.0) : glVertex3f_(0.23,-0.40,-1.0)
  glTexCoord2f_(1.0,0.0) : glVertex3f_(0.53,-0.40,-1.0)
  glTexCoord2f_(1.0,1.0) : glVertex3f_(0.53,-0.25,-1.0)
  glTexCoord2f_(0.0,1.0) : glVertex3f_(0.23,-0.25,-1.0)
  glEnd_()
  If useMultitexture
    glBindTexture_(#GL_TEXTURE_2D,multiLogo)
    glBegin_(#GL_QUADS)
    glTexCoord2f_(0.0,0.0) : glVertex3f_(-0.53,-0.4,-1.0)
    glTexCoord2f_(1.0,0.0) : glVertex3f_(-0.33,-0.4,-1.0)
    glTexCoord2f_(1.0,1.0) : glVertex3f_(-0.33,-0.3,-1.0)
    glTexCoord2f_(0.0,1.0) : glVertex3f_(-0.53,-0.3,-1.0)
    glEnd_()
  EndIf
  glDepthFunc_(#GL_LEQUAL)
  
EndProcedure

Procedure.b doMesh1TexelUnits()
  
  Protected Dim c.f(4) ;Holds Current Vertex
  c(0)=0.0 : c(1)=0.0 : c(2)=0.0 : c(3)=1.0
  Protected Dim n.f(4) ;Normalized Normal Of Current Surface 
  n(0)=0.0 : n(1)=0.0 : n(2)=0.0 : n(3)=1.0
  Protected Dim s.f(4) ;s-Texture Coordinate Direction, Normalized
  s(0)=0.0 : s(1)=0.0 : s(2)=0.0 : s(3)=1.0
  Protected Dim t.f(4) ;t-Texture Coordinate Direction, Normalized
  t(0)=0.0 : t(1)=0.0 : t(2)=0.0 : t(3)=1.0
  Protected Dim l.f(4) ;Holds Our Lightposition To Be Transformed Into Object Space
  Protected Dim Minv.f(16) ;Holds The Inverted Modelview Matrix To Do So.
  Protected i.l
  
  SetGadgetAttribute(0, #PB_OpenGL_SetContext, #True)
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  
  ;Build Inverse Modelview Matrix First. This Substitutes One Push/Pop With One glLoadIdentity();
  ;Simply Build It By Doing All Transformations Negated And In Reverse Order.
  glLoadIdentity_()
  glRotatef_(-yrot,0.0,1.0,0.0)
  glRotatef_(-xrot,1.0,0.0,0.0)
  glTranslatef_(0.0,0.0,-z)
  glGetFloatv_(#GL_MODELVIEW_MATRIX,Minv())
  glLoadIdentity_()
  glTranslatef_(0.0,0.0,z)
  glRotatef_(xrot,1.0,0.0,0.0)
  glRotatef_(yrot,0.0,1.0,0.0)
  
  ;Transform The Lightposition Into Object Coordinates:
  l(0)=LightPosition(0)
  l(1)=LightPosition(1)
  l(2)=LightPosition(2)
  l(3)=1.0 ;Homogenous Coordinate
  VMatMult(Minv(),l())
  
  ;PASS#1: Use Texture "Bump"
  ; No Blend
  ; No Lighting
  ; No Offset Texture-Coordinates
  glBindTexture_(#GL_TEXTURE_2D,bump(filter))
  glDisable_(#GL_BLEND)
  glDisable_(#GL_LIGHTING)
  doCube()
  
  ;PASS#2: Use Texture "Invbump"
  ; Blend GL_ONE To GL_ONE
  ; No Lighting
  ; Offset Texture Coordinates
  glBindTexture_(#GL_TEXTURE_2D,invbump(filter))
  glBlendFunc_(#GL_ONE,#GL_ONE)
  glDepthFunc_(#GL_LEQUAL)
  glEnable_(#GL_BLEND)
  
  glBegin_(#GL_QUADS)
  ;Front Face
  n(0)=0.0 : n(1)=0.0 : n(2)=1.0
  s(0)=1.0 : s(1)=0.0 : s(2)=0.0
  t(0)=0.0 : t(1)=1.0 : t(2)=0.0
  For i=0 To 4-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Back Face
  n(0)= 0.0 : n(1)=0.0 : n(2)=-1.0
  s(0)=-1.0 : s(1)=0.0 : s(2)= 0.0
  t(0)= 0.0 : t(1)=1.0 : t(2)= 0.0
  For i=4 To 8-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Top Face
  n(0)=0.0 : n(1)=1.0 : n(2)= 0.0
  s(0)=1.0 : s(1)=0.0 : s(2)= 0.0
  t(0)=0.0 : t(1)=0.0 : t(2)=-1.0
  For i=8 To 12-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Bottom Face
  n(0)= 0.0 : n(1)=-1.0 : n(2)= 0.0
  s(0)=-1.0 : s(1)= 0.0 : s(2)= 0.0
  t(0)= 0.0 : t(1)= 0.0 : t(2)=-1.0
  For i=12 To 16-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Right Face
  n(0)=1.0 : n(1)=0.0 : n(2)= 0.0
  s(0)=0.0 : s(1)=0.0 : s(2)=-1.0
  t(0)=0.0 : t(1)=1.0 : t(2)= 0.0
  For i=16 To 20-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Left Face
  n(0)=-1.0 : n(1)=0.0 : n(2)=0.0
  s(0)= 0.0 : s(1)=0.0 : s(2)=1.0
  t(0)= 0.0 : t(1)=1.0 : t(2)=0.0
  For i=20 To 24-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    glTexCoord2f_(dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  glEnd_()
  
  ;PASS#3: Use Texture "Base"
  ; Blend GL_DST_COLOR To GL_SRC_COLOR (Multiplies By 2)
  ; Lighting Enabled
  ; No Offset Texture-Coordinates
  If emboss=0
    glTexEnvf_(#GL_TEXTURE_ENV,#GL_TEXTURE_ENV_MODE,#GL_MODULATE)
    glBindTexture_(#GL_TEXTURE_2D,texture(filter))
    glBlendFunc_(#GL_DST_COLOR,#GL_SRC_COLOR)
    glEnable_(#GL_LIGHTING)
    doCube()
  EndIf
  
  xrot+xspeed
  yrot+yspeed
  If xrot>360.0 : xrot-360.0 : EndIf
  If xrot<0.0 : xrot+360.0 : EndIf
  If yrot>360.0 : yrot-360.0 : EndIf
  If yrot<0.0 : yrot+360.0 : EndIf
  ;LAST PASS: Do The Logos!
  doLogo()
  
  SetGadgetAttribute(0, #PB_OpenGL_FlipBuffers, #True)
  
  ProcedureReturn #True ;Keep Going
  
EndProcedure

Procedure.b doMesh2TexelUnits()
  
  Protected Dim c.f(4) ;holds current vertex
  c(0)=0.0 : c(1)=0.0 : c(2)=0.0 : c(3)=1.0
  Protected Dim n.f(4) ;normalized normal of current surface
  n(0)=0.0 : n(1)=0.0 : n(2)=0.0 : n(3)=1.0
  Protected Dim s.f(4) ;s-texture coordinate direction, normalized
  s(0)=0.0 : s(1)=0.0 : s(2)=0.0 : s(3)=1.0
  Protected Dim t.f(4) ;t-texture coordinate direction, normalized
  t(0)=0.0 : t(1)=0.0 : t(2)=0.0 : t(3)=1.0
  Protected Dim l.f(4) ;holds our lightposition to be transformed into object space
  Protected Dim Minv.f(16) ;holds the inverted modelview matrix to do so.
  Protected i.l
  
  SetGadgetAttribute(0, #PB_OpenGL_SetContext, #True)
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  
  ;Build Inverse Modelview Matrix First. This Substitutes One Push/Pop With One glLoadIdentity();
  ;Simply Build It By Doing All Transformations Negated And In Reverse Order.
  glLoadIdentity_()     
  glRotatef_(-yrot,0.0,1.0,0.0)
  glRotatef_(-xrot,1.0,0.0,0.0)
  glTranslatef_(0.0,0.0,-z)
  glGetFloatv_(#GL_MODELVIEW_MATRIX,Minv())
  glLoadIdentity_()
  glTranslatef_(0.0,0.0,z)
  glRotatef_(xrot,1.0,0.0,0.0)
  glRotatef_(yrot,0.0,1.0,0.0)
  
  ;Transform The Lightposition Into Object Coordinates:
  l(0)=LightPosition(0)
  l(1)=LightPosition(1)
  l(2)=LightPosition(2)
  l(3)=1.0 ;Homogenous Coordinate
  VMatMult(Minv(),l())
  
  ;PASS#1: Texel-Unit 0: Use Texture "Bump"
  ;    No Blend
  ;    No Lighting
  ;    No Offset Texture-Coordinates
  ;    Texture-Operation "Replace"
  ;Texel-Unit 1: Use Texture "Invbump"
  ;    No Lighting
  ;    Offset Texture Coordinates
  ;    Texture-Operation "Replace"
  
  ;TEXTURE-UNIT #0
  CallFunctionFast(glActiveTextureARB,#GL_TEXTURE0_ARB)
  glEnable_(#GL_TEXTURE_2D)
  glBindTexture_(#GL_TEXTURE_2D,bump(filter))
  glTexEnvf_(#GL_TEXTURE_ENV,#GL_TEXTURE_ENV_MODE,#GL_COMBINE_EXT)
  glTexEnvf_(#GL_TEXTURE_ENV,#GL_COMBINE_RGB_EXT,#GL_REPLACE)
  ;TEXTURE-UNIT #1:
  CallFunctionFast(glActiveTextureARB,#GL_TEXTURE1_ARB)
  glEnable_(#GL_TEXTURE_2D)
  glBindTexture_(#GL_TEXTURE_2D,invbump(filter))
  glTexEnvf_(#GL_TEXTURE_ENV,#GL_TEXTURE_ENV_MODE,#GL_COMBINE_EXT)
  glTexEnvf_(#GL_TEXTURE_ENV,#GL_COMBINE_RGB_EXT,#GL_ADD)
  ;General Switches:
  glDisable_(#GL_BLEND)
  glDisable_(#GL_LIGHTING)
  
  glBegin_(#GL_QUADS)
  ;Front Face
  n(0)=0.0 : n(1)=0.0 : n(2)=1.0
  s(0)=1.0 : s(1)=0.0 : s(2)=0.0
  t(0)=0.0 : t(1)=1.0 : t(2)=0.0
  For i=0 To 4-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1))
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Back Face
  n(0)= 0.0 : n(1)=0.0 : n(2)=-1.0
  s(0)=-1.0 : s(1)=0.0 : s(2)= 0.0
  t(0)= 0.0 : t(1)=1.0 : t(2)= 0.0
  For i=4 To 8-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1))
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Top Face
  n(0)=0.0 : n(1)=1.0 : n(2)= 0.0
  s(0)=1.0 : s(1)=0.0 : s(2)= 0.0
  t(0)=0.0 : t(1)=0.0 : t(2)=-1.0
  For i=8 To 12-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1)     )
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Bottom Face
  n(0)= 0.0 : n(1)=-1.0 : n(2)= 0.0
  s(0)=-1.0 : s(1)= 0.0 : s(2)= 0.0
  t(0)= 0.0 : t(1)= 0.0 : t(2)=-1.0
  For i=12 To 16-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1)     )
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Right Face
  n(0)=1.0 : n(1)=0.0 : n(2)= 0.0
  s(0)=0.0 : s(1)=0.0 : s(2)=-1.0
  t(0)=0.0 : t(1)=1.0 : t(2)= 0.0
  For i=16 To 20-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1)     )
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  ;Left Face
  n(0)=-1.0 : n(1)=0.0 : n(2)=0.0
  s(0)= 0.0 : s(1)=0.0 : s(2)=1.0
  t(0)= 0.0 : t(1)=1.0 : t(2)=0.0
  For i=20 To 24-1
    c(0)=dat((5*i)+2)
    c(1)=dat((5*i)+3)
    c(2)=dat((5*i)+4)
    SetUpBumps(n(),c(),l(),s(),t())
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE0_ARB,dat(5*i)     , dat((5*i)+1)     )
    CallFunctionFast(glMultiTexCoord2fARB,#GL_TEXTURE1_ARB,dat(5*i)+c(0), dat((5*i)+1)+c(1))
    glVertex3f_(dat((5*i)+2), dat((5*i)+3), dat((5*i)+4))
  Next
  glEnd_()
  
  ;PASS#2 Use Texture "Base"
  ; Blend GL_DST_COLOR To GL_SRC_COLOR (Multiplies By 2)
  ; Lighting Enabled
  ; No Offset Texture-Coordinates
  CallFunctionFast(glActiveTextureARB,#GL_TEXTURE1_ARB)
  glDisable_(#GL_TEXTURE_2D)
  CallFunctionFast(glActiveTextureARB,#GL_TEXTURE0_ARB)
  If emboss=0
    glTexEnvf_(#GL_TEXTURE_ENV,#GL_TEXTURE_ENV_MODE,#GL_MODULATE)
    glBindTexture_(#GL_TEXTURE_2D,texture(filter))
    glBlendFunc_(#GL_DST_COLOR,#GL_SRC_COLOR)
    glEnable_(#GL_BLEND)
    glEnable_(#GL_LIGHTING)
    doCube()
  EndIf
  
  xrot+xspeed
  yrot+yspeed
  If xrot>360.0 : xrot-360.0 : EndIf
  If xrot<0.0 : xrot+360.0 : EndIf
  If yrot>360.0 : yrot-360.0 : EndIf
  If yrot<0.0 : yrot+360.0 : EndIf
  
  ;LAST PASS: Do The Logos!
  doLogo()
  
  SetGadgetAttribute(0, #PB_OpenGL_FlipBuffers, #True)
  ProcedureReturn #True ;Keep Going
  
EndProcedure

Procedure.b doMeshNoBumps()
  
  SetGadgetAttribute(0, #PB_OpenGL_SetContext, #True)
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The View
  glTranslatef_(0.0,0.0,z)
  
  glRotatef_(xrot,1.0,0.0,0.0)
  glRotatef_(yrot,0.0,1.0,0.0)
  If useMultitexture
    CallFunctionFast(glActiveTextureARB,#GL_TEXTURE1_ARB)
    glDisable_(#GL_TEXTURE_2D)
    CallFunctionFast(glActiveTextureARB,#GL_TEXTURE0_ARB)
  EndIf
  glDisable_(#GL_BLEND)
  glBindTexture_(#GL_TEXTURE_2D,texture(filter))
  glBlendFunc_(#GL_DST_COLOR,#GL_SRC_COLOR)
  glEnable_(#GL_LIGHTING)
  doCube()
  
  xrot+xspeed
  yrot+yspeed
  If xrot>360.0 : xrot-360.0 : EndIf
  If xrot<0.0 : xrot+360.0 : EndIf
  If yrot>360.0 : yrot-360.0 : EndIf
  If yrot<0.0 : yrot+360.0 : EndIf
  
  ;LAST PASS: Do The Logos!
  doLogo()
  
  SetGadgetAttribute(0, #PB_OpenGL_FlipBuffers, #True)
  ProcedureReturn #True ;Keep Going
  
EndProcedure


Procedure DrawScene(Gadget)
 
  If bumps
    If useMultitexture And maxTexelUnits>1
      ProcedureReturn doMesh2TexelUnits()
    Else
      ProcedureReturn doMesh1TexelUnits()
    EndIf
  Else
    ProcedureReturn doMeshNoBumps()
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




CreateGLWindow("NeHe's GL_ARB_multitexture & Bump Mapping Tutorial (Lesson 22)",640,480,16,0,1)

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
  
        If KeyboardPushed(#PB_Key_E) And Ep=0 ;Is E Key Being Pressed?
          Ep=#True
          emboss=~emboss & 1 ;toggle emboss
        ElseIf Not KeyboardPushed(#PB_Key_E) ;Has L Key Been Released?
          Ep=#False ;If So, lp Becomes FALSE
        EndIf
        
        If KeyboardPushed(#PB_Key_M) And Mp=0 ;Is M Key Being Pressed?
          Mp=#True
          useMultitexture=Bool(useMultitexture=0 And multitextureSupported) ;toggle useMultitexture
        ElseIf Not KeyboardPushed(#PB_Key_M) ;Has L Key Been Released?
          Mp=#False ;If So, lp Becomes FALSE
        EndIf
        
        If KeyboardPushed(#PB_Key_B) And Bp=0;Is B Key Being Pressed?
          Bp=#True
          bumps=~bumps & 1 ;toggle bumps
        ElseIf Not KeyboardPushed(#PB_Key_B)
          Bp=#False ;If So, lp Becomes FALSE
        EndIf
        
        If KeyboardPushed(#PB_Key_F) And Fp=0 ;Is F Key Being Pressed?
          Fp=#True
          filter+1 ;increase filter
          filter=filter % 3 ;set filter range 0..2
        ElseIf Not KeyboardPushed(#PB_Key_F) ;Has L Key Been Released?
          Fp=#False ;If So, lp Becomes FALSE
        EndIf
       
        If KeyboardPushed(#PB_Key_PageDown) ;Is Page Up Being Pressed?
          z-0.02 ;If So, Move Into The Screen
        EndIf
        If KeyboardPushed(#PB_Key_PageUp) ;Is Page Down Being Pressed?
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
  DrawScene(0)
  
Until Quit = 1
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 127
; FirstLine = 123
; Folding = ---
; EnableAsm
; EnableXP