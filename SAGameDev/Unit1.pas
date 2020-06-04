unit Unit1;

interface

  var ElapsedTime : Integer;             // Elapsed time between frames

  procedure glInit();
  procedure glDraw();

implementation


uses Windows, OpenGL, Textures;

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

const PI   = 3.1415926535897932384626433832795;
      PI2  = 6.2831853071795864769252867665590;
      PID2 = 1.5707963267948966192313216916398;
      TEXTURE_SPEED = 1/45;

const KNOT_START = 0;
      KNOT_END   = 30800;
      TWIST_START = 30801;
      TWIST_END   = 53500;
      TWIST_TUNNEL_START = 53501;
      TWIST_TUNNEL_END   = 56300;
      TUNNEL_START = 56301;
      TUNNEL_END   = 83000;
      TITLES_START = 83001;
      TITLES_END   = 107000;

type TParticle = Record
       X, Y, Z : glFloat;
       XSpeed, YSpeed, zSpeed : glFloat;
     end;
     glCoord = Record
       X, Y, Z : glFLoat;
     end;
     GLColors = Record
       R, G, B : glFloat;
     end;

var // Textures
    BackgroundTex : glUint;     // scene 1
    GirlTex : glUint;           // scene 1
    GirlMaskTex : glUint;       // scene 1
    DemoNameTex : glUint;       // scene 1
    CrowdsTex : glUint;         // scene 2
    TunnelTex : glUint;         // scene 3
    TunnelBGTex : glUint;       // scene 3
    ParticleTex : glUint;       // scene 3
    StarBurstTex : glUint;      // titles
    TitlesTex    : glUint;      // titles

    // User variables
    XCoord, YCoord, ZCoord : Array[0..23, 0..23] of glFloat; // X, Y and Z coordinates of Grid for Twist
    Particle : Array[1..40] of TParticle;


{------------------------------------------------------------------}
{  Function to do an arctan fast                                   }
{------------------------------------------------------------------}
function ArcTan(X, Y : glFloat) : glFloat;
asm
  FLD     Y
  FLD     X
  FPATAN
  FWAIT
end;


{-------------------------------------------------------------------------}
{---  Loads the textures needed in the Demo                            ---}
{-------------------------------------------------------------------------}
procedure LoadDemoTextures;
begin
  LoadTexture('bg.bmp', BackgroundTex, true);
  LoadTexture('text.jpg', DemonameTex, true);
  LoadTexture('chick.jpg', GirlTex, true);
  LoadTexture('chick_mask.jpg', GirlMaskTex, true);
  LoadTexture('warp.jpg', CrowdsTex, true);
  LoadTexture('stargatetunnel.bmp', TunnelTex, true);
  LoadTexture('space.jpg', TunnelBGTex, true);
  LoadTexture('particle.jpg', ParticleTex, true);
  LoadTexture('starburst.jpg', StarBurstTex, true);
  LoadTexture('titles.jpg', TitlesTex, true);
end;


{-------------------------------------------------------------------------}
{---  Draw the flexing knot.                                           ---}
{-------------------------------------------------------------------------}
type TmyObject = Record
       numfaces, numverts, numsides : Integer;
       faces    : Array of gluint;            //numfaces*numsides
       vertices : Array of glCoord;           //numverts
       Colors   : Array of GLColors;          //numverts
     end;
var myObject : TmyObject;

{-----  Create the basic knot shape  -----}
procedure createKnot(SCALING_FACTOR1, SCALING_FACTOR2 : Integer; RADIUS1, RADIUS2, RADIUS3 : glFloat);
var Count1, Count2 : Integer;
    Alpha, Beta, Distance, MinDistance, Rotation : glFloat;
    X, Y, Z, dx, dy, dz : glFLoat;
    Value, modulus, dist : glFloat;
    index1, index2 : Integer;
