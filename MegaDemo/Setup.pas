unit setup;

interface

uses
  Windows,
  Messages;

Const SETUP_WIDTH  = 320;
      SETUP_HEIGHT = 216;

var Width  : Integer = 800;
    Height : Integer = 600;
    PixelDepth : Integer = 32;
    FullScreen : Boolean =TRUE;

function SetupWin(hInstance : HINST; hPrevInstance : HINST) : Boolean; stdcall;

implementation

{$R setup.RES}

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  keys   : Array[0..255] of Boolean; // Holds keystrokes
  Done   : Boolean = FALSE;
  bitmapDC, buttonsDC, menuTextDC : HDC;

  BtnHint : Integer;
  Button : Array[1..10] of HRgn;


{-----------------------------------------------------}
{---  Show the current selected menu options       ---}
{-----------------------------------------------------}
procedure ShowMenuStatus;
begin
  if (BtnHint = 5) OR (BtnHint > 7) then exit;

  if (BtnHint < 1) OR (BtnHint > 3) then
  begin
    if Width = 640 then BitBlt(h_DC, 118, 80, 86, 14, menuTextDC, 0, 39, SRCPAINT);
    if Width = 800 then BitBlt(h_DC, 118, 80, 86, 14, menuTextDC, 0, 52, SRCPAINT);
    if Width =1024 then BitBlt(h_DC, 117, 80, 86, 14, menuTextDC, 0, 65, SRCPAINT);
  end;

  if (FullScreen) AND (BtnHint <> 4) then
    BitBlt(h_DC, 118, 117, 86, 14, menuTextDC, 0, 142, SRCPAINT);

  if (BtnHint <> 6) AND (BtnHint <> 7) then
  begin
    if PixelDepth = 16 then BitBlt(h_DC, 118, 97, 86, 14, menuTextDC, 0, 103, SRCPAINT);
    if PixelDepth = 32 then BitBlt(h_DC, 118, 97, 86, 14, menuTextDC, 0, 116, SRCPAINT);
  end;
end;


{-----------------------------------------------------}
{---  Paint the emnu and Button BMP on the window  ---}
{-----------------------------------------------------}
procedure PaintWindow;
begin
  BitBlt(h_DC, 0, 0, SETUP_WIDTH, SETUP_HEIGHT, bitmapDC, 0, 0, SRCCOPY);

  if Width = 640 then BitBlt(h_DC, 25, 10, 61, 56, buttonsDC, 0,  0, SRCCOPY);
  if Width = 800 then BitBlt(h_DC, 10, 59, 59, 44, buttonsDC, 0, 56, SRCCOPY);

  if FullScreen then
  begin
    if Width =1024 then
    begin
      BitBlt(h_DC, 11,112, 59, 44, buttonsDC, 0,100, SRCCOPY);   // 1024 with fullscreen
      BitBlt(h_DC, 24, 149, 61, 56, buttonsDC, 0,144, SRCCOPY);  // fullscreen with 1024
    end
    else
      BitBlt(h_DC, 25, 149, 61, 56, buttonsDC, 61,132, SRCCOPY);  // fullscreen without 1024
  end
  else
    if Width =1024 then BitBlt(h_DC, 11,112, 59, 44, buttonsDC, 61, 88, SRCCOPY);

  if PixelDepth = 16 then BitBlt(h_DC, 252, 59, 59, 44, buttonsDC, 61, 0, SRCCOPY);
  if PixelDepth = 32 then BitBlt(h_DC, 253, 112, 59, 44, buttonsDC, 61, 44, SRCCOPY);

  ShowMenuStatus;
end;


