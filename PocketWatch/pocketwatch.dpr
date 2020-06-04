//------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://www.sulaco.co.za
//               http://home.global.co.za/~jhorn
// Date        : 28 January 2002
// Version     : 1.0
// Description : The initial project idea was to create a series of gears
//               but that is so boring, so I added the pocket watch around it
//
//------------------------------------------------------------------------
program pocketwatch;

uses
  Windows,
  Messages,
  OpenGL,
  BMP2,
  watch_data;

const
  WND_TITLE = 'Pocket Watch by Jan Horn';
  FPS_TIMER = 1;                     // Timer to calculate FPS
  FPS_INTERVAL = 500;                // Calculate FPS every 1000 ms

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  h_RC   : HGLRC;                    // OpenGL rendering context
  keys : Array[0..255] of Boolean;   // Holds keystrokes
  FPSCount : Integer = 0;            // Counter for FPS
  ElapsedTime : Integer;             // Elapsed time between frames

  // Textures
  WatchTex     : glUint;
  WatchFaceTex : glUint;

  // User variables
  Wireframe : Boolean;
  ShowFace  : Boolean;
  ShowCover : Boolean;
  Lighting  : Boolean;
  CaseDL, CoverDL, FaceDL : glUint;     // Case, Cover and face display Lists

  Gear1, Gear2, Gear3, Gear4 : glUint;  // Gear Display List
  Cylinder : gluQuadricObj;

  // mouse
  MouseButton : Integer;              // mouse button down
  YRot, XRot: glFloat;                // current X and Y rotation
  xPos, yPos, zPos : glFloat;         // Location
  Xcoord, Ycoord, Zcoord : Integer;   // Mouse Coordinates

  // Ligting
  LightPosition : array[0..3] of glFloat = (-18.0, 15.0, 3.0, 0);
  MatShine   : GLfloat = 50.0;
//  amb : Array[0..3] of glFloat


{$R *.RES}
{$R images.res}

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

{------------------------------------------------------------------}
{  Function to convert int to string. (No sysutils = smaller EXE)  }
{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;


{------------------------------------------------------------------}
{  Create a Displaylist for the watch and its cover                }
{------------------------------------------------------------------}
procedure createWatchDisplayList;
var I : Integer;
begin
  // Create a display list for the watch casing
  CaseDL :=glGenLists(1);
  glNewList(CaseDL, GL_COMPILE);
    glBindTexture(GL_TEXTURE_2D, WatchTex);
    glTranslate(0, 2, -1.1);
    glScale(3.3, 3.3, 3.3);
    glColor3f(1.0, 1.0, 1.0);

    glBegin (GL_TRIANGLES);
    for I :=0 to numCaseTriangles-1 do
    begin
      glNormal3f(CaseNormals[ CaseFace[i,3],0], CaseNormals[ CaseFace[i,3],1], CaseNormals[ CaseFace[i,3],2]);
      glVertex3f(CaseVertices[CaseFace[i,0],0], CaseVertices[CaseFace[i,0],1], CaseVertices[CaseFace[i,0],2]);

      glNormal3f(CaseNormals[ CaseFace[i,4],0], CaseNormals[ CaseFace[i,4],1], CaseNormals[ CaseFace[i,4],2]);
      glVertex3f(CaseVertices[CaseFace[i,1],0], CaseVertices[CaseFace[i,1],1], CaseVertices[CaseFace[i,1],2]);

      glNormal3f(CaseNormals[ CaseFace[i,5],0], CaseNormals[ CaseFace[i,5],1], CaseNormals[ CaseFace[i,5],2]);
      glVertex3f(CaseVertices[CaseFace[i,2],0], CaseVertices[CaseFace[i,2],1], CaseVertices[CaseFace[i,2],2]);
    end;
    glEnd ();
  glEndList();

  // Create a display list for the watch glass cover
  CoverDL :=glGenLists(1);
  glNewList(CoverDL, GL_COMPILE);
    glTranslate(0, -0.6, 0.58);
    glScale(0.65, 0.65, 0.65);
    glColor4f(0.8, 0.8, 0.8, 0.5);
    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);

    glBegin (GL_TRIANGLES);
    for I :=0 to numCoverTriangles-1 do
    begin
      glNormal3f(CoverNormals[ CoverFace[i,3],0], CoverNormals[ CoverFace[i,3],1], CoverNormals[ CoverFace[i,3],2]);
      glVertex3f(CoverVertices[CoverFace[i,0],0], CoverVertices[CoverFace[i,0],1], CoverVertices[CoverFace[i,0],2]);

      glNormal3f(CoverNormals[ CoverFace[i,4],0], CoverNormals[ CoverFace[i,4],1], CoverNormals[ CoverFace[i,4],2]);
      glVertex3f(CoverVertices[CoverFace[i,1],0], CoverVertices[CoverFace[i,1],1], CoverVertices[CoverFace[i,1],2]);

      glNormal3f(CoverNormals[ CoverFace[i,5],0], CoverNormals[ CoverFace[i,5],1], CoverNormals[ CoverFace[i,5],2]);
      glVertex3f(CoverVertices[CoverFace[i,2],0], CoverVertices[CoverFace[i,2],1], CoverVertices[CoverFace[i,2],2]);
    end;
    glEnd ();

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
  glEndList();

  // Create a display list for the watch face
  FaceDL :=glGenLists(1);
  glNewList(FaceDL, GL_COMPILE);
    glBindTexture(GL_TEXTURE_2D, WatchFaceTex);
    glPushMatrix();
      glColor3f(1, 1, 1);
      glEnable(GL_TEXTURE_2D);
      glTranslate(0, 0, 0.3);
      gluDisk(Cylinder, 0, 6.8, 64, 1);
      glRotate(180, 1, 0, 0);
      glColor3f(0.6, 0.6, 0.7);
      glDisable(GL_TEXTURE_2D);
      glTranslate(0, 0, -0.1);
      gluDisk(Cylinder, 0, 6.8, 64, 1);
      glColor3f(1, 1, 1);
    glPopMatrix();
  glEndList();