begin
  myObject.numSides :=4;

  setLength(myObject.vertices, SCALING_FACTOR1 * SCALING_FACTOR2);  //myObject.numverts);
  setLength(myObject.colors,   SCALING_FACTOR1 * SCALING_FACTOR2);  //myObject.numverts);
  setLength(myObject.faces, SCALING_FACTOR1 * SCALING_FACTOR2 * 4 * 4);  //myObject.numfaces*myObject.numsides);

  Alpha :=0;
  for Count2 :=0 to SCALING_FACTOR2-1 do
  begin
    Alpha :=Alpha + 2*PI / SCALING_FACTOR2;
    X := RADIUS2 * cos(2 * Alpha) + RADIUS1 * sin(Alpha);
    Y := RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
    Z := RADIUS2 * cos(3 * Alpha);
    dx := -2 * RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
    dy := 2 * RADIUS2 * cos(2 * Alpha) - RADIUS1 * sin(Alpha);
    dz := -3 * RADIUS2 * sin(3 * Alpha);
    Value := sqrt(dx * dx + dz * dz);
    Modulus := sqrt(dx * dx + dy * dy + dz * dz);

    Beta :=0;
    For Count1 :=0 to SCALING_FACTOR1-1 do
    begin
      Beta :=Beta + 2 * PI / SCALING_FACTOR1;

      myObject.vertices[myObject.numverts].x := X - RADIUS3 * (cos(Beta) * dz - sin(Beta) * dx * dy / Modulus) / Value;
      myObject.vertices[myObject.numverts].y := Y - RADIUS3 * sin(Beta) * Value / Modulus;
      myObject.vertices[myObject.numverts].z := Z + RADIUS3 * (cos(Beta) * dx + sin(Beta) * dy * dz / Modulus) / Value;


      dist := sqrt(myObject.vertices[myObject.numverts].x*myObject.vertices[myObject.numverts].x +
                   myObject.vertices[myObject.numverts].y*myObject.vertices[myObject.numverts].y +
                   myObject.vertices[myObject.numverts].z*myObject.vertices[myObject.numverts].z);

      myObject.colors[myObject.numverts].r := ((2/dist)+(0.5*sin(Beta)+0.4))/2.0;
      myObject.colors[myObject.numverts].g := ((2/dist)+(0.5*sin(Beta)+0.4))/2.0;
      myObject.colors[myObject.numverts].b := ((2/dist)+(0.5*sin(Beta)+0.4))/2.0;

      Inc(myObject.numverts);
    end;
  end;

  for Count1 := 0 to SCALING_FACTOR2-1 do
  begin
    Index1 := Count1 * SCALING_FACTOR1;
    Index2 := Index1 + SCALING_FACTOR1;
    Index2 := Index2 MOD myObject.numverts;
    Rotation := 0;
    MinDistance := (myObject.vertices[Index1].x - myObject.vertices[Index2].x) * (myObject.vertices[Index1].x - myObject.vertices[Index2].x) +
                   (myObject.vertices[Index1].y - myObject.vertices[Index2].y) * (myObject.vertices[Index1].y - myObject.vertices[Index2].y) +
                   (myObject.vertices[Index1].z - myObject.vertices[Index2].z) * (myObject.vertices[Index1].z - myObject.vertices[Index2].z);
    for Count2 := 1 to SCALING_FACTOR1-1 do
    begin
      Index2 := Count2 + Index1 + SCALING_FACTOR1;
      if Count1 = SCALING_FACTOR2 - 1 then
        Index2 := Count2;
      Distance := (myObject.vertices[Index1].x - myObject.vertices[Index2].x) * (myObject.vertices[Index1].x - myObject.vertices[Index2].x) +
                  (myObject.vertices[Index1].y - myObject.vertices[Index2].y) * (myObject.vertices[Index1].y - myObject.vertices[Index2].y) +
                  (myObject.vertices[Index1].z - myObject.vertices[Index2].z) * (myObject.vertices[Index1].z - myObject.vertices[Index2].z);
      if Distance < MinDistance then
      begin
        MinDistance := Distance;
        Rotation := Count2;
      end;
    end;

    for Count2 := 0 to SCALING_FACTOR1 -1 do
    begin
      myObject.faces[4*(Index1+Count2)+0] := Index1 + Count2;

      Index2 := Count2 + 1;
      Index2 := Index2 MOD SCALING_FACTOR1;
      myObject.faces[4*(Index1+Count2)+1] := Index1 + Index2;

      Index2 := Round(Count2 + Rotation + 1);
      Index2 := Index2 MOD SCALING_FACTOR1;
      myObject.faces[4*(Index1+Count2)+2] := (Index1 + Index2 + SCALING_FACTOR1) MOD  myObject.numverts;

      Index2 := Round(Count2 + Rotation);
      Index2 := Index2 MOD SCALING_FACTOR1;

      myObject.faces[4*(Index1+Count2)+3] := (Index1 + Index2 + SCALING_FACTOR1) MOD myObject.numverts;
      Inc(myObject.numfaces);
    end;
  end;
end;


{-----  Recalculate the knot shape for every frame  -----}
procedure ReCalculateKnot(SCALING_FACTOR1, SCALING_FACTOR2 : Integer; RADIUS1, RADIUS2, RADIUS3 : glFloat);
var Count1, Count2 : Integer;
    Alpha, Beta : glFloat;
    X, Y, Z, dx, dy, dz : glFLoat;
    Value, modulus : glFloat;
    index1, index2 : Integer;
    Distance, MinDistance, Rotation : glFloat;
