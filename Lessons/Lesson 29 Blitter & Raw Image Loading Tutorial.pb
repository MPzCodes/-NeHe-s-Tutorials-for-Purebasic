;Andreas Löffler, Rob Fletcher & NeHe's Blitter & Raw Image Loading Tutorial (Lesson 29)
;http://nehe.gamedev.net and http://www.tiptup.com
;https://nehe.gamedev.net/tutorial/bezier_patches__fullscreen_fix/18003/
;Note: requires RAW files in paths "Data/Monitor.raw", "Data/GL.raw"
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 2 Nov 2021
;Note: up-to-date with PB v5.73 (Windows)

UsePNGImageDecoder() 

;Start of Lesson 29

;Global DMsaved.DEVMODE ;Saves The Previous Screen Settings

Global xrot.f ;X Rotation
Global yrot.f ;Y Rotation
Global zrot.f ;Z Rotation

Global Dim texture.i(1) ;Storage For 1 Texture

Structure TEXTURE_IMAGE
 width.l ;Width Of Image In Pixels
 height.l ;Height Of Image In Pixels
 format.l ;Number Of Bytes Per Pixel
 Data.i ;Texture Data
EndStructure

Global t1.TEXTURE_IMAGE ;Pointer To The Texture Image Data Type
Global t2.TEXTURE_IMAGE ;Pointer To The Texture Image Data Type

