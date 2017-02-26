unit MEMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Menus, JPeg;

type
  TForm1 = class(TForm)
    Image1: TImage;
    ScrollBox1: TScrollBox;
    Image2: TImage;
    Label1: TLabel;
    maptype: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    mouse_image: TImage;
    PopupMenu1: TPopupMenu;
    Actions1: TMenuItem;
    Exit1: TMenuItem;
    Button1: TButton;
    Timer1: TTimer;
    Panel2: TPanel;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image20: TImage;
    Image21: TImage;
    Image22: TImage;
    Image23: TImage;
    Image24: TImage;
    Image25: TImage;
    Load1: TMenuItem;
    Save1: TMenuItem;
    New1: TMenuItem;
    procedure FormResize(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image13Click(Sender: TObject);
    procedure Image14Click(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mouse_imageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image16Click(Sender: TObject);
    procedure Image17Click(Sender: TObject);
    procedure Image18Click(Sender: TObject);
    procedure Image24Click(Sender: TObject);
    procedure Image19Click(Sender: TObject);
    procedure Image23Click(Sender: TObject);
    procedure Image25Click(Sender: TObject);
    procedure Image22Click(Sender: TObject);
    procedure Image20Click(Sender: TObject);
    procedure Image21Click(Sender: TObject);
    procedure Compile1Click(Sender: TObject);
    procedure Generate1Click(Sender: TObject);
    procedure Actions1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  LastMap: string;

implementation

Uses Keyboard, Camera;

{$R *.dfm}

procedure TForm1.Actions1Click(Sender: TObject);
var
JPegImage :TJPegImage; // uses JPeg
begin
{JPegImage := TJPegImage.Create;
JPegImage.CompressionQuality := 90;
image1.Picture.Bitmap.PixelFormat := pf24bit;

JPegImage.Assign(image2.Picture.Bitmap);
JPegImage.SaveToFile(combobox1.text+'.png');
JPegImage.Free;

Keyboard.blocks.SaveToFile(combobox1.Text);

showmessage('The file was compiled and saved to: '+combobox1.Text+'.png');  }
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Popupmenu1.Popup(mouse.CursorPos.X, mouse.CursorPos.y);
end;

procedure ListFileDir(Path: string; FileList: TStrings);
var
  SR: TSearchRec;
begin
  if FindFirst(Path + '*.bmp', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        FileList.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;



procedure TForm1.Compile1Click(Sender: TObject);
var
JPegImage :TJPegImage; // uses JPeg
begin
{JPegImage := TJPegImage.Create;
JPegImage.CompressionQuality := 90;
image1.Picture.Bitmap.PixelFormat := pf24bit;

JPegImage.Assign(image2.Picture.Bitmap);
JPegImage.SaveToFile(combobox1.text+'.png');
JPegImage.Free;

Keyboard.blocks.SaveToFile(combobox1.Text);    }
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin

if MessageDlg('Exit Without Saving?',mtError, mbOKCancel, 0) = mrOK then
  form1.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not directoryexists('maps') then
  mkdir('maps');

image2.Canvas.Brush.Color := clWhite;
image2.Canvas.Brush.Style := bsSolid;
image2.Canvas.FillRect(Rect(0,0,2250,2250));

  screen.Cursors[0] := LoadCursor(HInstance, 'MAINCUR');
  screen.Cursor := screen.Cursors[0];
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = VK_CONTROL then
 popupmenu1.Popup(mouse.CursorPos.X, mouse.CursorPos.y);

end;

procedure TForm1.FormResize(Sender: TObject);
begin
Scrollbox1.Width := form1.Width-60;
scrollbox1.Height := form1.Height-60;
panel1.Top := form1.Height-panel1.Height*2+15;
panel1.Left := trunc(form1.Width/2-panel1.Width/2);
end;

procedure TForm1.Generate1Click(Sender: TObject);
begin
showmessage('Function Not Implemented.');
end;

procedure TForm1.Image10Click(Sender: TObject);
begin
mouse_image.Picture := image10.Picture;
maptype.Caption := 'Wood 1';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image11Click(Sender: TObject);
begin
mouse_image.Picture := image11.Picture;
maptype.Caption := 'Stone 2';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image12Click(Sender: TObject);
begin
mouse_image.Picture := image12.Picture;
maptype.Caption := 'Stone 1';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image13Click(Sender: TObject);
begin
mouse_image.Picture := image13.Picture;
maptype.Caption := 'Wood 2';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image14Click(Sender: TObject);
begin
mouse_image.Picture := image14.Picture;
maptype.Caption := 'Wood 3';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image16Click(Sender: TObject);
begin
mouse_image.Picture := image16.Picture;
maptype.Caption := 'Bridge 2';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image17Click(Sender: TObject);
begin
mouse_image.Picture := image17.Picture;
maptype.Caption := 'Chest 1';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image18Click(Sender: TObject);
begin
mouse_image.Picture := image18.Picture;
maptype.Caption := 'Sand 1';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image19Click(Sender: TObject);
begin
mouse_image.Picture := image19.Picture;
maptype.Caption := 'Redstone';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
mouse_image.Picture := image1.Picture;
maptype.Caption := 'Bridge 1';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.mouse_imageClick(Sender: TObject);
var
x,y: integer;
begin

x := -scrollbox1.Left+(mouse.CursorPos.X-mouse.CursorPos.X mod 30)-(cam.X);
y := -scrollbox1.top+(mouse.CursorPos.Y-mouse.CursorPos.Y mod 30)-(cam.y);

Blocks.PlaceBlock(x, y);
image2.Canvas.Draw(x, y, mouse_image.Picture.Graphic);
end;

procedure TForm1.New1Click(Sender: TObject);
begin
if MessageDlg('Create New?',mtError, mbOKCancel, 0) = mrOK then begin
image2.Canvas.LineTo(0,0);
image2.Canvas.Brush.Color := clWhite;
image2.Canvas.Brush.Style := bsSolid;
image2.Canvas.FillRect(Rect(0,0,2250,2250));
end;
end;

procedure TForm1.Save1Click(Sender: TObject);
var
lastmap: string;
begin
lastmap := InputBox('Save As..','Name','');

  image2.Picture.Bitmap.SaveToFile('maps/'+lastmap+'.bmp');
  Keyboard.blocks.SaveToFile(lastmap);
end;

procedure TForm1.Image20Click(Sender: TObject);
begin
mouse_image.Picture := image20.Picture;
maptype.Caption := 'Vertical Wall';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image21Click(Sender: TObject);
begin
mouse_image.Picture := image21.Picture;
maptype.Caption := 'Weird Plant';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image22Click(Sender: TObject);
begin
mouse_image.Picture := image22.Picture;
maptype.Caption := 'Horizontal Wall';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image23Click(Sender: TObject);
begin
mouse_image.Picture := image23.Picture;
maptype.Caption := 'End-Point';
Keyboard.block_type := ENDPOINT;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image25Click(Sender: TObject);
begin
mouse_image.Picture := image23.Picture;
maptype.Caption := 'Entry-Point';
Keyboard.block_type := ENTRYPOINT;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image24Click(Sender: TObject);
begin
mouse_image.Picture := image24.Picture;
maptype.Caption := 'Shoptable 1';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
xc,yc: integer;
begin
if getAsyncKEyState(VK_CONTROL) <> 0 then begin
xc := -scrollbox1.Left+(mouse.CursorPos.X-mouse.CursorPos.X mod 30)-(cam.X);
yc := -scrollbox1.top+(mouse.CursorPos.Y-mouse.CursorPos.Y mod 30)-(cam.y);
image2.Canvas.Draw(xc, yc, mouse_image.Picture.Graphic);
Blocks.PlaceBlock(xc, yc);
end;


mouse_image.Left := (mouse.CursorPos.X-mouse.CursorPos.X mod 30)-scrollbox1.Left;
mouse_image.Top := (mouse.CursorPos.Y-mouse.CursorPos.Y mod 30)-scrollbox1.top;
image2.SendToBack;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
mouse_image.Picture := image3.Picture;
maptype.Caption := 'Campfire 1';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image4Click(Sender: TObject);
begin
mouse_image.Picture := image4.Picture;
maptype.Caption := 'Campfire 2';
Keyboard.block_type := BLOCKING;
label1.Caption := 'Blocking: ON';
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
mouse_image.Picture := image5.Picture;
maptype.Caption := 'Grass 1';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image6Click(Sender: TObject);
begin
mouse_image.Picture := image6.Picture;
maptype.Caption := 'Grass 2';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image7Click(Sender: TObject);
begin
mouse_image.Picture := image7.Picture;
maptype.Caption := 'Grass 3';
Keyboard.block_type := WALKABLE;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image8Click(Sender: TObject);
begin
mouse_image.Picture := image8.Picture;
maptype.Caption := 'Water 1';
Keyboard.block_type := WATER;
label1.Caption := 'Blocking: OFF';
end;

procedure TForm1.Image9Click(Sender: TObject);
begin
mouse_image.Picture := image9.Picture;
maptype.Caption := 'Lava 1';
Keyboard.block_type := LAVA;
label1.Caption := 'Blocking: OFF';
end;


procedure TForm1.Load1Click(Sender: TObject);
var
map: string;
begin
image2.Canvas.LineTo(0,0);
image2.Canvas.Brush.Color := clWhite;
image2.Canvas.Brush.Style := bsSolid;
image2.Canvas.FillRect(Rect(0,0,2250,2250));

map := InputBox('New Map Name', 'Enter map Name..', 'map'+IntToStr(random(999)+1));
image2.Picture.Bitmap.LoadFromFile('maps/'+map+'.bmp');
Keyboard.blocks.LoadFromFile(map);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
Camera.cam.Update;
end;

end.