end;


{------------------------------------------------------------------}
{  Procedure to create a gear.                                     }
{------------------------------------------------------------------}
procedure CreateGear(InnerRadius, OuterRadius, Width: glFloat; Teeth : Integer; ToothDepth: glFloat);
var I : Integer;
    OuterRadius1, OuterRadius2 : glFloat;
    angle, da : glFloat;
    u, v, len : glFloat;
begin
  OuterRadius1 := OuterRadius - ToothDepth/2.0;
  OuterRadius2 := OuterRadius + ToothDepth/2.0;

  da := 2*Pi/teeth/4.0;
  glShadeModel(GL_FLAT);

  // front flat part of the gear
  glNormal3f(0.0, 0.0, 1.0);
  glBegin(GL_QUAD_STRIP);
    for i := 0 to teeth do
    begin
      angle := I*2*Pi/teeth;
      glVertex3f(InnerRadius *cos(angle+da/2),   InnerRadius*sin(angle+da/2),    width*0.5);
      glVertex3f(OuterRadius1*cos(angle),        OuterRadius1*sin(angle),        width*0.5);
      glVertex3f(InnerRadius *cos(angle+5*da/2), InnerRadius*sin(angle+5*da/2),  width*0.5);
      glVertex3f(OuterRadius1*cos(angle+3*da),   OuterRadius1*sin(angle+3*da),   width*0.5);
    end;
  glEnd;

  // back flat part of the gear
  glNormal3f(0.0, 0.0, -1.0);
  glBegin(GL_QUAD_STRIP);
    for I := 0 to teeth do
    begin
      angle := I*2*Pi/teeth;
      glVertex3f(OuterRadius1*cos(angle),      OuterRadius1*sin(angle),      -width*0.5);
      glVertex3f(InnerRadius *cos(angle+da/2), InnerRadius*sin(angle+da/2),  -width*0.5);
      glVertex3f(OuterRadius1*cos(angle+3*da), OuterRadius1*sin(angle+3*da), -width*0.5);
      glVertex3f(InnerRadius *cos(angle+5*da/2), InnerRadius*sin(angle+5*da/2),  -width*0.5);
    end;
  glEnd;

  // front flat part of the teeth
  glNormal3f(0.0, 0.0, 1.0);
  da := 2*Pi/teeth/4.0;
  glBegin(GL_QUADS);
    for I := 0 to Teeth - 1 do
    begin
      angle := I*2*Pi/teeth;
      glVertex3f(OuterRadius1*cos(angle),      OuterRadius1*sin(angle),      width*0.5);
      glVertex3f(OuterRadius2*cos(angle+da),   OuterRadius2*sin(angle+da),   width*0.5);
      glVertex3f(OuterRadius2*cos(angle+2*da), OuterRadius2*sin(angle+2*da), width*0.5);
      glVertex3f(OuterRadius1*cos(angle+3*da), OuterRadius1*sin(angle+3*da), width*0.5);
    end;
  glEnd;

  // back flat part of the teeth
  glNormal3f(0.0, 0.0, -1.0);
  glBegin(GL_QUADS);
    for i := 0 to teeth - 1 do
    begin
      angle := i*2.0*Pi/teeth;
      glVertex3f(OuterRadius1*cos(angle+3*da), OuterRadius1*sin(angle+3*da), -width*0.5);
      glVertex3f(OuterRadius2*cos(angle+2*da), OuterRadius2*sin(angle+2*da), -width*0.5);
      glVertex3f(OuterRadius2*cos(angle+da),   OuterRadius2*sin(angle+da),   -width*0.5);
      glVertex3f(OuterRadius1*cos(angle),      OuterRadius1*sin(angle),      -width*0.5);
    end;
  glEnd;

  // the outer circle (ie. the teeth)
  glBegin(GL_QUAD_STRIP);
    for I := 0 to Teeth - 1 do
    begin
      angle := I*2*Pi/Teeth;
      glVertex3f(OuterRadius1*cos(angle), OuterRadius1*sin(angle),  width*0.5);
      glVertex3f(OuterRadius1*cos(angle), OuterRadius1*sin(angle), -width*0.5);
      // calculate formal for tooth face
      u   := OuterRadius2*cos(angle+da) - OuterRadius1*cos(angle);
      v   := OuterRadius2*sin(angle+da) - OuterRadius1*sin(angle);
      len := sqrt(u*u + v*v);
      u   := u/len;
      v   := v/len;
      glNormal3f(v, -u, 0.0);
      glVertex3f(OuterRadius2*cos(angle+da),   OuterRadius2*sin(angle+da),    width*0.5);
      glVertex3f(OuterRadius2*cos(angle+da),   OuterRadius2*sin(angle+da),   -width*0.5);
      glNormal3f(cos(angle), sin(angle), 0.0);
      glVertex3f(OuterRadius2*cos(angle+2*da), OuterRadius2*sin(angle+2*da),  width*0.5);
      glVertex3f(OuterRadius2*cos(angle+2*da), OuterRadius2*sin(angle+2*da), -width*0.5);
      u   := OuterRadius1*cos(angle+3*da) - OuterRadius2*cos(angle+2*da);
      v   := OuterRadius1*sin(angle+3*da) - OuterRadius2*sin(angle+2*da);
      glNormal3f(v, -u, 0.0);
      glVertex3f(OuterRadius1*cos(angle+3*da), OuterRadius1*sin(angle+3*da),  width*0.5);
      glVertex3f(OuterRadius1*cos(angle+3*da), OuterRadius1*sin(angle+3*da), -width*0.5);
      glNormal3f(cos(angle), sin(angle), 0.0);
    end;
    glVertex3f(OuterRadius1*cos(0), OuterRadius1*sin(0),  width*0.5);
    glVertex3f(OuterRadius1*cos(0), OuterRadius1*sin(0), -width*0.5);
  glEnd;

  glShadeModel(GL_SMOOTH);

  // inner circle
  glBegin(GL_QUAD_STRIP);
    for I := 0 to 2*Teeth do
    begin
      angle := I*Pi/Teeth + da/2;
      glNormal3f(-cos(angle), -sin(angle), 0.0);
      glVertex3f(InnerRadius*cos(angle), InnerRadius*sin(angle), -width*0.5);
      glVertex3f(InnerRadius*cos(angle), InnerRadius*sin(angle), width*0.5);
    end;
  glEnd;
