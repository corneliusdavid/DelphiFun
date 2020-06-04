object frmSetup: TfrmSetup
  Left = 189
  Top = 122
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Setup'
  ClientHeight = 132
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Resolution: TLabel
    Left = 8
    Top = 40
    Width = 50
    Height = 13
    Caption = 'Resolution'
  end
  object Label1: TLabel
    Left = 8
    Top = 72
    Width = 56
    Height = 13
    Caption = 'Color Depth'
  end
  object cmbRes: TComboBox
    Left = 72
    Top = 40
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cmbResChange
    Items.Strings = (
      '640x480'
      '800x600'
      '1024x768'
      '1152x864'
      '1280x960'
      '1280x1024'
      '1600x1200')
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 16
    Width = 73
    Height = 17
    Caption = 'Fullscreen'
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object btnOK: TButton
    Left = 40
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 120
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object cmbClr: TComboBox
    Left = 72
    Top = 64
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnChange = cmbClrChange
    Items.Strings = (
      '16 bit'
      '32 bit')
  end
end
