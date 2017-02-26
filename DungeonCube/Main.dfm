object RenderForm: TRenderForm
  Left = 771
  Top = 161
  BorderStyle = bsNone
  Caption = 'DungeonCube: ARENA'
  ClientHeight = 412
  ClientWidth = 557
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object BroadCastServerT: TTimer
    Enabled = False
    Interval = 3850
    OnTimer = BroadCastServerTTimer
    Left = 210
    Top = 26
  end
end