begin
  myObject.numverts :=0;
  Alpha :=0;
  for Count2 :=0 to SCALING_FACTOR2-1 do
  begin
    Alpha :=Alpha + 2*PI / SCALING_FACTOR2;
    X := RADIUS2 * cos(2 * Alpha) + RADIUS1 * sin(Alpha);
    Y := RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
    Z := RADIUS2 * cos(3 * Alpha);
    dx := -2 * RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
    dy := 2 * RADIUS2 * cos(2 * Alpha) - RADIUS1 * sin(Alpha);
    dz := -3 * RADIUS2 * sin(3 * Alpha);
    Value := sqrt(dx * dx + dz * dz);
    Modulus := sqrt(dx * dx + dy * dy + dz * dz);

    Beta :=0;
    For Count1 :=0 to SCALING_FACTOR1-1 do
    begin
      Beta :=Beta + 2 * PI / SCALING_FACTOR1;

      myObject.vertices[myObject.numverts].x := X - RADIUS3 * (cos(Beta) * dz - sin(Beta) * dx*dy/Modulus) / Value;
      myObject.vertices[myObject.numverts].y := Y - RADIUS3 *  sin(Beta) * Value / Modulus;
      myObject.vertices[myObject.numverts].z := Z + RADIUS3 * (cos(Beta) * dx + sin(Beta) * dy*dz/Modulus) / Value;

      Inc(myObject.numverts);
    end;
  end;

  myObject.numfaces :=0;
  for Count1 := 0 to SCALING_FACTOR2-1 do
  begin
    Index1 := Count1 * SCALING_FACTOR1;
    Index2 := Index1 + SCALING_FACTOR1;
    Index2 := Index2 MOD myObject.numverts;
    Rotation := 0;
    MinDistance := (myObject.vertices[Index1].x - myObject.vertices[Index2].x) * (myObject.vertices[Index1].x - myObject.vertices[Index2].x) +
                   (myObject.vertices[Index1].y - myObject.vertices[Index2].y) * (myObject.vertices[Index1].y - myObject.vertices[Index2].y) +
                   (myObject.vertices[Index1].z - myObject.vertices[Index2].z) * (myObject.vertices[Index1].z - myObject.vertices[Index2].z);
    for Count2 := 1 to SCALING_FACTOR1-1 do
    begin
      Index2 := Count2 + Index1 + SCALING_FACTOR1;
      if Count1 = SCALING_FACTOR2 - 1 then
        Index2 := Count2;
      Distance := (myObject.vertices[Index1].x - myObject.vertices[Index2].x) * (myObject.vertices[Index1].x - myObject.vertices[Index2].x) +
                  (myObject.vertices[Index1].y - myObject.vertices[Index2].y) * (myObject.vertices[Index1].y - myObject.vertices[Index2].y) +
                  (myObject.vertices[Index1].z - myObject.vertices[Index2].z) * (myObject.vertices[Index1].z - myObject.vertices[Index2].z);
      if Distance < MinDistance then
      begin
        MinDistance := Distance;
        Rotation := Count2;
      end;
    end;

    for Count2 := 0 to SCALING_FACTOR1 -1 do
    begin
      myObject.faces[4*(Index1+Count2)+0] := Index1 + Count2;

      // hiding this line generates triangles
      if (ElapsedTime < 13000) OR (ElapsedTime > 27000) then
        Index2 := Round(Count2 + Rotation + 1);

      // hiding this line generates glue
      if (ElapsedTime < 18000) OR (ElapsedTime > 24000) then
        Index2 := Index2 MOD SCALING_FACTOR1;

      myObject.faces[4*(Index1+Count2)+2] := (Index1 + Index2 + SCALING_FACTOR1) MOD  myObject.numverts;

      Index2 := Round(Count2 + Rotation);
      Index2 := Index2 MOD SCALING_FACTOR1;

      myObject.faces[4*(Index1+Count2)+3] := (Index1 + Index2 + SCALING_FACTOR1) MOD myObject.numverts;
      Inc(myObject.numfaces);
    end;
  end;
end;


procedure drawKnot;
var I, J, num : Integer;
begin
  glBegin(GL_QUADS);
    J := myObject.numfaces*4;
    for I :=0 to J do
    begin
      num := myObject.faces[i];
      // after 7 seconds, throw in some color
      if ElapsedTime > 7000 then
        glColor3f(myObject.Colors[num].r*2, myObject.Colors[num].g, myObject.Colors[num].b);
      glVertex3f(myObject.vertices[num].x, myObject.vertices[num].y,  myObject.vertices[num].z);
    end;
  glEnd();
end;