Procedure AllocateTextureBuffer(*ti.TEXTURE_IMAGE,w.l,h.l,f.l) ;Allocate Memory For An Image

 Protected c.i=#Null ;Pointer To Block Memory For Image
 
 If *ti<>#Null
  *ti\width=w ;Set Width
  *ti\height=h ;Set Height
  *ti\format=f ;Set Format
  c=AllocateMemory(w*h*f)
  If c<>#Null
   *ti\Data=c ;Set Data
  Else
    MessageRequester("BUFFER ERROR","Could Not Allocate Memory For A Texture Buffer",#PB_MessageRequester_Info)
    ProcedureReturn #Null
  EndIf
 Else
   MessageRequester("IMAGE STRUCTURE ERROR","Invalid Image Structure",#PB_MessageRequester_Info)
   ProcedureReturn #Null
 EndIf
 
EndProcedure

Procedure DeallocateTexture(*t.TEXTURE_IMAGE) ;Free Up The Image Data

 If *t
  If *t\Data
   FreeMemory(*t\Data)
  EndIf
  ;FreeMemory(*t) ;Note: this doesn't apply for a structure
 EndIf
 
EndProcedure

;Read A .RAW File In To The Allocated Image Buffer Using Data In The Image Structure Header.
;Flip The Image Top To Bottom. Returns 0 For Failure Of Read, Or Number Of Bytes Read.

Procedure ReadTextureData(filename.s,*buffer.TEXTURE_IMAGE)

 Protected f.i,i.i,j.i,k.i
 Protected done.l=0,stride.i,p.i=#Null
 
 stride=*buffer\width**buffer\format ;Size Of A Row (Width * Bytes Per Pixel)
 
 f=ReadFile(#PB_Any,filename) ;Open "filename" For Reading Bytes
 
 If f<>#Null ;If File Exists
  For i=*buffer\height-1 To 0 Step -1 ;Loop Through Height (Bottoms Up - Flip Image)
   p=*buffer\Data+(i*stride)
   For j=0 To *buffer\width-1 ;Loop Through Width
    For k=0 To (*buffer\format-1)-1
     PokeB(p,ReadByte(f)) ;Read Value From File And Store In Memory
     p+1 : done+1 ;Next Byte
    Next
    PokeB(p,255) : p+1 ;Store 255 In Alpha Channel And Increase Pointer
   Next
  Next
    CloseFile(f) ;Close The File  
  Else           ;Otherwise
    MessageRequester("IMAGE ERROR","Unable To Open Image File",#PB_MessageRequester_Info)
 EndIf
 
 ProcedureReturn done ;Returns Number Of Bytes Read In
 
EndProcedure

Procedure BuildTexture(*tex.TEXTURE_IMAGE)

 glGenTextures_(1,@texture(0))
 glBindTexture_(#GL_TEXTURE_2D,texture(0))
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR)
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR)
 gluBuild2DMipmaps_(#GL_TEXTURE_2D,#GL_RGB,*tex\width,*tex\height,#GL_RGBA,#GL_UNSIGNED_BYTE,*tex\Data)
 
EndProcedure

Procedure Blit(*src.TEXTURE_IMAGE,*dst.TEXTURE_IMAGE,src_xstart.l,src_ystart.l,src_width.l,src_height.l,dst_xstart.l,dst_ystart.l,blend.l,alpha.l)

 Protected i.l,j.l,k.l,v.l
 Protected s.i,d.i ;Source & Destination
 
 ;Clamp Alpha If Value Is Out Of Range
 If alpha>255 : alpha=255 : EndIf
 If alpha<0 : alpha=0 : EndIf
 
 ;Check For Incorrect Blend Flag Values
 If blend<0 : blend=0 : EndIf
 If blend>1 : blend=1 : EndIf
 
 d=*dst\Data+(dst_ystart**dst\width**dst\format) ;Start Row - dst (Row * Width In Pixels * Bytes Per Pixel)
 s=*src\Data+(src_ystart**src\width**src\format) ;Start Row - src (Row * Width In Pixels * Bytes Per Pixel)
 
 For i=0 To src_height-1 ;Height Loop
  s=s+(src_xstart**src\format) ;Move Through Src Data By Bytes Per Pixel
  d=d+(dst_xstart**dst\format) ;Move Through Dst Data By Bytes Per Pixel
  For j=0 To src_width-1 ;Width Loop
   For k=0 To *src\format-1 ;"n" Bytes At A Time
    If blend ;If Blending Is On
     v=((PeekB(s) & 255)*alpha)+((PeekB(d) & 255)*(255-alpha)) ;Src Data*alpha + Dst Data*(255-alpha)
     PokeB(d,v >> 8) ;Keep in 0-255 Range With >> 8
    Else
     PokeB(d,PeekB(s)) ;No Blending Just Do A Straight Copy
    EndIf
    d+1 : s+1 ;Next Byte
   Next
  Next
  d=d+(*dst\width-(src_width+dst_xstart))**dst\format ;Add End Of Row
  s=s+(*src\width-(src_width+src_xstart))**src\format ;Add End Of Row
 Next
 
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

 AllocateTextureBuffer(t1,256,256,4) ;Get An Image Structure
 If ReadTextureData("Data/Monitor.raw",t1)=0 ;Fill The Image Structure With Data
   MessageRequester("TEXTURE ERROR","Could Not Read 'Monitor.raw' Image Data",#PB_MessageRequester_Info)
   ProcedureReturn #False ;Nothing Read?
 EndIf
 
 AllocateTextureBuffer(t2,256,256,4) ;Second Image Structure
 If ReadTextureData("Data/GL.raw",t2)=0 ;Fill The Image Structure With Data
  MessageRequester("TEXTURE ERROR","Could Not Read 'GL.raw' Image Data",#PB_MessageRequester_Info)
  ProcedureReturn #False ;Nothing Read?
 EndIf
 
 ;Image To Blend In, Original Image, Src Start X & Y, Src Width & Height, Dst Start X & Y, Blend Flag, Alpha Value
 Blit(t2,t1,127,127,128,128,64,64,1,127) ;Call The Blitter Routine
 
 BuildTexture(t1) ;Load The Texture Map Into Texture Memory
 
 DeallocateTexture(t1) ;Clean Up Image Memory Because Texture Is
 DeallocateTexture(t2) ;In GL Texture Memory Now
 
 glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
 
 glShadeModel_(#GL_SMOOTH) ;Enables Smooth Color Shading
 glClearColor_(0.0,0.0,0.0,0.0) ;This Will Clear The Background Color To Black
 glClearDepth_(1.0) ;Enables Clearing Of The Depth Buffer
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing
 glDepthFunc_(#GL_LESS) ;The Type Of Depth Test To Do
 
 ProcedureReturn #True

EndProcedure

Procedure DrawScene(Gadget)
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear The Screen And The Depth Buffer
  glLoadIdentity_() ;Reset The View
  glTranslatef_(0.0,0.0,-5.0)
 
  glRotatef_(xrot,1.0,0.0,0.0)
  glRotatef_(yrot,0.0,1.0,0.0)
  glRotatef_(zrot,0.0,0.0,1.0)
 
  glBindTexture_(#GL_TEXTURE_2D,texture(0))
 
  glBegin_(#GL_QUADS)
   ;Front Face
   glNormal3f_( 0.0, 0.0, 1.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0)
   ;Back Face
   glNormal3f_( 0.0, 0.0,-1.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0)
   ;Top Face
   glNormal3f_( 0.0, 1.0, 0.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0, 1.0, 1.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0, 1.0, 1.0)
   ;Bottom Face
   glNormal3f_( 0.0,-1.0, 0.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0,-1.0,-1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0,-1.0,-1.0)
   ;Right Face
   glNormal3f_( 1.0, 0.0, 0.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_( 1.0,-1.0,-1.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 1.0, 1.0,-1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 1.0, 1.0, 1.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_( 1.0,-1.0, 1.0)
   ;Left Face
   glNormal3f_(-1.0, 0.0, 0.0)
   glTexCoord2f_(0.0, 0.0) : glVertex3f_(-1.0,-1.0,-1.0)
   glTexCoord2f_(1.0, 0.0) : glVertex3f_(-1.0,-1.0, 1.0)
   glTexCoord2f_(1.0, 1.0) : glVertex3f_(-1.0, 1.0, 1.0)
   glTexCoord2f_(0.0, 1.0) : glVertex3f_(-1.0, 1.0,-1.0)
  glEnd_()
 
  xrot+0.3
  yrot+0.2
  zrot+0.4
  
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

CreateGLWindow("Andreas Löffler, Rob Fletcher & NeHe's Blitter & Raw Image Loading Tutorial (Lesson 29)",640,480,16,0)

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
  
  Delay(5)
Until Quit = 1


 
; IDE Options = PureBasic 6.00 Beta 1 (Linux - x64)
; CursorPosition = 164
; FirstLine = 161
; Folding = --
; EnableAsm
; EnableXP