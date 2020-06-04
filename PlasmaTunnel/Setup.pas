unit setup;

interface

uses
  Windows,
  Messages;

Const SETUP_WIDTH  = 128;
      SETUP_HEIGHT = 128;

var Width  : Integer = 800;
    Height : Integer = 600;
    PixelDepth : Integer = 32;
    FullScreen : Boolean =FALSE;

function SetupWin(hInstance : HINST; hPrevInstance : HINST) : Boolean; stdcall;

implementation

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  keys   : Array[0..255] of Boolean; // Holds keystrokes
  Done   : Boolean = FALSE;
  bitmapDC, CheckBoxDC : HDC;


procedure PaintWindow;
begin
  BitBlt(h_DC, 0, 0, SETUP_WIDTH, SETUP_HEIGHT, bitmapDC, 0, 0, SRCCOPY);

  if Width = 640 then BitBlt(h_DC, 14, 15, 10, 10, checkboxDC, 0, 0, SRCCOPY);
  if Width = 800 then BitBlt(h_DC, 14, 27, 10, 10, checkboxDC, 0, 0, SRCCOPY);
  if Width =1024 then BitBlt(h_DC, 14, 39, 10, 10, checkboxDC, 0, 0, SRCCOPY);

  if FullScreen then BitBlt(h_DC, 14, 55, 10, 10, checkboxDC, 0, 0, SRCCOPY);

  if PixelDepth = 16 then BitBlt(h_DC, 14, 84, 10, 10, checkboxDC, 0, 0, SRCCOPY);
  if PixelDepth = 32 then BitBlt(h_DC, 14, 96, 10, 10, checkboxDC, 0, 0, SRCCOPY);
end;


procedure LoadSetupBMP;
var hBMP : HBitmap;
begin
  hBMP :=LoadImage(hInstance, 'images\setup.bmp', IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE OR LR_LOADFROMFILE);
  bitmapDC :=CreateCompatibleDC( h_dc );
  SelectObject(bitmapDC, hBMP);
  DeleteObject(hBMP);

  hBMP :=LoadImage(hInstance, 'images\setup_check.bmp', IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE OR LR_LOADFROMFILE);
  checkBoxDC :=CreateCompatibleDC( h_dc );
  SelectObject(checkBoxDC, hBMP);
  DeleteObject(hBMP);

  PaintWindow;
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
    WM_MOVE:
      begin
        PaintWindow;  // Repaint the screen
      end;
    WM_ACTIVATE:
      begin
        PaintWindow;  // Repaint the screen
      end;
    WM_KEYDOWN:        // Set the pressed key (wparam) to equal true so we can check if its pressed
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_LBUTTONDOWN:   // Left mouse button down
      begin

        // test for checkboxes
        if (LOWORD(lParam) >=13 ) AND (LOWORD(lParam) <=23) then  { X range }
        begin
          if (HiWORD(lParam) >=14) AND (HiWORD(lParam) <=24) then Width :=640;
          if (HiWORD(lParam) >=26) AND (HiWORD(lParam) <=36) then Width :=800;
          if (HiWORD(lParam) >=38) AND (HiWORD(lParam) <=48) then Width :=1024;

          if (HiWORD(lParam) >=54) AND (HiWORD(lParam) <=64) then FullScreen :=Not(FullScreen);

          if (HiWORD(lParam) >=83) AND (HiWORD(lParam) <=93) then PixelDepth :=16;
          if (HiWORD(lParam) >=95) AND (HiWORD(lParam) <=105) then PixelDepth :=32;
        end;

        // Test for OK button
        if (LOWORD(lParam) >=14 ) AND (LOWORD(lParam) <=62) AND  { X range }
           (HiWORD(lParam) >=111) AND (HiWORD(lParam) <=125) then { Y range }
        begin
          Done :=TRUE;
          keys[VK_ESCAPE] := TRUE;
        end;

        // Test for Cancel button
        if (LOWORD(lParam) >=67 ) AND (LOWORD(lParam) <=115) AND  { X range }
           (HiWORD(lParam) >=111) AND (HiWORD(lParam) <=125) then { Y range }
             keys[VK_ESCAPE] := TRUE;

        Result := 0;
        PaintWindow;  // Repaint the screen
      end;
    else
    begin
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);
      Exit;
    end;
  end;
end;