{---- Demo part of the knot effect. ---}
procedure drawKnotEffect;
begin
  glTranslatef(0.0,0.0,-15);

  // Slide off screen after number of seconds
  if ElapsedTime > 29300 then
    glTranslate((ElapsedTime-29300)/100, 0, 0);

  // Draw the background
  glBindTexture(GL_TEXTURE_2D, BackGroundTex);
  glBegin(GL_QUADS);
    glNormal3f( 0.0, 0.0, 1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f(-9.0, -7.0, 0.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 9.0, -7.0, 0.0);
    glTexCoord2f(1.0, 7.0); glVertex3f( 9.0,  7.0, 0.0);
    glTexCoord2f(0.0, 7.0); glVertex3f(-9.0,  7.0, 0.0);
  glEnd();

  // background must slide faster, because its further away, so add negative slide here.
  if ElapsedTime > 29500 then
    glTranslate((29500-ElapsedTime)/170, 0, 0);

  // Draw the demo name
  glTranslatef(2.0, 1.0, 9.0);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  glEnable(GL_BLEND);
  glBindTexture(GL_TEXTURE_2D, DemonameTex);  // Bind the Texture to the object
  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.4); glVertex3f(-1.0, -0.2, 0.0);
    glTexCoord2f(1.0, 0.4); glVertex3f( 1.0, -0.2, 0.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0.0);
  glEnd();

  // draw the girl mask
  glTranslatef(0.45, -2.3,0.5);
  glBlendFunc(GL_DST_COLOR,GL_ZERO);			// Blend Screen Color With Zero (Black)
  glBindTexture(GL_TEXTURE_2D, GirlMaskTex);  // Bind the Texture to the object
  glBegin(GL_QUADS);
    glTexCoord2f(0.2, 0.0); glVertex3f(-0.6, -1.0, 0.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, 0.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, 0.0);
    glTexCoord2f(0.2, 1.0); glVertex3f(-0.6,  1.0, 0.0);
  glEnd();

  // draw the girl
  glTranslatef(0.0, 0.0, 0.0001);
  glBlendFunc(GL_ONE, GL_ONE);
  glBindTexture(GL_TEXTURE_2D, GirlTex);  // Bind the Texture to the object
  glBegin(GL_QUADS);
    glTexCoord2f(0.2, 0.0); glVertex3f(-0.6, -1.0, 0.001);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, 0.001);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, 0.001);
    glTexCoord2f(0.2, 1.0); glVertex3f(-0.6,  1.0, 0.001);
  glEnd();

  // draw the knot
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glColor(0.9, 0.9, 0.9);
  glTranslatef(-3.4, 1.2, -1.5);
  glScale(0.2, 0.2, 0.2);
  if ElapsedTime < 8400 then
  begin
    glPolygonMode(GL_FRONT, GL_LINE);
    glPolygonMode(GL_BACK, GL_LINE);
  end;

  glRotatef(ElapsedTime/10, 1, 0, 0);
  glRotatef(ElapsedTime/7, 0, 1, 0);

  if ElapsedTime < 4200 then   // start with torus sphape
    ReCalculateKnot(16, 64, 6, 0, 1.8)
  else if (ElapsedTime > 4200) AND (ElapsedTime < 5000) then   // fade torus to prepare for bounce
  begin
    ReCalculateKnot(16, 64, 6, 0, 1.8);
    glScale(1-(ElapsedTime-4200)/1000, 1-(ElapsedTime-4200)/1000, 1-(ElapsedTime-4200)/1000);
  end
  else
    ReCalculateKnot(16, 64, 3*sin(0.017*ElapsedTime)+4, 2*cos(0.008*ElapsedTime)+2.5, 1.1);

  drawKnot;
  glEnable(GL_TEXTURE_2D);

  glColor3f(1, 1, 1);
  glPolygonMode(GL_FRONT, GL_FILL);
end;


{------------------------------------------------------------------------}
{---  Draw Twisting warping effect                                    ---}
{------------------------------------------------------------------------}
procedure DrawTwist;
var I, J : Integer;
    Radius, R, angle, x, y : glFLoat;
    Effect : glFloat;
    XPos, YPos, ZPos1, ZPos2 : glFloat;
