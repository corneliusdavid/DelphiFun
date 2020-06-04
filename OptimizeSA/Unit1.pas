unit Unit1;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, SysUtils,
  OpenGL, Textures, ExtCtrls, StdCtrls, LookUpTable, MPlayer, Buttons;

type
  TGLCoord = Record
    X, Y, Z : glFLoat;
  end;
  TMetaBall = Record
    Radius : glFloat;
    Normal : TGLCoord;
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

  TForm1 = class(TForm)
    Memo1: TMemo;
    MediaPlayer1: TMediaPlayer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    rc : HGLRC;    // Rendering Context
    dc  : HDC;     // Device Context

    backgroundTexture : glUint;
    EnviroTex : glUint;

    ElapsedTime, DemoStart, LastTime : DWord;
    TessTriangles : Integer;           // Number of triangles by metaball tesselation.
    MetaBall : Array[1..3] of TMetaBall;
    Grid  : Array[0..24, 0..24, 0..24] of TGridPoint;  // for this demo set max 32 = 50
    Cubes : Array[0..24, 0..24, 0..24] of TGridCube;
    procedure InitGrid;
    procedure CreateCubeTriangles(const GridCube : TGridCube);
    procedure glDraw;
    procedure Idle(Sender: TObject; var Done: Boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
{$R resources.res}

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


procedure NormalizeVector(var V : TGLCoord);
var Length : glFloat;
begin
  Length :=Sqrt(V.x*V.x + V.y*V.y + V.z*V.z);
  if Length = 0 then exit;

  V.x :=V.x / Length;
  V.y :=V.y / Length;
  V.z :=V.z / Length;
end;


procedure TForm1.InitGrid;
var cx, cy, cz : Integer;
begin
  // Create the grid positions
  for cx := 0 to 24 do
    for cy := 0 to 24 do
      for cz := 0 to 24 do
      begin
        Grid[cx, cy, cz].Pos.X := 2*cx/24 -1;   // grid from -1 to 1
        Grid[cx, cy, cz].Pos.Y := 2*cy/24 -1;   // grid from -1 to 1
        Grid[cx, cy, cz].Pos.Z := 1-2*cz/24;    // grid from -1 to 1
      end;

  // Create the cubes. Each cube points to 8 grid points
  for cx := 0 to 23 do
    for cy := 0 to 23 do
      for cz := 0 to 23 do
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
procedure TForm1.CreateCubeTriangles(const GridCube : TGridCube);
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


procedure TForm1.FormCreate(Sender: TObject);
var pfd : TPIXELFORMATDESCRIPTOR;
    pf  : Integer;
    ResourceStream : TResourceStream;
begin
  // OpenGL initialisieren
  dc:=GetDC(Form1.Handle);

  // PixelFormat
  pfd.nSize:=sizeof(pfd);
  pfd.nVersion:=1;
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
  pfd.iPixelType:=PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
  pfd.cColorBits:=32;

  pf :=ChoosePixelFormat(dc, @pfd);   // Returns format that most closely matches above pixel format
  SetPixelFormat(dc, pf, @pfd);

  rc :=wglCreateContext(dc);    // Rendering Context = window-glCreateContext
  wglMakeCurrent(dc,rc);        // Make the DC (Form1) the rendering Context

  glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
  glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
  LoadTexture('background.jpg', backgroundTexture, TRUE);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

  LoadTexture('environment.bmp', EnviroTex, TRUE);

  // Set up environment mapping
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR); 	// Set The Texture Generation Mode For S To Sphere Mapping
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR); 	// Set The Texture Generation Mode For T To Sphere Mapping

  // initialise the metaball size and positions
  MetaBall[1].Radius :=0.3;
  MetaBall[1].X :=0.5;
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

  try
    ResourceStream :=TResourceStream.Create(hInstance, 'Merit', 'MIDI');
    ResourceStream.SaveToFile('merit.mid');
    MediaPlayer1.Open;
    MediaPlayer1.Position :=40;
    MediaPlayer1.Play;
  finally
    ResourceStream.Free;
  end;

  DemoStart :=GetTickCount;
  Application.OnIdle := Idle;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MediaPlayer1.Stop;
end;

procedure TForm1.Idle(Sender: TObject; var Done: Boolean);
begin
  Done := FALSE;

  LastTime :=ElapsedTime;
  ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
  ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

  glDraw();                         // Draw the scene
  SwapBuffers(DC);                  // Display the scene
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Form1.Width, Form1.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Form1.Width/Form1.Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
end;


procedure TForm1.glDraw;
var cx, cy, cz : Integer;
    I : Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  glPushMatrix();
    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);
    glTranslatef(-0.03, 0.0, -2.35);
    glBindTexture(GL_TEXTURE_2D, BackgroundTexture);  // Bind the Texture to the object
    glBegin(GL_QUADS);
      glTexCoord2f(0.0, 0.0); glVertex3f(-1.3, -1.0,  0.0);
      glTexCoord2f(1.0, 0.0); glVertex3f( 1.3, -1.0,  0.0);
      glTexCoord2f(1.0, 1.0); glVertex3f( 1.3,  1.0,  0.0);
      glTexCoord2f(0.0, 1.0); glVertex3f(-1.3,  1.0,  0.0);
    glEnd();
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
  glPopMatrix();

  glTranslatef(-0.5, 0.3, -2.0);
  glScale(0.5, 0.5, 0.5);
  glRotatef(ElapsedTime/10, 1, 0, 0);
  glRotatef(ElapsedTime/15, 0, 0, 1);
  glBindTexture(GL_TEXTURE_2D, EnviroTex);
  MetaBall[2].X :=0.4*sin(ElapsedTime/400) - 0.25*cos(ElapsedTime/600);
  MetaBall[2].Y :=0.45*cos(ElapsedTime/400) - 0.2*cos(ElapsedTime/600);
  MetaBall[3].X :=-0.4*cos(ElapsedTime/500) - 0.2*sin(ElapsedTime/600);
  MetaBall[3].Z :=0.4*sin(ElapsedTime/500) - 0.2*sin(ElapsedTime/400);

  TessTriangles := 0;
  For cx := 0 to 24 do
    For cy := 0 to 24 do
      For cz := 0 to 24 do
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
    For cx := 1 to 23 do
      For cy := 1 to 23 do
        For cz := 1 to 23 do
        begin
          for I :=1 to 3 do  // go through all meta balls
          begin
            with Metaball[I] do
            begin
              Normal.X := Grid[cx-1, cy, cz].Value - Grid[cx+1, cy, cz].Value;
              Normal.Y := Grid[cx, cy-1, cz].Value - Grid[cx, cy+1, cz].Value;
              Normal.Z := Grid[cx, cy, cz-1].Value - Grid[cx, cy, cz+1].Value;
              NormalizeVector(Normal);
            end;
          end;
        end;


  // Draw the metaballs by drawing the triangle in each cube in the grid
  glBegin(GL_TRIANGLES);
    For cx := 0 to 23 do
      for cy := 0 to 23 do
        for cz := 0 to 23 do
          CreateCubeTriangles(Cubes[cx, cy, cz]);
  glEnd;

end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Close;
end;

end.