{-----------------------------------------------------}
{---  Show the button hints.                       ---}
{-----------------------------------------------------}
procedure ShowButtonHint(Btn : Integer);
begin
  if BtnHint = Btn then exit;  // if there is no change, then dont repaint

  BtnHint :=Btn;
  PaintWindow;
  case Btn of
    0 : ShowMenuStatus;
    1 : BitBlt(h_DC, 118, 79, 86, 14, menuTextDC, 0, 0, SRCPAINT);
    2 : BitBlt(h_DC, 118, 79, 86, 14, menuTextDC, 0, 13, SRCPAINT);
    3 : BitBlt(h_DC, 118, 79, 86, 14, menuTextDC, 0, 26, SRCPAINT);
    4 : BitBlt(h_DC, 118, 117, 86, 14, menuTextDC, 0, 129, SRCPAINT);
    5 : BitBlt(h_DC, 118, 90, 86, 44, menuTextDC, 0, 186, SRCPAINT);
    6 : BitBlt(h_DC, 118, 97, 86, 14, menuTextDC, 0, 77, SRCPAINT);
    7 : BitBlt(h_DC, 118, 97, 86, 14, menuTextDC, 0, 90, SRCPAINT);
    8 : BitBlt(h_DC, 118, 83, 86, 46, menuTextDC, 0, 231, SRCPAINT);
    9 : BitBlt(h_DC, 118, 99, 86, 15, menuTextDC, 0, 157, SRCPAINT);
   10 : BitBlt(h_DC, 118, 99, 86, 15, menuTextDC, 0, 171, SRCPAINT);
  end;
end;


procedure LoadSetupBMP;
var hBMP : HBitmap;
    ButtonRgn : Array[1..4] of TPoint;
begin
  hBMP :=LoadImage(hInstance, 'MENU', IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE);
  bitmapDC :=CreateCompatibleDC( h_dc );
  SelectObject(bitmapDC, hBMP);
  DeleteObject(hBMP);

  hBMP :=LoadImage(hInstance, 'BUTTONS', IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE);
  buttonsDC :=CreateCompatibleDC( h_dc );
  SelectObject(buttonsDC, hBMP);
  DeleteObject(hBMP);

  hBMP :=LoadImage(hInstance, 'MENUTEXT', IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE);
  menuTextDC :=CreateCompatibleDC( h_dc );
  SelectObject(menuTextDC, hBMP);
  DeleteObject(hBMP);

  PaintWindow;

  // 640x480
  ButtonRgn[1].X :=46;    ButtonRgn[1].Y :=10;
  ButtonRgn[2].X :=25;    ButtonRgn[2].Y :=41;
  ButtonRgn[3].X :=71;    ButtonRgn[3].Y :=65;
  ButtonRgn[4].X :=84;    ButtonRgn[4].Y :=42;
  Button[1] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  //800x600
  ButtonRgn[1].X :=18;    ButtonRgn[1].Y :=60;
  ButtonRgn[2].X :=11;    ButtonRgn[2].Y :=96;
  ButtonRgn[3].X :=60;    ButtonRgn[3].Y :=101;
  ButtonRgn[4].X :=65;    ButtonRgn[4].Y :=77;
  Button[2] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  //1024x768
  ButtonRgn[1].X :=12;    ButtonRgn[1].Y :=117;
  ButtonRgn[2].X :=18;    ButtonRgn[2].Y :=153;
  ButtonRgn[3].X :=65;    ButtonRgn[3].Y :=137;
  ButtonRgn[4].X :=60;    ButtonRgn[4].Y :=114;
  Button[3] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // fullscreen
  ButtonRgn[1].X :=27;    ButtonRgn[1].Y :=172;
  ButtonRgn[2].X :=45;    ButtonRgn[2].Y :=203;
  ButtonRgn[3].X :=83;    ButtonRgn[3].Y :=171;
  ButtonRgn[4].X :=70;    ButtonRgn[4].Y :=150;
  Button[4] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // top about
  ButtonRgn[1].X :=235;    ButtonRgn[1].Y :=43;
  ButtonRgn[2].X :=249;    ButtonRgn[2].Y :=63;
  ButtonRgn[3].X :=292;    ButtonRgn[3].Y :=40;
  ButtonRgn[4].X :=273;    ButtonRgn[4].Y :=11;
  Button[5] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // 16 bit color
  ButtonRgn[1].X :=255;    ButtonRgn[1].Y :=77;
  ButtonRgn[2].X :=259;    ButtonRgn[2].Y :=99;
  ButtonRgn[3].X :=307;    ButtonRgn[3].Y :=97;
  ButtonRgn[4].X :=301;    ButtonRgn[4].Y :=61;
  Button[6] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // 32 bit color
  ButtonRgn[1].X :=259;    ButtonRgn[1].Y :=114;
  ButtonRgn[2].X :=255;    ButtonRgn[2].Y :=137;
  ButtonRgn[3].X :=300;    ButtonRgn[3].Y :=153;
  ButtonRgn[4].X :=308;    ButtonRgn[4].Y :=117;
  Button[7] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // URL
{  ButtonRgn[1].X :=250;    ButtonRgn[1].Y :=152;
  ButtonRgn[2].X :=236;    ButtonRgn[2].Y :=172;
  ButtonRgn[3].X :=273;    ButtonRgn[3].Y :=203;
  ButtonRgn[4].X :=292;    ButtonRgn[4].Y :=173;
  Button[8] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);
}
  // OK
  ButtonRgn[1].X :=93;     ButtonRgn[1].Y :=191;
  ButtonRgn[2].X :=93;     ButtonRgn[2].Y :=215;
  ButtonRgn[3].X :=160;    ButtonRgn[3].Y :=215;
  ButtonRgn[4].X :=160;    ButtonRgn[4].Y :=191;
  Button[9] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);

  // Cancel
  ButtonRgn[1].X :=160;    ButtonRgn[1].Y :=191;
  ButtonRgn[2].X :=160;    ButtonRgn[2].Y :=215;
  ButtonRgn[3].X :=226;    ButtonRgn[3].Y :=215;
  ButtonRgn[4].X :=226;    ButtonRgn[4].Y :=191;
  Button[10] :=CreatePolygonRgn(ButtonRgn, 4, WINDING);
