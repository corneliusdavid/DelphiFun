unit BlobTunnel;

interface

  procedure initTunnel;
  procedure drawTunnel;

implementation

Uses OpenGL, BlobEffect, Globals;

const TUNNEL_SPEED = 1/60;
      PI_8 = 0.3926990816987;    // PI/8

var Blob    : TBlob;
    Sphere  : TBlob;
    Tunnels : Array[0..64, 0..32] of TVertex;
    LU : Array[0..numVertices-1] of TVertex;


{------------------------------------------------------------------}
{  Draws the tunnel with the blob appearing in a window            }
{------------------------------------------------------------------}
procedure drawTunnel();
var I, J : Integer;
    C, J1, J2 : glFloat;
    X, Y : glFloat;
    Angle : glFloat;
    A1, A2, A3, A4 : glFloat;
    DemoTime : Integer;
begin
  DemoTime :=ElapsedTime - TUNNEL_START;

  // --- Drawing the tunnel --- //
  glDisable(GL_BLEND);
  glPushMatrix();
    glTranslatef(0.0,0.0,-2);

    Angle := DemoTime/14;

    //--- Outside tunnel ---//
    // setup tunnel coordinates
    A1 := sin(Angle/27);
    A2 := cos(Angle/33);
    A3 := cos(Angle/13);
    A4 := sin(Angle/17);
    for I :=0 to 16 do
    begin
      X :=cos(PI_8*I);
      Y :=sin(PI_8*I);
      for J :=0 to 32 do
      begin
        Tunnels[I, J].X :=(3 - J/12)*X + 2.0*sin((Angle+2*j)/27) + cos((Angle+2*j)/13) - 2*A1 - A3;
        Tunnels[I, J].Y :=(3 - J/12)*Y + 2.5*cos((Angle+2*j)/33) + sin((Angle+2*j)/17) - 2*A2 - A4;
        Tunnels[I, J].Z :=-J;
      end;
    end;

    // draw tunnel and fade out last few
    glBindTexture(GL_TEXTURE_2D, TunnelTex);
    For J :=0 to 31 do
    begin
      J1 :=J/32 + Angle*TUNNEL_SPEED;        // precalculate texture v coords for speed
      J2 :=(J+1)/32 + Angle*TUNNEL_SPEED;

      // near the end of the tunnel, fade the effect away
      if J > 24 then
        C :=1.0-(J-24)/10
      else
        C :=1.0;

      // fade in tunnel
      if DemoTime < 500 then
        C :=C*DemoTime/500;

      glColor3f(C, C, C);

      glBegin(GL_QUADS);
        For I :=0 to 15 do
        begin
          glTexCoord2f((I-1)/16, J1); glVertex3f(Tunnels[ I,   J ].X, Tunnels[ I,   J ].Y, Tunnels[ I,   J ].Z);
          glTexCoord2f(( I )/16, J1); glVertex3f(Tunnels[I+1,  J ].X, Tunnels[I+1,  J ].Y, Tunnels[I+1,  J ].Z);
          glTexCoord2f(( I )/16, J2); glVertex3f(Tunnels[I+1, J+1].X, Tunnels[I+1, J+1].Y, Tunnels[I+1, J+1].Z);
          glTexCoord2f((I-1)/16, J2); glVertex3f(Tunnels[ I,  J+1].X, Tunnels[ I,  J+1].Y, Tunnels[ I,  J+1].Z);
        end;
      glEnd();

    end;

    //--- Outside tunnel ---//
    // setup tunnel coordinates
    for I :=0 to 16 do
    begin
      X :=cos(PI_8*I);
      Y :=sin(PI_8*I);
      for J :=0 to 28 do
      begin
        Tunnels[I, J].X :=(2.4 - J/12)*X + 2.0*sin((Angle+2*j)/27) + cos((Angle+2*j)/13) - 2*A1 - A3;
        Tunnels[I, J].Y :=(2.4 - J/12)*Y + 2.5*cos((Angle+2*j)/33) + sin((Angle+2*j)/17) - 2*A2 - A4;
        Tunnels[I, J].Z :=-J;
      end;
    end;

    X :=DemoTime/120;
    glEnable(GL_DEPTH_TEST);
    glBindTexture(GL_TEXTURE_2D, FireTex);
    glEnable(GL_BLEND);
    For J :=0 to 27 do
    begin
      J1 :=J/32 + Angle*TUNNEL_SPEED;        // precalculate texture v coords for speed
      J2 :=(J+1)/32 + Angle*TUNNEL_SPEED;

      // near the end of the tunnel, fade the effect away
      if J > 24 then
        C :=1.0-(J-24)/10
      else
        C :=1.0;

      // fade in tunnel
      if DemoTime < 500 then
        C :=C*DemoTime/500;

      glColor3f(C, C, C);

      glBegin(GL_QUADS);
        For I :=0 to 15 do
        begin
          glTexCoord2f((I-1 + X)/16, J1); glVertex3f(Tunnels[ I,   J ].X, Tunnels[ I,   J ].Y, Tunnels[ I,   J ].Z);
          glTexCoord2f(( I  + X)/16, J1); glVertex3f(Tunnels[I+1,  J ].X, Tunnels[I+1,  J ].Y, Tunnels[I+1,  J ].Z);
          glTexCoord2f(( I  + X)/16, J2); glVertex3f(Tunnels[I+1, J+1].X, Tunnels[I+1, J+1].Y, Tunnels[I+1, J+1].Z);
          glTexCoord2f((I-1 + X)/16, J2); glVertex3f(Tunnels[ I,  J+1].X, Tunnels[ I,  J+1].Y, Tunnels[ I,  J+1].Z);
        end;
      glEnd();
    end;
  glPopMatrix;

  // --- Drawing the Blob and Rectangle --- //
  if DemoTime > 9700 then
  begin
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glColor3f(1.0, 1.0, 1.0);

    X :=(DemoTime-9700)/800;
    if X > 1 then X :=1;
    glScale(X, X, 1);
    glTranslatef(0.7,-0.52, -2.4);

    // Rectangle (blob frame)
    glDisable(GL_TEXTURE_2D);
    glLineWidth(3);
    glBegin(GL_LINE_LOOP);
      glVertex3f(-0.4, -0.3, 0.01);
      glVertex3f( 0.4, -0.3, 0.01);
      glVertex3f( 0.4,  0.3, 0.01);
      glVertex3f(-0.4,  0.3, 0.01);
    glEnd;
    glEnable(GL_TEXTURE_2D);

    // Blob
