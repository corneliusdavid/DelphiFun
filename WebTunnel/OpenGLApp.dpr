//------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://home.global.co.za/~jhorn
// Date        : 20 May 2001
// Version     : 1.0
// Description : Tinderbox Tunnel. Scrolls Tinderbox websites past and when
//               the user clicks on the browser, it opens the site.
//
//------------------------------------------------------------------------
program OpenGLApp;

uses
  Windows,
  Messages,
  OpenGL,
  ShellAPI,
  Textures;

const
  WND_TITLE = 'OpenGL App by Jan Horn';
  FPS_TIMER = 1;                     // Timer to calculate FPS
  FPS_INTERVAL = 1000;               // Calculate FPS every 1000 ms

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  h_RC   : HGLRC;                    // OpenGL rendering context
  keys : Array[0..255] of Boolean;   // Holds keystrokes
  FPSCount : Integer = 0;            // Counter for FPS
  ElapsedTime : Integer;             // Average Elapsed time between frames

  // Textures
  TunnelTex : glUint;
  Banners : Array[1..9] of glUint;

  // User vaiables
  AveTime : Integer;
  Angle, Speed : glFloat;
  MyQuadratic : GLUquadricObj;
  Selection : Boolean;

const BannerURL : Array[1..9] of String = (
         'http://www.avis.co.za',
         'http://www.explorercorp.com',
         'http://www.lleap.com',
         'http://www.mazda.co.za',
         'http://www.mazdawildlife.co.za',
         'http://www.prism.co.za',
         'http://www.musica.co.za',
         'http://www.truworths.co.za',
         'http://www.tinderbox.co.za');


{$R *.RES}

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

{------------------------------------------------------------------}
{  Function to convert int to string. (No sysutils = smaller EXE)  }
{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw();
var z : glFloat;
    I : Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer

  glLoadIdentity();                                       // Reset The View
  glTranslatef(21,0.0,-39);
  glRotatef(30, 0.0,-1.0, 0.0);

  Angle := Angle + ElapsedTime/250;
  Angle :=Angle + Speed;
  if Angle < 30 then   // Bounce back
  begin
    Angle :=30;
    Speed :=0;
  end;

  glPushMatrix();

  //----- background cylinder -------//
  glBindTexture(GL_TEXTURE_2D, TunnelTex);

  // main cylinder
  glRotatef(Angle, 0, 0, 1);
  gluCylinder(MyQuadratic, 1, 2.0, 44.0, 16, 16);
  glRotatef(-Angle, 0, 0, 1);

  //top rail
  glpushMatrix();
  glTranslatef(-1.05, 0.6, 0.0);
  glRotatef(Angle, 0, 0, 1);
  gluCylinder(MyQuadratic, 0.05, 0.05, 44.0, 8, 8);
  glPopMatrix();

  //bottom rail
  glTranslatef(-1.05, -0.6,0.0);
  glRotatef(Angle, 0, 0, 1);
  gluCylinder(MyQuadratic, 0.05, 0.05, 44.0, 8, 8);

  glPopMatrix();

  // website banners
  For I :=1 to 9 do
  begin
    z :=frac((Angle/3-I*4)/36)*36;

    if (z > 0) AND (Z < 34) then
    begin
      glPushMatrix();
      if Selection then
        glLoadName(I);
      glBindTexture(GL_TEXTURE_2D, Banners[I]);
      glTranslatef(-1.0, 0.0, z+10);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.125); glVertex3f( 0.0, -0.6,  2.0);
        glTexCoord2f(1.0, 0.125); glVertex3f( 0.0, -0.6,  0.0);
        glTexCoord2f(1.0, 0.875); glVertex3f( 0.0,  0.6,  0.0);
        glTexCoord2f(0.0, 0.875); glVertex3f( 0.0,  0.6,  2.0);
      glEnd();
      glPopMatrix();
    end;
  end;
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

  glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
  LoadTexture('tunnel2.bmp', TunnelTex, FALSE);
  LoadTexture('avis.jpg', Banners[1], FALSE);
  LoadTexture('explorercorp.jpg', Banners[2], FALSE);
  LoadTexture('leap.jpg', Banners[3], FALSE);
  LoadTexture('mazda.jpg', Banners[4], FALSE);
  LoadTexture('mazdawildlife.jpg', Banners[5], FALSE);
  LoadTexture('prism.jpg', Banners[6], FALSE);
  LoadTexture('musica.jpg', Banners[7], FALSE);
  LoadTexture('truworths.jpg', Banners[8], FALSE);
  LoadTexture('tinderbox.jpg', Banners[9], FALSE);

  Angle :=100;
  Speed :=0;
  MyQuadratic := gluNewQuadric();							// Create A Pointer To The Quadric Object (Return 0 If No Memory) (NEW)
  gluQuadricNormals(MyQuadratic, GLU_SMOOTH);	// Create Smooth Normals (NEW)
  gluQuadricTexture(MyQuadratic, GL_TRUE);   	// Create Texture Coords (NEW)
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
  if (keys[VK_UP])    then speed := speed + 0.005;
  if (keys[VK_DOWN])  then speed := speed - 0.005;
  if (keys[VK_RIGHT]) then speed := speed - 0.005;
  if (keys[VK_LEFT])  then speed := speed + 0.005;
end;


{------------------------------------------------------------------}
{  Processes all mouse Clicks                                      }
{------------------------------------------------------------------}
procedure MouseClick(X, Y : Integer);
var selectBuff : Array[0..63] of glUint;
    viewport : Array[0..3] of glUint;
    hits, SelectedName : glUint;
    I : Integer;
    URL : String;
    Hndl : HWnd;
begin
  // Select buffer parameters
  glGetIntegerv(GL_VIEWPORT, @viewport);   // Viewport = [0, 0, width, height]
  glSelectBuffer(23, @selectBuff);

  // Enter to selection mode
  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
    glRenderMode(GL_SELECT);
    Selection :=TRUE;

    // Clear Select Buffer;
    glInitNames();
    glPushName(0);
    glLoadIdentity();

    // setup a viewing volume.  (x, y, width, height, viewport)
    // NOTE : y has -27 to account to caption bar
    gluPickMatrix(x, viewport[3]-y-27, 1, 1, @viewport);      // Set-up pick matrix
    gluPerspective(45.0, viewport[2]/viewport[3], 0.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth
    glMatrixMode(GL_MODELVIEW);

    // Render all scene and fill selection buffer
    glDraw();

    // Get hits and go back to normal rendering
    hits := glRenderMode(GL_RENDER);

    // Get the element in the selection buffer if there was a hit.
    if (hits > 1) then
    begin
      URL :=BannerURL[selectBuff[hits*3+1]];
      Hndl :=ShellExecute(h_Wnd, 'open', PChar(URL), nil, nil, SW_SHOWNOACTIVATE);
      ShowWindow(Hndl, SW_SHOWNOACTIVATE);
    end;

    glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  Selection :=FALSE;
  glMatrixMode(GL_MODELVIEW);
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
    WM_LBUTTONDOWN:
      begin
        MouseClick(LOWORD(lParam), HIWORD(lParam));
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
    hInstance := NULL;
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
  pfd : PIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
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
    nSize           := SizeOf(PIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
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
  DemoStart : DWord;
  Frames : Integer;
begin
  finished := False;

  // Perform application initialization:
  if not glCreateWnd(800, 600, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  DemoStart := GetTickCount();            // Get Time when demo started
  Frames :=0;

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
      Inc(Frames);

//      LastTime :=ElapsedTime;
//      ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
//      ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement
      ELapsedTime :=(GetTickCount() - DemoStart) DIV Frames;

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