end;


{------------------------------------------------------------------}
{  Procedure to create gear spokes.  Spokes have a gap in center   }
{------------------------------------------------------------------}
procedure CreateSpokes(InnerRadius, OuterRadius : glFloat);
begin
  glBegin(GL_QUADS);
    glNormal3f( 0.0, 1.0, 0.0);
    glVertex3f( InnerRadius,  0.15, -0.15);
    glVertex3f( InnerRadius,  0.15,  0.15);
    glVertex3f( OuterRadius,  0.15,  0.15);
    glVertex3f( OuterRadius,  0.15, -0.15);

    glVertex3f(-OuterRadius,  0.15, -0.15);
    glVertex3f(-OuterRadius,  0.15,  0.15);
    glVertex3f(-InnerRadius,  0.15,  0.15);
    glVertex3f(-InnerRadius,  0.15, -0.15);

    glNormal3f( 0.0, -1.0, 0.0);
    glVertex3f( InnerRadius, -0.15, -0.15);
    glVertex3f( OuterRadius, -0.15, -0.15);
    glVertex3f( OuterRadius, -0.15,  0.15);
    glVertex3f( InnerRadius, -0.15,  0.15);

    glVertex3f(-OuterRadius, -0.15, -0.15);
    glVertex3f(-InnerRadius, -0.15, -0.15);
    glVertex3f(-InnerRadius, -0.15,  0.15);
    glVertex3f(-OuterRadius, -0.15,  0.15);

    glNormal3f( 0.0, 0.0, 1.0);
    glVertex3f( InnerRadius, -0.15,  0.15);
    glVertex3f( OuterRadius, -0.15,  0.15);
    glVertex3f( OuterRadius,  0.15,  0.15);
    glVertex3f( InnerRadius,  0.15,  0.15);

    glVertex3f(-OuterRadius, -0.15,  0.15);
    glVertex3f(-InnerRadius, -0.15,  0.15);
    glVertex3f(-InnerRadius,  0.15,  0.15);
    glVertex3f(-OuterRadius,  0.15,  0.15);

    glNormal3f( 0.0, 0.0,-1.0);
    glVertex3f( InnerRadius, -0.15, -0.15);
    glVertex3f( InnerRadius,  0.15, -0.15);
    glVertex3f( OuterRadius,  0.15, -0.15);
    glVertex3f( OuterRadius, -0.15, -0.15);

    glVertex3f(-OuterRadius, -0.15, -0.15);
    glVertex3f(-OuterRadius,  0.15, -0.15);
    glVertex3f(-InnerRadius,  0.15, -0.15);
    glVertex3f(-InnerRadius, -0.15, -0.15);
  glEnd();
