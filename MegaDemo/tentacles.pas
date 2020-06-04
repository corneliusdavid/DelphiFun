unit tentacles;

interface

Uses Globals;

  procedure drawTentacles;
  procedure initTentacles;

implementation

Uses OpenGL;

type TVertex = Record
       X, Y, Z : glFloat;
     end;
var CubeDL : glUint;
    DemoTime : Integer;


{------------------------------------------------------------------}
{  Draw a tentacle                                                 }
{------------------------------------------------------------------}
procedure DrawTentacle(const Step : Integer; const Angle, TwistAngle : glFloat);
begin
  if Step = 19 then
    exit;

  glTranslate(2.25, 0, 0);
  glRotatef(Angle, 0, 1, 0);
  glRotatef(TwistAngle, 1, 0, 0);

  glCallList(CubeDL);

  glScale(0.9, 0.9, 0.9);
  DrawTentacle(Step+1, Angle, TwistAngle);
end;


{------------------------------------------------------------------}
{  Draw the entire tentacle object                                 }
{------------------------------------------------------------------}
procedure DrawObject;
var Angle, TwistAngle : glFloat;
begin
  glCallList(CubeDL);
  glScale(0.9, 0.9, 0.9);

  Angle :=25*sin(DemoTime/800);
  TwistAngle :=25*sin(DemoTime/1000);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*cos(DemoTime/700);
  TwistAngle :=25*sin(DemoTime/1000);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, -TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/700);
  TwistAngle :=25*cos(DemoTime/800);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/800);
  TwistAngle :=25*sin(DemoTime/600);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, -TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/800);
  TwistAngle :=25*cos(DemoTime/600);
  glRotate(90, 0, 0, 1);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/600);
  TwistAngle :=25*cos(DemoTime/1000);
  glRotate(180, 0, 0, 1);
  glPushMatrix();
    DrawTentacle(0, -Angle, -TwistAngle);
  glPopMatrix();
end;


{------------------------------------------------------------------}
{  Draw the tentacle scene                                         }
{------------------------------------------------------------------}
procedure drawTentacles;
var Angle, TwistAngle : glFloat;
    I : Integer;
    X : glFloat;
