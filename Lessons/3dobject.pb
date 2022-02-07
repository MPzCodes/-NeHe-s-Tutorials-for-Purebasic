;Include File For 3D Object Handling (Lesson 27)

;INFINITY For Calculating The Extension Vector For The Shadow Volume
;#INFINITY=100 ;Note: was used in doShadowPass()

Structure POINT3F ;Structure Describing An Object's Vertex
 x.f : y.f : z.f
EndStructure

Structure PLANE ;Structure Describing A Plane
 a.f : b.f : c.f : d.f ;Equation In The Format: ax + by + cz + d = 0
EndStructure

Structure FACE ;Structure Describing An Object's Face
 vert.l[3] ;Index Of Each Vertex That Makes Up The Triangle Of This Face
 normals.POINT3F[3] ;Normals To Each Vertex
 planeEq.PLANE ;Equation Of A Plane That Contains This Triangle
 neigh.l[3] ;Index Of Each Face That Neighbours This One
 visible.b ;Is The Face Visible By The Light?
EndStructure

Structure SHADOWEDOBJECT ;Shadowed Object Structure
 nVerts.l ;Number Of Vertices
 pVerts.i ;Pointer To Vertices, Dynamically Allocated
 nFaces.l ;Number Of Faces
 pFaces.i ;Pointer To Faces, Dynamically Allocated
EndStructure

Procedure.s readstr(f.i) ;Reads A String From File

 Protected string.s
 While Left(string,1)="/" Or Left(string,1)=""
  string=ReadString(f)
 Wend
 ProcedureReturn string
 
EndProcedure

