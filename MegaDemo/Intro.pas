unit Intro;

interface

Uses OpenGL, Globals;

procedure drawIntro;
procedure drawIntroTunnel;

implementation


procedure drawIntro;
var S, A1, A2, A3 : glFloat;
    X, Y, Z, fTime : glFloat;
    StageTime : Integer;
    I : Integer;
begin
  glTranslatef(0.0,0.0,-8.8);

  glEnable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);

  // Background image
  glBindTexture(GL_TEXTURE_2D, PowerLines);
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex3f(-5,-5, 0);
    glTexCoord2f(1, 0); glVertex3f( 5,-5, 0);
    glTexCoord2f(1, 1); glVertex3f( 5, 5, 0);
    glTexCoord2f(0, 1); glVertex3f(-5, 5, 0);
  glEnd();

  // Set text position
  glPushMatrix;
    glBindTexture(GL_TEXTURE_2D, DemoNameTex);
    glTranslatef(-2.0, -1.5, 3.0);

    // enlarge and start rotating text
    if ElapsedTime < 4000 then
    begin
      Z :=sin(pi/2*ElapsedTime/2000);
      A1 :=cos(pi+ ElapsedTime/800) * ElapsedTime/16000;
      A2 :=sin(pi+ ElapsedTime/800) * ElapsedTime/16000;
      glEnable(GL_BLEND);
      glBegin(GL_QUADS);
        for I :=0 to 9 do
        begin
          X :=A1*I;
          Y :=A2*I;
          if ElapsedTime < 2000 then
            S :=1 + I/3*Z
          else
            S :=1 + I/3;
          glColor3f(0.6-I/18, 0.6-I/18, 0.6-I/18);
          glTexCoord2f(0, 0); glVertex3f(-S+X,-S+Y, 0);
          glTexCoord2f(1, 0); glVertex3f( S+X,-S+Y, 0);
          glTexCoord2f(1, 1); glVertex3f( S+X, S+Y, 0);
          glTexCoord2f(0, 1); glVertex3f(-S+X, S+Y, 0);
        end;
      glEnd();
      glColor3f(1, 1, 1);
    end
    else if ElapsedTime < 6000 then  // shrink and stop rotation of text
    begin
      Z :=sin(pi/2*ElapsedTime/2000);
      A3 :=(6000 - ElapsedTime)/2000;
      A1 :=cos(pi+ ElapsedTime/800) * ElapsedTime/16000 * A3;
      A2 :=sin(pi+ ElapsedTime/800) * ElapsedTime/16000 * A3;
      A3 :=sin(pi/2*A3);
      glEnable(GL_BLEND);
      glBegin(GL_QUADS);
        for I :=0 to 9 do
        begin
          X :=A1*I;
          Y :=A2*I;
          S :=1 + (I/3)*A3;
          glColor3f(0.6-I/18, 0.6-I/18, 0.6-I/18);
          glTexCoord2f(0, 0); glVertex3f(-S+X,-S+Y, 0);
          glTexCoord2f(1, 0); glVertex3f( S+X,-S+Y, 0);
          glTexCoord2f(1, 1); glVertex3f( S+X, S+Y, 0);
          glTexCoord2f(0, 1); glVertex3f(-S+X, S+Y, 0);
        end;
      glEnd();
      glColor3f(1, 1, 1);
    end
    else   // show normal text
    begin
      // Calculate vibration position
      if (ElapsedTime > 6500) AND (ElapsedTime < 7500) then
      begin
{        FTime := ((ElapsedTime-7000) MOD 4500) / 3.8;
        if (FTime > 300) AND (FTime < 450) then
          X :=0.1*sin((FTime-150)*PI/150) + 0.03*sin((FTime-150)*PI/4)*sin((FTime-150)*pi/150)
        else if (FTime > 450) AND (FTime < 600) then
          X :=0.05*sin(FTime*PI/150) + 0.03*sin(FTime*PI/4)*sin(FTime*PI/150);
}
        X :=1+ 0.2 * sin(pi*(ElapsedTime-6500)/1000) + 0.03*sin((ElapsedTime-6500)/5);
      end
      else
        X :=1;

      if ElapsedTime > (INTRO_TUNNEL-1000) then
      begin
        S :=(INTRO_TUNNEL-ElapsedTime)/1200;
        glColor3f(S, S, S);
      end;

      glBegin(GL_QUADS);
        glTexCoord2f(0, 0); glVertex3f(-X,-1, 0);
        glTexCoord2f(1, 0); glVertex3f( X,-1, 0);
        glTexCoord2f(1, 1); glVertex3f( X, 1, 0);
        glTexCoord2f(0, 1); glVertex3f(-X, 1, 0);
      glEnd();
    end;
  glPopMatrix();


  // roto zoom effect
  if ElapsedTime > 7000 then
  begin
    StageTime :=ElapsedTime-7000;
    glTranslatef(0.0,0.0,7);
    glRotatef(-30*sin(StageTime/2000) + 25*sin(StageTime/2400), 0, 0, 1);
    glTranslatef(0.2, 0, 0);

    // calculate rotozoom fadein and fadeout color
    if ElapsedTime < 11000 then
      fTime :=0.15 * StageTime/4000
    else if ElapsedTime > INTRO_TUNNEL - 3000 then
      fTime :=0.15 * (INTRO_TUNNEL - ElapsedTime)/3000
    else
      fTime :=0.15;
    glColor4f(1, 1, 1, fTime);

    glBindTexture(GL_TEXTURE_2D, IntroZoom);
    X :=0.3*sin(StageTime/1600) + 0.28*cos(StageTime/2100);
    Y :=0.32*sin(StageTime/2000) + 0.25*cos(StageTime/1500);
    For I :=1 to 16 do
    begin
      Z :=i/6;
      glRotate(i, -X, Y, 0.6);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  -Z);
        glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  -Z);
        glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  -Z);
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  -Z);
      glEnd();
    end;
    glColor4f(1, 1, 1, 1);
  end;
  
  if ElapsedTime > INTRO_TUNNEL then
    Inc(Stage);