begin
  glBindTexture(GL_TEXTURE_2D, CrowdsTex);

  // zoom the twisting image into scene
  if ElapsedTime < (TWIST_START+1200) then
  begin
    glPolygonMode(GL_BACK, GL_FILL);
    glTranslatef(0.0, 0.0, -2.4 + (ElapsedTime-(TWIST_START+1200))/80);
    if ElapsedTime < (TWIST_START+1000) then
    glRotate((ElapsedTime-TWIST_START-1000)/10, 1, 0, 0);
  end
  else
    glTranslatef(0.0, 0.0, -2.4);

  // right at the end, bring the scene closer
  if ElapsedTime > (TWIST_END-1000) then
    glTranslatef(0.0, 0.0, 1 - (TWIST_END-ElapsedTime)/1000);

  // general interesting movement of scene
  glRotate(25*sin(ElapsedTime/200), 1, 0, 0);
  glRotate(25*sin(ElapsedTime/250), 0, 1, 0);

  // caluclate the type and amount of twist
  // first one twists entire scene, next only part of the scene
  if ElapsedTime < TWIST_START+3140 then
  begin
    Effect :=3.2*sin((ElapsedTime-TWIST_START)/1000);
    if Effect < 0 then
      Effect :=0;
    Radius :=2.9;
    XPos :=0;
    YPos :=0;
  end
  else  // dancing twist stage
  begin
    Radius :=0.6;
    Effect :=2.8;
    XPos :=0.6*Sin(ElapsedTime/400) + 0.6*Sin(ElapsedTime/170);
    YPos :=0.5*Cos(ElapsedTime/300) + 0.5*cos(ElapsedTime/140);
  end;

  x :=-1.15;
  y :=-1.2;

  // Generate new X and Y coordinates for the grid
  For I := 0 to 23 do
  begin
    For J :=0 to 23 do
    begin
      R :=sqrt((x-Xpos)*(x-Xpos) + (y-YPos)*(y-YPos));          // Get the radius of the current point
      angle := arctan((x-Xpos),(y-YPos));         // Get the angle at that point
      if r < Radius then               // If we're inside the affected radius
        angle :=angle + (Radius -R)* Effect;

      XCoord[I][J] :=XPos + R*cos(angle);  // Recalculate coordinates
      YCoord[I][J] :=YPos + R*sin(angle);
      y :=y + 0.1;
    end;
    x :=x + 0.1;
    y :=-1.2;
  end;

  // Calculate amount of curvature in the surface
  if (ElapsedTime > TWIST_START+9412) AND (ElapsedTime <= TWIST_START+16952) then
  begin
    ZPos1 :=2*sin(ElapsedTime/800);   // both surfaces curve together
    ZPos2 :=2*sin(ElapsedTime/800);
  end
  else if (ElapsedTime > TWIST_START+16952) AND (ElapsedTime <= TWIST_START+21978) then   {24292}
  begin
    ZPos1 :=1.5*sin(ElapsedTime/800);   // both survafes curve, but in opposite directions
    ZPos2 :=-1.5*sin(ElapsedTime/800);
  end
  else
  begin
    ZPos1 :=0;   // no curvature. surfaces flat.
    ZPos2 :=0;
  end;

  // Draw the newly calculated vertices
  glBegin(GL_TRIANGLES);
    for J :=1 to 22 do
    begin
      for I :=1 to 22 do
      begin
        // Draw the first triangle of the quad
        glTexCoord2f(i/23,     j/23);     glVertex3f(XCoord[i-1][j], YCoord[i-1][j], ZPos1*ZCoord[i-1][j]);
        glTexCoord2f((i+1)/23, j/23);     glVertex3f(XCoord[i][j],   YCoord[i][j],   ZPos1*ZCoord[i][j]);
        glTexCoord2f((i+1)/23, (j+1)/23); glVertex3f(XCoord[i][j+1], YCoord[i][j+1], ZPos1*ZCoord[i][j+1]);
        // Draw the second triangle of the quad
        glTexCoord2f(i/23,     j/23);    glVertex3f(XCoord[i-1][j],   YCoord[i-1][j],    ZPos2*ZCoord[i-1][j]);
        glTexCoord2f((i+1)/23, (j+1)/23); glVertex3f(XCoord[i][j+1],   YCoord[i][j+1],   ZPos2*ZCoord[i][j+1]);
        glTexCoord2f(i/23,     (j+1)/23); glVertex3f(XCoord[i-1][j+1], YCoord[i-1][j+1], ZPos2*ZCoord[i-1][j+1]);
      end;
    end;
  glEnd();
end;


{------------------------------------------------------------------------}
{---  Draw The transition between he twist effect and the tunnel      ---}
{------------------------------------------------------------------------}
procedure drawTwistToTunnelFade;
var X, Y : glFloat;
    I : glUint;
    DemoTime: Integer;
begin
  DemoTime := ElapsedTime-TWIST_TUNNEL_START;

  glTranslatef(0.0, 0.0, -1.4);

  // if tunnel has been created, fly down tunnel
  if DemoTime > 1500 then
    glTranslate(0.0, 0.0, 2+(DemoTime-1500)/6);

  // if at the zoom stage, draw a normal square, else draw a triangle fan
  glBindTexture(GL_TEXTURE_2D, CrowdsTex);
  glBegin(GL_TRIANGLE_FAN);
    glTexCoord2f(0.5, 0.5); glVertex3f( 0, 0, -DemoTime/14);   // center
    for I :=1 to 17 do
    begin
      X :=cos(I*PI/8);
      Y :=sin(I*PI/8);
      glTexCoord2f(X/2+0.5, Y/2+0.5);  // range from 0 - 1
      glVertex3f(X, Y, 0);
    end;
  glEnd();
