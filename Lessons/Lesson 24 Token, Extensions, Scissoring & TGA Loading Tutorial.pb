;NeHe's Token, Extensions, Scissoring & TGA Loading Tutorial (Lesson 24)
;http://nehe.gamedev.net
;https://nehe.gamedev.net/tutorial/tokens_extensions_scissor_testing_and_tga_loading/19002/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 29 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)

Global hDC.i ;Private GDI Device Context

Global scroll.l ;Used For Scrolling The Screen
Global maxtokens.l ;Keeps Track Of The Number Of Extensions Supported
Global swidth.l ;Scissor Width
Global sheight.l ;Scissor Height

Global base.l ;Base Display List For The Font

Structure TEXTUREIMAGE ;Create A Structure
  imageData.i ;Image Data (Up To 32 Bits)
  bpp.l ;Image Color Depth In Bits Per Pixel.
  width.l ;Image Width
  height.l ;Image Height
  texID.i ;Texture ID Used To Select A Texture
EndStructure

Global Dim textures.TEXTUREIMAGE(1) ;Storage For One Texture

Procedure.b LoadTGA(*texture.TEXTUREIMAGE,filename.s) ;Loads A TGA File Into Memory
  
  Protected Dim TGAheader.b(12) ;Uncompressed TGA Header
  TGAheader(2)=2 ;ie. {0,0,2,0,0,0,0,0,0,0,0,0}
  Protected Dim TGAcompare.b(12) ;Used To Compare TGA Header
  Protected Dim header.b(6) ;First 6 Useful Bytes From The Header
  Protected bytesPerPixel.l ;Holds Number Of Bytes Per Pixel Used In The TGA File
  Protected imageSize.l ;Used To Store The Image Size When Setting Aside Ram
  Protected temp.i ;Temporary Variable
  Protected type.l=#GL_RGBA ;Set The Default GL Mode To RBGA (32 BPP)
  Protected file.i ;file handle
  Protected i.l ;loop variable
  
  file=ReadFile(#PB_Any,filename) ;Open The TGA File
  
  If file=0 ;Does File Even Exist?
    ProcedureReturn #False ;Return False
  EndIf
  If ReadData(file,TGAcompare(),12)<>12 ;Are There 12 Bytes To Read?
    CloseFile(file) ;Close The File
    ProcedureReturn #False ;Return False
  EndIf
  For i=0 To 12-1 ;Does The Header Match What We Want?
    If TGAheader(i)<>TGAcompare(i)
      CloseFile(file) ;Close The File
      ProcedureReturn #False ;Return False
    EndIf
  Next
  If ReadData(file,header(),6)<>6 ;If So Read Next 6 Header Bytes
    CloseFile(file) ;Close The File
    ProcedureReturn #False ;Return False
  EndIf
  
  *texture\width=((header(1) & 255)*256)+(header(0) & 255) ;Determine The TGA Width (highbyte*256+lowbyte)
  *texture\height=((header(3) & 255)*256)+(header(2) & 255) ;Determine The TGA Height (highbyte*256+lowbyte)
  
  ;Is The Width Or Height Less Than Or Equal To Zero Or Is The TGA Not 24 Or 32 Bit?
  If *texture\width<=0 Or *texture\height<=0 Or (header(4)<>24 And header(4)<>32)
    CloseFile(file) ;If Anything Failed, Close The File
    ProcedureReturn #False ;Return False
  EndIf
  
  *texture\bpp=header(4) ;Grab The TGA's Bits Per Pixel (24 or 32)
  bytesPerPixel=*texture\bpp/8 ;Divide By 8 To Get The Bytes Per Pixel
  imageSize=*texture\width**texture\height*bytesPerPixel ;Calculate The Memory Required For The TGA Data
  
  *texture\imageData=AllocateMemory(imageSize) ;Reserve Memory To Hold The TGA Data
  
  ;Does The Storage Memory Exist? and Does The Image Size Match The Memory Reserved?
  If *texture\imageData=0 Or ReadData(file,*texture\imageData,imageSize)<>imageSize
    If *texture\imageData<>0 ;Was Image Data Loaded
      FreeMemory(*texture\imageData) ;If So, Release The Image Data
    EndIf
    CloseFile(file) ;Close The File
    ProcedureReturn #False ;Return False
  EndIf
  
  For i=0 To (imageSize/bytesPerPixel)-1 ;Loop Through The Image Data
    ;Swaps The 1st And 3rd Bytes ('R'ed And 'B'lue)
    temp=PeekB(*texture\imageData+(i*bytesPerPixel)) ;Temporarily Store The Value At Image Data 'i'
    PokeB(*texture\imageData+(i*bytesPerPixel),PeekB(*texture\imageData+(i*bytesPerPixel)+2)) ;Set The 1st Byte To The Value Of The 3rd Byte
    PokeB(*texture\imageData+(i*bytesPerPixel)+2,temp) ;Set The 3rd Byte To The Value In 'temp' (1st Byte Value)
  Next
  
  CloseFile(file) ;Close The File
  
  ;Build A Texture From The Data
  glGenTextures_(1,@*texture\texID) ;Generate OpenGL texture IDs
  
  glBindTexture_(#GL_TEXTURE_2D,*texture\texID) ;Bind Our Texture
  glTexParameterf_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR) ;Linear Filtered
  glTexParameterf_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR) ;Linear Filtered
  
  If *texture\bpp=24 ;Was The TGA 24 Bits
    type=#GL_RGB ;If So Set The 'type' To GL_RGB
  EndIf
  
  glTexImage2D_(#GL_TEXTURE_2D,0,type,*texture\width,*texture\height,0,type,#GL_UNSIGNED_BYTE,*texture\imageData)
  
  If *texture\imageData
    FreeMemory(*texture\imageData)
  EndIf
  
  ProcedureReturn #True ;Texture Building Went Ok, Return True
  
EndProcedure

Procedure BuildFont() ;Build Our Font Display List
  
  Protected loop1.l,cx.f,cy.f,modx.l
  
  base=glGenLists_(256) ;Creating 256 Display Lists
  glBindTexture_(#GL_TEXTURE_2D,textures(0)\texID) ;Select Our Font Texture
  
  For loop1=0 To 256-1 ;Loop Through All 256 Lists
    modx=loop1 % 16 ;Note: can't use % with floats
    cx=modx/16.0 ;X Position Of Current Character
    cy=Int(loop1/16)/16.0 ;Y Position Of Current Character
    
    glNewList_(base+loop1,#GL_COMPILE) ;Start Building A List
    glBegin_(#GL_QUADS) ;Use A Quad For Each Character
    glTexCoord2f_(cx,1.0-cy-0.0625) ;Texture Coord (Bottom Left)
    glVertex2i_(0,16) ;Vertex Coord (Bottom Left)
    glTexCoord2f_(cx+0.0625,1.0-cy-0.0625) ;Texture Coord (Bottom Right)
    glVertex2i_(16,16) ;Vertex Coord (Bottom Right)
    glTexCoord2f_(cx+0.0625,1.0-cy-0.001) ;Texture Coord (Top Right)
    glVertex2i_(16,0) ;Vertex Coord (Top Right)
    glTexCoord2f_(cx,1.0-cy-0.001) ;Texture Coord (Top Left)
    glVertex2i_(0,0) ;Vertex Coord (Top Left)
    glEnd_() ;Done Building Our Quad (Character)
    glTranslated_(14,0,0) ;Move To The Right Of The Character
    glEndList_() ;Done Building The Display List
  Next ;Loop Until All 256 Are Built
  
EndProcedure

Procedure KillFont() ;Delete The Font From Memory
  
  glDeleteLists_(base,256) ;Delete All 256 Display Lists
  
EndProcedure

Procedure glPrint(x.l,y.l,set.l,text.s) ;Where The Printing Happens
  
  If text="" ;If There's No Text
    ProcedureReturn 0 ;Do Nothing
  EndIf
  
  If set : set=1 : EndIf ;Is set True? If So, Select Set 1 (Italic)
  
  glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping
  glLoadIdentity_() ;Reset The Modelview Matrix
  glTranslated_(x,y,0) ;Position The Text (0,0 - Top Left)
  glListBase_(base-32+(128*set)) ;Choose The Font Set (0 or 1)
  
  glScalef_(1.0,2.0,1.0) ;Make The Text 2X Taller
  *pointer = Ascii(text)
  glCallLists_(Len(text),#GL_UNSIGNED_BYTE,*pointer) ;Write The Text To The Screen
  FreeMemory (*pointer)
  
  glDisable_(#GL_TEXTURE_2D) ;Disable Texture Mapping
  
EndProcedure

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

  If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
  
  ResizeGadget(0, 0, 0, width, height)
  
  swidth=width ;Set Scissor Width To Window Width
  sheight=height ;Set Scissor Height To Window Height
  
  glViewport_(0,0,width,height) ;Reset The Current Viewport
  
  glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
  glLoadIdentity_() ;Reset The Projection Matrix
  
  glOrtho_(0.0,640,480,0.0,-1.0,1.0) ;Create Ortho 640x480 View (0,0 At Top Left)
  
  glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
  glLoadIdentity_() ;Reset The Modelview Matrix
 
 
EndProcedure

Procedure.l InitGL() ;All Setup For OpenGL Goes Here

  If LoadTGA(textures(0),"Data/Font.tga")=0 ;Load The Font Texture
    ProcedureReturn #False ;If Loading Failed, Return False
  EndIf
  
  BuildFont() ;Build The Font
  
  glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading
  glClearColor_(0.0,0.0,0.0,0.5) ;Black Background
  glClearDepth_(1.0) ;Depth Buffer Setup
  glBindTexture_(#GL_TEXTURE_2D,textures(0)\texID) ;Select Our Font Texture
  
  ProcedureReturn #True ;Initialization Went OK
 
EndProcedure

Procedure DrawScene(Gadget)
   SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
Protected token.s ;Storage For Our Token
  Protected cnt.l=0 ;Local Counter Variable
  Protected text.s ;Storage For Our Extension String
  Protected start.l,len.l ;token variables
  
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer
  
  glColor3f_(1.0,0.5,0.5) ;Set Color To Bright Red
  glPrint(20,16,1,"Renderer") ;Display Renderer
  glPrint(50,48,1,"Vendor") ;Display Vendor Name
  glPrint(36,80,1,"Version") ;Display Version
  
  glColor3f_(1.0,0.7,0.4) ;Set Color To Orange
  glPrint(170,16,1,PeekS(glGetString_(#GL_RENDERER),-1,#PB_Ascii)) ;Display Renderer
  glPrint(170,48,1,PeekS(glGetString_(#GL_VENDOR),-1,#PB_Ascii)) ;Display Vendor Name
  glPrint(170,80,1,PeekS(glGetString_(#GL_VERSION),-1,#PB_Ascii)) ;Display Version
  
  glColor3f_(0.5,0.5,1.0) ;Set Color To Bright Blue
  glPrint(192,432,1,"NeHe Productions") ;Write NeHe Productions At The Bottom Of The Screen
  
  glLoadIdentity_() ;Reset The ModelView Matrix
  glColor3f_(1.0,1.0,1.0) ;Set The Color To White
  glBegin_(#GL_LINE_STRIP) ;Start Drawing Line Strips (Something New)
  glVertex2i_(639,417) ;Top Right Of Bottom Box
  glVertex2i_(  1,417) ;Top Left Of Bottom Box
  glVertex2i_(  1,480) ;Lower Left Of Bottom Box
  glVertex2i_(639,480) ;Lower Right Of Bottom Box
  glVertex2i_(639,128) ;Up To Bottom Right Of Top Box
  glEnd_() ;Done First Line Strip
  glBegin_(#GL_LINE_STRIP) ;Start Drawing Another Line Strip
  glVertex2i_(  1,128) ;Bottom Left Of Top Box
  glVertex2i_(639,128) ;Bottom Right Of Top Box       
  glVertex2i_(639,  1) ;Top Right Of Top Box
  glVertex2i_(  1,  1) ;Top Left Of Top Box
  glVertex2i_(  1,417) ;Down To Top Left Of Bottom Box
  glEnd_() ;Done Second Line Strip
  
  glScissor_(1,Int(0.135416*sheight),swidth-2,Int(0.597916*sheight)) ;Define Scissor Region
  glEnable_(#GL_SCISSOR_TEST) ;Enable Scissor Testing
  
  text=PeekS(glGetString_(#GL_EXTENSIONS),-1,#PB_Ascii) ;Grab The Extension List, Store In Text

  start=1 ;Parse 'text' For Words, Seperated By " " (spaces)
  len=FindString(text," ",start)
  token=Mid(text,start,len-start)
  While token<>"" ;While The Token Isn't NULL
    cnt+1 ;Increase The Counter
    If cnt>maxtokens ;Is 'maxtokens' Less Than 'cnt'
      maxtokens=cnt ;If So, Set 'maxtokens' Equal To 'cnt'
    EndIf
    glColor3f_(0.5,1.0,0.5) ;Set Color To Bright Green
    glPrint(2,96+(cnt*32)-scroll,0,Str(cnt)) ;Print Current Extension Number
    glColor3f_(1.0,1.0,0.5) ;Set Color To Yellow
    glPrint(50,96+(cnt*32)-scroll,0,token) ;Print The Current Token (Parsed Extension Name)
    start=len+1 ;Search For The Next Token
    len=FindString(text," ",start)
    token=Mid(text,start,len-start)
  Wend
  
  glDisable_(#GL_SCISSOR_TEST) ;Disable Scissor Testing
  
  glFlush_() ;Flush The Rendering Pipeline
  
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
  
  ProcedureReturn #True ;Everything Went OK
 

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

CreateGLWindow("NeHe's Token, Extensions, Scissoring & TGA Loading Tutorial (Lesson 24)",640,480,16)

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
    Quit = 1                              ; // This is the end
  EndIf
  If KeyboardPushed(#PB_Key_Up) And scroll>0 ;Is Up Arrow Being Pressed? 
    scroll-2                   ;If So, Decrease 'scroll' Moving Screen Down
  EndIf

  If KeyboardPushed(#PB_Key_Down) And scroll<32*(maxtokens-9) ;Is Down Arrow Being Pressed?
     scroll+2 ;If So, Increase 'scroll' Moving Screen Up
  EndIf
        
  DrawScene(0)
  Delay(10)
Until Quit = 1

; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 18
; Folding = --
; EnableAsm
; EnableXP