;NeHe's Collision Detection Tutorial (Lesson 30) 
;http://nehe.gamedev.net
;https://nehe.gamedev.net/tutorial/collision_detection/17005/
;Credits: Nico Gruener, Dreglor, traumatic, hagibaba
;Author: MPz
;Date: 29 Oct 2021
;Note: up-to-date with PB v5.73 (Windows)
;Note: requires bitmaps in paths "Data/Marble.bmp", "Data/Spark.bmp", 
;"Data/Boden.bmp", "Data/Wand.bmp" 
;Note: requires a wave file in path "Data/Explode.wav" 

;Start of Lesson 30 

XIncludeFile "Collisions.pb" ;Include File For Collisions 

Structure IMAGE ;Image Type - Contains Height, Width and Data 
 sizeX.l 
 sizeY.l 
 Data.i 
EndStructure 

;Global DMsaved.DEVMODE ;Saves The Previous Screen Settings 

Global Dim spec.f(4) ;Sets Specular Highlight Of Balls 
 spec(0)=1.0 : spec(1)=1.0 : spec(2)=1.0 : spec(3)=1.0 
Global Dim posl.f(4) ;Position Of Light Source 
 posl(0)=0 : posl(1)=400 : posl(2)=0 : posl(3)=1 
Global Dim amb.f(4) ;Global Ambient 
 amb(0)=0.2 : amb(1)=0.2 : amb(2)=0.2 : amb(3)=1.0 
Global Dim amb2.f(4) ;Ambient Of Light Source 
 amb2(0)=0.3 : amb2(1)=0.3 : amb2(2)=0.3 : amb2(3)=1.0 
  
Global dir.TVECTOR ;Initial Direction Of Camera 
 TVector_make(dir,0,0,-10) 
Global pos.TVECTOR ;Initial Position Of Camera 
 TVector_make(pos,0,-50,1000) 
Global camera_rotation.f=0 ;Holds Rotation Around The Y Axis 

Global veloc.TVECTOR ;Initial Velocity Of Balls 
 TVector_make(veloc,0.5,-0.1,0.5) 
Global accel.TVECTOR ;Acceleration ie. Gravity Of Balls 
 TVector_make(accel,0,-0.05,0) 
  
Global Dim ArrayVel.TVECTOR(10) ;Holds Velocity Of Balls 
Global Dim ArrayPos.TVECTOR(10) ;Position Of Balls 
Global Dim OldPos.TVECTOR(10) ;Old Position Of Balls 

Global NrOfBalls.l ;Sets The Number Of Balls 
Global Time.d=0.6 ;Timestep Of Simulation 
Global hook_toball1.i=0 ;Hook Camera to Ball 
Global sounds.i=1 ;Sound On/Off 

Structure PLANE ;Plane Structure 
 _Position.TVECTOR 
 _Normal.TVECTOR 
EndStructure 

Structure CYLINDER ;Cylinder Structure 
 _Position.TVECTOR 
 _Axis.TVECTOR 
 _Radius.d 
EndStructure 

Structure EXPLOSION ;Explosion Structure 
 _Position.TVECTOR 
 _Alpha.f 
 _Scale.f 
EndStructure 

Global pl1.PLANE,pl2.PLANE,pl3.PLANE,pl4.PLANE,pl5.PLANE ;The 5 Planes Of The Room 
Global cyl1.CYLINDER,cyl2.CYLINDER,cyl3.CYLINDER ;The 3 Cylinders Of The Room 
Global Dim ExplosionArray.EXPLOSION(20) ;Holds Max 20 Explosions At Once 

Global cylinder_obj.i ;Quadratic Object To Render The Cylinders 
Global Dim texture.i(5) ;Stores Texture Objects 
Global dlist.i ;Stores Display List 

;Quick And Dirty Bitmap Loader, For 24 Bit Bitmaps With 1 Plane Only 
;See http://www.dcs.ed.ac.uk/~mxr/gfx/2d/BMP.txt For More Info 

