unit Fetus;

interface

procedure initFetus;
procedure drawFetus;
procedure drawFetusInRoom;

implementation

Uses OpenGL, GenObjects, Globals;

var LastTime : Integer;
    Count : Integer;    // number of times statis has been displayed

    // Display Lists
    ChildDL : glUint;
    CageDL  : glUint;
    Quadratic : GLUquadricObj;	          // Storage For Our Quadratic Objects


procedure initFetus;
begin
  Count :=0;
  childDL :=CreateChildDisplayList;
  cageDL  :=createCageDisplayList;

  Quadratic := gluNewQuadric();		               // Create A Pointer To The Quadric Object (Return 0 If No Memory) (NEW)
  gluQuadricNormals(Quadratic, GLU_SMOOTH);	       // Create Smooth Normals (NEW)
  gluQuadricTexture(Quadratic, GL_TRUE);	       // Create Texture Coords (NEW)
end;


{------------------------------------------------------------------}
{  Fly in baby in cage and then rotate cage.                       }
{------------------------------------------------------------------}
procedure drawFetus;
var Angle : glFLoat;
    DemoTime : Integer;    // Duration that this bit of demo has been running for.
begin
  DemoTime :=ElapsedTime - FETUS_START;

  if DemoTime < 200 then
    glTranslatef(0.0, 0.0, -15.0 + DemoTime/20)   // Fly towards viewer
  else
    glTranslatef(0.0, 0.0, -5);

  glPushMatrix();

  // get an average elapsed time for smoother movement
  Angle :=(DemoTime + LastTime)/72;
  LastTime :=DemoTime;

  if (DemoTime > 500) AND (DemoTime < 1000) then
    glColor((DemoTime-500)/500, (DemoTime-500)/500, (DemoTime-500)/500)
  else if DemoTime < 500 then
    glColor3f(0, 0, 0)
  else
    glColor3f(1, 1, 1);

  glBindTexture(GL_TEXTURE_2D, FetusBG);
  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex3f(-3.9, -3.9, -2);
    glTexCoord2f(1.0, 0.0); glVertex3f( 3.9, -3.9, -2);
    glTexCoord2f(1.0, 1.0); glVertex3f( 3.9,  3.9, -2);
    glTexCoord2f(0.0, 1.0); glVertex3f(-3.9,  3.9, -2);
  glEnd;
  glColor3f(1, 1, 1);

  // Rotate and draw the cage
  glRotatef(Angle*2, 1.0, 0.0, 0.0);
  glRotatef(Angle*3, 0.0, 1.0, 0.0);
  glCallList(CageDL);

  // Rotate and draw the baby
  glRotatef(-Angle*2, 0.5, 0.0, 0.0);
  glRotatef(-Angle*3, 0.0, 0.5, 0.0);
  glScalef(0.7, 0.7, 0.7);
  glCallList(ChildDL);

  glPopMatrix();

  // Draw the Static after 12 seconds
  if DemoTime >= 11000 then
  begin
    if (DemoTime < 11200) OR
      ((DemoTime > 12200) AND (DemoTime < 12600)) OR
       (DemoTime > 13800) then
    begin
      Inc(Count);

      if DemoTime < 13800 then
        glEnable(GL_BLEND);

      glBindTexture(GL_TEXTURE_2D, Static);
      case (DemoTime MOD 200) of
        0..49 : ;  // no rotation required
        50..99 : glRotate(90, 0, 0, 1);
        100..149 : glRotate(180, 0, 0, 1);
        150..199 : glRotate(270, 0, 0, 1);
      end;
      
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, 3.5);
        glTexCoord2f(2.0, 0.0); glVertex3f( 1.0, -1.0, 3.5);
        glTexCoord2f(2.0, 2.0); glVertex3f( 1.0,  1.0, 3.5);
        glTexCoord2f(0.0, 2.0); glVertex3f(-1.0,  1.0, 3.5);
      glEnd;
      glDisable(GL_BLEND);
    end;
  end;

  if ElapsedTime > FETUS_ROOM_START then
  begin
    Count :=0;
    Inc(Stage);
  end;
end;


{------------------------------------------------------------------}
{  Baby in cage in Room.                                           }
{------------------------------------------------------------------}
procedure drawFetusInRoom;
var I : Integer;
    h, r, Angle : glFloat;
    DemoTime : Integer;