end;


{------------------------------------------------------------------------}
{---  Draws the stargate tunnel effect                                ---}
{------------------------------------------------------------------------}
procedure DrawTunnel;
var I, J : Integer;
    Angle : glFloat;
    C, R, A1, A2, A3, A4 : glFLoat;  // temp variables
    ParticleX, ParticleY, ParticleZ : glFloat;
    Tunnels : Array[0..12, 0..32] of glCoord;
    DemoTime : Integer;
begin
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);

  glTranslatef(0.0,0.0,-4.1);
  DemoTime :=(ElapsedTime-TUNNEL_START);
  Angle :=DemoTime/14;

  // setup tunnel coordinates
  A1 := -2*cos(Angle/29) - sin(Angle/13);
  A2 := -2*sin(Angle/33) - cos(Angle/17);
  for I :=0 to 12 do
  begin
    A3 :=0.5235987756*I;     // = 2*pi/12*I
    for J :=0 to 31 do
    begin
      A4 :=Angle+2*j;
      Tunnels[I, J].X :=(3 - J/12)*sin(A3) + 2*cos(A4/29) + sin(A4/13) + A1;  // (3 - J/12)*cos(2*pi/12*I) + 2*sin((Angle+2*j)/29) + cos((Angle+2*j)/13) - 2*sin(Angle/29) - cos(Angle/13);}
      Tunnels[I, J].Y :=(3 - J/12)*cos(A3) + 2*sin(A4/33) + cos(A4/17) + A2;  // (3 - J/12)*sin(2*pi/12*I) + 2*cos((Angle+2*j)/33) + sin((Angle+2*j)/17) - 2*cos(Angle/33) - sin(Angle/17);
    end;
  end;


  // draw the tunnel
  glEnable(GL_DEPTH_TEST);                // hides the tunnel in the distance
  glBindTexture(GL_TEXTURE_2D, TunnelTex);
  For J :=0 to 30 do
  begin
    A1 :=J/32 + Angle*TEXTURE_SPEED;      // precalculate texture v coords for speed
    A2 :=(J+1)/32 + Angle*TEXTURE_SPEED;

    // near the end of the tunnel, fade the effect away
    if J > 24 then
      C :=1.0-(J-24)/10
    else
      C :=1.0;

    // fade in tunnel
    if DemoTime < 2000 then
      C :=C*DemoTime/2000;

    glColor3f(C, C, C);

    glBegin(GL_QUADS);
      For I :=0 to 11 do
      begin
        glTexCoord2f(    I/12, A1);   glVertex3f(Tunnels[ I,   J ].X, Tunnels[ I,   J ].Y, -J  );
        glTexCoord2f((I+1)/12, A1);   glVertex3f(Tunnels[I+1,  J ].X, Tunnels[I+1,  J ].Y, -J  );
        glTexCoord2f((I+1)/12, A2);   glVertex3f(Tunnels[I+1, J+1].X, Tunnels[I+1, J+1].Y, -J-1);
        glTexCoord2f(    I/12, A2);   glVertex3f(Tunnels[ I,  J+1].X, Tunnels[ I,  J+1].Y, -J-1);
      end;
    glEnd();
  end;

  // Draw the Background image
  C :=C+0.1;
  glColor3f(C, C, C);
  C := DemoTime/20000;
  glTranslate(0, 0, C);
  glDisable(GL_DEPTH_TEST);
  glBindTexture(GL_TEXTURE_2D, TunnelBGTex);
  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex3f(-2,-2, 0);
    glTexCoord2f(1, 0); glVertex3f( 2,-2, 0);
    glTexCoord2f(1, 1); glVertex3f( 2, 2, 0);
    glTexCoord2f(0, 1); glVertex3f(-2, 2, 0);
  glEnd();
  glTranslate(0, 0, -C);

  // at the end of the sequence, fade in the starburst
  if (TUNNEL_END-ElapsedTime) < 500 then
  begin
    C := 1-(TUNNEL_END-ElapsedTime)/500;
    glColor3f(C, C, C);
    glRotate(Angle/2, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, StarBurstTex);
    glBegin(GL_QUADS);
      glTexCoord2f(0, 0); glVertex3f(-3,-3, 0);
      glTexCoord2f(1, 0); glVertex3f( 3,-3, 0);
      glTexCoord2f(1, 1); glVertex3f( 3, 3, 0);
      glTexCoord2f(0, 1); glVertex3f(-3, 3, 0);
    glEnd();
    glRotate(-Angle, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, StarBurstTex);
    glBegin(GL_QUADS);
      glTexCoord2f(0, 0); glVertex3f(-3,-3, 0);
      glTexCoord2f(1, 0); glVertex3f( 3,-3, 0);
      glTexCoord2f(1, 1); glVertex3f( 3, 3, 0);
      glTexCoord2f(0, 1); glVertex3f(-3, 3, 0);
    glEnd();
  end;


  // Draw the particles
  if DemoTime > 5000 then
  begin
    glBindTexture(GL_TEXTURE_2D, ParticleTex);
    A1 := -2*cos(Angle/29) - sin(Angle/13);
    A2 := -2*sin(Angle/33) - cos(Angle/17);

    if (DemoTime > 11000) AND (DemoTime < 23000)then
      J :=40
    else
      J :=1;

    glColor3f(0, 0.8, 0);
    For I :=1 to J do
    begin
      // Set up particle coordinates based on tunnel coords
      ParticleZ :=(DemoTime-7000-J*150)/(200-(DemoTime-4000)/140) - Particle[I].Z*3;

      if ParticleZ > 24 then
        Particle[I].Z :=(DemoTime-7000-J*150)/(200-(DemoTime-4000)/140 -24)/3;

      A4 :=Angle+2*ParticleZ;
      ParticleX := 2*cos(A4/29) + sin(A4/13) + A1;
      ParticleY := 2*sin(A4/33) + cos(A4/17) + A2;
      R :=1/(6+ParticleZ/2);

      glPushMatrix();
        glTranslate(ParticleX + Particle[I].X, ParticleY + Particle[I].Y, -ParticleZ);
        glScale(R, R, R);
        glBegin(GL_QUADS);
          glTexCoord2f(0.0, 0.0); glVertex3f(-1, -1, 0);
          glTexCoord2f(1.0, 0.0); glVertex3f( 1, -1, 0);
          glTexCoord2f(1.0, 1.0); glVertex3f( 1,  1, 0);
          glTexCoord2f(0.0, 1.0); glVertex3f(-1,  1, 0);
        glEnd();
      glPopMatrix;
    end;
  end;
