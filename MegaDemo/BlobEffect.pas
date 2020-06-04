unit BlobEffect;

interface

Uses Globals;

Const xRows =32;
      yRows =16;
      numVertices = 2*yrows*xrows+xrows+2;   //842;
      numTriangles = 2*xrows+yrows*xrows*4;  //1680;
      PI2  = 6.28318530717958647692528;  // 2*PI

type TTriangle = record
       V : Array[0..2] of Integer;     // Vertices
       T : Array[0..2] of TTexCoord;   // Texture coordinates
     end;
     TBlob = Record
       vertex : Array[0..numVertices-1] of TVertex;
       Triangle : Array[0..numTriangles-1] of TTriangle;
     end;

  procedure CreateSphere(var obj : TBlob);
  procedure RenderBlob(const obj : TBlob);
  procedure drawBlob;
  procedure initBlob;

implementation

Uses OpenGL;

var Blob : TBlob;
    sphere : TBlob;
    LU : Array[0..numVertices-1] of TVertex;

{------------------------------------------------------------------}
{  Function to create a sphere                                     }
{------------------------------------------------------------------}
procedure CreateSphere(var obj : TBlob);
const R = 10;
      yRing =yRows*4 + 4;
      uTex = 3.0 / (xRows);
      vTex = 3.0 / (3+2*yRows);
var X, Y, I, J : Integer;
    yLevel, Radius : glFloat;
    offset : Integer;
begin
  // Top center
  obj.vertex[0].x := 0;
  obj.vertex[0].z := 0;
  obj.vertex[0].y := -r;
  offset := 1;

  // Top half and center
  for Y :=0 to yRows do
  begin
    yLevel := -r*cos(PI2*(y+1) / yring);
    radius := r*sin(PI2*(y+1) / yring);

    for X :=0 to xRows-1 do
    begin
      obj.vertex[offset].x := radius * sin(PI2*x / xRows);
      obj.vertex[offset].z := radius * cos(PI2*x / xRows);
      obj.vertex[offset].y := yLevel;
      Inc(offset);
    end;
  end;

  // Bottom half
  for Y :=0 to yRows-1 do
  begin
    yLevel := r*sin(PI2*(y+1) / yring);
    radius := r*cos(PI2*(y+1) / yring);

    for X :=0 to xRows-1 do
    begin
      obj.vertex[offset].x := radius * sin(PI2*x / xRows);
      obj.vertex[offset].z := radius * cos(PI2*x / xRows);
      obj.vertex[offset].y := ylevel;
      Inc(offset);
    end;
  end;

  // Bottom center
  obj.vertex[offset].x := 0;
  obj.vertex[offset].z := 0;
  obj.vertex[offset].y := r;

  with Obj do
  begin
    for i :=0 to xRows-1 do
    begin
      Triangle[i].v[0] := 0;
      Triangle[i].v[1] := (i+1) MOD xRows +1;
      Triangle[i].v[2] := (i+1);

      Triangle[i].T[0].u := 0.5;
      Triangle[i].T[0].v := 0.0;
      Triangle[i].T[1].u := (i+1)*uTex;
      Triangle[i].T[1].v := vTex;
      Triangle[i].T[2].u := i*uTex;
      Triangle[i].T[2].v := vTex;
    end;

    for J :=0 to yRows*2 -1 do
    begin
      for I :=0 to xRows-1 do
      begin
        offset := xRows+(i+j*xRows)*2;
        Triangle[offset].v[0] := j*xRows+1 + i;
        Triangle[offset].v[1] := j*xRows+1 + (i+1) MOD xRows;
        Triangle[offset].v[2] := j*xRows+1 + i +xRows;

        Triangle[offset].T[0].u := i*uTex;
        Triangle[offset].T[0].v := (1+j) * vTex;
        Triangle[offset].T[1].u := (1+i) * uTex;
        Triangle[offset].T[1].v := (1+j) * vTex;
        Triangle[offset].T[2].u := i     * uTex;
        Triangle[offset].T[2].v := (2+j) * vTex;

        offset := xRows+(i+j*xRows)*2 + 1;
        Triangle[offset].v[0] := j*xRows+1+ (i+1) MOD xRows;
        Triangle[offset].v[1] := j*xRows+1+ (i+1) MOD xRows + xRows;
        Triangle[offset].v[2] := j*xRows+1+   i+xRows;

        Triangle[offset].T[0].u := (i+1) * uTex;
        Triangle[offset].T[0].v := (1+j) * vTex;
        Triangle[offset].T[1].u := (i+1) * uTex;
        Triangle[offset].T[1].v := (2+j) * vTex;
        Triangle[offset].T[2].u := i     * uTex;
        Triangle[offset].T[2].v := (2+j) * vTex;
      end;

      for i := 0 to xRows-1 do
      begin
        offset := xRows+xRows*2*yRows*2 + i;
        Triangle[offset].v[0] := 2*yRows*xRows+1+i;
        Triangle[offset].v[1] := 2*yRows*xRows+1+ (i+1) MOD xRows;
        Triangle[offset].v[2] := 2*yRows*xRows+1+xRows;

        Triangle[offset].T[0].u := i           * uTex;
        Triangle[offset].T[0].v := (yRows*2+1) * vTex;
        Triangle[offset].T[1].u := (i+1)       * uTex;
        Triangle[offset].T[1].v := (yRows*2+1) * vTex;
        Triangle[offset].T[2].u := 0.5;
        Triangle[offset].T[2].v := 1.0;
      end;
    end;
  end;
