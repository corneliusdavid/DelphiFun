unit GenObjects;

interface

Uses OpenGL;

  function createCageDisplayList : GLUint;
  function CreateChildDisplayList : GLuint;

implementation

Uses Globals, FetusData;

{----------------------------------------------------------}
{  Create a display list of the metal frame and the glass. }
{----------------------------------------------------------}
function createCageDisplayList : GLUint;
var I, J : Integer;
    DisplayList : GLUint;
begin
  DisplayList :=glGenLists(1);
  glNewList(DisplayList, GL_COMPILE);
    // First draw the glass because it needs blending
    glDisable(GL_DEPTH_TEST);                // Turn Depth Testing Off
    glEnable(GL_BLEND);                      // Turn Blending On
    glBindTexture(GL_TEXTURE_2D, MetalFrame);
    glBegin(GL_QUADS);
      // Front Face
      glTexCoord2f(0.08, 0.08); glVertex3f(-0.86, -0.86,  1.0);
      glTexCoord2f(0.92, 0.08); glVertex3f( 0.86, -0.86,  1.0);
      glTexCoord2f(0.92, 0.92); glVertex3f( 0.86,  0.86,  1.0);
      glTexCoord2f(0.08, 0.92); glVertex3f(-0.86,  0.86,  1.0);
      // Back Face
      glTexCoord2f(0.92, 0.08); glVertex3f(-0.86, -0.86, -1.0);
      glTexCoord2f(0.92, 0.92); glVertex3f(-0.86,  0.86, -1.0);
      glTexCoord2f(0.08, 0.92); glVertex3f( 0.86,  0.86, -1.0);
      glTexCoord2f(0.08, 0.08); glVertex3f( 0.86, -0.86, -1.0);
      // Top Face
      glTexCoord2f(0.08, 0.92); glVertex3f(-0.86,  1.0, -0.86);
      glTexCoord2f(0.08, 0.08); glVertex3f(-0.86,  1.0,  0.86);
      glTexCoord2f(0.92, 0.08); glVertex3f( 0.86,  1.0,  0.86);
      glTexCoord2f(0.92, 0.92); glVertex3f( 0.86,  1.0, -0.86);
      // Bottom Face
      glTexCoord2f(0.92, 0.92); glVertex3f(-0.86, -1.0, -0.86);
      glTexCoord2f(0.08, 0.92); glVertex3f( 0.86, -1.0, -0.86);
      glTexCoord2f(0.08, 0.08); glVertex3f( 0.86, -1.0,  0.86);
      glTexCoord2f(0.92, 0.08); glVertex3f(-0.86, -1.0,  0.86);
      // Right face
      glTexCoord2f(0.92, 0.08); glVertex3f( 1.0, -0.86, -0.86);
      glTexCoord2f(0.92, 0.92); glVertex3f( 1.0,  0.86, -0.86);
      glTexCoord2f(0.08, 0.92); glVertex3f( 1.0,  0.86,  0.86);
      glTexCoord2f(0.08, 0.08); glVertex3f( 1.0, -0.86,  0.86);
      // Left Face
      glTexCoord2f(0.08, 0.08); glVertex3f(-1.0, -0.86, -0.86);
      glTexCoord2f(0.92, 0.08); glVertex3f(-1.0, -0.86,  0.86);
      glTexCoord2f(0.92, 0.92); glVertex3f(-1.0,  0.86,  0.86);
      glTexCoord2f(0.08, 0.92); glVertex3f(-1.0,  0.86, -0.86);
    glEnd;

    // Biohazard badge
    glEnable(GL_DEPTH_TEST);
    glBindTexture(GL_TEXTURE_2D, BioHazard);
    glBegin(GL_QUADS);
      glTexCoord2f(0, 0); glVertex3f(0.50, -1.0, 0.50);
      glTexCoord2f(1, 0); glVertex3f(0.80, -1.0, 0.50);
      glTexCoord2f(1, 1); glVertex3f(0.80, -1.0, 0.80);
      glTexCoord2f(0, 1); glVertex3f(0.50, -1.0, 0.80);
    glEnd;

    // Now draw the metal frame
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, MetalFrame);
    glBegin(GL_QUADS);
      // Front face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(Cage[I, J, 2], Cage[I, J, 3],  Cage[I, J, 4]);
        end;

      // Left face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(Cage[I, J, 4], Cage[I, J, 3],  Cage[I, J, 2]);
        end;

      // Back face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(Cage[I, J, 2], Cage[I, J, 3], -Cage[I, J, 4]);
        end;

      // Right face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(-Cage[I, J, 4], Cage[I, J, 3],  Cage[I, J, 2]);
        end;

      // Top face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(Cage[I, J, 2], Cage[I, J, 4], Cage[I, J, 3]);
        end;

      // Bottom face
      For I :=1 to 4 do
        For J :=1 to 4 do
        begin
          glTexCoord2f(Cage[I, J, 0], Cage[I, J, 1]);
          glVertex3f(Cage[I, J, 2], -Cage[I, J, 4], Cage[I, J, 3]);
        end;
    glEnd;
  glEndList;

  result :=DisplayList;
end;


{----------------------------------------------------------}
{  Create a display list of the baby.                      }
{----------------------------------------------------------}
function CreateChildDisplayList : GLuint;
var I : Integer;
DisplayList : Gluint;
begin
  DisplayList :=glGenLists(1);
  glNewList(DisplayList, GL_COMPILE);
    glBindTexture(GL_TEXTURE_2D, ChildTexture);
    glBegin(GL_TRIANGLES);
    for I :=0 to 6152 do
    begin
      glTexCoord2f(Child[I, 0] + Child[I, 1]*Child[I, 2], Child[I, 1] + Child[I, 0]*Child[I, 2]);
      glVertex3f(Child[I, 0], Child[I, 1], Child[I, 2]);
    end;
    glEnd();
  glEndList;
  result :=DisplayList;
end;


end.