begin
  DemoTime :=ElapsedTime - FETUS_ROOM_START;

  glTranslatef(0.0, 0.0, -10.0);
  Angle :=(LastTime + DemoTime)/96;   // average/48
  LastTime :=DemoTime;

  // Normal rotation around the room
  if DemoTime < 28500 then
  begin                            
    glRotatef(Angle*sin(Angle/120), 0.0, 1.0, 0.0);
    glRotatef(20*sin(Angle/180*PI), 0.0, 0.0, 1.0);   //  DemoTime/16*pi/540
  end
  else   // Stop spinning around the room and head down the passage
  begin
    if Count = 0 then
      Count :=DemoTime DIV 14;
    h := Angle*sin(Angle/120);
    if h > -540 then
      glRotatef(-540, 0.0, 1.0, 0.0)
    else
      glRotatef(Angle*sin(Angle/120), 0.0, 1.0, 0.0);
    glRotatef(20*sin(Angle/180*PI), 0.0, 0.0, 1.0);
    h:=sqr(DemoTime/14 - Count)/500;         // accelerate away
    glTranslatef(0.0, 0.0, -h);
  end;

  glPushMatrix();

  //----------------------------------//
  //  Draw the room and the passage.  //
  //----------------------------------//
  glBindTexture(GL_TEXTURE_2D, Floor);
  glBegin(GL_QUADS);
    // Draw the room
    glTexCoord2f(0.0, 0.0); glVertex3f(-15.0, -3.0, -15.0);
    glTexCoord2f(5.0, 0.0); glVertex3f( 15.0, -3.0, -15.0);
    glTexCoord2f(5.0, 5.0); glVertex3f( 15.0, -3.0,  15.0);
    glTexCoord2f(0.0, 5.0); glVertex3f(-15.0, -3.0,  15.0);
    // Passage floor
    glColor3f(1.0, 1.0, 1.0); // light at the start
    glTexCoord2f(0.2, 0.0);   glVertex3f(-2.2, -3.0, 15.0);
    glTexCoord2f(0.8, 0.0);   glVertex3f( 2.2, -3.0, 15.0);
    glColor3f(0.0, 0.0, 0.0); // dark at the end
    glTexCoord2f(0.8, 6.0);   glVertex3f( 2.2, -3.0, 45.0);
    glTexCoord2f(0.2, 6.0);   glVertex3f(-2.2, -3.0, 45.0);
  glEnd;
  glColor3f(1.0, 1.0, 1.0);

  glBindTexture(GL_TEXTURE_2D, Walls);
  glBegin(GL_QUADS);
    // Front left
    glTexCoord2f(0.0, 0.0); glVertex3f(-15.0, -3.0, 15.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-15.0,  7.0, 15.0);
    glTexCoord2f(0.8, 1.0); glVertex3f( -3.0,  7.0, 15.0);
    glTexCoord2f(0.8, 0.0); glVertex3f( -3.0, -3.0, 15.0);
    // Front right
    glTexCoord2f(1.2, 0.0); glVertex3f(  3.0, -3.0, 15.0);
    glTexCoord2f(1.2, 1.0); glVertex3f(  3.0,  7.0, 15.0);
    glTexCoord2f(2.0, 1.0); glVertex3f( 15.0,  7.0, 15.0);
    glTexCoord2f(2.0, 0.0); glVertex3f( 15.0, -3.0, 15.0);
    // Front top
    glTexCoord2f(0.8, 0.8); glVertex3f( -3.0,  5.0, 15.0);
    glTexCoord2f(0.8, 1.0); glVertex3f( -3.0,  7.0, 15.0);
    glTexCoord2f(1.2, 1.0); glVertex3f(  3.0,  7.0, 15.0);
    glTexCoord2f(1.2, 0.8); glVertex3f(  3.0,  5.0, 15.0);
    // Back
    glTexCoord2f(0.0, 0.0); glVertex3f(-15.0, -3.0, -15.0);
    glTexCoord2f(2.0, 0.0); glVertex3f( 15.0, -3.0, -15.0);
    glTexCoord2f(2.0, 1.0); glVertex3f( 15.0,  7.0, -15.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-15.0,  7.0, -15.0);
    // Right
    glTexCoord2f(0.0, 0.0); glVertex3f( 15.0, -3.0, -15.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 15.0,  7.0, -15.0);
    glTexCoord2f(2.0, 1.0); glVertex3f( 15.0,  7.0,  15.0);
    glTexCoord2f(2.0, 0.0); glVertex3f( 15.0, -3.0,  15.0);
    // Left
    glTexCoord2f(0.0, 0.0); glVertex3f( -15.0, -3.0, -15.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( -15.0,  7.0, -15.0);
    glTexCoord2f(2.0, 1.0); glVertex3f( -15.0,  7.0,  15.0);
    glTexCoord2f(2.0, 0.0); glVertex3f( -15.0, -3.0,  15.0);
    // Passage Right
    glColor3f(1.0, 1.0, 1.0); // light at the start
    glTexCoord2f(0.0, 0.8);   glVertex3f( 2.2,  5.0, 15.0);
    glTexCoord2f(0.0, 0.0);   glVertex3f( 2.2, -3.0, 15.0);
    glColor3f(0.0, 0.0, 0.0); // dark at the end
    glTexCoord2f(6.0, 0.0);   glVertex3f( 2.2, -3.0, 45.0);
    glTexCoord2f(6.0, 0.8);   glVertex3f( 2.2,  5.0, 45.0);
    // Passage Left
    glColor3f(1.0, 1.0, 1.0); // light at the start
    glTexCoord2f(0.0, 0.0);   glVertex3f( -2.2, -3.0, 15.0);
    glTexCoord2f(0.0, 0.8);   glVertex3f( -2.2,  5.0, 15.0);
    glColor3f(0.0, 0.0, 0.0); // dark at the end
    glTexCoord2f(6.0, 0.8);   glVertex3f( -2.2,  5.0, 45.0);
    glTexCoord2f(6.0, 0.0);   glVertex3f( -2.2, -3.0, 45.0);
  glEnd;
  glColor3f(1.0, 1.0, 1.0);

  glBindTexture(GL_TEXTURE_2D, WallTrim);
  glBegin(GL_QUADS);
    // door trim left
    glTexCoord2f(0.0,  0.0); glVertex3f( 2.2, -3.0, 15.0);
    glTexCoord2f(1.0,  0.0); glVertex3f( 3.0, -3.0, 15.0);
    glTexCoord2f(1.0, 10.0); glVertex3f( 3.0, 5.0, 15.0);
    glTexCoord2f(0.0, 10.0); glVertex3f( 2.2, 5.0, 15.0);

    // door trim right
    glTexCoord2f(0.0,  0.0); glVertex3f( -2.2, -3.0, 15.0);
    glTexCoord2f(1.0,  0.0); glVertex3f( -3.0, -3.0, 15.0);
    glTexCoord2f(1.0, 10.0); glVertex3f( -3.0, 5.0, 15.0);
    glTexCoord2f(0.0, 10.0); glVertex3f( -2.2, 5.0, 15.0);
  glEnd;

  glBindTexture(GL_TEXTURE_2D, Ceiling);
  glBegin(GL_QUADS);
    // Room ceiling
    glTexCoord2f(0.0, 0.0);   glVertex3f(-15.0, 7.0, -15.0);
    glTexCoord2f(2.0, 0.0);   glVertex3f( 15.0, 7.0, -15.0);
    glTexCoord2f(2.0, 2.0);   glVertex3f( 15.0, 7.0,  15.0);
    glTexCoord2f(0.0, 2.0);   glVertex3f(-15.0, 7.0,  15.0);
    // Passage ceiling
    glColor3f(1.0, 1.0, 1.0); // light at the start
    glTexCoord2f(0.2, 0.0);   glVertex3f(-2.2, 5.0, 15.0);
    glTexCoord2f(0.8, 0.0);   glVertex3f( 2.2, 5.0, 15.0);
    glColor3f(0.0, 0.0, 0.0); // dark at the end
    glTexCoord2f(0.8, 6.0);   glVertex3f( 2.2, 5.0, 45.0);
    glTexCoord2f(0.2, 6.0);   glVertex3f(-2.2, 5.0, 45.0);
  glEnd;
  glColor3f(1.0, 1.0, 1.0);

  // Energy Pod
  glBindTexture(GL_TEXTURE_2D, EnergyPod);
  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.5, -2.99, -1.5);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.5, -2.99, -1.5);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.5, -2.99,  1.5);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.5, -2.99,  1.5);
  glEnd;

  // Energy Glow
  glBindTexture(GL_TEXTURE_2D, EnergyGlow);
  glRotatef(90, -1.0, 0.0, 0.0);
  glRotatef(3*Angle, 0.0, 0.0, 1.0);
  glTranslatef(0.0, 0.0, -3.0);
  glEnable(GL_BLEND);
  glColor3f(0.5, 0.5, 0.5);
  gluCylinder(Quadratic, 0.6, 1.1, 0.7, 16, 16);
  glDisable(GL_BLEND);

  glPopMatrix;

  // Energy Particles
  glPointSize(2);
  glDisable(GL_TEXTURE_2D);
  glColor3f(0.2, 0.6, 0.9);
  glBegin(GL_POINTS);
    For I :=0 to 24 do
    begin
      h :=(Round(6*Angle + I*4) MOD 100)/70 + abs(sin(I))/2;    // Height
      r :=0.4+0.4*h;   // radius varies from 0.4 - 1.18         // Radius
      glVertex3f(r*cos(Angle/4+I/2), -3+h, r*sin(Angle/4+I/2));
    end;
  glEnd();
  glColor3f(1.0, 1.0, 1.0);
  glEnable(GL_TEXTURE_2D);

  // Rotate and draw the cage
  glRotatef(3*Angle, 0.0, 1.0, 0.0);
  glRotatef(2*Angle, 1.0, 0.0, 0.0);
  glRotatef(45,     -1.0, 1.0, 1.0);
  glCallList(CageDL);

  // Rotate and draw the baby
  glRotatef(-3*Angle, 1.0, 0.0, 0.0);
  glRotatef(-2*Angle, 0.0, 1.0, 0.0);
  glScalef(0.7, 0.7, 0.7);
  glCallList(ChildDL);

  if ElapsedTime > TUNNEL_START then
  begin
    glBlendFunc(GL_ONE, GL_ONE);
    Inc(Stage);
  end;
end;

end.