end;


{------------------------------------------------------------------}
{  Procedure that creates all the gears as display lists           }
{------------------------------------------------------------------}
procedure CreateGears;
var I : Integer;
    angle : glFloat;
begin
  // big center gear
  Gear1 :=glGenLists(1);
  glNewList(Gear1, GL_COMPILE);
    CreateGear( 2.5, 3, 0.3, 32, 0.3);
    createSpokes(0.3, 2.51);
    glRotate(90, 0, 0, 1);
    createSpokes(0.3, 2.51);
    glTranslate(0, 0, -0.15);

    // outer and inner cylinders
    glRotate(15, 0, 0, 1);
    gluCylinder(Cylinder, 0.4, 0.4, 0.3, 16, 1);
    glTranslate(0, 0, 0.15);
    glBegin(GL_QUAD_STRIP);
      for I := 0 to 16 do
      begin
        angle := I*Pi/8;
        glNormal3f(-cos(angle), -sin(angle), 0.0);
        glVertex3f(0.2*cos(angle), 0.2*sin(angle), -0.3*0.5);
        glVertex3f(0.2*cos(angle), 0.2*sin(angle), 0.3*0.5);
      end;
    glEnd;

    // top and bottom covers
    glTranslate(0, 0, 0.15);
    gluDisk(Cylinder, 0.2, 0.4, 16, 1);
    glRotate(180, 1, 0, 0);
    glTranslate(0, 0, 0.3);
    gluDisk(Cylinder, 0.2, 0.4, 16, 1);
  glEndList;

  // small center gear
  Gear2 :=glGenLists(1);
  glNewList(Gear2, GL_COMPILE);
    CreateGear( 0.0, 0.8, 0.3, 11, 0.3);
  glEndList;

  // gear joining center small
  Gear3 :=glGenLists(1);
  glNewList(Gear3, GL_COMPILE);
    CreateGear( 1.5, 2, 0.3, 24, 0.3);
    createSpokes(0.0, 1.51);
    glRotate(90, 0, 0, 1);
    createSpokes(0.0, 1.51);
  glEndList;

  // smallest gear for the seconds
  Gear4 :=glGenLists(1);
  glNewList(Gear4, GL_COMPILE);
    CreateGear( 0.1, 0.6, 0.3, 7, 0.3);
  glEndList;
end;