end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
var X, Y : Integer;
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
    WM_ENABLE:
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
        X := LOWORD(lParam);
        Y := HiWORD(lParam);
        BtnHint :=0;
        
        if PtInRegion(Button[1], X, Y) then Width:= 640;
        if PtInRegion(Button[2], X, Y) then Width:= 800;
        if PtInRegion(Button[3], X, Y) then Width:=1024;
        if PtInRegion(Button[4], X, Y) then FullScreen :=Not(FullScreen);

        if PtInRegion(Button[6], X, Y) then PixelDepth :=16;
        if PtInRegion(Button[7], X, Y) then PixelDepth :=32;

        if PtInRegion(Button[9], X, Y) then   //OK
        begin
          Done :=TRUE;
          keys[VK_ESCAPE] := TRUE;
        end;;
        if PtInRegion(Button[10], X, Y) then keys[VK_ESCAPE] := TRUE;  // Cancel

        Result := 0;
        PaintWindow;  // Repaint the screen
      end;
    WM_MOUSEMOVE:   // Mouse move
      begin
        X := LOWORD(lParam);
        Y := HiWORD(lParam);

        if PtInRegion(Button[1], X, Y) then ShowButtonHint(1)
        else if PtInRegion(Button[2], X, Y) then ShowButtonHint(2)
        else if PtInRegion(Button[3], X, Y) then ShowButtonHint(3)
        else if PtInRegion(Button[4], X, Y) then ShowButtonHint(4)

        else if PtInRegion(Button[5], X, Y) then ShowButtonHint(5)
        else if PtInRegion(Button[8], X, Y) then ShowButtonHint(8)

        else if PtInRegion(Button[6], X, Y) then ShowButtonHint(6)
        else if PtInRegion(Button[7], X, Y) then ShowButtonHint(7)

        else if PtInRegion(Button[9], X, Y)  then ShowButtonHint(9)
        else if PtInRegion(Button[10], X, Y) then ShowButtonHint(10)

        else if BtnHint > 0 then ShowButtonHint(0);

        Result := 0;
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
             WS_CLIPSIBLINGS or WS_POPUP;         // Doesn't draw within sibling windows
  dwExStyle := WS_EX_APPWINDOW or WS_EX_TOPMOST;  // Border with a raised edge

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
                          Width, Height-20,  // Size of window
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