begin
  DemoTime :=ElapsedTime - TENTACLE_START;

  // Draw the White background
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_TEXTURE_2D);
  glPushMatrix();
    glTranslate(0, 0, -1.5);

    // fade out section at end of demo
    if ElapsedTime > DEMO_END-750 then
      X :=(DEMO_END-ElapsedTime)/1000
    else
      X :=1;
    glColor3f(X, X, X);
    glBegin(GL_QUADS);
      glVertex3f(-1.0, -1.0, 0.0);
      glVertex3f( 1.0, -1.0, 0.0);
      glVertex3f( 1.0,  1.0, 0.0);
      glVertex3f(-1.0,  1.0, 0.0);
    glEnd();
  glPopMatrix();

  glTranslatef(0.0,0.0,-35);

  Angle :=25*sin(DemoTime/1000);
  TwistAngle :=25*sin(DemoTime/1200);

  // Draw the gray tentacles
  glPushMatrix();
    glDisable(GL_TEXTURE_2D);
    glTranslate(0, 0, 15);
    glRotatef(DemoTime/20, 1, 0, 0);
    glRotatef(DemoTime/30, 0, 1, 0);

    // fade out section at end of demo
    if ElapsedTime > DEMO_END-750 then
      X :=0.6*(DEMO_END-ElapsedTime)/1000
    else
      X :=0.6;
    glColor3f(X, X, X);

    DrawObject;
    glColor3f(1, 1, 1);
  glPopMatrix();

  // draw the black bounding boxes
  glPushMatrix();
    glColor3f(0, 0, 0);
    glTranslate(0, 0, 34);
    glBegin(GL_QUADS);
      glVertex3f(-1.0, 0.19, 0.0);
      glVertex3f( 1.0, 0.19, 0.0);
      glVertex3f( 1.0, 0.5, 0.0);
      glVertex3f(-1.0, 0.5, 0.0);

      glVertex3f(-1.0, -0.2, 0.0);
      glVertex3f( 1.0, -0.2, 0.0);
      glVertex3f( 1.0, -0.5, 0.0);
      glVertex3f(-1.0, -0.5, 0.0);
    glEnd();
    glColor3f(1, 1, 1);
  glPopMatrix();

  // Draw the blue tentacles
  glPushMatrix();
    glRotatef(DemoTime/20, 1, 0, 0);
    glRotatef(DemoTime/25, 0, 1, 0);

    glBindTexture(GL_TEXTURE_2D, TentacleTex);  // Bind the Texture to the object
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);

    // fade out section at end of demo
    if ElapsedTime > DEMO_END-750 then
      X :=(DEMO_END-ElapsedTime)/1000
    else
      X :=1;
    glColor3f(X, X, X);

    DrawObject;
    glDisable(GL_BLEND);
  glPopMatrix;

  // Draw the titles
  if DemoTime > 10000 then
  begin
    glEnable(GL_BLEND);
    if DemoTime < 11000 then
      X :=(DemoTime-10000) / 1000
    else if
      DemoTime > 43000 then
        X :=(44000-DemoTime) / 1000
    else
      X :=1;

    glColor3f(X, X, X);

    // Demoname / biohazard logo
    glPushMatrix();
      glBindTexture(GL_TEXTURE_2D, Biohazard2);
      glTranslatef(0, 21, -40);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.0); glVertex3f(-10.0, -10.0, 0.0);
        glTexCoord2f(1.0, 0.0); glVertex3f( 10.0, -10.0, 0.0);
        glTexCoord2f(1.0, 1.0); glVertex3f( 10.0,  10.0, 0.0);
        glTexCoord2f(0.0, 1.0); glVertex3f(-10.0,  10.0, 0.0);
      glEnd;
    glPopMatrix();

    // Optimize 2001
    glPushMatrix();
      glTranslatef(19, 0, -20);
      glBindTexture(GL_TEXTURE_2D, OptimizeTex);
      glBegin(GL_QUADS);
        glTexCoord2f(0.89, 0.0); glVertex3f(  8.0, -10.0, 0.0);
        glTexCoord2f(0.99, 0.0); glVertex3f( 10.0, -10.0, 0.0);
        glTexCoord2f(0.99, 1.0); glVertex3f( 10.0,  10.0, 0.0);
        glTexCoord2f(0.89, 1.0); glVertex3f(  8.0,  10.0, 0.0);
      glEnd;
    glPopMatrix();

    glBindTexture(GL_TEXTURE_2D, TitlesTex);

    // design text
    if (DemoTime > 16000) AND (DemoTime < 20000) then
    begin
      if DemoTime < 17000 then
        X :=(DemoTime-17000)/50 -18
      else if DemoTime > 19000 then
        X :=(19000-DemoTime)/50 -18
      else X :=-18;

      glTranslatef(X, -17, -20);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.62); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.6, 0.62); glVertex3f(  2.0, -1.5, 0.0);
        glTexCoord2f(0.6, 0.77); glVertex3f(  2.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.77); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;

      // Jan Horn
      glTranslatef(-2*X +5, 0, 0);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.23); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.23); glVertex3f(  4.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.39); glVertex3f(  4.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.39); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;
    end;

    // code text
    if (DemoTime > 22000) AND (DemoTime < 26000) then
    begin
      if DemoTime < 23000 then
        X :=(DemoTime-23000)/50 -18
      else if DemoTime > 25000 then
        X :=(25000-DemoTime)/50 -18
      else X :=-18;

      glTranslatef(X, -17, -20);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.49); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.6, 0.49); glVertex3f(  2.0, -1.5, 0.0);
        glTexCoord2f(0.6, 0.64); glVertex3f(  2.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.64); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;

      // Jan Horn
      glTranslatef(-2*X +5, 0, 0);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.23); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.23); glVertex3f(  4.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.39); glVertex3f(  4.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.39); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;
    end;

    // graphics text
    if (DemoTime > 28000) AND (DemoTime < 32000) then
    begin
      if DemoTime < 29000 then
        X :=(DemoTime-29000)/50 -18
      else if DemoTime > 31000 then
        X :=(31000-DemoTime)/50 -18
      else X :=-18;

      glTranslatef(X, -17, -20);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.36); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.8, 0.36); glVertex3f(  6.0, -1.5, 0.0);
        glTexCoord2f(0.8, 0.51); glVertex3f(  6.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.51); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;

      // jan horn text
      glTranslatef(-2*X +5, 0, 0);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.23); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.23); glVertex3f(  4.0, -1.5, 0.0);
        glTexCoord2f(0.7, 0.39); glVertex3f(  4.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.39); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;
    end;

    // URL text
    if (DemoTime > 36000) AND (DemoTime < 40000) then
    begin
      if DemoTime < 36500 then
        X :=(DemoTime-36000) / 500
      else if
        DemoTime > 39500 then
          X :=(40000-DemoTime) / 500
      else
        X :=1;

      glColor3f(X, X, X);
      glTranslatef(0, -17, -20);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.1); glVertex3f(-10.0, -1.5, 0.0);
        glTexCoord2f(1.0, 0.1); glVertex3f( 10.0, -1.5, 0.0);
        glTexCoord2f(1.0, 0.25); glVertex3f( 10.0,  1.5, 0.0);
        glTexCoord2f(0.0, 0.25); glVertex3f(-10.0,  1.5, 0.0);
      glEnd;
    end;
    glDisable(GL_BLEND);
  end;

  if ElapsedTime > DEMO_END then
    Inc(Stage);            
end;


{------------------------------------------------------------------}
{  Create a display list object for the tentacle cubes             }
{------------------------------------------------------------------}
procedure initTentacles;
begin
  CubeDL :=glGenLists(1);
  glNewList(CubeDL, GL_COMPILE);
  glBegin(GL_QUADS);
    // Front Face
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
    // Back Face
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
    // Top Face
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    // Bottom Face
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    // Right face
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    // Left Face
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
  glEnd();
  glEndList();
end;

end.