{------------------------------------------------------------------}
{  Procedure to draw the gears                                     }
{------------------------------------------------------------------}
procedure drawGears;
begin
  glColor(0.7, 0.7, 0.7);
  // center big gear
  glPushMatrix();
    glRotate(ElapsedTime/40-40, 0, 0, 1);
    glCallList(Gear1);
  glPopMatrix();

  // center small gear
  glPushMatrix();
    glRotate(ElapsedTime/5, 0, 0, 1);
    glTranslate(0, 0, 0.4);
    glCallList(Gear2);
    // draw joining shaft
    glTranslate(0, 0, -0.6);
    gluCylinder(Cylinder, 0.15, 0.15, 0.8, 16, 1);
    glRotate(180, 1, 0, 0);
    gluDisk(Cylinder, 0, 0.15, 16, 1);
  glPopMatrix();

  // gear joining center small
  glPushMatrix();
    glTranslate(2.9, 0, 0.4);
    glRotate(-ElapsedTime/10.91-3, 0, 0, 1);
    glCallList(Gear3);
  glPopMatrix();

  // small gear below gear above
  glPushMatrix();
    glTranslate(2.9, 0, 0.8);
    glRotate(-ElapsedTime/4.01+5, 0, 0, 1);
    glCallList(Gear2);
    // draw joining shaft
    glTranslate(0, 0, -0.6);
    gluCylinder(Cylinder, 0.15, 0.15, 0.8, 16, 1);
    glRotate(180, 1, 0, 0);
    gluDisk(Cylinder, 0, 0.15, 16, 1);
  glPopMatrix();

  // medium bottom most gear
  glPushMatrix();
    glTranslate(3, -2.9, 0.8);
    glRotate(ElapsedTime/8.75, 0, 0, 1);
    glCallList(Gear3);
    // draw joining shaft
    glTranslate(0, 0, -1.0);
    gluCylinder(Cylinder, 0.15, 0.15, 1.2, 16, 1);
    glRotate(180, 1, 0, 0);
    gluDisk(Cylinder, 0, 0.15, 16, 1);
  glPopMatrix();

  // small gear at top joining small and medium
  glPushMatrix();
    glTranslate(3, -2.9, 0);
    glRotate(ElapsedTime/8.75-35, 0, 0, 1);
    glCallList(Gear4);
  glPopMatrix();

  // medium gear at top joining big and seconds gear
  glPushMatrix();
    glTranslate(1.68, -3.5, 0);
    glRotate(-ElapsedTime/13.75+4, 0, 0, 1);
    glCallList(Gear2);
  glPopMatrix();

    // seconds gear at top for seconds
  glPushMatrix();
    glTranslate(0.3, -4.0, 0);
    glRotate(ElapsedTime/8.75+8, 0, 0, 1);
    glCallList(Gear4);
  glPopMatrix();
end;