end;


procedure drawIntroTunnel;
var X, Y : glFloat;
    I : glUint;
    DemoTime : Integer;
begin
  DemoTime :=ElapsedTime - INTRO_TUNNEL;

  // zoom in on picture
  if DemoTime < 500 then
    glTranslatef(0.0, 0.0, -8.8 + DemoTime/250)
  else
    glTranslatef(0.0, 0.0, -6.8);

  // if tunnel has been created, fly down tunnel
  if DemoTime > 2000 then
    glTranslate(0.0, 0.0, (DemoTime-2000)/6);

  // if at the zoom stage, draw a normal square, else draw a triangle fan
  glBindTexture(GL_TEXTURE_2D, PowerLines);
  glColor3f(1.0, 1.0, 1.0);
  if DemoTime < 500 then
  begin
    glBegin(GL_QUADS);
      glTexCoord2f(0, 0); glVertex3f(-5,-5, 0);
      glTexCoord2f(1, 0); glVertex3f( 5,-5, 0);
      glTexCoord2f(1, 1); glVertex3f( 5, 5, 0);
      glTexCoord2f(0, 1); glVertex3f(-5, 5, 0);
    glEnd();
  end
  else
  begin
    glBegin(GL_TRIANGLE_FAN);
      glTexCoord2f(0.5, 0.5); glVertex3f( 0, 0, 36-DemoTime/14);   // center
      for I :=1 to 16 do
      begin
        X :=cos(I*PI/8);
        Y :=sin(I*PI/8);
        glTexCoord2f(X/2+0.5, Y/2+0.5);  // range from 0 - 1
        glVertex3f(5*X, 5*Y, 0);
      end;
    glEnd();
  end;

  if ElapsedTime > FETUS_START then
    Inc(Stage);
end;

end.