end;


{------------------------------------------------------------------}
{---  Draw the end titles                                       ---}
{------------------------------------------------------------------}
procedure DrawTitles;
var C : glFloat;
    DemoTime : glFloat;
begin
  DemoTime :=ElapsedTime - TITLES_START;

  if (ElapsedTime - TITLES_END) < 1000 then
  begin
    C :=(TITLES_END - ElapsedTime)/1000;
    glColor3f(C, C, C);
  end
  else
    glColor3f(1, 1, 1);

  glTranslatef(0.0,0.0,-1.4);

  glPushMatrix();
    glBlendFunc(GL_ONE,GL_ONE);
    glRotatef(DemoTime/55, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, StarBurstTex);
    glBegin(GL_QUADS);
      glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  0.0);
      glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  0.0);
      glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  0.0);
      glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  0.0);
    glEnd();

    glRotatef(-2.0*DemoTime/55, 0, 0, 1);
    glBegin(GL_QUADS);
      glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  0.0);
      glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  0.0);
      glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  0.0);
      glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  0.0);
    glEnd();
  glPopMatrix;

  glBindTexture(GL_TEXTURE_2D, TitlesTex);

  if DemoTime > 3000 then  // start showing the titles
  begin
    DemoTime :=(DemoTime-3000)/40;
    glTranslate(0, -2.5, -3.5);
    if DemoTime < 75 then            // Demo Name
    begin
      C :=0.8*Sin((DemoTime-0)/24);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.9); glVertex3f(-1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.9); glVertex3f( 1.0, 0.8, 0);
        glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0);
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0);
      glEnd();
    end
    else
    if (DemoTime >= 75) AND (DemoTime < 150) then            // SAGamedev competition entry
    begin
      C :=0.8*Sin((DemoTime-75)/24);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.78); glVertex3f(-1.8, 0.8, 0);
        glTexCoord2f(1.0, 0.78); glVertex3f( 0.2, 0.8, 0);
        glTexCoord2f(1.0, 0.88); glVertex3f( 0.2, 1.0, 0);
        glTexCoord2f(0.0, 0.88); glVertex3f(-1.8, 1.0, 0);
      glEnd();
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.65); glVertex3f(-0.2, 0.8, 0);
        glTexCoord2f(1.0, 0.65); glVertex3f( 1.8, 0.8, 0);
        glTexCoord2f(1.0, 0.76); glVertex3f( 1.8, 1.0, 0);
        glTexCoord2f(0.0, 0.76); glVertex3f(-0.2, 1.0, 0);
      glEnd();
    end;
    if (DemoTime >= 150) AND (DemoTime < 225) then            // Design
    begin
      C :=0.8*Sin((DemoTime-150)/24);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.53); glVertex3f(-1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.53); glVertex3f( 1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.64); glVertex3f( 1.0, 1.0, 0);
        glTexCoord2f(0.0, 0.64); glVertex3f(-1.0, 1.0, 0);
      glEnd();
    end;
    if (DemoTime >= 225) AND (DemoTime < 300) then            // Code
    begin
      C :=0.8*Sin((DemoTime-225)/24);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.41); glVertex3f(-1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.41); glVertex3f( 1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.52); glVertex3f( 1.0, 1.0, 0);
        glTexCoord2f(0.0, 0.52); glVertex3f(-1.0, 1.0, 0);
      glEnd();
    end;
    if (DemoTime >= 300) AND (DemoTime < 375) then            // Graphics
    begin
      C :=0.8*Sin((DemoTime-300)/24);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.29); glVertex3f(-1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.29); glVertex3f( 1.0, 0.8, 0);
        glTexCoord2f(1.0, 0.40); glVertex3f( 1.0, 1.0, 0);
        glTexCoord2f(0.0, 0.40); glVertex3f(-1.0, 1.0, 0);
      glEnd();
    end;
    if (DemoTime >= 375) AND (DemoTime < 520) then            // URL
    begin
      C :=0.8*Sin((DemoTime-375)/40);
      glColor3f(C, C, C);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.16); glVertex3f(-1.55, 0.8, 0);
        glTexCoord2f(1.0, 0.16); glVertex3f( 0.45, 0.8, 0);
        glTexCoord2f(1.0, 0.28); glVertex3f( 0.45, 1.0, 0);
        glTexCoord2f(0.0, 0.28); glVertex3f(-1.55, 1.0, 0);
      glEnd();
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.04); glVertex3f(-0.0, 0.8, 0);
        glTexCoord2f(1.0, 0.04); glVertex3f( 2.0, 0.8, 0);
        glTexCoord2f(1.0, 0.16); glVertex3f( 2.0, 1.0, 0);
        glTexCoord2f(0.0, 0.16); glVertex3f(-0.0, 1.0, 0);
      glEnd();
    end;
  end;
