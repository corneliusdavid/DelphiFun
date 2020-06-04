//******************************************************************************
//
// Author : Jason Allen
// Email : jra101@home.com
// Website : members.home.com/jra101
// Description: Setup form. Allows user to pick resolution and to toggle
//              fullscreen mode.
//
//******************************************************************************
unit Setup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmSetup = class(TForm)
    cmbRes: TComboBox;
    Resolution: TLabel;
    CheckBox1: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    cmbClr: TComboBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure cmbResChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbClrChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    windowWidth : Integer;    // Desired window width (fullscreen)
    windowHeight : Integer;   // Desired window height (fullscreen)
    fullscreen : Boolean;   // Toggle's fullscreen
    ColorBits : Integer;      // Color Depth
    closeProgram : Boolean;
  end;

var
  frmSetup: TfrmSetup;

implementation

{$R *.DFM}

procedure TfrmSetup.btnCancelClick(Sender: TObject);
begin
  closeProgram := True;
  Close;
end;

procedure TfrmSetup.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSetup.CheckBox1Click(Sender: TObject);
begin
  // Toggle fullscreen when the checkbox is clicked
  fullscreen := not fullscreen;
end;

procedure TfrmSetup.cmbResChange(Sender: TObject);
begin
  // Choose resolution based on selected item in combo box
  case cmbRes.ItemIndex of
    0 : // 640x480
      begin
        windowWidth := 640;
        windowHeight := 480;
      end;
    1 : // 800x600
      begin
        windowWidth := 800;
        windowHeight := 600;
      end;
    2 : //1024x768
      begin
        windowWidth := 1024;
        windowHeight := 768;
      end;
    3 : // 1152x864
      begin
        windowWidth := 1152;
        windowHeight := 864;
      end;
    4 : // 1280x960
      begin
        windowWidth := 1280;
        windowHeight := 960;
      end;
    5 : // 1280x1024
      begin
        windowWidth := 1280;
        windowHeight := 1024;
      end;
    6 : // 1600x1200
      begin
        windowWidth := 1600;
        windowHeight := 1200;
      end;
  end;
end;

procedure TfrmSetup.FormCreate(Sender: TObject);
begin
  // Set 640x480 to be default item in combobox
  cmbRes.ItemIndex := 1;
  cmbClr.ItemIndex := 1;

  // Set default resolution
  windowWidth := 800;
  windowHeight := 600;
  fullscreen := False;
  ColorBits :=32;
  
  // Default to not closeing program when setup form is closed
  closeProgram := False;
end;

procedure TfrmSetup.cmbClrChange(Sender: TObject);
begin
  if cmbRes.ItemIndex = 0 then
    ColorBits :=16
  else
    ColorBits :=32;
end;

procedure TfrmSetup.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then btnCancelClick(self);
end;

end.