end;


{------------------------------------------------------------------}
{  Function to draw the blob (warped sphere)                       }
{------------------------------------------------------------------}
procedure RenderBlob(const obj : TBlob);
var I : Integer;
begin
  glBegin (GL_TRIANGLES);
    begin
      for I :=0 to numTriangles-1 do
      begin
        with obj.Triangle[i] do
        begin
          glTexCoord2f(T[0].u, T[0].v);
          glVertex3f(obj.vertex[v[0]].x, obj.vertex[v[0]].y, obj.vertex[v[0]].z);

          glTexCoord2f (T[1].u, T[1].v);
          glVertex3f (obj.vertex[v[1]].x, obj.vertex[v[1]].y, obj.vertex[v[1]].z);

          glTexCoord2f (T[2].u, T[2].v);
          glVertex3f (obj.vertex[v[2]].x, obj.vertex[v[2]].y, obj.vertex[v[2]].z);
        end;
      end;
    end;
  glEnd();

  if ElapsedTime > DEMO_END then
    Inc(Stage);
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure drawBlob;
var I : Integer;
    dist : glFLoat;
    C : glFloat;
    DemoTime, D : Integer;
begin
  DemoTime :=ElapsedTime - BLOB_START;

  // --- Draw Blob and Background --- //
  glPushMatrix();
    C :=DemoTime/1000;
    glTranslatef(0.0,0.0,-60);
    glColor3f(1.0, 1.0, 1.0);

    glRotatef(cos(C)*30, 1, 0, 0);
    glRotatef(cos(C)*10, 0, 1, 0);
    glRotatef(-30*C,     0, 0, 1);

    // Draw Background
    glPushMatrix();
      glDisable(GL_DEPTH_TEST);
      glTranslate(0, 0, -35);
      glScale(20, 20, 20);

      //galaxy background
      glBindTexture(GL_TEXTURE_2D, TunnelTex);
      RenderBlob(sphere);

      // blended fire background
      glRotatef(-15*C, 0, 0, 1);

      glEnable(GL_BLEND);
      glBindTexture(GL_TEXTURE_2D, FireTex);
      RenderBlob(sphere);
      glDisable(GL_BLEND);

      glEnable(GL_DEPTH_TEST);
    glPopMatrix;

    // Calculate New Blob shape
    for i := 0 to numVertices-1 do
    begin
      dist := 1 + 0.1*((1 - cos(LU[i].X + C*5)) +
                        (1 - cos(LU[i].Y + C*7)) +
                        (1 - cos(LU[i].Z + C*8)));
      blob.vertex[i].x := sphere.vertex[i].x * dist;
      blob.vertex[i].y := sphere.vertex[i].y * dist;
      blob.vertex[i].z := sphere.vertex[i].z * dist;
    end;

    // DrawBlob
    glBindTexture(GL_TEXTURE_2D, BlobTex);
    renderBlob(blob);

    // Draw wireframe Blob
    D :=DemoTime MOD 7000;
    if (D > 2000) and (D < 6000) then
    begin
      glEnable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
      glScalef(1.05, 1.05, 1.05);
      C :=0.7 - 0.7*(Abs(D - 3500) / 1500);
      glColor3f(C, C, C);

      renderBlob(blob);

      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
      glEnable(GL_TEXTURE_2D);
      glDisable(GL_BLEND);
    end;
  glPopMatrix();

  // Fade the sequence in
  if DemoTime < 100 then
  begin
    glEnable(GL_BLEND);
    C :=1-DemoTime/100;
    glColor3f(C, C, C);

    glBindTexture(GL_TEXTURE_2D, WhiteTex);
    glBegin(GL_QUADS);
      glTexCoord(0, 0);  glVertex3f(-1, -1, -1.8);
      glTexCoord(1, 0);  glVertex3f( 1, -1, -1.8);
      glTexCoord(1, 1);  glVertex3f( 1,  1, -1.8);
      glTexCoord(0, 1);  glVertex3f(-1,  1, -1.8);
    glEnd;
    glDisable(GL_BLEND);
  end;

  // Fade the sequence out
  if ElapsedTime > METABALL_START - 800 then
  begin
    C := (METABALL_START - ElapsedTime) / 800;
    glTranslatef(0.0,0.0,-2);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glColor3f(0, 0, 0);
    glBegin(GL_QUADS);
      glVertex3f(-1.2,  C , 0);
      glVertex3f( 1.2,  C , 0);
      glVertex3f( 1.2, C+1, 0);
      glVertex3f(-1.2, C+1, 0);

      glVertex3f(-1.2, -1-C, 0);
      glVertex3f( 1.2, -1-C, 0);
      glVertex3f( 1.2,  -C , 0);
      glVertex3f(-1.2,  -C , 0);
    glEnd();
    glColor3f(1, 1, 1);
    glEnable(GL_TEXTURE_2D);
  end;

  if ElapsedTime > METABALL_START then
    Inc(Stage);
end;


procedure initBlob;
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