end;


{-------------------------------------------------------------------------}
{---  Initialise Local variables and objects                           ---}
{-------------------------------------------------------------------------}
procedure InitVariables;
Var I, J : Integer;
begin
  // create the momory space for a knot.
  createKnot(16, 64, 2, 2.0, 1.0);

  // precalculate the Z coordintes for the flexing plane in part 2
  For I := 0 to 23 do
    For J :=0 to 23 do
      ZCoord[I][J] :=Sqrt(sqr((i-12)/23) + sqr((j-12)/23));

  For I :=1 to 40 do
  begin
    Particle[I].XSpeed :=(Random(100)/2000 -0.025);  // Random speed
    Particle[I].YSpeed :=(Random(100)/2000 -0.025);
    Particle[I].ZSpeed :=(Random(100)/3000 + 0.2);
    Particle[I].X :=Random(100)/1000;  // Give it a random position based on the speed.
    Particle[I].Y :=Random(100)/1000;
    Particle[I].Z :=Random(100)/1000;
  end;

  // shuffle particles around a bit
  For J :=1 to 500 do
  begin
    For I :=1 to 40 do
    begin
      with Particle[I] do
      begin
        X := X + XSpeed;
        Y := Y + YSpeed;
        Z := Z + ZSpeed;
        if sqrt(X*X + Y*Y + Z*Z) > 16 then
        begin
          X :=0;
          Y :=0;
          Z :=0;
        end;
      end;
    end;
  end;

end;


{-------------------------------------------------------------------------}
{---  Function to draw the various demo scenes                         ---}
{-------------------------------------------------------------------------}
procedure glDraw();
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  case ElapsedTime of
    KNOT_START .. KNOT_END   : DrawKnotEffect;
    TWIST_START ..TWIST_END  : DrawTwist;
    TWIST_TUNNEL_START..TWIST_TUNNEL_END : DrawTwistToTunnelFade;
    TUNNEL_START..TUNNEL_END : DrawTunnel;
    TITLES_START..TITLES_END : DrawTitles;
  end;
end;


{------------------------------------------------------------------}
{---  Initialise OpenGL                                         ---}
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  glEnable(GL_TEXTURE_2D);

  LoadDemoTextures;
  InitVariables;
  ElapsedTime :=0;
end;


end.
