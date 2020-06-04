//----------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://www.sulaco.co.za
//             : http://home.global.co.za/~jhorn
// Date        : 8 April 2001
// Description : A unit that used with OpenGL projects to load BMP files
// Usage       : LoadTexture(BMPFilename, TextureName);
//               eg : LoadTexture('logo.bmp', LogoTex);
//
// Changes     : 28 July    - Faster BGR to RGB routine
//             : 27 January - Added load from resource
//----------------------------------------------------------------------------
unit BMP2;

interface

uses
  Windows, OpenGL, Classes;

function LoadTexture(Filename: String; var Texture : GLuint) : Boolean;
function LoadResTexture(ResFilename: String; var Texture : GLuint) : Boolean;

implementation


function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


{------------------------------------------------------------------}
{  Swap bitmap format from BGR to RGB                              }
{------------------------------------------------------------------}
procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;


{------------------------------------------------------------------}
{  Create the Texture                                              }
{------------------------------------------------------------------}
function CreateTexture(Width, Height, Format : Word; pData : Pointer) : Integer;
var
  Texture : GLuint;
begin
  glGenTextures(1, Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  {Texture does NOT blend with object background}

  { Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  }  

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  if Format = GL_RGBA then
    gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pData)
  else
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, pData);
//  glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);  // Use when not wanting mipmaps to be built by openGL

  result :=Texture;
end;


{------------------------------------------------------------------}
{  Load BMP textures from file                                     }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Texture : GLuint) : Boolean;
var
  FileHeader : BITMAPFILEHEADER;
  InfoHeader : BITMAPINFOHEADER;
  Palette    : array of RGBQUAD;
  pData      : Pointer;
  BitmapFile    : THandle;
  BitmapLength  : LongWord;
  PaletteLength : LongWord;
  ReadBytes     : LongWord;
  Width, Height : Integer;
begin
  result :=FALSE;

  BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (BitmapFile = INVALID_HANDLE_VALUE) then begin
    MessageBox(0, PChar('Error opening ' + Filename), PChar('BMP Unit'), MB_OK);
    Exit;
  end;

  // Get header information
  ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
  ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

  // Get palette
  PaletteLength := InfoHeader.biClrUsed;
  SetLength(Palette, PaletteLength);
  ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
  if (ReadBytes <> PaletteLength) then begin
    MessageBox(0, PChar('Error reading palette'), PChar('BMP Unit'), MB_OK);
    Exit;
  end;

  Width  := InfoHeader.biWidth;
  Height := InfoHeader.biHeight;
  BitmapLength := InfoHeader.biSizeImage;
  if BitmapLength = 0 then
    BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

  // Get the actual pixel data
  GetMem(pData, BitmapLength);
  ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
  if (ReadBytes <> BitmapLength) then begin
    MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
    Exit;
  end;
  CloseHandle(BitmapFile);

  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  SwapRGB(pData, Width*Height);

  Texture :=CreateTexture(Width, Height, GL_RGB, pData);
  FreeMem(pData);
  result :=TRUE;
end;


{------------------------------------------------------------------}
{  Load BMP textures from the app resource                         }
{------------------------------------------------------------------}
function LoadResTexture(ResFilename: String; var Texture : GLuint) : Boolean;
var
  FileHeader : BITMAPFILEHEADER;
  InfoHeader : BITMAPINFOHEADER;
  Palette    : array of RGBQUAD;
  pData      : Pointer;
  BitmapLength  : LongWord;
  PaletteLength : LongWord;
  Width, Height : Integer;
  ResStream  : TResourceStream;
begin
  result :=FALSE;

  try
    ResStream := TResourceStream.Create(hInstance, PChar(copy(ResFilename, 1, Pos('.', ResFilename)-1)), 'BMP');
    ResStream.ReadBuffer(FileHeader, SizeOf(FileHeader));  // FileHeader
    ResStream.ReadBuffer(InfoHeader, SizeOf(InfoHeader));  // InfoHeader
    PaletteLength := InfoHeader.biClrUsed;
    SetLength(Palette, PaletteLength);
    ResStream.ReadBuffer(Palette, PaletteLength);          // Palette

    Width  := InfoHeader.biWidth;
    Height := InfoHeader.biHeight;

    BitmapLength := InfoHeader.biSizeImage;
    if BitmapLength = 0 then
      BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

    GetMem(pData, BitmapLength);
    ResStream.ReadBuffer(pData^, BitmapLength);            // Bitmap Data
    ResStream.Free;
  except on
    EResNotFound do
    begin
      MessageBox(0, PChar('File not found in resource - ' + ResFilename), PChar('BMP Texture'), MB_OK);
      Exit;
    end
    else
    begin
      MessageBox(0, PChar('Unable to read from resource - ' + ResFilename), PChar('BMP Unit'), MB_OK);
      Exit;
    end;
  end;

  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  SwapRGB(pData, Width*Height);

  Texture :=CreateTexture(Width, Height, GL_RGB, pData);
  FreeMem(pData);
  result :=TRUE;
end;

end.
