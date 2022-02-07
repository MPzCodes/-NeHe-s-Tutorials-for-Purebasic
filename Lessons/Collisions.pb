
;Include File For Collisions (Lesson 30) 

;Mathex.h 

#EPSILON=1.0e-8 ;General maths constants 
#ZERO=#EPSILON 
#M_PI=3.1415926535 

Procedure.d T_limit(x.d,lower.d,upper.d) ;Limit range of value 
 If x<lower 
  ProcedureReturn lower 
 EndIf 
 If x>upper 
  ProcedureReturn upper 
 EndIf 
 ProcedureReturn x 
EndProcedure 

Procedure.d T_sqr(x.d) ;Square of value (power of 2) 
 ProcedureReturn x*x 
EndProcedure 

Procedure.d T_RadToDeg(rad.d) ;Convert radian to degree 
 ProcedureReturn ((rad*180.0)/#M_PI) 
EndProcedure 

Procedure.d T_DegToRad(deg.d) ;Convert degree to radian 
 ProcedureReturn ((deg*#M_PI)/180.0) 
EndProcedure 

;Structures 

Structure TVECTOR ;Vector (point or direction) 
 _x.d : _y.d : _z.d : _Status.i 
EndStructure 

Structure TRAY ;Line or Ray 
 _P.TVECTOR ;Any point on the line 
 _V.TVECTOR ;Direction of the line 
EndStructure 

Structure TMATRIX33 ;Matrix (3 by 3) 
 _Mx.d[3*3] 
EndStructure 

;TVector.h, TVector.cpp 

;#INVALID=0 ;TVector constants (Note: I've used numbers instead) 
;#DEFAULT=1 
;#UNIT=2 

;Constructors 

Procedure TVector_reset(*this.TVECTOR) ;this=0,0,0,#INVALID 
 *this\_x=0.0 
 *this\_y=0.0 
 *this\_z=0.0 
 *this\_Status=0 ;#INVALID 
EndProcedure 

Procedure TVector_make(*this.TVECTOR,x.d,y.d,z.d) ;this=x,y,z,#DEFAULT 
 *this\_x=x 
 *this\_y=y 
 *this\_z=z 
 *this\_Status=1 ;#DEFAULT 
EndProcedure 

Procedure TVector_set(*this.TVECTOR,*v.TVECTOR) ;this=v 
 *this\_x=*v\_x 
 *this\_y=*v\_y 
 *this\_z=*v\_z 
 *this\_Status=*v\_Status 
EndProcedure 

Declare.b TRay_adjacentPoints(*this.TRAY,*ray.TRAY,*point1.TVECTOR,*point2.TVECTOR) 

;Mid point between two lines 

Procedure TVector_midpoint(*this.TVECTOR,*ray1.TRAY,*ray2.TRAY) ;Mid point between two rays 

 Protected point1.TVECTOR,point2.TVECTOR 
 If TRay_adjacentPoints(*ray1,*ray2,point1,point2) 
  *this\_x=(point1\_x+point2\_x)*0.5 
  *this\_y=(point1\_y+point2\_y)*0.5 
  *this\_z=(point1\_z+point2\_z)*0.5 
 Else 
  TVector_reset(*this) 
 EndIf 
  
EndProcedure 

;Selectors 

Procedure.d TVector_X(*this.TVECTOR) ;d=this\_x 
 ProcedureReturn *this\_x 
EndProcedure 

Procedure.d TVector_Y(*this.TVECTOR) ;d=this\_y 
 ProcedureReturn *this\_y 
EndProcedure 

Procedure.d TVector_Z(*this.TVECTOR) ;d=this\_z 
 ProcedureReturn *this\_z 
EndProcedure 

Procedure TVector_isUnit(*this.TVECTOR) ;this\_Status=#UNIT 
 If *this\_Status=2 
  ProcedureReturn *this\_Status 
 EndIf 
EndProcedure 

Procedure TVector_isDefault(*this.TVECTOR) ;this\_Status=#DEFAULT 
 If *this\_Status=1 
  ProcedureReturn *this\_Status 
 EndIf 
EndProcedure 

Procedure TVector_isValid(*this.TVECTOR) ;this\_Status<>INVALID 
 If *this\_Status<>0 
  ProcedureReturn *this\_Status 
 EndIf 
EndProcedure 

Declare.d TVector_mag(*this.TVECTOR) 

;Change the status of a vector 

Procedure TVector_unit(*this.TVECTOR) ;Make a unit vector 

 If TVector_isDefault(*this) 
  Protected REP.d=TVector_mag(*this) 
  If REP<#EPSILON 
   *this\_x=0.0 
   *this\_y=0.0 
   *this\_z=0.0 
  Else 
   Protected temp.d=1.0/REP 
   *this\_x*temp 
   *this\_y*temp 
   *this\_z*temp 
  EndIf 
  *this\_Status=2 ;#UNIT 
 EndIf 
 ProcedureReturn *this 
  
EndProcedure 

Procedure TVector_setunit(*result.TVECTOR,*v.TVECTOR) 
 TVector_set(*result,*v) ;result=v 
 ProcedureReturn TVector_unit(*result) ;result.unit() 
EndProcedure 

Procedure TVector_default(*this.TVECTOR) ;Make a default vector 

 If TVector_isUnit(*this) 
  *this\_Status=1 ;#DEFAULT 
 EndIf 
 ProcedureReturn *this 
  
EndProcedure 

Procedure TVector_setdefault(*result.TVECTOR,*v.TVECTOR) 
 TVector_set(*result,*v) ;result=v 
 ProcedureReturn TVector_default(*result) ;result.default() 
EndProcedure 

;Magnitude 

Procedure.d TVector_mag(*this.TVECTOR) 
 If TVector_isValid(*this) 
  If TVector_isUnit(*this) 
   ProcedureReturn 1.0 
  Else 
   ProcedureReturn Sqr(T_sqr(*this\_x) + T_sqr(*this\_y) + T_sqr(*this\_z)) 
  EndIf 
 Else 
  ProcedureReturn 0.0 
 EndIf 
EndProcedure 

Procedure.d TVector_magSqr(*this.TVECTOR) 
 If TVector_isValid(*this) 
  If TVector_isUnit(*this) 
   ProcedureReturn 1.0 
  Else 
   ProcedureReturn (T_sqr(*this\_x) + T_sqr(*this\_y) + T_sqr(*this\_z)) 
  EndIf 
 Else 
  ProcedureReturn 0.0 
 EndIf 
EndProcedure 

;Dot or scalar product 

Procedure.d TVector_dot(*this.TVECTOR,*v.TVECTOR) 
 If TVector_isValid(*this) And TVector_isValid(*v) 
  ProcedureReturn (*this\_x**v\_x + *this\_y**v\_y + *this\_z**v\_z) 
 Else 
  ProcedureReturn 0.0 
 EndIf 
EndProcedure 

Declare TVector_subtract(*result.TVECTOR,*v1.TVECTOR,*v2.TVECTOR) 

;Distance between two vectors 

Procedure.d TVector_dist(*this.TVECTOR,*v.TVECTOR) 
 Protected tv.TVECTOR 
 TVector_subtract(tv,*this,*v) ;tv=this-v 
 ProcedureReturn TVector_mag(tv) ;tv.mag() 
EndProcedure 

Procedure.d TVector_distSqr(*this.TVECTOR,*v.TVECTOR) 
 Protected tv.TVECTOR 
 TVector_subtract(tv,*this,*v) ;tv=this-v 
 ProcedureReturn TVector_magSqr(tv) ;tv.magSqr() 
EndProcedure 

;Optimised arithmetic methods 

Procedure TVector_add(*result.TVECTOR,*v1.TVECTOR,*v2.TVECTOR) 

 If TVector_isValid(*v1) And TVector_isValid(*v2) 
  *result\_x=*v1\_x+*v2\_x 
  *result\_y=*v1\_y+*v2\_y 
  *result\_z=*v1\_z+*v2\_z 
  *result\_Status=1 ;#DEFAULT 
 Else 
  TVector_reset(*result) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TVector_subtract(*result.TVECTOR,*v1.TVECTOR,*v2.TVECTOR) 

 If TVector_isValid(*v1) And TVector_isValid(*v2) 
  *result\_x=*v1\_x-*v2\_x 
  *result\_y=*v1\_y-*v2\_y 
  *result\_z=*v1\_z-*v2\_z 
  *result\_Status=1 ;#DEFAULT 
 Else 
  TVector_reset(*result) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TVector_cross(*result.TVECTOR,*v1.TVECTOR,*v2.TVECTOR) 

 If TVector_isValid(*v1) And TVector_isValid(*v2) 
  *result\_x=*v1\_y**v2\_z - *v1\_z**v2\_y 
  *result\_y=*v1\_z**v2\_x - *v1\_x**v2\_z 
  *result\_z=*v1\_x**v2\_y - *v1\_y**v2\_x 
  *result\_Status=1 ;#DEFAULT 
 Else 
  TVector_reset(*result) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TVector_invert(*result.TVECTOR,*v1.TVECTOR) 

 If TVector_isValid(*v1) 
  *result\_x=-*v1\_x 
  *result\_y=-*v1\_y 
  *result\_z=-*v1\_z 
  *result\_Status=*v1\_Status 
 Else 
  TVector_reset(*result) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TVector_multiply(*result.TVECTOR,*v1.TVECTOR,scale.d) 

 If TVector_isValid(*v1) 
  *result\_x=*v1\_x*scale 
  *result\_y=*v1\_y*scale 
  *result\_z=*v1\_z*scale 
  *result\_Status=1 ;#DEFAULT 
 Else 
  TVector_reset(*result) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 

;TRay.h, TRay.cpp 

;Line between two points OR point and a direction 

Procedure TRay_setunit(*this.TRAY,*point1.TVECTOR,*point2.TVECTOR) ;Line between two points OR point and a direction 

 TVector_set(*this\_P,*point1) ;this\_P=point1 
 If TVector_isUnit(*point2) 
  TVector_set(*this\_V,*point2) ;this\_V=point2 
 Else 
  TVector_subtract(*this\_V,*point2,*point1) ;this\_V=point2-point1 
  TVector_unit(*this\_V) ;this\_V.unit() 
 EndIf 
  
EndProcedure 

Declare TRay_isValid(*this.TRAY) 

;Adjacent points on both lines 

Procedure.b TRay_adjacentPoints(*this.TRAY,*ray.TRAY,*point1.TVECTOR,*point2.TVECTOR) 

 If TRay_isValid(*this) And TRay_isValid(*ray) 
  Protected temp.d=TVector_dot(*this\_V,*ray\_V) 
  Protected temp2.d=1.0-T_sqr(temp) 
  Protected mu.d,a.d,b.d,lambda.d 
  Protected tv.TVECTOR ;Temporary vector to enable use of optimised routines 
  ;Check for parallel rays 
  If Abs(temp2)<#EPSILON 
   TVector_subtract(tv,*this\_P,*ray\_P) ;tv=this\_P-ray\_P 
   mu=TVector_dot(*this\_V,tv)/temp 
   TVector_set(*point1,*this\_P) ;point1=this\_P 
   TVector_add(*point2,*ray\_P,TVector_multiply(tv,*ray\_V,mu)) ;point2=ray\_P+(ray\_V*mu) 
  Else 
   a=TVector_dot(*this\_V,TVector_subtract(tv,*ray\_P,*this\_P)) ;tv=ray\_P-this\_P 
   b=TVector_dot(*ray\_V,TVector_subtract(tv,*this\_P,*ray\_P)) ;tv=this\_P-ray\_P 
   mu=(b+temp*a)/temp2 
   lambda=(a+temp*b)/temp2 
   TVector_add(*point1,*this\_P,TVector_multiply(tv,*this\_V,lambda)) ;point1=this\_P+(this\_V*lambda) 
   TVector_add(*point2,*ray\_P,TVector_multiply(tv,*ray\_V,mu)) ;point2=ray\_P+(ray\_V*mu) 
  EndIf 
  ProcedureReturn #True 
 EndIf 
 ProcedureReturn #False 
  
EndProcedure 

;Unary operator 

Procedure TRay_invert(*result.TRAY,*ray.TRAY) 
 TVector_set(*result\_P,*ray\_P) ;result\_P=ray\_P 
 TVector_invert(*result\_V,*ray\_V) ;*result\_V=-ray\_V 
 ProcedureReturn *result 
EndProcedure 

;Selectors 

Procedure TRay_P(*this.TRAY) ;this\_P 
 ProcedureReturn *this\_P 
EndProcedure 

Procedure TRay_V(*this.TRAY) ;this\_V 
 ProcedureReturn *this\_V 
EndProcedure 

Procedure TRay_isValid(*this.TRAY) 
 ProcedureReturn (TVector_isUnit(*this\_V) | TVector_isValid(*this\_P)) 
EndProcedure 

;Distances 

Procedure.d TRay_raydist(*this.TRAY,*ray.TRAY) ;Distance between two rays 

 Protected point1.TVECTOR,point2.TVECTOR 
 If TRay_adjacentPoints(*this,*ray,point1,point2) 
  ProcedureReturn TVector_dist(point1,point2) 
 Else 
  ProcedureReturn 0.0 
 EndIf 
  
EndProcedure 

Procedure.d TRay_pointdist(*this.TRAY,*point.TVECTOR) ;Distance between a ray and a point 

 If TRay_isValid(*this) And TVector_isValid(*point) 
  Protected tv.TVECTOR,point2.TVECTOR 
  Protected lambda.d 
  TVector_subtract(tv,*point,*this\_P) ;tv=point-this\_P 
  lambda=TVector_dot(*this\_V,tv) 
  TVector_add(point2,*this\_P,TVector_multiply(tv,*this\_V,lambda)) ;point2=this\_P+(this\_V*lambda) 
  ProcedureReturn TVector_dist(*point,point2) 
 EndIf 
 ProcedureReturn 0.0 
  
EndProcedure 

;TMatrix.h, TMatrix.cpp 

;_Mx[0,0]=x1, _Mx[0,1]=y1, _Mx[0,2]=z1 
;_Mx[1,0]=x2, _Mx[1,1]=y2, _Mx[1,2]=z2 
;_Mx[2,0]=x3, _Mx[2,1]=y3, _Mx[2,2]=z3 

;Constructors 

Procedure TMatrix33_normal(*this.TMATRIX33) 

 *this\_Mx[0]=1.0 : *this\_Mx[1]=0.0 : *this\_Mx[2]=0.0 
 *this\_Mx[3]=0.0 : *this\_Mx[4]=1.0 : *this\_Mx[5]=0.0 
 *this\_Mx[6]=0.0 : *this\_Mx[7]=0.0 : *this\_Mx[8]=1.0 
  
EndProcedure 

Procedure TMatrix33_make(*this.TMATRIX33,mx00.d,mx01.d,mx02.d,mx10.d,mx11.d,mx12.d,mx20.d,mx21.d,mx22.d) 

 *this\_Mx[0]=mx00 : *this\_Mx[1]=mx01 : *this\_Mx[2]=mx02 
 *this\_Mx[3]=mx10 : *this\_Mx[4]=mx11 : *this\_Mx[5]=mx12 
 *this\_Mx[6]=mx20 : *this\_Mx[7]=mx21 : *this\_Mx[8]=mx22 
  
EndProcedure 

Procedure TMatrix33_cosine(*this.TMATRIX33,Phi.d,Theta.d,Psi.d) 

 Protected c1.d=Cos(Phi),c2.d=Cos(Theta),c3.d=Cos(Psi) 
 Protected s1.d=Sin(Phi),s2.d=Sin(Theta),s3.d=Sin(Psi) 
 *this\_Mx[0]=c2*c3 
 *this\_Mx[1]=-c2*s3 
 *this\_Mx[2]=s2 
 *this\_Mx[3]=s1*s2*c3+c1*s3 
 *this\_Mx[4]=-s1*s2*s3+c1*c3 
 *this\_Mx[5]=-s1*c2 
 *this\_Mx[6]=-c1*s2*c3+s1*s3 
 *this\_Mx[7]=c1*s2*s3+s1*c3 
 *this\_Mx[8]=c1*c2 
  
EndProcedure 

;Selectors 

Procedure.d TMatrix33_get(*this.TMATRIX33,Row.l,Column.l) 
 ProcedureReturn *this\_Mx[(3*Row)+Column] 
EndProcedure 

;Optimised artimetric methods 

Procedure TMatrix33_add(*result.TMATRIX33,*m1.TMATRIX33,*m2.TMATRIX33) 

 *result\_Mx[0]=*m1\_Mx[0]+*m2\_Mx[0] 
 *result\_Mx[1]=*m1\_Mx[1]+*m2\_Mx[1] 
 *result\_Mx[2]=*m1\_Mx[2]+*m2\_Mx[2] 
 *result\_Mx[3]=*m1\_Mx[3]+*m2\_Mx[3] 
 *result\_Mx[4]=*m1\_Mx[4]+*m2\_Mx[4] 
 *result\_Mx[5]=*m1\_Mx[5]+*m2\_Mx[5] 
 *result\_Mx[6]=*m1\_Mx[6]+*m2\_Mx[6] 
 *result\_Mx[7]=*m1\_Mx[7]+*m2\_Mx[7] 
 *result\_Mx[8]=*m1\_Mx[8]+*m2\_Mx[8] 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TMatrix33_subtract(*result.TMATRIX33,*m1.TMATRIX33,*m2.TMATRIX33) 

 *result\_Mx[0]=*m1\_Mx[0]-*m2\_Mx[0] 
 *result\_Mx[1]=*m1\_Mx[1]-*m2\_Mx[1] 
 *result\_Mx[2]=*m1\_Mx[2]-*m2\_Mx[2] 
 *result\_Mx[3]=*m1\_Mx[3]-*m2\_Mx[3] 
 *result\_Mx[4]=*m1\_Mx[4]-*m2\_Mx[4] 
 *result\_Mx[5]=*m1\_Mx[5]-*m2\_Mx[5] 
 *result\_Mx[6]=*m1\_Mx[6]-*m2\_Mx[6] 
 *result\_Mx[7]=*m1\_Mx[7]-*m2\_Mx[7] 
 *result\_Mx[8]=*m1\_Mx[8]-*m2\_Mx[8] 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TMatrix33_dot33(*result.TMATRIX33,*m1.TMATRIX33,*m2.TMATRIX33) 

 *result\_Mx[0]=*m1\_Mx[0]**m2\_Mx[0] + *m1\_Mx[1]**m2\_Mx[3] + *m1\_Mx[2]**m2\_Mx[6] 
 *result\_Mx[3]=*m1\_Mx[3]**m2\_Mx[0] + *m1\_Mx[4]**m2\_Mx[3] + *m1\_Mx[5]**m2\_Mx[6] 
 *result\_Mx[6]=*m1\_Mx[6]**m2\_Mx[0] + *m1\_Mx[7]**m2\_Mx[3] + *m1\_Mx[8]**m2\_Mx[6] 
 *result\_Mx[1]=*m1\_Mx[0]**m2\_Mx[1] + *m1\_Mx[1]**m2\_Mx[4] + *m1\_Mx[2]**m2\_Mx[7] 
 *result\_Mx[4]=*m1\_Mx[3]**m2\_Mx[1] + *m1\_Mx[4]**m2\_Mx[4] + *m1\_Mx[5]**m2\_Mx[7] 
 *result\_Mx[7]=*m1\_Mx[6]**m2\_Mx[1] + *m1\_Mx[7]**m2\_Mx[4] + *m1\_Mx[8]**m2\_Mx[7] 
 *result\_Mx[2]=*m1\_Mx[0]**m2\_Mx[2] + *m1\_Mx[1]**m2\_Mx[5] + *m1\_Mx[2]**m2\_Mx[8] 
 *result\_Mx[5]=*m1\_Mx[3]**m2\_Mx[2] + *m1\_Mx[4]**m2\_Mx[5] + *m1\_Mx[5]**m2\_Mx[8] 
 *result\_Mx[8]=*m1\_Mx[6]**m2\_Mx[2] + *m1\_Mx[7]**m2\_Mx[5] + *m1\_Mx[8]**m2\_Mx[8] 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TMatrix33_multiply(*result.TMATRIX33,*m1.TMATRIX33,scale.d) 

 *result\_Mx[0]=*m1\_Mx[0]*scale 
 *result\_Mx[1]=*m1\_Mx[1]*scale 
 *result\_Mx[2]=*m1\_Mx[2]*scale 
 *result\_Mx[3]=*m1\_Mx[3]*scale 
 *result\_Mx[4]=*m1\_Mx[4]*scale 
 *result\_Mx[5]=*m1\_Mx[5]*scale 
 *result\_Mx[6]=*m1\_Mx[6]*scale 
 *result\_Mx[7]=*m1\_Mx[7]*scale 
 *result\_Mx[8]=*m1\_Mx[8]*scale 
 ProcedureReturn *result 
  
EndProcedure 

Procedure TMatrix33_dot(*result.TVECTOR,*m1.TMATRIX33,*v.TVECTOR) 

 Protected a.d,b.d,c.d 
 a=*m1\_Mx[0]**v\_x + *m1\_Mx[1]**v\_y + *m1\_Mx[2]**v\_z 
 b=*m1\_Mx[3]**v\_x + *m1\_Mx[4]**v\_y + *m1\_Mx[5]**v\_z 
 c=*m1\_Mx[6]**v\_x + *m1\_Mx[7]**v\_y + *m1\_Mx[8]**v\_z 
 TVector_make(*result,a,b,c) 
 ProcedureReturn *result 
  
EndProcedure 

;Determinants 

Procedure.d TMatrix33_determinant(*this.TMATRIX33) 

 Protected a.d,b.d,c.d 
 a=*this\_Mx[0] * (*this\_Mx[4]**this\_Mx[8] - *this\_Mx[5]**this\_Mx[7]) 
 b=*this\_Mx[1] * (*this\_Mx[3]**this\_Mx[8] - *this\_Mx[5]**this\_Mx[6]) 
 c=*this\_Mx[2] * (*this\_Mx[3]**this\_Mx[7] - *this\_Mx[4]**this\_Mx[6]) 
 ProcedureReturn (a-b+c) 
  
EndProcedure 

;Transpose 

Procedure TMatrix33_transpose(*this.TMATRIX33) 

 Protected t.d 
 t=*this\_Mx[2] : *this\_Mx[2]=*this\_Mx[6] : *this\_Mx[6]=t 
 t=*this\_Mx[1] : *this\_Mx[1]=*this\_Mx[3] : *this\_Mx[3]=t 
 t=*this\_Mx[5] : *this\_Mx[5]=*this\_Mx[7] : *this\_Mx[7]=t 
 ProcedureReturn *this 
  
EndProcedure 

;Inverse 

Procedure TMatrix33_inverse(*result.TMATRIX33,*m1.TMATRIX33) 

 Protected det.d=TMatrix33_determinant(*m1) 
 If Abs(det)<#EPSILON 
  TMatrix33_normal(*result) 
 Else 
  *result\_Mx[0]=*m1\_Mx[4]**m1\_Mx[8] - *m1\_Mx[5]**m1\_Mx[7] 
  *result\_Mx[1]=*m1\_Mx[7]**m1\_Mx[2] - *m1\_Mx[8]**m1\_Mx[1] 
  *result\_Mx[2]=*m1\_Mx[1]**m1\_Mx[5] - *m1\_Mx[2]**m1\_Mx[4] 
  *result\_Mx[3]=*m1\_Mx[5]**m1\_Mx[6] - *m1\_Mx[3]**m1\_Mx[8] 
  *result\_Mx[4]=*m1\_Mx[8]**m1\_Mx[0] - *m1\_Mx[6]**m1\_Mx[2] 
  *result\_Mx[5]=*m1\_Mx[2]**m1\_Mx[3] - *m1\_Mx[0]**m1\_Mx[5] 
  *result\_Mx[6]=*m1\_Mx[3]**m1\_Mx[7] - *m1\_Mx[4]**m1\_Mx[6] 
  *result\_Mx[7]=*m1\_Mx[6]**m1\_Mx[1] - *m1\_Mx[7]**m1\_Mx[0] 
  *result\_Mx[8]=*m1\_Mx[0]**m1\_Mx[4] - *m1\_Mx[1]**m1\_Mx[3] 
  TMatrix33_multiply(*result,*result,1.0/det) ;result=result*(1.0/det) 
 EndIf 
 ProcedureReturn *result 
  
EndProcedure 


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 429
; FirstLine = 426
; Folding = ---------
; EnableAsm