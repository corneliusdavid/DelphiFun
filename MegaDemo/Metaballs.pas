unit Metaballs;

interface

Uses Globals;

  procedure InitMetaballs;
  procedure drawMetaballs;

implementation

Uses OpenGL, LookUpTable;

type
  TGLCoord = Record
    X, Y, Z : glFLoat;
  end;
  TMetaBall = Record
    Radius : glFloat;
    X, Y, Z : glFLoat;
  end;
  TGridPoint = record
    Pos : TGLCoord;
    Normal : TGLCoord;
    Value : glFLoat;  // Result of the metaball equations at this point
  end;
  PGridPoint = ^TGridPoint;
  TGridCube = record
    GridPoint : Array [0..7] of PGridPoint; // Points to 8 grid points (cube)
  end;

const GridSize = 26;
var
  MetaBall : Array[1..3] of TMetaBall;
  Grid  : Array[0..50, 0..50, 0..50] of TGridPoint;  // for this demo set max gridsize = 50
  Cubes : Array[0..49, 0..49, 0..49] of TGridCube;
  TessTriangles : Integer;           // Number of triangles by metaball tesselation.
  MetaballsInit : Boolean;


procedure NormalizeVector(var V : TGLCoord);
var Length : glFloat;
begin
  Length :=Sqrt(V.x*V.x + V.y*V.y + V.z*V.z);
  if Length = 0 then exit;

  V.x :=V.x / Length;
  V.y :=V.y / Length;
  V.z :=V.z / Length;
end;

procedure InitGrid;
var cx, cy, cz : Integer;
begin
  // Create the grid positions
  for cx := 0 to GridSize do
    for cy := 0 to GridSize do
      for cz := 0 to GridSize do
      begin
        Grid[cx, cy, cz].Pos.X := 2*cx/GridSize -1;   // grid from -1 to 1
        Grid[cx, cy, cz].Pos.Y := 2*cy/GridSize -1;   // grid from -1 to 1
        Grid[cx, cy, cz].Pos.Z := 1-2*cz/GridSize;    // grid from -1 to 1
      end;

  // Create the cubes. Each cube points to 8 grid points
  for cx := 0 to GridSize-1 do
    for cy := 0 to GridSize-1 do
      for cz := 0 to GridSize-1 do
      begin
        Cubes[cx,cy,cz].GridPoint[0] := @Grid[cx,   cy,   cz  ];
        Cubes[cx,cy,cz].GridPoint[1] := @Grid[cx+1, cy,   cz  ];
        Cubes[cx,cy,cz].GridPoint[2] := @Grid[cx+1, cy,   cz+1];
        Cubes[cx,cy,cz].GridPoint[3] := @Grid[cx,   cy,   cz+1];
        Cubes[cx,cy,cz].GridPoint[4] := @Grid[cx,   cy+1, cz  ];
        Cubes[cx,cy,cz].GridPoint[5] := @Grid[cx+1, cy+1, cz  ];
        Cubes[cx,cy,cz].GridPoint[6] := @Grid[cx+1, cy+1, cz+1];
        Cubes[cx,cy,cz].GridPoint[7] := @Grid[cx,   cy+1, cz+1];
      end;
end;

{----------------------------------------------------------}
{  Interpolate the position where an metaballs intersects  }
{  the line betweenthe two coordicates, C1 and C2          }
{----------------------------------------------------------}
procedure Interpolate(const C1, C2 : TGridPoint; var CResult, Norm : TGLCoord);
var mu : glFLoat;
begin
  if Abs(C1.Value) = 1 then
  begin
    CResult := C1.Pos;
    Norm := C1.Normal;
  end
  else
  if Abs(C2.Value) = 1 then
  begin
    CResult := C2.Pos;
    Norm := C2.Normal;
  end
  else
  if C1.Value = C2.Value then
  begin
    CResult := C1.Pos;
    Norm := C1.Normal;
  end
  else
  begin
    mu := (1 - C1.Value) / (C2.Value - C1.Value);
    CResult.x := C1.Pos.x + mu * (C2.Pos.x - C1.Pos.x);
    CResult.y := C1.Pos.y + mu * (C2.Pos.y - C1.Pos.y);
    CResult.z := C1.Pos.z + mu * (C2.Pos.z - C1.Pos.z);

    Norm.X := C1.Normal.X + (C2.Normal.X - C1.Normal.X) * mu;
    Norm.Y := C1.Normal.Y + (C2.Normal.Y - C1.Normal.Y) * mu;
    Norm.Z := C1.Normal.Z + (C2.Normal.Z - C1.Normal.Z) * mu;
  end;
end;


{------------------------------------------------------------}
{  Calculate the triangles required to draw a Cube.          }
{  Draws the triangles that makes up a Cube                  }
{------------------------------------------------------------}
procedure CreateCubeTriangles(const GridCube : TGridCube);
var I : Integer;
    CubeIndex: Integer;
    VertList, Norm : Array[0..11] of TGLCoord;