Procedure ImageLoad(filename.s,*image.IMAGE) 

 Protected file.i 
 Protected size.i ;Size Of The Image In Bytes 
 Protected i.i ;Standard Counter 
 Protected planes.w ;Number Of Planes In Image (Must Be 1) 
 Protected bpp.w ;Number Of Bits Per Pixel (Must Be 24) 
 Protected temp.b ;Temporary Color Storage For bgr-rgb Conversion 
  
 file=ReadFile(#PB_Any,filename) 
  
 If file=#Null ;Make Sure The File Is There 
  MessageRequester("IMAGE ERROR","File Not Found: ",#PB_MessageRequester_Info)
  ProcedureReturn 0 
 EndIf 
  
 FileSeek(file,18) ;Seek Through The Bmp Header, Up To The Width/Height 
  
 *image\sizeX=ReadLong(file) ;Read The Width 
 *image\sizeY=ReadLong(file) ;Read The Height 
  
 ;Calculate The Size (Assuming 24 Bits Or 3 Bytes Per Pixel) 
 size=*image\sizeX**image\sizeY*3 
 
 planes=ReadWord(file) ;Read The Planes 
 If planes<>1 
  MessageRequester("IMAGE ERROR","Planes from "+filename+" is Not 1: "+Str(planes),#PB_MessageRequester_Info)
  ProcedureReturn 0 
 EndIf 
  
 bpp=ReadWord(file) ;Read The Bpp
 
 If bpp<>24 
  MessageRequester("IMAGE ERROR","Bpp from "+filename+" is Not 24: "+Str(bpp),#PB_MessageRequester_Info)
  ProcedureReturn 0 
 EndIf 
  
 FileSeek(file,54) ;Seek Past The Rest Of The Bitmap Header 
  
 *image\Data=AllocateMemory(size) 
 If *image\Data=#Null 
  MessageRequester("IMAGE ERROR","Error allocating memory for image data",#PB_MessageRequester_Info)
  ProcedureReturn 0 
 EndIf 
  
 If ReadData(file,*image\Data,size)<>size ;Read The Data 
  MessageRequester("IMAGE ERROR","Error reading image data from "+filename,#PB_MessageRequester_Info)
  ProcedureReturn 0 
 EndIf 
  
 For i=0 To size -1 Step 3 ;Reverse All Of The Colors (bgr -> rgb) 
  temp=PeekB(*image\Data+i) 
  PokeB(*image\Data+i,PeekB(*image\Data+i+2)) 
  PokeB(*image\Data+i+2,temp) 
 Next

 CloseFile(file) 
 ProcedureReturn 1 ;We're Done 
  
EndProcedure 

Procedure LoadGLTextures() ;Load Bitmaps And Convert To Textures 

 Protected image1.IMAGE,image2.IMAGE,image3.IMAGE,image4.IMAGE 
 
 ;Load Textures 
 If ImageLoad("Data/Marble.bmp",image1)=0 
   ProcedureReturn 0 
 EndIf
 
If ImageLoad("Data/Spark.bmp",image2)=0 
   ProcedureReturn 0 
 EndIf 
 
 If ImageLoad("Data/Boden.bmp",image3)=0 
   ProcedureReturn 0 
 EndIf 
 If ImageLoad("Data/Wand.bmp",image4)=0 
   ProcedureReturn 0 
 EndIf 
 
 glGenTextures_(5,@texture(0)) 
 
 ;Create Texture 1 
 glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;2d texture (x and y size) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR) ;Scale linearly when image bigger than texture 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR) ;Scale linearly when image smaller than texture 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT) 
 ;2d texture, level of detail 0 (normal), 3 components (red, green, blue), x size from image, y size from image, 
 ;border 0 (normal), rgb color data, unsigned byte data, and finally the data itself. 
 glTexImage2D_(#GL_TEXTURE_2D,0,3,image1\sizeX,image1\sizeY,0,#GL_RGB,#GL_UNSIGNED_BYTE,image1\Data) 
 
 ;Create Texture 2 
 glBindTexture_(#GL_TEXTURE_2D,texture(1)) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT) 
 glTexImage2D_(#GL_TEXTURE_2D,0,3,image2\sizeX,image2\sizeY,0,#GL_RGB,#GL_UNSIGNED_BYTE,image2\Data) 
  
 ;Create Texture 3 
 glBindTexture_(#GL_TEXTURE_2D,texture(2)) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT) 
 glTexImage2D_(#GL_TEXTURE_2D,0,3,image3\sizeX,image3\sizeY,0,#GL_RGB,#GL_UNSIGNED_BYTE,image3\Data) 
 
 ;Create Texture 4 
 glBindTexture_(#GL_TEXTURE_2D,texture(3)) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT) 
 glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT) 
 glTexImage2D_(#GL_TEXTURE_2D,0,3,image4\sizeX,image4\sizeY,0,#GL_RGB,#GL_UNSIGNED_BYTE,image4\Data) 
 
 FreeMemory(image1\Data) 
 FreeMemory(image2\Data) 
 FreeMemory(image3\Data) 
 FreeMemory(image4\Data) 
  
EndProcedure 

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

 If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error 
 
 ResizeGadget(0, 0, 0, width, height)
 
 glViewport_(0,0,width,height) ;Reset The Current Viewport 
  
 glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix 
 glLoadIdentity_() ;Reset The Projection Matrix 
  
 gluPerspective_(45.0,Abs(width/height),10.0,1700.0) ;Calculate The Aspect Ratio Of The Window 
  
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix 
 glLoadIdentity_()            ;Reset The Modelview Matrix 
 
EndProcedure

Procedure InitVars() 

 ;Create Planes 
 TVector_make(pl1\_Position,0,-300,0) 
 TVector_make(pl1\_Normal,0,1,0) 
 TVector_make(pl2\_Position,300,0,0) 
 TVector_make(pl2\_Normal,-1,0,0) 
 TVector_make(pl3\_Position,-300,0,0) 
 TVector_make(pl3\_Normal,1,0,0) 
 TVector_make(pl4\_Position,0,0,300) 
 TVector_make(pl4\_Normal,0,0,-1) 
 TVector_make(pl5\_Position,0,0,-300) 
 TVector_make(pl5\_Normal,0,0,1) 
  
 ;Create Cylinders 
 TVector_make(cyl1\_Position,0,0,0) 
 TVector_make(cyl1\_Axis,0,1,0) 
 cyl1\_Radius=60+20 
 TVector_make(cyl2\_Position,200,-300,0) 
 TVector_make(cyl2\_Axis,0,0,1) 
 cyl2\_Radius=60+20 
 TVector_make(cyl3\_Position,-200,0,0) 
 TVector_make(cyl3\_Axis,0,1,1) 
 TVector_unit(cyl3\_Axis) 
 cyl3\_Radius=30+20 
  
 ;Create Quadratic Object To Render Cylinders 
 cylinder_obj=gluNewQuadric_() 
 gluQuadricTexture_(cylinder_obj,#GL_TRUE) 
  
 ;Set Initial Positions And Velocities Of Balls 
 ;Also Initialize Array Which Holds Explosions 
 NrOfBalls=10 
 TVector_set(ArrayVel(0),veloc) 
 TVector_make(ArrayPos(0),199,180,10) 
 ExplosionArray(0)\_Alpha=0 
 ExplosionArray(0)\_Scale=1 
 TVector_set(ArrayVel(1),veloc) 
 TVector_make(ArrayPos(1),0,150,100) 
 ExplosionArray(1)\_Alpha=0 
 ExplosionArray(1)\_Scale=1 
 TVector_set(ArrayVel(2),veloc) 
 TVector_make(ArrayPos(2),-100,180,-100) 
 ExplosionArray(2)\_Alpha=0 
 ExplosionArray(2)\_Scale=1 
  
 Protected i.i 
 For i=3 To 10-1 
  TVector_set(ArrayVel(i),veloc) 
  TVector_make(ArrayPos(i),-500+i*75,300,-500+i*50) 
  ExplosionArray(i)\_Alpha=0 
  ExplosionArray(i)\_Scale=1 
 Next 
 For i=10 To 20-1 
  ExplosionArray(i)\_Alpha=0 
  ExplosionArray(i)\_Scale=1 
 Next 
 InitSound() ;
 LoadSound(0, "Data/Explode.wav")
 
 
EndProcedure 

Procedure InitGL() ;All Setup For OpenGL Goes Here

 Protected df.f=100.0 ;Material Shininess 
  
 glClearDepth_(1.0) ;Depth Buffer Setup 
 glEnable_(#GL_DEPTH_TEST) ;Enables Depth Testing 
 glDepthFunc_(#GL_LEQUAL) ;The Type Of Depth Testing To Do 
 glHint_(#GL_PERSPECTIVE_CORRECTION_HINT,#GL_NICEST) ;Really Nice Perspective Calculations 
  
 glClearColor_(0.0,0.0,0.0,0.0) ;Black Background 
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix 
 glLoadIdentity_() ;Reset The Modelview Matrix 
  
 glShadeModel_(#GL_SMOOTH) ;Enable Smooth Shading 
 glEnable_(#GL_CULL_FACE) ;Enable Culling 
 glEnable_(#GL_DEPTH_TEST) ;Enable Depth Testing 
  
 glMaterialfv_(#GL_FRONT,#GL_SPECULAR,spec()) ;Set Material Specular 
 glMaterialfv_(#GL_FRONT,#GL_SHININESS,@df) ;Set Material Shininess 
  
 glEnable_(#GL_LIGHTING) ;Enable Lighting 
 glLightfv_(#GL_LIGHT0,#GL_POSITION,posl()) ;Position The Light 
 glLightfv_(#GL_LIGHT0,#GL_AMBIENT,amb2()) ;Setup The Ambient Light 
 glEnable_(#GL_LIGHT0) ;Enable Light One 
  
 glLightModelfv_(#GL_LIGHT_MODEL_AMBIENT,amb()) ;Ambient Model Lighting 
 glEnable_(#GL_COLOR_MATERIAL) ;Enable Material Coloring 
 glColorMaterial_(#GL_FRONT,#GL_AMBIENT_AND_DIFFUSE) 
  
 glEnable_(#GL_BLEND) ;Enable Blending 
 glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE) ;Select The Type Of Blending 
  
 glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping 
 
 LoadGLTextures() 
  
 ;Construct Billboarded Explosion Primitive As Display List 
 ;4 Quads At Right Angles To Each Other 
 dlist=glGenLists_(1) 
 glNewList_(dlist,#GL_COMPILE) 
  glBegin_(#GL_QUADS) 
   glRotatef_(-45.0,0.0,1.0,0.0) ;Rotate On The Y Axis By 45 
   glNormal3f_(0.0,0.0,1.0) ;Front Face 
   glTexCoord2f_(0.0, 0.0) : glVertex3f_(-50.0,-40.0, 0.0) 
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 50.0,-40.0, 0.0) 
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 50.0, 40.0, 0.0) 
   glTexCoord2f_(1.0, 0.0) : glVertex3f_(-50.0, 40.0, 0.0) 
   glNormal3f_(0.0,0.0,-1.0) ;Back Face 
   glTexCoord2f_(0.0, 0.0) : glVertex3f_(-50.0, 40.0, 0.0) 
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 50.0, 40.0, 0.0) 
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 50.0,-40.0, 0.0) 
   glTexCoord2f_(1.0, 0.0) : glVertex3f_(-50.0,-40.0, 0.0) 
   glNormal3f_(1.0,0.0,0.0) ;Right Face 
   glTexCoord2f_(0.0, 0.0) : glVertex3f_( 0.0,-40.0, 50.0) 
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 0.0,-40.0,-50.0) 
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 0.0, 40.0,-50.0) 
   glTexCoord2f_(1.0, 0.0) : glVertex3f_( 0.0, 40.0, 50.0) 
   glNormal3f_(-1.0,0.0,0.0) ;Left Face 
   glTexCoord2f_(0.0, 0.0) : glVertex3f_( 0.0, 40.0, 50.0) 
   glTexCoord2f_(0.0, 1.0) : glVertex3f_( 0.0, 40.0,-50.0) 
   glTexCoord2f_(1.0, 1.0) : glVertex3f_( 0.0,-40.0,-50.0) 
   glTexCoord2f_(1.0, 0.0) : glVertex3f_( 0.0,-40.0, 50.0) 
  glEnd_() 
 glEndList_() 
  
 ProcedureReturn #True ;Initialization Went OK 

EndProcedure

;Fast Intersection Function Between Ray / Plane 

Procedure TestIntersionPlane(*plane.PLANE,*position.TVECTOR,*direction.TVECTOR,*lamda.DOUBLE,*pNormal.TVECTOR) 

 Protected DotProduct.d,l2.d 
 Protected result.TVECTOR 
  
 DotProduct=TVector_dot(*direction,*plane\_Normal) ;Dot Product Between Plane Normal And Ray Direction 
  
 ;Determine If Ray Parallel To Plane 
 If DotProduct<#ZERO And DotProduct>-#ZERO 
  ProcedureReturn 0 
 EndIf 
  
 TVector_subtract(result,*plane\_Position,*position) ;result=plane\_Position-position 
 l2=TVector_dot(*plane\_Normal,result)/DotProduct ;Find Distance To Collision Point 
  
 If l2<-#ZERO ;Test If Collision Behind Start 
  ProcedureReturn 0 
 EndIf 
  
 TVector_set(*pNormal,*plane\_Normal) ;pNormal=plane\_Normal 
 *lamda\d=l2 
 ProcedureReturn 1 
  
EndProcedure 

;Fast Intersection Function Between Ray / Cylinder 

Procedure TestIntersionCylinder(*cylinder.CYLINDER,*position.TVECTOR,*direction.TVECTOR,*lamda.DOUBLE,*pNormal.TVECTOR,*newposition.TVECTOR) 

 Protected d.d,t.d,s.d,ln.d,IN.d,OUT.d 
 Protected RC.TVECTOR,NV.TVECTOR,OV.TVECTOR,HB.TVECTOR 
  
 TVector_subtract(RC,*position,*cylinder\_Position) 
 TVector_cross(NV,*direction,*cylinder\_Axis) 
  
 ln=TVector_mag(NV) 
  
 If ln<#ZERO And ln>-#ZERO 
  ProcedureReturn 0 
 EndIf 
  
 TVector_unit(NV) 
  
 d=Abs(TVector_dot(RC,NV)) 
  
 If d<=*cylinder\_Radius 
  
  TVector_cross(OV,RC,*cylinder\_Axis) 
  t=-TVector_dot(OV,NV)/ln 
  TVector_cross(OV,NV,*cylinder\_Axis) 
  TVector_unit(OV) 
  s=Abs(Sqr(*cylinder\_Radius**cylinder\_Radius-d*d)/TVector_dot(*direction,OV)) 
  
  IN=t-s 
  OUT=t+s 
  
  If IN<-#ZERO 
   If OUT<-#ZERO 
    ProcedureReturn 0 
   Else 
    *lamda\d=OUT 
   EndIf 
  Else 
     If OUT<-#ZERO 
   *lamda\d=IN 
   Else 
    If IN<OUT 
     *lamda\d=IN 
    Else 
     *lamda\d=OUT 
    EndIf 
   EndIf 
  EndIf 
  
  TVector_add(*newposition,*position,TVector_multiply(*newposition,*direction,*lamda\d)) ;newposition=position+(direction*lamda) 
  TVector_subtract(HB,*newposition,*cylinder\_Position) ;HB=newposition-cylinder\_Position 
  TVector_subtract(*pNormal,HB,TVector_multiply(*pNormal,*cylinder\_Axis,TVector_dot(HB,*cylinder\_Axis))) ;pNormal=HB-cylinder\_Axis*(HB.dot(cylinder\_Axis)) 
  TVector_unit(*pNormal) 
  
  ProcedureReturn 1 
  
 EndIf 
  
 ProcedureReturn 0 
  
EndProcedure 

;Find If Any Of The Current Balls Intersect With Eachother In The Current Timestep 
;Returns The Index Of The 2 Intersecting Balls, The Point And Time Of Intersection 

Procedure FindBallCol(*point.TVECTOR,*TimePoint.DOUBLE,Time2.d,*BallNr1.INTEGER,*BallNr2.INTEGER) 

 Protected RelativeV.TVECTOR,posi.TVECTOR 
 Protected rays.TRAY 
 Protected MyTime.d=0.0,ADD.d=Time2/150.0 
 Protected Timedummy.d=10000,Timedummy2.d=-1 
 Protected i.i,j.i 
  
 ;Test All Balls Against Eachother In 150 Small Steps 
 For i=0 To (NrOfBalls-1)-1 
  For j=i+1 To NrOfBalls-1 
  
   TVector_subtract(RelativeV,ArrayVel(i),ArrayVel(j)) ;Find Distance 
   TRay_setunit(rays,OldPos(i),TVector_unit(RelativeV)) 
   MyTime=0.0 
    
   If TRay_pointdist(rays,OldPos(j))>40 ;If Distance Between Centers Greater Than 2*radius 
    Continue ;No Intersection Occurred 
   EndIf 
    
   While MyTime<Time2 ;Loop To Find The Exact Intersection Point 
    MyTime+ADD 
    TVector_add(posi,OldPos(i),TVector_multiply(posi,RelativeV,MyTime)) ;posi=OldPos(i)+(RelativeV*MyTime) 
    If TVector_dist(posi,OldPos(j))<=40 
     TVector_set(*point,posi) ;point=posi 
     If Timedummy>MyTime-ADD And MyTime-ADD<>0 ;Note: added zero check 
      Timedummy=MyTime-ADD 
     EndIf 
     *BallNr1\i=i 
     *BallNr2\i=j 
     Break 
    EndIf 
   Wend 
    
  Next 
 Next 
  
 If Timedummy<>10000 
  *TimePoint\d=Timedummy 
  ProcedureReturn 1 
 EndIf 
  
 ProcedureReturn 0 
  
EndProcedure 

;Moves, Finds The Collisions And Responses Of The Objects In The Current Time Step 

Procedure idle() ;Main Loop Of The Simulation 

 Protected rt.d,rt2.d,rt4.d,lamda.d=10000 
 Protected norm.TVECTOR,uveloc.TVECTOR 
 Protected normal.TVECTOR,point.TVECTOR 
 Protected RestTime.d,BallTime.d 
 Protected Pos2.TVECTOR,Nc.TVECTOR,tv.TVECTOR 
 Protected BallNr.i=0,BallColNr1.i,BallColNr2.i 
 Protected i.i,j.l 
  
 If hook_toball1=0 
  camera_rotation+0.1 
  If camera_rotation>360 
   camera_rotation=0 
  EndIf 
 EndIf 
  
 RestTime=Time 
 lamda=1000 
  
 ;Compute Velocity For Next Timestep Using Euler Equations 
 For j=0 To NrOfBalls-1 
  TVector_add(ArrayVel(j),ArrayVel(j),TVector_multiply(tv,accel,RestTime)) ;ArrayVel(j)+=accel*RestTime 
 Next 
  
 ;While Time Step Not Over 
 While RestTime>#ZERO 
  
  lamda=10000 ;Initialize To Very Large Value 
  
  ;For All The Balls Find Closest Intersection Between Balls And Planes / Cylinders 
  For i=0 To NrOfBalls-1 
  
   ;Compute New Position And Distance 
   TVector_set(OldPos(i),ArrayPos(i)) 
   TVector_setunit(uveloc,ArrayVel(i)) 
   TVector_add(ArrayPos(i),ArrayPos(i),TVector_multiply(tv,ArrayVel(i),RestTime)) ;ArrayPos(i)+=ArrayVel(i)*RestTime 
   rt2=TVector_dist(OldPos(i),ArrayPos(i)) 
    
   ;Test If Collision Occured Between Ball And All 5 Planes 
   If TestIntersionPlane(pl1,OldPos(i),uveloc,@rt,norm) 
    rt4=rt*RestTime/rt2 ;Find Intersection Time 
    If rt4<=lamda ;If Smaller Than The One Already Stored Replace In Timestep 
     ;If Intersection Time In Current Time Step 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_add(point,OldPos(i),TVector_multiply(tv,uveloc,rt)) ;point=OldPos(i)+(uveloc*rt) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionPlane(pl2,OldPos(i),uveloc,@rt,norm) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_add(point,OldPos(i),TVector_multiply(tv,uveloc,rt)) ;point=OldPos(i)+(uveloc*rt) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionPlane(pl3,OldPos(i),uveloc,@rt,norm) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_add(point,OldPos(i),TVector_multiply(tv,uveloc,rt)) ;point=OldPos(i)+(uveloc*rt) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionPlane(pl4,OldPos(i),uveloc,@rt,norm) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_add(point,OldPos(i),TVector_multiply(tv,uveloc,rt)) ;point=OldPos(i)+(uveloc*rt) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionPlane(pl5,OldPos(i),uveloc,@rt,norm) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_add(point,OldPos(i),TVector_multiply(tv,uveloc,rt)) ;point=OldPos(i)+(uveloc*rt) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   ;Now Test Intersection With The 3 Cylinders 
   If TestIntersionCylinder(cyl1,OldPos(i),uveloc,@rt,norm,Nc) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_set(point,Nc) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionCylinder(cyl2,OldPos(i),uveloc,@rt,norm,Nc) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_set(point,Nc) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
   If TestIntersionCylinder(cyl3,OldPos(i),uveloc,@rt,norm,Nc) 
    rt4=rt*RestTime/rt2 
    If rt4<=lamda 
     If rt4<=RestTime+#ZERO 
      If Not (rt<=#ZERO And TVector_dot(uveloc,norm)>#ZERO) 
       TVector_set(normal,norm) 
       TVector_set(point,Nc) 
       lamda=rt4 
       BallNr=i 
      EndIf 
     EndIf 
    EndIf 
   EndIf 
    
  Next 
  
  ;After All Balls Were Tested With Planes / Cylinders Test For 
  ;Collision Between Them And Replace If Collision Time Smaller 
  If FindBallCol(Pos2,@BallTime,RestTime,@BallColNr1,@BallColNr2) 
  
    If sounds
      PlaySound(0)
    EndIf 
    
   If lamda=10000 Or lamda>BallTime 
   RestTime=RestTime-BallTime 
    
    Protected pb1.TVECTOR,pb2.TVECTOR,xaxis.TVECTOR 
    Protected U1x.TVECTOR,U1y.TVECTOR,U2x.TVECTOR,U2y.TVECTOR 
    Protected V1x.TVECTOR,V1y.TVECTOR,V2x.TVECTOR,V2y.TVECTOR 
    Protected a.d,b.d 
    
    ;Find Positions Of Ball1 And Ball2 
    TVector_add(pb1,OldPos(BallColNr1),TVector_multiply(tv,ArrayVel(BallColNr1),BallTime)) ;pb1=OldPos(BallColNr1)+(ArrayVel(BallColNr1)*BallTime) 
    TVector_add(pb2,OldPos(BallColNr2),TVector_multiply(tv,ArrayVel(BallColNr2),BallTime)) ;pb2=OldPos(BallColNr2)+(ArrayVel(BallColNr2)*BallTime) 
    
    TVector_set(xaxis,TVector_unit(TVector_subtract(tv,pb2,pb1))) ;Find X-Axis 
    a=TVector_dot(xaxis,ArrayVel(BallColNr1)) ;Find Projection 
    TVector_multiply(U1x,xaxis,a) ;Find Projected Vectors 
    TVector_subtract(U1y,ArrayVel(BallColNr1),U1x) ;U1y=ArrayVel(BallColNr1)-U1x 
    
    ;Do The Same As Above To Find Projection Vectors For The Other Ball 
    TVector_set(xaxis,TVector_unit(TVector_subtract(tv,pb1,pb2))) ;xaxis=(pb1-pb2).unit() 
    b=TVector_dot(xaxis,ArrayVel(BallColNr2)) 
    TVector_multiply(U2x,xaxis,b) ;U2x=xaxis*b 
    TVector_subtract(U2y,ArrayVel(BallColNr2),U2x) ;U2y=ArrayVel(BallColNr2)-U2x 
    
    ;Now Find New Velocities 
    TVector_add(V1x,U1x,TVector_subtract(tv,U2x,TVector_subtract(tv,U1x,U2x))) 
    TVector_multiply(V1x,V1x,0.5) ;V1x=(U1x+U2x-(U1x-U2x))*0.5 
    TVector_add(V2x,U1x,TVector_subtract(tv,U2x,TVector_subtract(tv,U2x,U1x))) 
    TVector_multiply(V2x,V2x,0.5) ;V2x=(U1x+U2x-(U2x-U1x))*0.5 
    TVector_set(V1y,U1y) ;V1y=U1y 
    TVector_set(V2y,U2y) ;V2y=U2y 
    
    For j=0 To NrOfBalls-1 ;Update All Ball Positions 
     TVector_add(ArrayPos(j),OldPos(j),TVector_multiply(tv,ArrayVel(j),BallTime)) ;ArrayPos(j)=OldPos(j)+(ArrayVel(j)*BallTime) 
    Next 
    
    ;Set New Velocity Vectors To The Colliding Balls 
    TVector_add(ArrayVel(BallColNr1),V1x,V1y) ;ArrayVel(BallColNr1)=V1x+V1y 
    TVector_add(ArrayVel(BallColNr2),V2x,V2y) ;ArrayVel(BallColNr2)=V2x+V2y 
    
    ;Update Explosion Array 
    For j=0 To 20-1 
     If ExplosionArray(j)\_Alpha<=0 
      ExplosionArray(j)\_Alpha=1 
      TVector_set(ExplosionArray(j)\_Position,ArrayPos(BallColNr1)) 
      ExplosionArray(j)\_Scale=1 
      Break 
     EndIf 
    Next 
    
    Continue 
   EndIf 
    
  EndIf 
  
  ;End Of Tests 
  ;If Collision Occured Move Simulation For The Correct Timestep 
  ;And Compute Response For The Colliding Ball 
  If lamda<>10000 
   RestTime-lamda 
    
   For j=0 To NrOfBalls-1 
    TVector_add(ArrayPos(j),OldPos(j),TVector_multiply(tv,ArrayVel(j),lamda)) ;ArrayPos(j)=OldPos(j)+(ArrayVel(j)*lamda) 
   Next 
    
   rt2=TVector_mag(ArrayVel(BallNr)) ;Find Magnitude Of Velocity 
   TVector_unit(ArrayVel(BallNr)) ;Normalize It 
    
   ;Compute Reflection 
   TVector_add(tv,ArrayVel(BallNr),TVector_multiply(tv,normal,2*TVector_dot(normal,TVector_invert(tv,ArrayVel(BallNr))))) 
   TVector_set(ArrayVel(BallNr),TVector_unit(tv)) ;ArrayVel(BallNr)=TVector_unit(ArrayVel(BallNr)+(normal * (2*TVector_dot(normal,-ArrayVel(BallNr))) )) 
    
   TVector_multiply(ArrayVel(BallNr),ArrayVel(BallNr),rt2) ;Multiply With Magnitude To Obtain Final Velocity Vector 
    
   ;Update Explosion Array And Insert Explosion 
   For j=0 To 20-1 
    If ExplosionArray(j)\_Alpha<=0 
     ExplosionArray(j)\_Alpha=1 
     TVector_set(ExplosionArray(j)\_Position,point) 
     ExplosionArray(j)\_Scale=1 
     Break 
    EndIf 
   Next 
    
  Else 
   RestTime=0 
  EndIf 
  
 Wend ;End Of While Loop 
  
EndProcedure 


Procedure DrawScene(Gadget)
 
 Protected i.i
  
 SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix 
 glLoadIdentity_() ;Reset The Modelview Matrix 
  
 ;Set Camera In Hookmode 
 If hook_toball1 
  Protected unit_followvector.TVECTOR 
  TVector_set(unit_followvector,ArrayVel(0)) ;unit_followvector=ArrayVel(0) 
  TVector_unit(unit_followvector) 
  gluLookAt_(ArrayPos(0)\_x+250,ArrayPos(0)\_y+250,ArrayPos(0)\_z,ArrayPos(0)\_x+ArrayVel(0)\_x,ArrayPos(0)\_y+ArrayVel(0)\_y,ArrayPos(0)\_z+ArrayVel(0)\_z,0.0,1.0,0.0) 
 Else 
  gluLookAt_(pos\_x,pos\_y,pos\_z,pos\_x+dir\_x,pos\_y+dir\_y,pos\_z+dir\_z,0.0,1.0,0.0) 
 EndIf 
  
 glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT) ;Clear Screen And Depth Buffer 
 glRotatef_(camera_rotation,0.0,1.0,0.0) ;Rotate On The Y Axis 
  
 ;Render Balls 
 For i=0 To NrOfBalls-1 
  Select i 
   Case 1 : glColor3f_(1.0,1.0,1.0) ;white 
   Case 2 : glColor3f_(1.0,1.0,0.0) ;yellow 
   Case 3 : glColor3f_(0.0,1.0,1.0) ;cyan 
   Case 4 : glColor3f_(0.0,1.0,0.0) ;green 
   Case 5 : glColor3f_(0.0,0.0,1.0) ;blue 
   Case 6 : glColor3f_(0.6,0.2,0.3) ;dark red 
   Case 7 : glColor3f_(1.0,0.0,1.0) ;purple 
   Case 8 : glColor3f_(0.0,0.7,0.4) ;dark green 
   Case 9 : glColor3f_(0.5,0.4,0.0) ;brown 
   Default : glColor3f_(1.0,0.0,0.0) ;red 
  EndSelect 
  glPushMatrix_() 
   glTranslated_(ArrayPos(i)\_x,ArrayPos(i)\_y,ArrayPos(i)\_z) ;Position Ball 
   gluSphere_(cylinder_obj,20.0,20,20) 
  glPopMatrix_() 
 Next 
  
 glEnable_(#GL_TEXTURE_2D) ;Enable Texture Mapping 
  
 ;Render Walls (Planes) With Texture 
 glBindTexture_(#GL_TEXTURE_2D,texture(3)) 
 glColor3f_(1.0,1.0,1.0) ;white 
 glBegin_(#GL_QUADS) 
  ;Front Face 
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 320.0, 320.0, 320.0) 
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 320.0,-320.0, 320.0) 
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-320.0,-320.0, 320.0) 
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-320.0, 320.0, 320.0) 
  ;Back Face 
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-320.0, 320.0,-320.0) 
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-320.0,-320.0,-320.0) 
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 320.0,-320.0,-320.0) 
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 320.0, 320.0,-320.0) 
  ;Right Face 
  glTexCoord2f_(1.0, 0.0) : glVertex3f_( 320.0, 320.0,-320.0) 
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 320.0,-320.0,-320.0) 
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 320.0,-320.0, 320.0) 
  glTexCoord2f_(0.0, 0.0) : glVertex3f_( 320.0, 320.0, 320.0) 
  ;Left Face 
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-320.0, 320.0, 320.0) 
  glTexCoord2f_(1.0, 1.0) : glVertex3f_(-320.0,-320.0, 320.0) 
  glTexCoord2f_(0.0, 1.0) : glVertex3f_(-320.0,-320.0,-320.0) 
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-320.0, 320.0,-320.0) 
 glEnd_() 
  
 ;Render Floor (Plane) With Colours 
 glBindTexture_(#GL_TEXTURE_2D,texture(2)) 
 glBegin_(#GL_QUADS) 
  ;Bottom Face 
  glTexCoord2f_(1.0, 0.0) : glVertex3f_(-320.0,-320.0, 320.0) 
  glTexCoord2f_(1.0, 1.0) : glVertex3f_( 320.0,-320.0, 320.0) 
  glTexCoord2f_(0.0, 1.0) : glVertex3f_( 320.0,-320.0,-320.0) 
  glTexCoord2f_(0.0, 0.0) : glVertex3f_(-320.0,-320.0,-320.0) 
 glEnd_() 
  
 ;Render Columns (Cylinders) 
 glBindTexture_(#GL_TEXTURE_2D,texture(0)) ;Choose The Texture To Use 
 glColor3f_(0.5,0.5,0.5) ;grey 
 glPushMatrix_() 
 glRotatef_(90.0,1.0,0.0,0.0) ;Rotate On The X Axis By 90 
 glTranslatef_(0.0,0.0,-500.0) ;Move Away 500 
 gluCylinder_(cylinder_obj,60.0,60.0,1000.0,20,2) 
 glPopMatrix_() 
  
 glPushMatrix_() 
  glTranslatef_(200.0,-300.0,-500.0) ;Move Right 200, Down 300 And Away 500 
  gluCylinder_(cylinder_obj,60.0,60.0,1000.0,20,2) 
 glPopMatrix_() 
  
 glPushMatrix_() 
  glTranslatef_(-200.0,0.0,0.0) ;Move Left 200 
  glRotatef_(135.0,1.0,0.0,0.0) ;Rotate On The X Axis By 135 
  glTranslatef_(0.0,0.0,-500.0) ;Move Away 500 
  gluCylinder_(cylinder_obj,30.0,30.0,1000.0,20,2) 
 glPopMatrix_() 
  
 ;Render / Blend Explosions 
 glEnable_(#GL_BLEND) ;Enable Blending 
 glDepthMask_(#GL_FALSE) ;Disable Depth Buffer Writes 
 glBindTexture_(#GL_TEXTURE_2D,texture(1)) ;Upload Texture 
 For i=0 To 20-1 ;Update And Render Explosions 
  If ExplosionArray(i)\_Alpha>=0 
   glPushMatrix_() 
    ExplosionArray(i)\_Alpha-0.01 ;Update Alpha 
    ExplosionArray(i)\_Scale+0.03 ;Update Scale 
    glColor4f_(1.0,1.0,0.0,ExplosionArray(i)\_Alpha) ;Assign Vertices Colour Yellow With Alpha 
    glScalef_(ExplosionArray(i)\_Scale,ExplosionArray(i)\_Scale,ExplosionArray(i)\_Scale) ;Scale 
    ;Translate Into Position Taking Into Account The Offset Caused By The Scale 
    glTranslatef_(ExplosionArray(i)\_Position\_x/ExplosionArray(i)\_Scale,ExplosionArray(i)\_Position\_y/ExplosionArray(i)\_Scale,ExplosionArray(i)\_Position\_z/ExplosionArray(i)\_Scale) 
    glCallList_(dlist) ;Call Display List 
   glPopMatrix_() 
  EndIf 
 Next 
  
 glDepthMask_(#GL_TRUE) ;Enable Depth Mask 
 glDisable_(#GL_BLEND) ;Disable Blending 
 glDisable_(#GL_TEXTURE_2D) ;Disable Texture Mapping 
 
 SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
 
 ProcedureReturn #True ;Keep Going 
      
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


InitVars() 

CreateGLWindow("NeHe's Collision Detection Tutorial (Lesson 30) ",640,480,16,0,1)

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
  
  If KeyboardPushed(#PB_Key_Up) And pos\_z>400 ;Up Arrow 
    pos\_z-10 
  EndIf
  
  If KeyboardPushed(#PB_Key_Down) And pos\_z<1200 ;Down Arrow 
   pos\_z+10 
  EndIf 
  
  If KeyboardPushed(#PB_Key_Left) ;Left Arrow 
   camera_rotation+2 
  EndIf 
  
  If KeyboardPushed(#PB_Key_Right) ;Right Arrow 
   camera_rotation-2 
  EndIf 
  
  If KeyboardPushed(#PB_Key_Add) And Time<2.5 And Addp=0;Numpad + Key 
    Addp=#True
    Time+0.1 
  ElseIf Not KeyboardPushed(#PB_Key_Add)
   Addp=#False 
 EndIf 
  
 If KeyboardPushed(#PB_Key_Subtract) And Time>0.0 And Subp = 0;Numpad - Key 
   Subp = #True
   Time-0.1 
 ElseIf Not KeyboardPushed(#PB_Key_Subtract)
   Subp=#False 
 EndIf 
  
 If KeyboardPushed(#PB_Key_F2) And F2p=0 ;F2 Key 
   F2p=#True
   hook_toball1=~hook_toball1 & 1 ;Toggle Hook Camera To Ball 
   camera_rotation=0 
 ElseIf Not KeyboardPushed(#PB_Key_F2)
   F2p=#False 
 EndIf
 
 If KeyboardPushed(#PB_Key_F3) And F3p=0;F3 Key 
   F3p=#True
   sounds=~sounds & 1 ;Toggle Sound 
 ElseIf Not KeyboardPushed(#PB_Key_F3)
   F3p=#False 
 EndIf   
  idle()
  DrawScene(0)
  
Until Quit = 1
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 662
; FirstLine = 639
; Folding = --
; EnableAsm
; EnableXP