Procedure readObject(filename.s,*o.SHADOWEDOBJECT) ;Load Object

 Protected file.i,i.l
 Protected fsize.l,vsize.l,normals.l
 Protected oneline.s,char.s,pos.l,count.l
 
 file=ReadFile(#PB_Any,filename)
 
 If file=0
  ProcedureReturn #False
 EndIf
 
 fsize=SizeOf(FACE) ;77
 vsize=SizeOf(POINT3F) ;12
 normals=OffsetOf(FACE\normals) ;12
 
 ;Read Vertices
 *o\nVerts=Val(readstr(file))
 *o\pVerts=AllocateMemory((*o\nVerts+1)*vsize)
 For i=1 To *o\nVerts
  oneline=readstr(file)
 
  count=0 : char=""
  For pos=1 To Len(oneline)
   If Mid(oneline,pos,1)<>" " : char=char+Mid(oneline,pos,1) : EndIf
   If Len(char)>0 And (Mid(oneline,pos,1)=" " Or pos=Len(oneline))
    Select count
     Case 0 : PokeF(*o\pVerts+(i*vsize),ValF(char)) ;pVerts[i]\x
     Case 1 : PokeF(*o\pVerts+(i*vsize)+4,ValF(char)) ;pVerts[i]\y
     Case 2 : PokeF(*o\pVerts+(i*vsize)+8,ValF(char)) ;pVerts[i]\z
    EndSelect
    count=count+1 : char=""
   EndIf
  Next
 
 Next
 
 ;Read Faces
 *o\nFaces=Val(readstr(file))
 *o\pFaces=AllocateMemory(*o\nFaces*fsize)
 For i=0 To *o\nFaces-1
  oneline=readstr(file)
 
  count=0 : char=""
  For pos=1 To Len(oneline)
   If Mid(oneline,pos,1)<>" " : char=char+Mid(oneline,pos,1) : EndIf
   If Len(char)>0 And (Mid(oneline,pos,1)=" " Or pos=Len(oneline))
    Select count
     Case 0 : PokeL(*o\pFaces+(i*fsize),Val(char)) ;pFaces[i]\vert[0]
     Case 1 : PokeL(*o\pFaces+(i*fsize)+4,Val(char)) ;pFaces[i]\vert[1]
     Case 2 : PokeL(*o\pFaces+(i*fsize)+8,Val(char)) ;pFaces[i]\vert[2]
     
     Case 3 : PokeF(*o\pFaces+(i*fsize)+normals,ValF(char)) ;pFaces[i]\normals[0]\x
     Case 4 : PokeF(*o\pFaces+(i*fsize)+normals+4,ValF(char)) ;pFaces[i]\normals[0]\y
     Case 5 : PokeF(*o\pFaces+(i*fsize)+normals+8,ValF(char)) ;pFaces[i]\normals[0]\z
     Case 6 : PokeF(*o\pFaces+(i*fsize)+normals+12,ValF(char)) ;pFaces[i]\normals[1]\x
     Case 7 : PokeF(*o\pFaces+(i*fsize)+normals+16,ValF(char)) ;pFaces[i]\normals[1]\y
     Case 8 : PokeF(*o\pFaces+(i*fsize)+normals+20,ValF(char)) ;pFaces[i]\normals[1]\z
     Case 9 : PokeF(*o\pFaces+(i*fsize)+normals+24,ValF(char)) ;pFaces[i]\normals[2]\x
     Case 10 : PokeF(*o\pFaces+(i*fsize)+normals+28,ValF(char)) ;pFaces[i]\normals[2]\y
     Case 11 : PokeF(*o\pFaces+(i*fsize)+normals+32,ValF(char)) ;pFaces[i]\normals[2]\z
    EndSelect
    count=count+1 : char=""
   EndIf
  Next
 
 Next
 
 ProcedureReturn #True
 
EndProcedure

Procedure killObject(*o.SHADOWEDOBJECT) ;Free Object Data

 If *o\pFaces
  FreeMemory(*o\pFaces)
 EndIf
 *o\pFaces=#Null
 *o\nFaces=0
 
 If *o\pVerts
  FreeMemory(*o\pVerts)
 EndIf
 *o\pVerts=#Null
 *o\nVerts=0
 
EndProcedure

Procedure setConnectivity(*o.SHADOWEDOBJECT) ;Connectivity Procedure - Based On Gamasutra's Article

 Protected p1i.l,p2i.l,p1j.l,p2j.l
 Protected cP1i.l,cP2i.l,cP1j.l,cP2j.l
 Protected i.l,j.l,ki.l,kj.l
 Protected fsize.l,neigh.l
 
 fsize=SizeOf(FACE) ;77
 neigh=OffsetOf(FACE\neigh) ;64
 
 For i=0 To (*o\nFaces-1)-1
  For j=i+1 To *o\nFaces-1
   For ki=0 To 3-1
    If PeekL(*o\pFaces+(i*fsize)+neigh+(ki*4))=0 ;pFaces[i]\neigh[ki]
     For kj=0 To 3-1
      p1i=ki
      p1j=kj
      p2i=(ki+1) % 3
      p2j=(kj+1) % 3
     
      p1i=PeekL(*o\pFaces+(i*fsize)+(p1i*4)) ;pFaces[i]\vert[p1i]
      p2i=PeekL(*o\pFaces+(i*fsize)+(p2i*4)) ;pFaces[i]\vert[p2i]
      p1j=PeekL(*o\pFaces+(j*fsize)+(p1j*4)) ;pFaces[j]\vert[p1j]
      p2j=PeekL(*o\pFaces+(j*fsize)+(p2j*4)) ;pFaces[j]\vert[p2j]
     
      cP1i=((p1i+p2i)-Abs(p1i-p2i))/2
      cP2i=((p1i+p2i)+Abs(p1i-p2i))/2
      cP1j=((p1j+p2j)-Abs(p1j-p2j))/2
      cP2j=((p1j+p2j)+Abs(p1j-p2j))/2
     
      If cP1i=cP1j And cP2i=cP2j ;Check If They Are Neighbours - I.E. The Edges Are The Same
       PokeL(*o\pFaces+(i*fsize)+neigh+(ki*4),j+1) ;pFaces[i]\neigh[ki]
       PokeL(*o\pFaces+(j*fsize)+neigh+(kj*4),i+1) ;pFaces[j]\neigh[kj]
      EndIf
     Next
    EndIf
   Next
  Next
 Next
 
EndProcedure

Procedure drawObject(*o.SHADOWEDOBJECT) ;Draw An Object - Simply Draw Each Triangular Face

 Protected i.l,j.l,vi.l
 Protected fsize.l,vsize.l,normals.l
 Protected v.POINT3F
 
 fsize=SizeOf(FACE) ;77
 vsize=SizeOf(POINT3F) ;12
 normals=OffsetOf(FACE\normals) ;12
 
 glBegin_(#GL_TRIANGLES)
 For i=0 To *o\nFaces-1
  For j=0 To 3-1
   v\x=PeekF(*o\pFaces+(i*fsize)+normals+(j*vsize)) ;pFaces[i]\normals[j]\x
   v\y=PeekF(*o\pFaces+(i*fsize)+normals+(j*vsize)+4) ;pFaces[i]\normals[j]\y
   v\z=PeekF(*o\pFaces+(i*fsize)+normals+(j*vsize)+8) ;pFaces[i]\normals[j]\z
   glNormal3f_(v\x,v\y,v\z)
   vi=PeekL(*o\pFaces+(i*fsize)+(j*4)) ;pFaces[i]\vert[j]
   v\x=PeekF(*o\pVerts+(vi*vsize)) ;pVerts[pFaces[i]\vert[j]]\x
   v\y=PeekF(*o\pVerts+(vi*vsize)+4) ;pVerts[pFaces[i]\vert[j]]\y
   v\z=PeekF(*o\pVerts+(vi*vsize)+8) ;pVerts[pFaces[i]\vert[j]]\z
   glVertex3f_(v\x,v\y,v\z)
  Next
 Next
 glEnd_()
 
EndProcedure

Procedure calculatePlane(*o.SHADOWEDOBJECT,fi.l) ;Function For Computing A Plane Equation Given 3 Points

 Protected Dim v.POINT3F(4)
 Protected i.l,vi.l
 Protected fsize.l,vsize.l,planeEq.l
 Protected plEq.PLANE
 
 fsize=SizeOf(FACE) ;77
 vsize=SizeOf(POINT3F) ;12
 planeEq=OffsetOf(FACE\planeEq) ;48
 
 For i=0 To 3-1 ;Get Shortened Names For The Vertices Of The Face
  vi=PeekL(*o\pFaces+(fi*fsize)+(i*4)) ;pFaces[fi]\vert[i]
  v(i+1)\x=PeekF(*o\pVerts+(vi*vsize)) ;pVerts[pFaces[fi]\vert[i]]\x
  v(i+1)\y=PeekF(*o\pVerts+(vi*vsize)+4) ;pVerts[pFaces[fi]\vert[i]]\y
  v(i+1)\z=PeekF(*o\pVerts+(vi*vsize)+8) ;pVerts[pFaces[fi]\vert[i]]\z
 Next
 
 plEq\a= v(1)\y*(v(2)\z-v(3)\z) + v(2)\y*(v(3)\z-v(1)\z) + v(3)\y*(v(1)\z-v(2)\z)
 plEq\b= v(1)\z*(v(2)\x-v(3)\x) + v(2)\z*(v(3)\x-v(1)\x) + v(3)\z*(v(1)\x-v(2)\x)
 plEq\c= v(1)\x*(v(2)\y-v(3)\y) + v(2)\x*(v(3)\y-v(1)\y) + v(3)\x*(v(1)\y-v(2)\y)
 plEq\d=-( v(1)\x*(v(2)\y*v(3)\z - v(3)\y*v(2)\z) + v(2)\x*(v(3)\y*v(1)\z - v(1)\y*v(3)\z) + v(3)\x*(v(1)\y*v(2)\z - v(2)\y*v(1)\z) )
 PokeF(*o\pFaces+(fi*fsize)+planeEq,plEq\a) ;pFaces[fi]\planeEq\a
 PokeF(*o\pFaces+(fi*fsize)+planeEq+4,plEq\b) ;pFaces[fi]\planeEq\b
 PokeF(*o\pFaces+(fi*fsize)+planeEq+8,plEq\c) ;pFaces[fi]\planeEq\c
 PokeF(*o\pFaces+(fi*fsize)+planeEq+12,plEq\d) ;pFaces[fi]\planeEq\d
 
EndProcedure

Procedure doShadowPass(*o.SHADOWEDOBJECT, Array lp.f(1)) ;Draw Object's Shadow

 Protected i.l,j.l,k.l,jj.l,p1.l,p2.l
 Protected fsize.l,vsize.l,neigh.l,visible.l
 Protected Dim v.POINT3F(4)
 
 fsize=SizeOf(FACE) ;77
 vsize=SizeOf(POINT3F) ;12
 neigh=OffsetOf(FACE\neigh) ;64
 visible=OffsetOf(FACE\visible) ;76
 
 For i=0 To *o\nFaces-1
  If PeekB(*o\pFaces+(i*fsize)+visible) ;pFaces[i]\visible
   For j=0 To 3-1 ;Go Through Each Edge
    k=PeekL(*o\pFaces+(i*fsize)+neigh+(j*4)) ;pFaces[i]\neigh[j]
    ;If There Is No Neighbour, Or Its Neighbouring Face Is Not Visible, Then This Edge Casts A Shadow
    If k=0 Or PeekB(*o\pFaces+((k-1)*fsize)+visible)=0 ;pFaces[k-1]\visible
   
     ;Get The Points On The Edge
     p1=PeekL(*o\pFaces+(i*fsize)+(j*4)) ;pFaces[i]\vert[j]
     jj=(j+1) % 3
     p2=PeekL(*o\pFaces+(i*fsize)+(jj*4)) ;pFaces[i]\vert[jj]
     
     v(1)\x=PeekF(*o\pVerts+(p1*vsize)) ;pVerts[p1]\x
     v(1)\y=PeekF(*o\pVerts+(p1*vsize)+4) ;pVerts[p1]\y
     v(1)\z=PeekF(*o\pVerts+(p1*vsize)+8) ;pVerts[p1]\z
     
     v(2)\x=PeekF(*o\pVerts+(p2*vsize)) ;pVerts[p2]\x
     v(2)\y=PeekF(*o\pVerts+(p2*vsize)+4) ;pVerts[p2]\y
     v(2)\z=PeekF(*o\pVerts+(p2*vsize)+8) ;pVerts[p2]\z
     
     ;Calculate The Two Vertices In Distance (INFINITY=100)
     v(3)\x=(v(1)\x-lp(0))*100 ;pVerts[p1]\x
     v(3)\y=(v(1)\y-lp(1))*100 ;pVerts[p1]\y
     v(3)\z=(v(1)\z-lp(2))*100 ;pVerts[p1]\z
     
     v(4)\x=(v(2)\x-lp(0))*100 ;pVerts[p2]\x
     v(4)\y=(v(2)\y-lp(1))*100 ;pVerts[p2]\y
     v(4)\z=(v(2)\z-lp(2))*100 ;pVerts[p2]\z
     
     ;Draw The Quadrilateral (As A Triangle Strip)
     glBegin_(#GL_TRIANGLE_STRIP)
      glVertex3f_(v(1)\x,v(1)\y,v(1)\z)
      glVertex3f_(v(1)\x+v(3)\x,v(1)\y+v(3)\y,v(1)\z+v(3)\z)
      glVertex3f_(v(2)\x,v(2)\y,v(2)\z)
      glVertex3f_(v(2)\x+v(4)\x,v(2)\y+v(4)\y,v(2)\z+v(4)\z)
     glEnd_()
     
    EndIf
   Next
  EndIf
 Next
 
EndProcedure

Procedure castShadow(*o.SHADOWEDOBJECT, Array lp.f(1)) ;Render Object's Shadow

 Protected i.l,side.f
 Protected fsize.l,planeEq.l,visible.l
 Protected plEq.PLANE
 
 fsize=SizeOf(FACE) ;77
 planeEq=OffsetOf(FACE\planeEq) ;48
 visible=OffsetOf(FACE\visible) ;76
 
 ;Determine Which Faces Are Visible By The Light
 For i=0 To *o\nFaces-1
  plEq\a=PeekF(*o\pFaces+(i*fsize)+planeEq) ;pFaces[i]\planeEq\a
  plEq\b=PeekF(*o\pFaces+(i*fsize)+planeEq+4) ;pFaces[i]\planeEq\b
  plEq\c=PeekF(*o\pFaces+(i*fsize)+planeEq+8) ;pFaces[i]\planeEq\c
  plEq\d=PeekF(*o\pFaces+(i*fsize)+planeEq+12) ;pFaces[i]\planeEq\d
  side=plEq\a*lp(0) + plEq\b*lp(1) + plEq\c*lp(2) + plEq\d*lp(3)
  If side>0
   PokeB(*o\pFaces+(i*fsize)+visible,#True) ;pFaces[i]\visible
  Else
   PokeB(*o\pFaces+(i*fsize)+visible,#False) ;pFaces[i]\visible
  EndIf
 Next
 
 glDisable_(#GL_LIGHTING) ;Turn Off Lighting
 glDepthMask_(#GL_FALSE) ;Turn Off Writing To The Depth-Buffer
 glDepthFunc_(#GL_LEQUAL)
 
 glEnable_(#GL_STENCIL_TEST) ;Turn On Stencil Buffer Testing
 glColorMask_(0,0,0,0) ;Don't Draw Into The Colour Buffer
 glStencilFunc_(#GL_ALWAYS,1,$ffffffff)
 
 ;First Pass, Stencil Operation Increases Stencil Value
 glFrontFace_(#GL_CCW)
 glStencilOp_(#GL_KEEP,#GL_KEEP,#GL_INCR)
 doShadowPass(*o,lp())
 
 ;Second Pass, Stencil Operation Decreases Stencil Value
 glFrontFace_(#GL_CW)
 glStencilOp_(#GL_KEEP,#GL_KEEP,#GL_DECR)
 doShadowPass(*o,lp())
 
 glFrontFace_(#GL_CCW)
 glColorMask_(1,1,1,1) ;Enable Rendering To Colour Buffer For All Components
 
 ;Draw A Shadowing Rectangle Covering The Entire Screen
 glColor4f_(0.0,0.0,0.0,0.4)
 glEnable_(#GL_BLEND)
 glBlendFunc_(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
 glStencilFunc_(#GL_NOTEQUAL,0,$ffffffff)
 glStencilOp_(#GL_KEEP,#GL_KEEP,#GL_KEEP)
 glPushMatrix_()
 glLoadIdentity_()
 glBegin_(#GL_TRIANGLE_STRIP)
  glVertex3f_(-0.1, 0.1,-0.1)
  glVertex3f_(-0.1,-0.1,-0.1)
  glVertex3f_( 0.1, 0.1,-0.1)
  glVertex3f_( 0.1,-0.1,-0.1)
 glEnd_()
 glPopMatrix_()
 glDisable_(#GL_BLEND)
 
 glDepthFunc_(#GL_LEQUAL)
 glDepthMask_(#GL_TRUE)
 glEnable_(#GL_LIGHTING)
 glDisable_(#GL_STENCIL_TEST)
 glShadeModel_(#GL_SMOOTH)
 
EndProcedure
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; FirstLine = 291
; Folding = --
; EnableAsm
; EnableXP