begin
  // Determine the index into the edge table which tells
  // us which vertices are inside/outside the metaballs
  CubeIndex := 0;
  if GridCube.GridPoint[0]^.Value < 1 then CubeIndex := CubeIndex or 1;
  if GridCube.GridPoint[1]^.Value < 1 then CubeIndex := CubeIndex or 2;
  if GridCube.GridPoint[2]^.Value < 1 then CubeIndex := CubeIndex or 4;
  if GridCube.GridPoint[3]^.Value < 1 then CubeIndex := CubeIndex or 8;
  if GridCube.GridPoint[4]^.Value < 1 then CubeIndex := CubeIndex or 16;
  if GridCube.GridPoint[5]^.Value < 1 then CubeIndex := CubeIndex or 32;
  if GridCube.GridPoint[6]^.Value < 1 then CubeIndex := CubeIndex or 64;
  if GridCube.GridPoint[7]^.Value < 1 then CubeIndex := CubeIndex or 128;

  // Check if the cube is entirely in/out of the surface
  if edgeTable[CubeIndex] = 0 then
    Exit;

  // Find the vertices where the surface intersects the cube.
  with GridCube do
  begin
    if (edgeTable[CubeIndex] and 1) <> 0 then
      Interpolate(GridPoint[0]^, GridPoint[1]^, VertList[0], Norm[0]);
    if (edgeTable[CubeIndex] and 2) <> 0 then
      Interpolate(GridPoint[1]^, GridPoint[2]^, VertList[1], Norm[1]);
    if (edgeTable[CubeIndex] and 4) <> 0 then
      Interpolate(GridPoint[2]^, GridPoint[3]^, VertList[2], Norm[2]);
    if (edgeTable[CubeIndex] and 8) <> 0 then
      Interpolate(GridPoint[3]^, GridPoint[0]^, VertList[3], Norm[3]);
    if (edgeTable[CubeIndex] and 16) <> 0 then
      Interpolate(GridPoint[4]^, GridPoint[5]^, VertList[4], Norm[4]);
    if (edgeTable[CubeIndex] and 32) <> 0 then
      Interpolate(GridPoint[5]^, GridPoint[6]^, VertList[5], Norm[5]);
    if (edgeTable[CubeIndex] and 64) <> 0 then
      Interpolate(GridPoint[6]^, GridPoint[7]^, VertList[6], Norm[6]);
    if (edgeTable[CubeIndex] and 128) <> 0 then
      Interpolate(GridPoint[7]^, GridPoint[4]^, VertList[7], Norm[7]);
    if (edgeTable[CubeIndex] and 256) <> 0 then
      Interpolate(GridPoint[0]^, GridPoint[4]^, VertList[8], Norm[8]);
    if (edgeTable[CubeIndex] and 512) <> 0 then
      Interpolate(GridPoint[1]^, GridPoint[5]^, VertList[9], Norm[9]);
    if (edgeTable[CubeIndex] and 1024) <> 0 then
      Interpolate(GridPoint[2]^, GridPoint[6]^, VertList[10], Norm[10]);
    if (edgeTable[CubeIndex] and 2048) <> 0 then
      Interpolate(GridPoint[3]^, GridPoint[7]^, VertList[11], Norm[11]);
  end;

  // Draw the triangles for this cube
  I := 0;
  glColor3f(1, 1, 1);
  while TriangleTable[CubeIndex, i] <> -1 do
  begin
    glNormal3fv(@Norm[TriangleTable[CubeIndex, i]]);
    glVertex3fv(@VertList[TriangleTable[CubeIndex][i]]);

    glNormal3fv(@Norm[TriangleTable[CubeIndex, i+1]]);
    glVertex3fv(@VertList[TriangleTable[CubeIndex][i+1]]);

    glNormal3fv(@Norm[TriangleTable[CubeIndex, i+2]]);
    glVertex3fv(@VertList[TriangleTable[CubeIndex][i+2]]);

    Inc(TessTriangles);
    Inc(i, 3);
  end;
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure drawMetaballs;
var cx, cy, cz : Integer;
    I : Integer;
    C : glFloat;
    DemoTime : Integer;