//    if DemoTime > 8200 then
//    begin
      C :=DemoTime/1000;

      for i := 0 to numVertices-1 do
      begin
        Y := 1 + 0.1*((1 - cos(LU[i].X + C*5)) +
                      (1 - cos(LU[i].Y + C*7)) +
                      (1 - cos(LU[i].Z + C*8)));
        blob.vertex[i].x := sphere.vertex[i].x * Y;
        blob.vertex[i].y := sphere.vertex[i].y * Y;
        blob.vertex[i].z := sphere.vertex[i].z * Y;
      end;

      glPushMatrix();
        glScale(0.015, 0.015, 0.015);
        glRotate(-DemoTime/50, 0, 0, 1);
        glBindTexture(GL_TEXTURE_2D, BlobTex);
        renderBlob(blob);
      glPopMatrix();
//    end;

    // Expanding frame
    if (DemoTime > 13500) AND (DemoTime < 14400) then
    begin
      X :=(DemoTime-13500)/800;
      X :=X;
      Y:=3*X/4;
      glTranslatef(-4*X/5, 4*Y/5, 0.0);

      // Rectangle (blob frame)
      glDisable(GL_TEXTURE_2D);
      glBegin(GL_LINE_LOOP);
        glVertex3f(-0.4-X, -0.3-Y, 0.01);
        glVertex3f( 0.4+X, -0.3-Y, 0.01);
        glVertex3f( 0.4+X,  0.3+Y, 0.01);
        glVertex3f(-0.4-X,  0.3+Y, 0.01);
      glEnd;
      glEnable(GL_TEXTURE_2D);
    end;

    // fade to white
    if DemoTime > 14400 then
    begin
      glEnable(GL_BLEND);
      glTranslatef(-0.7, 0.5, 0.6);
      glBindTexture(GL_TEXTURE_2D, WhiteTex);
      C :=(DemoTime - 10400)/100;
      if C > 1 then C :=1;

      if DemoTime > 14500 then
        C := (14500 - DemoTime)/100;

      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord(0, 0);  glVertex3f(-1, -1, 0);
        glTexCoord(1, 0);  glVertex3f( 1, -1, 0);
        glTexCoord(1, 1);  glVertex3f( 1,  1, 0);
        glTexCoord(0, 1);  glVertex3f(-1,  1, 0);
      glEnd;
    end;
  end;

  if ElapsedTime > BLOB_START then
  begin
    glLineWidth(1);
    Inc(Stage);
  end;
end;


procedure initTunnel;
var I : Integer;
begin
  CreateSphere(blob);
  Sphere :=Blob;
  for I :=0 to numVertices-1 do
  begin
    LU[i].X := ArcTan(sphere.vertex[i].x, sphere.vertex[i].y) * 5;
    LU[i].Y := ArcTan(sphere.vertex[i].x, sphere.vertex[i].z) * 6;
    LU[i].Z := ArcTan(sphere.vertex[i].y, sphere.vertex[i].z) * 8;
  end;
end;

end.
