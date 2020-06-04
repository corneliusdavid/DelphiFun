//------------------------------------------------------------------------
//
//  This Code Was Created By Ben Humphrey 2001
//  If You've Found This Code Useful, Please Let Me Know.
//  Visit NeHe Productions At http://nehe.gamedev.net
//
//  Translation to Delphi by Jan Horn (jhorn@global.co.za)
//  http://home.global.co.za/~jhorn

//------------------------------------------------------------------------
program lesson35b;

uses
  Windows,
  Messages,
  OpenGL;

const
  WND_TITLE = 'NeHe & Ben Humphrey''s Height Map Tutorial';

  MAP_SIZE     = 1024;		     // Size Of Our .RAW Height Map (NEW)
  STEP_SIZE    = 16;		     // Width And Height Of Each Quad (NEW)
  HEIGHT_RATIO = 1.5;		     // Ratio That The Y Is Scaled According To The X And Z (NEW)

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  h_RC   : HGLRC;                    // OpenGL rendering context
  keys   : Array[0..255] of Boolean; // Holds keystrokes

  bRender : Boolean;	             // Polygon Flag Set To TRUE By Default (NEW)
  g_HeightMap : Array[0..MAP_SIZE*MAP_SIZE-1] of Byte;  // Holds The Height Map Data (NEW)
  scaleValue : glFloat;	             // Scale Value For The Terrain (NEW)

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


{------------------------------------------------------------------}
{  Loads The .RAW File And Stores It In pHeightMap                 }
{------------------------------------------------------------------}
procedure LoadRawFile(strName : String; nSize : Integer; var HeightMap : Array of Byte);
var F : File;
begin
  AssignFile(F, strName);
{$I-}
  Reset(F, 1);
{$I+}
  if IOResult <> 0 then
  begin
    MessageBox(0, 'Can''t Find The Height Map!', 'Error', MB_OK);
    Exit;
  end;

  // Here We Load The .RAW File Into Our pHeightMap Data Array
  // We Are Only Reading In '1', And The Size Is (Width * Height)
  BlockRead(F, HeightMap, nSize);
  CloseFile(F);
end;


{------------------------------------------------------------------}
{  This Returns The Height From A Height Map Index                 }
{------------------------------------------------------------------}
function Height(var HeightMap : Array of Byte; X, Y : Integer) : Byte;
begin
  X :=X MOD MAP_SIZE;                        // Error Check Our x Value
  Y :=Y MOD MAP_SIZE;                        // Error Check Our y Value

  result := HeightMap[x + (y * MAP_SIZE)];   // Index Into Our Height Array And Return The Height
end;


{-----------------------------------------------------------------------------}
{  Sets The Color Value For A Particular Index, Depending On The Height Index }
{-----------------------------------------------------------------------------}
procedure SetVertexColor(var HeightMap : Array of Byte; x, y : Integer);
var fColor : glFloat;
begin
  fColor :=-0.2 + Height(HeightMap, x, y) / 256.0;

  // Assign This Blue Shade To The Current Vertex
  if bRender then
    glColor((220-104*fColor)/256, (220-110*abs(fColor-0.4))/256, (220-200*abs(fColor-0.6))/256)
  else
    glColor3i(0, 0, 0);
end;


{------------------------------------------------------------------}
{  This This Renders The Height Map As Quads                       }
{------------------------------------------------------------------}
procedure RenderHeightMap(var HeightMap : Array of Byte);
var X, Y : Integer;
    x2, y2, z2 : Integer;
begin
  if (bRender) then                        // What We Want To Render
    glBegin( GL_QUADS )                    // Render Polygons
  else
    glBegin( GL_LINES );                   // Render Lines Instead

  X :=0;
  while X < MAP_SIZE do
  begin
    Y :=0;
    while Y < MAP_SIZE do
    begin
      // Get The (X, Y, Z) Value For The Bottom Left Vertex
      x2 := X;
      y2 := Height(HeightMap, X, Y );
      z2 := Y;

      // Set The Color Value Of The Current Vertex
      SetVertexColor(HeightMap, x2, z2);

      // Send This Vertex To OpenGL To Be Rendered (Integer Points Are Faster)
      glVertex3i(x2, y2, z2);

      // Get The (X, Y, Z) Value For The Top Left Vertex
      x2 := X;
      y2 := Height(HeightMap, X, Y + STEP_SIZE);
      z2 := Y + STEP_SIZE ;

      // Set The Color Value Of The Current Vertex
      SetVertexColor(HeightMap, x2, z2);

      // Send This Vertex To OpenGL To Be Rendered
      glVertex3i(x2, y2, z2);

      // Get The (X, Y, Z) Value For The Top Right Vertex
      x2 := X + STEP_SIZE;
      y2 := Height(HeightMap, X + STEP_SIZE, Y + STEP_SIZE );
      z2 := Y + STEP_SIZE ;

      // Set The Color Value Of The Current Vertex
      SetVertexColor(HeightMap, x2, z2);

      // Send This Vertex To OpenGL To Be Rendered
      glVertex3i(x2, y2, z2);

      // Get The (X, Y, Z) Value For The Bottom Right Vertex
      x2 := X + STEP_SIZE;
      y2 := Height(HeightMap, X + STEP_SIZE, Y );
      z2 := Y;

      // Set The Color Value Of The Current Vertex
      SetVertexColor(HeightMap, x2, z2);

      // Send This Vertex To OpenGL To Be Rendered
      glVertex3i(x2, y2, z2);

      Y :=Y + STEP_SIZE
    end;
    X := X + STEP_SIZE
  end;
  glEnd();
  glColor4f(1.0, 1.0, 1.0, 1.0);             // Reset The Color
end;

{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw();
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  //           Position        View      Up Vector
  gluLookAt(212, 60, 194,  186, 55, 171,  0, 1, 0);	  // This Determines Where The Camera's Position And View Is

  glScalef(scaleValue, scaleValue * HEIGHT_RATIO, scaleValue);

  bRender :=TRUE;
  RenderHeightMap(g_HeightMap);		                  // Render The Height Map
  bRender :=FALSE;
  RenderHeightMap(g_HeightMap);		                  // Render The Height Map
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.5); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LEQUAL);	           // The Type Of Depth Test To Do
  glDisable(GL_TEXTURE_2D);                // Disable Texture Mapping
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

  LoadRawFile('Data/Terrain.raw', MAP_SIZE * MAP_SIZE, g_HeightMap);	// (NEW)

  bRender :=TRUE;
  ScaleValue := 0.18;
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
  gluPerspective(45.0, Width/Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glLoadIdentity();                   // Reset View
end;


{------------------------------------------------------------------}
{  Processes all the keystrokes                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  if (keys[VK_UP])    then scaleValue := scaleValue + 0.001;
  if (keys[VK_DOWN])  then scaleValue := scaleValue - 0.001;
end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case (Msg) of
    WM_CREATE:
      begin
        Result := 0
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
  FullScreen : Boolean;
begin
  finished := False;

  // Ask The User Which Screen Mode They Prefer
  if MessageBox(0, 'Would You Like To Run In Fullscreen Mode?', 'Start FullScreen?', MB_YESNO OR MB_ICONQUESTION) = IDNO then
    FullScreen :=FALSE
  else
    FullScreen :=TRUE;

  // Perform application initialization:
  if not glCreateWnd(640, 480, FullScreen, 32) then
  begin
    Result := 0;
    Exit;
  end;

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
  WinMain( hInstance, hPrevInst, CmdLine, CmdShow );
end.