{------------------------------------------------------------------}
{  Procedure to draw the watch arms                                }
{------------------------------------------------------------------}
procedure drawArms;
var SysTime : SystemTime;
begin
  GetLocalTime(SysTime);

  glPushMatrix();
    glTranslate(0, 0, 0.4);
      glNormal3f( 0.0, 0.0, 1.0);

    // hours
    glPushMatrix();
      glRotate(-SysTime.wHour*30 - SysTime.wMinute/2 +90 , 0, 0, 1);
      glBegin(GL_QUADS);
        glColor3f(1, 0.2, 0.2);

        glVertex3f(-1, 0, 0);
        glVertex3f(0, -0.2, 0);
        glVertex3f(4, 0, 0);
        glVertex3f(0, 0, 0.1);

        glColor3f(0.8, 0.2, 0.2);
        glVertex3f(-1, 0, 0);
        glVertex3f(0, 0, 0.1);
        glVertex3f(4, 0, 0);
        glVertex3f(0, 0.2, 0);
      glEnd();
    glPopMatrix();

    // minutes
    glPushMatrix();
      glRotate(-SysTime.wMinute*6 - SysTime.wSecond/10 +90, 0, 0, 1);
      glBegin(GL_QUADS);
        glColor3f(1, 0.2, 0.2);
        glVertex3f(-1, 0, 0.1);
        glVertex3f(0, -0.2, 0.1);
        glVertex3f(6, 0, 0.1);
        glVertex3f(0, 0, 0.2);

        glColor3f(0.8, 0.2, 0.2);
        glVertex3f(-1, 0, 0.1);
        glVertex3f(0, 0, 0.2);
        glVertex3f(6, 0, 0.1);
        glVertex3f(0, 0.2, 0.1);
      glEnd();
    glPopMatrix();

    // seconds
    glPushMatrix();
      glTranslate(0, -3.94, 0);
      glRotate(-SysTime.wSecond*6 +90, 0, 0, 1);
      glBegin(GL_QUADS);
        glVertex3f(-0.1, 0, 0);
        glVertex3f(0, -0.07, 0);
        glVertex3f(1.6, 0, 0);
        glVertex3f(0, 0.07, 0);
      glEnd();
      gluDisk(Cylinder, 0, 0.15, 8, 1);
    glPopMatrix();

  glPopMatrix();
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw();
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  glTranslatef(xPos, yPos, zPos);   // move scene to screen center
  if MouseButton=-1 then
  begin
    glRotatef(30*cos(Elapsedtime/300), 1, 0, 0);
    glRotatef(30*sin(Elapsedtime/300)+10, 0, 1, 0);
  end
  else
  begin
    glRotatef(xRot, 1, 0, 0);         // rotate to mouse coords
    glRotatef(yRot, 0, 1, 0);         // rotate to mouse coords
  end;

  // Draw the watch face and arms
  if ShowFace then
  begin
    glCallList(FaceDL);             // Draw the watch face
    drawArms;                       // draw the watch arms
  end;

  // Draw the watch cover
  if ShowCover then
  begin
    glPushMatrix();
      glEnable(GL_TEXTURE_GEN_S);   // Enable spherical
      glEnable(GL_TEXTURE_GEN_T);   // Environment Mapping
      glEnable(GL_TEXTURE_2D);
      glCallList(CaseDL);           // draw the watch cover
      glDisable(GL_TEXTURE_2D);
      if Lighting then              // if lighting then
        glCallList(CoverDL);        // draw the transparent glass cover
      glDisable(GL_TEXTURE_GEN_S);  // Disable spherical
      glDisable(GL_TEXTURE_GEN_T);  // Environment Mapping
    glPopMatrix();
  end;

  if (ShowCover = FALSE) OR Wireframe then
  begin                             // if the cover is not displayed, draw the gears
    glRotate(180, 1, 0, 0);
    glRotate(176, 0, 0, 1);
    drawGears;                      // draw the gears
  end;
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.2, 0.2, 0.4, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

  glLightfv(GL_LIGHT0, GL_POSITION, @LightPosition);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_LIGHTING);
  glEnable(GL_CULL_FACE);  //***
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @MatShine);

  glEnable(GL_NORMALIZE);

  glEnable(GL_TEXTURE_2D);                      // Enable Texture Mapping
  LoadResTexture('watchFace.bmp', WatchFaceTex);
  LoadResTexture('Reflection.bmp', WatchTex);

  Cylinder := gluNewQuadric();		        // Create A Pointer To The Quadric Object (Return 0 If No Memory) (NEW)
  gluQuadricNormals(Cylinder, GLU_SMOOTH);	// Create Smooth Normals
  gluQuadricTexture(Cylinder, GL_TRUE);		// Create Texture Coords

  glTexGenf(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGenf(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

  createWatchDisplayList;
  CreateGears;
  Wireframe :=FALSE;
  ShowFace  :=TRUE;
  ShowCover :=TRUE;
  Lighting  :=TRUE;
  xRot :=-5;
  xPos :=0;
  yPos :=-2.5;
  zPos :=-34;
  MouseButton :=-1;
end;


{------------------------------------------------------------------}
{  Handle window resize                                            }
{------------------------------------------------------------------}
procedure glResizeWnd(Width, Height : Integer);
begin
  if (Height = 0) then                // prevent divide by zero exception
    Height := 1;
  glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glLoadIdentity();                   // Reset View
end;


{------------------------------------------------------------------}
{  Processes all the keystrokes                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  // toggle wireframe
  if Keys[ord('W')] then
  begin
    Wireframe :=Not(Wireframe);
    if Wireframe then
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    Keys[ord('W')] :=FALSE;
  end;

  // toggle lighting
  if Keys[ord('L')] then
  begin
    Lighting :=Not(Lighting);
    if Lighting then
      glEnable(GL_LIGHTING)
    else
      glDisable(GL_LIGHTING);
    Keys[ord('L')] :=FALSE;
  end;

  // Show/Hide watch face
  if Keys[ord('F')] then
  begin
    ShowFace :=Not(ShowFace);
    Keys[ord('F')] :=FALSE;
  end;

  // Show/Hide watch cover
  if Keys[ord('C')] then
  begin
    ShowCover :=Not(ShowCover);
    Keys[ord('C')] :=FALSE;
  end;
end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case (Msg) of
    WM_CREATE:
      begin
        // Insert stuff you want executed when the program starts
      end;
    WM_CLOSE:
      begin
        PostQuitMessage(0);
        Result := 0
      end;
    WM_KEYDOWN:       // Set the pressed key (wparam) to equal true so we can check if its pressed
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_SIZE:          // Resize the window with the new width and height
      begin
        glResizeWnd(LOWORD(lParam),HIWORD(lParam));
        Result := 0;
      end;
    // Mouse buttons
    WM_LBUTTONDOWN:
      begin
        ReleaseCapture();   // need them here, because if mouse moves off
        SetCapture(h_Wnd);  // window and returns, it needs to reset status
        MouseButton := 1;
        Xcoord := LOWORD(lParam);
        Ycoord := HIWORD(lParam);
        Result := 0;
      end;
    WM_LBUTTONUP:
      begin
        ReleaseCapture();   // above
        MouseButton := 0;
        XCoord := 0;
        YCoord := 0;
        Result := 0;
      end;
    WM_RBUTTONDOWN:
      begin
        ReleaseCapture();   // need them here, because if mouse moves off
        SetCapture(h_Wnd);  // window and returns, it needs to reset status
        MouseButton := 2;
        ZCoord :=HIWORD(lParam);
        Result := 0;
      end;
    WM_RBUTTONUP:
      begin
        ReleaseCapture();   // above
        MouseButton := 0;
        Result := 0;
      end;
    WM_MBUTTONDOWN:
      begin
        ReleaseCapture();   // need them here, because if mouse moves off
        SetCapture(h_Wnd);  // window and returns, it needs to reset status
        MouseButton := 3;
        Xcoord := LOWORD(lParam);
        Ycoord := HIWORD(lParam);
        Result := 0;
      end;
    WM_MBUTTONUP:
      begin
        ReleaseCapture();   // above
        MouseButton := 0;
        Result := 0;
      end;
    WM_MOUSEMOVE:
      begin
        if MouseButton = 1 then
        begin
          xRot := xRot + (HIWORD(lParam) - Ycoord)/2;  // moving up and down = rot around X-axis
          yRot := yRot + (LOWORD(lParam) - Xcoord)/2;
          Xcoord := LOWORD(lParam);
          Ycoord := HIWORD(lParam);
        end;
        if MouseButton = 2 then
        begin
          zPos :=zPos - (HIWORD(lParam)-ZCoord)/10;
          Zcoord := HIWORD(lParam);
        end;
        if MouseButton = 3 then
        begin
          xPos := xPos + (LOWORD(lParam)-xCoord)/24;
          yPos := yPos - (HIWORD(lParam)-yCoord)/24;
          Xcoord := LOWORD(lParam);
          Ycoord := HIWORD(lParam);
        end;
        Result := 0;
      end;
    WM_TIMER :                     // Add code here for all timers to be used.
      begin
        if wParam = FPS_TIMER then
        begin
          FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // calculate to get per Second incase intercal is less or greater than 1 second
          SetWindowText(h_Wnd, PChar(WND_TITLE + '   [' + intToStr(FPSCount) + ' FPS]'));
          FPSCount := 0;
          Result := 0;
        end;
      end;
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
  end;
end;


{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}
procedure glKillWnd(Fullscreen : Boolean);
begin
  if Fullscreen then             // Change back to non fullscreen
  begin
    ChangeDisplaySettings(devmode(nil^), 0);
    ShowCursor(True);
  end;

  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
  if (not wglMakeCurrent(h_DC, 0)) then
    MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Attempts to delete the rendering context
  if (not wglDeleteContext(h_RC)) then
  begin
    MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_RC := 0;
  end;

  // Attemps to release the device context
  if ((h_DC = 1) and (ReleaseDC(h_Wnd, h_DC) <> 0)) then
  begin
    MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_DC := 0;
  end;

  // Attempts to destroy the window
  if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then
  begin
    MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
    h_Wnd := 0;
  end;

  // Attempts to unregister the window class
  if (not UnRegisterClass('OpenGL', hInstance)) then
  begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Creates the window and attaches a OpenGL rendering context to it  }
{--------------------------------------------------------------------}
function glCreateWnd(Width, Height : Integer; Fullscreen : Boolean; PixelDepth : Integer) : Boolean;
var
  wndClass : TWndClass;         // Window class
  dwStyle : DWORD;              // Window styles
  dwExStyle : DWORD;            // Extended window styles
  dmScreenSettings : DEVMODE;   // Screen settings (fullscreen, etc...)
  PixelFormat : GLuint;         // Settings for the OpenGL rendering
  h_Instance : HINST;           // Current instance
  pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
  h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

  with wndClass do                    // Set up the window class
  begin
    style         := CS_HREDRAW or    // Redraws entire window if length changes
                     CS_VREDRAW or    // Redraws entire window if height changes
                     CS_OWNDC;        // Unique device context for the window
    lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'OpenGL';
  end;

  if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit
  end;

  // Change to fullscreen if so desired
  if Fullscreen then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Set parameters for the screen setting
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Width;                    // Window width
      dmPelsHeight := Height;                   // Window height
      dmBitsPerPel := PixelDepth;               // Window color depth
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to fullscreen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  // If we are still in fullscreen then
  if (Fullscreen) then
  begin
    dwStyle := WS_POPUP or                // Creates a popup window
               WS_CLIPCHILDREN            // Doesn't draw within child windows
               or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW;         // Top level window
    ShowCursor(False);                    // Turn of the cursor (gets in the way)
  end
  else
  begin
    dwStyle := WS_OVERLAPPEDWINDOW or     // Creates an overlapping window
               WS_CLIPCHILDREN or         // Doesn't draw within child windows
               WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW or       // Top level window
                 WS_EX_WINDOWEDGE;        // Border with a raised edge
  end;

  // Attempt to create the actual window
  h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                          'OpenGL',       // Class name
                          WND_TITLE,      // Window title (caption)
                          dwStyle,        // Window styles
                          0, 0,           // Window position
                          Width, Height,  // Size of window
                          0,              // No parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if h_Wnd = 0 then
  begin
    glKillWnd(Fullscreen);                // Undo all the settings we've changed
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // The version of this data structure
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                       or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
    cColorBits      := PixelDepth;           // OpenGL color depth
    cRedBits        := 0;                    // Number of red bitplanes
    cRedShift       := 0;                    // Shift count for red bitplanes
    cGreenBits      := 0;                    // Number of green bitplanes
    cGreenShift     := 0;                    // Shift count for green bitplanes
    cBlueBits       := 0;                    // Number of blue bitplanes
    cBlueShift      := 0;                    // Shift count for blue bitplanes
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                    // No accumulation buffer
    cAccumRedBits   := 0;                    // Number of red bits in a-buffer
    cAccumGreenBits := 0;                    // Number of green bits in a-buffer
    cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
    cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
    cDepthBits      := 16;                   // Specifies the depth of the depth buffer
    cStencilBits    := 0;                    // Turn off stencil buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Ignored
    bReserved       := 0;                    // Number of overlay and underlay planes
    dwLayerMask     := 0;                    // Ignored
    dwVisibleMask   := 0;                    // Transparent color of underlay plane
    dwDamageMask    := 0;                     // Ignored
  end;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Create a OpenGL rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Initializes the timer used to calculate the FPS
  SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

  // Settings to ensure that the window is the topmost window
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  // Ensure the OpenGL window is resized properly
  glResizeWnd(Width, Height);
  glInit();

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  finished : Boolean;
  DemoStart, LastTime : DWord;
begin
  finished := False;

  // Perform application initialization:
  if not glCreateWnd(800, 600, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  DemoStart := GetTickCount();            // Get Time when demo started

  // Main message loop:
  while not finished do
  begin
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Check if there is a message for this window
    begin
      if (msg.message = WM_QUIT) then     // If WM_QUIT message received then we are done
        finished := True
      else
      begin                               // Else translate and dispatch the message to this window
  	TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      Inc(FPSCount);                      // Increment FPS Counter

      LastTime :=ElapsedTime;
      ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
      ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

      glDraw();                           // Draw the scene
      SwapBuffers(h_DC);                  // Display the scene

      if (keys[VK_ESCAPE]) then           // If user pressed ESC then set finised TRUE
        finished := True
      else
        ProcessKeys;                      // Check for any other key Pressed
    end;
  end;
  glKillWnd(FALSE);
  Result := msg.wParam;
end;


begin
  WinMain(hInstance, hPrevInst, CmdLine, CmdShow);
end.