begin
  DemoTime :=ElapsedTime - METABALL_START;

  if MetaballsInit = FALSE then
  begin
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDepthFunc(GL_LEQUAL);		           // The Type Of Depth Test To Do
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_NORMALIZE);

    // Set up environment mapping
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_S, GL_SPHERE_MAP, 0);
    glTexGeni(GL_T, GL_SPHERE_MAP, 0);

    MetaballsInit :=TRUE;
  end;

  glTranslatef(0.0,0.0,-2.4);

  // Create the background image
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);

  glEnable(GL_BLEND);
  I :=DemoTime MOD 2000;
  C :=I/2000;
  glColor3f(C, C, C);
  glBindTexture(GL_TEXTURE_2D, MBallsBGTex[((DemoTime+2000) DIV 2000) MOD 4]);
  glBegin(GL_QUADS);
    glTexCoord(0.0, 0.0); glVertex(-1.5, -1.1, 0);
    glTexCoord(1.0, 0.0); glVertex( 1.5, -1.1, 0);
    glTexCoord(1.0, 1.0); glVertex( 1.5,  1.1, 0);
    glTexCoord(0.0, 1.0); glVertex(-1.5,  1.1, 0);
  glend;

  glColor3f(1-C, 1-C, 1-C);
  glBindTexture(GL_TEXTURE_2D, MBallsBGTex[(DemoTime DIV 2000) MOD 4]);
  glBegin(GL_QUADS);
    glTexCoord(0.0, 0.0); glVertex(-1.5, -1.1, 0);
    glTexCoord(1.0, 0.0); glVertex( 1.5, -1.1, 0);
    glTexCoord(1.0, 1.0); glVertex( 1.5,  1.1, 0);
    glTexCoord(0.0, 1.0); glVertex(-1.5,  1.1, 0);
  glend;
  glDisable(GL_BLEND);

  // alternate transparent metaballs every 8 seconds
  if DemoTime MOD 15000 > 10000 then
    glEnable(GL_BLEND)
  else
    glDisable(GL_BLEND);

  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);

  // calculate metaball positions
  MetaBall[1].X :=-0.4*cos(DemoTime/600) - 0.15*cos(DemoTime/600);
  MetaBall[1].Y :=0.5*sin(DemoTime/500) + 0.1*cos(DemoTime/600);

  MetaBall[2].X :=0.3*sin(DemoTime/400) - 0.35*cos(DemoTime/600);
  MetaBall[2].Y :=-0.4*cos(DemoTime/400) + 0.3*cos(DemoTime/600);

  MetaBall[3].X :=0.4*cos(DemoTime/400) - 0.3*sin(DemoTime/600);
  MetaBall[3].y :=0.4*cos(DemoTime/500) - 0.3*sin(DemoTime/400);

  TessTriangles := 0;
  For cx := 0 to GridSize do
    For cy := 0 to GridSize do
      For cz := 0 to GridSize do
        with Grid[cx, cy, cz] do
        begin
          Value :=0;
          for I :=1 to 3 do  // go through all meta balls
          begin
            with Metaball[I] do
               Value := Value + Radius*Radius /((Pos.x-x)*(Pos.x-x) + (Pos.y-y)*(Pos.y-y) + (Pos.z-z)*(Pos.z-z));
          end;
        end;

  // Calculate normals at the grid vertices
  For cx := 1 to GridSize-1 do
  begin
    For cy := 1 to GridSize-1 do
    begin
      For cz := 1 to GridSize-1 do
      begin
        Grid[cx,cy,cz].Normal.X := Grid[cx-1, cy, cz].Value - Grid[cx+1, cy, cz].Value;
        Grid[cx,cy,cz].Normal.Y := Grid[cx, cy-1, cz].Value - Grid[cx, cy+1, cz].Value;
        Grid[cx,cy,cz].Normal.Z := Grid[cx, cy, cz-1].Value - Grid[cx, cy, cz+1].Value;
      end;
    end;
  end;

  // Draw the metaballs by drawing the triangle in each cube in the grid
  glPushMatrix();
    glRotate(DemoTime/100, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, EnviroTex);
    glBegin(GL_TRIANGLES);
      For cx := 0 to GridSize-1 do
        for cy := 0 to GridSize-1 do
          for cz := 0 to GridSize-1 do
            CreateCubeTriangles(Cubes[cx, cy, cz]);
    glEnd;
  glPopMatrix();

  // Fade the sequence in
  if DemoTime < 400 then
    C := DemoTime / 800
  else if DemoTime > 5200 then
    C := (DemoTime - 2000) / 6400
  else
    C :=0.5;

  // Draw the black borders
  if DemoTime < 8000 then
  begin
    glTranslatef(0.0,0.0,0.5);
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

  // fade to white
  if ElapsedTime > TENTACLE_START - 250 then
  begin
    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);
    glEnable(GL_BLEND);
    glTranslatef(0, 0.0, 0.6);
    glBindTexture(GL_TEXTURE_2D, WhiteTex);
    C :=(250 - (TENTACLE_START  - ElapsedTime))/250;

    glColor3f(C, C, C);
    glBegin(GL_QUADS);
      glTexCoord(0, 0);  glVertex3f(-1, -1, 0);
      glTexCoord(1, 0);  glVertex3f( 1, -1, 0);
      glTexCoord(1, 1);  glVertex3f( 1,  1, 0);
      glTexCoord(0, 1);  glVertex3f(-1,  1, 0);
    glEnd;
  end;

  if ElapsedTime > TENTACLE_START then
    Inc(Stage);
end;


procedure InitMetaballs;
begin
  // initialise the metaball size and positions
  MetaBall[1].Radius :=0.3;
  MetaBall[1].X :=0;
  MetaBall[1].Y :=0;
  MetaBall[1].Z :=0;

  MetaBall[2].Radius :=0.22;
  MetaBall[2].X :=0;
  MetaBall[2].Y :=0;
  MetaBall[2].Z :=0;

  MetaBall[3].Radius :=0.25;
  MetaBall[3].X :=0;
  MetaBall[3].Y :=0;
  MetaBall[3].Z :=0;

  InitGrid;
  MetaballsInit :=FALSE;
end;


end.