{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}
procedure KillWnd(Fullscreen : Boolean);
begin

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
  if (not UnRegisterClass('SetupGL', hInstance)) then
  begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Creates the window and attaches a OpenGL rendering context to it  }
{--------------------------------------------------------------------}
function CreateWnd(Width, Height : Integer; Fullscreen : Boolean) : Boolean;
Const   pfd : PIXELFORMATDESCRIPTOR = (
    nSize:            SizeOf(PIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion:         1;                    // The version of this data structure
    dwFlags:          PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                      or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                      or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType:       PFD_TYPE_RGBA;        // RGBA color format
    cColorBits:       16;                   // OpenGL color depth
    cRedBits:         0;                    // Number of red bitplanes
    cRedShift:        0;                    // Shift count for red bitplanes
    cGreenBits:       0;                    // Number of green bitplanes
    cGreenShift:      0;                    // Shift count for green bitplanes
    cBlueBits:        0;                    // Number of blue bitplanes
    cBlueShift:       0;                    // Shift count for blue bitplanes
    cAlphaBits:       0;                    // Not supported
    cAlphaShift:      0;                    // Not supported
    cAccumBits:       0;                    // No accumulation buffer
    cAccumRedBits:    0;                    // Number of red bits in a-buffer
    cAccumGreenBits:  0;                    // Number of green bits in a-buffer
    cAccumBlueBits:   0;                    // Number of blue bits in a-buffer
    cAccumAlphaBits:  0;                    // Number of alpha bits in a-buffer
    cDepthBits:       16;                   // Specifies the depth of the depth buffer
    cStencilBits:     0;                    // Turn off stencil buffer
    cAuxBuffers:      0;                    // Not supported
    iLayerType:       PFD_MAIN_PLANE;       // Ignored
    bReserved:        0;                    // Number of overlay and underlay planes
    dwLayerMask:      0;                    // Ignored
    dwVisibleMask:    0;                    // Transparent color of underlay plane
    dwDamageMask:     0                     // Ignored
  );
var
  wndClass : TWndClass;       // Window class
  dwStyle : DWORD;            // Window styles
  dwExStyle : DWORD;          // Extended window styles
  dmScreenSettings : DEVMODE; // Screen settings (fullscreen, etc...)
  PixelFormat : Integer;       // Settings for the OpenGL rendering
  h_Instance : HINST;         // Current instance
  hPos, vPos : Integer;
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
    lpszClassName := 'SetupGL';
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
      dmBitsPerPel := 16;                       // 16 bit color
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to fullscreen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  dwStyle := WS_CLIPCHILDREN or     // Doesn't draw within child windows
             WS_CLIPSIBLINGS;       // Doesn't draw within sibling windows
  dwExStyle := WS_EX_APPWINDOW or   // Top level window
               WS_EX_WINDOWEDGE or WS_EX_DLGMODALFRAME;    // Border with a raised edge

  // Get screen center and coordinates to position window in the center
  hPos := GetDeviceCaps(GetDC(0), HORZRES);  // Screen width
  vPos := GetDeviceCaps(GetDC(0), VERTRES);  // Screen Height
  hPos := (hPos - Width) DIV 2;
  vPos := (vPos - Height) DIV 2;

  // Attempt to create the actual window
  h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                          'SetupGL',      // Class name
                          'Demo Setup',   // Window title (caption)
                          dwStyle,        // Window styles
                          hPos, vPos,     // Window Position
                          Width, Height,  // Size of window
                          0,              // No parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if h_Wnd = 0 then
  begin
    KillWnd(Fullscreen);                // Undo all the settings we've changed
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    KillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Attempts to find the pixel format supported by a device context that is the
  // best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    KillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by
  // the PixelFormat.
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    KillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings to ensure that the window is the topmost window
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  LoadSetupBMP;

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function SetupWin(hInstance : HINST; hPrevInstance : HINST) : Boolean; stdcall;
var
  msg : TMsg;
  finished : Boolean;
begin
  finished := False;
  Done   :=FALSE;
  Result :=FALSE;

  // Perform application initialization:
  if not CreateWnd(SETUP_WIDTH+6, SETUP_HEIGHT+25, FALSE) then
    Exit;

  // Main message loop:
  while not(finished) do
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
      if (keys[VK_ESCAPE]) then
        finished := True;

      if (keys[VK_RETURN]) then
      begin
        finished := True;
        Done :=True;
      end;

    end;
  end;

  case width of
     640 : Height :=480;
     800 : Height :=600;
    1024 : Height :=768;
  end;
  KillWnd(FALSE);
  result  :=Done;
end;

end.
