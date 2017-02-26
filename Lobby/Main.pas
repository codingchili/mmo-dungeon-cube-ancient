unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, ShellApi;

type
  TForm1 = class(TForm)
    backgroundIMG: TImage;
    Edit1: TEdit;
    join_not: TImage;
    start_not: TImage;
    Label1: TLabel;
    Ver_Label: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox3: TComboBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    start_on: TImage;
    join_on: TImage;
    Image1: TImage;
    Image2: TImage;
    procedure backgroundIMGMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure start_notMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure backgroundIMGMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure join_notMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure join_onClick(Sender: TObject);
    procedure start_onClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Ver_LabelClick(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure UpdateGame();

var
  Form1: TForm1;
  mousex, mousey: integer;
  UserName, ver: string;
  GameMap: string = 'map_philip';

implementation

uses Networking, Chat, Reg;

{$R *.dfm}



procedure UpdateGame();
var
i: integer;
begin
form1.ListBox1.Clear;

for i := 0 to high(networking.inGame) do
  form1.ListBox1.Items.Add(networking.inGame[i].name);
end;

procedure TForm1.backgroundIMGMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;


procedure TForm1.backgroundIMGMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
join_on.Visible := false;
start_on.Visible := false;
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin
gameMap := ComboBox3.Text;
Session.RollUp('SYSTEM', 'Your game will be hosting '+GameMap+'.');
end;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
 ListOfStrings.Clear;
 ListOfStrings.Delimiter     := Delimiter;
 ListOfStrings.DelimitedText := Str;
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  DataList: TStringList;
  i: integer;
begin

if getAsyncKeyState(VK_RETURN) <> 0 then begin
try
try
datalist := TStringList.Create;

Split(' ', edit1.Text, Datalist);

if Datalist[0] = '/peermode' then begin  //client or server
networking.peermode := datalist.strings[1];
Session.rollup('Peermode', networking.peermode);

if networking.peermode = 'server' then begin
  networking.host := '127.0.0.1';
Session.rollup('Master', Networking.host);
Session.rollup('Lobby', 'Connecting..');
//Networking.Client.Send(datalist.Strings[1], 1558, 'PING&'+username);
Networking.Server.Send(networking.host, 1558, 'PING&'+username, TEncoding.Unicode);
end;
end;


if Datalist[0] = '/master' then begin   //master ip or self
networking.host := datalist.Strings[1];
Session.rollup('Master', Networking.host);
Session.rollup('Lobby', 'Connecting..');
//Networking.Client.Send(datalist.Strings[1], 1558, 'PING&'+username);
Networking.Server.Send(networking.host, 1558, 'PING&'+username, TEncoding.Unicode);
end;

if Datalist[0] = '/who-here' then begin   //master ip or self
  Session.rollup('Lobby', 'Listing Local Clients..');
for i := 0 to length(networking.users)-1 do
    memo1.Lines.Add(users[i].name+' - '+users[i].ip+':'+inttostr(users[i].port));
end;

if Datalist[0] = '/who-there' then begin   //master ip or self
  Session.rollup('Lobby', 'Listing Remote Clients..');
Networking.Server.Send(networking.host, 1558, 'WHO_THERE', TEncoding.Unicode);
end;

if Datalist[0] = '/langame' then begin
Session.RollUp('SYSTEM', 'Not Implemented.');
//Networking.Server.Broadcast('ANY_GAMES_HERE', 1558, '', TEncoding.Unicode);
//Networking.Server.Broadcast('ANY_GAMES_HERE', 1556, '', TEncoding.Unicode);
end;

if Datalist[0] = '/ip' then
Session.RollUp('SYSTEM', 'Running on IP: '+Networking.GetIPAddress);

if Datalist[0] = '/ping' then    //master ip or self
Networking.Server.Send(datalist.Strings[1], 1558, 'PING&'+username, TEncoding.Unicode);


if Datalist[0] = '/clear' then    //clear
memo1.Lines.Clear;

if Datalist[0] = '/game' then begin   //clear
Session.RollUp('Game','Joining.. '+datalist.Strings[1]);
networking.Server.Send(networking.GameHost, 1558, 'GAME_LEAVE', TEncoding.Unicode);
networking.gamehost := datalist.Strings[1];

try
networking.gameport := StrToInt(datalist.Strings[2]);
except
  networking.gameport := 1556;
end;
networking.Server.Send(networking.GameHost, 1558, 'GAME_JOIN&'+username, TEncoding.Unicode);
networking.Server.Send(networking.GameHost, networking.gameport, 'GAME_JOIN&'+username, TEncoding.Unicode);
end;

if Datalist[0] = '/name' then begin   //set userame
if registered = true then begin
username := datalist.Strings[1];
Session.rollup('Name', username);
end else
Session.RollUp('License', 'Required For This Action.');
end;


if datalist.Strings[0][1]  <> '/' then
  Networking.SendMsg(UserName, edit1.Text);

  edit1.Clear;

finally
edit1.Clear;
datalist.Free;
end;
except
  Session.rollup('SYSTEM', 'Unrecognized Command or Invalid Parameters.');
end;
end;
end;

function SafeFloat( pText : string ): Double;
var
  is_euro: boolean;
  i: integer;
  dummy: double;
  dummy_str: string;
begin
  dummy := 1/2;
  dummy_str := FloatToStr(dummy);                             //swap depending on host machine

  for i := 0 to length(dummy_str)-1 do begin
    if dummy_str[i] = '.' then is_euro := true;
    if dummy_str[i] = ',' then is_euro := false;
  end;

  if is_euro = false then
    pText := StringReplace(pText, '.', ',', [rfIgnoreCase, rfReplaceAll]);

  if is_euro = true then
    pText := StringReplace(pText, ',' ,'.', [rfIgnoreCase, rfReplaceAll]);

result := StrToFloat(pText);
End;

procedure SetTransparent(Aform: TForm; AValue: Boolean);
begin
  Form1.TransparentColor := AValue;
  Form1.TransparentColorValue := Form1.Color;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
verFile: textFile;
begin
SetTransparent(Self, True);

  screen.Cursors[0] := LoadCursor(HInstance, 'MAINCUR');
  screen.Cursor := screen.Cursors[0];

form1.Left := trunc(screen.Width/2-form1.Width/2);
form1.Top := trunc(screen.Height/2-form1.Height/2);

username := 'Stranger'+inttostr(random(999));

try
if fileexists('conf/Version.inf') then begin
assignFile(verFile, 'conf/Version.inf');
reset(verFile);
readln(verFile, ver);
closefile(verFile);
ver_label.Caption := 'Unlicensed Version v'+ver;
end;
except
  ver_label.Caption := 'Could Not Load Version.';
end;

chat.initialize;
Session.RollUp('SYSTEM', 'Running on Version: '+ver);
Session.RollUp('SYSTEM', 'Running on IP: '+Networking.GetIPAddress);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
form1.WindowState := wsMinimized;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
form1.Close;
end;

procedure TForm1.join_notMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
join_on.Visible := true;
//join_not.Visible := false;
end;

procedure TForm1.join_onClick(Sender: TObject);
begin
Networking.peermode := 'client';
networking.gameport := 1556;
networking.gamehost := '192.168.0.14'; //default host change this
Session.rollup('Master', Networking.host);
Session.rollup('Lobby', 'Connecting..');
Networking.Server.Send(networking.host, 1558, 'PING&'+username, TEncoding.Unicode);
networking.Server.Send(networking.GameHost, 1558, 'GAME_LEAVE', TEncoding.Unicode);
sleep(1);
Session.RollUp('Game', 'Connecting to Game..');
networking.Server.Send(networking.GameHost, 1558, 'GAME_JOIN&'+username, TEncoding.Unicode);
networking.Server.Send(networking.GameHost, networking.gameport, 'GAME_JOIN&'+username, TEncoding.Unicode);
end;

procedure TForm1.start_notMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
start_on.Visible := true;
//start_not.Visible := false;
end;


procedure TForm1.start_onClick(Sender: TObject);
begin
if MessageDlg('Start Game?',mtConfirmation, mbOKCancel, 0) = 1 then begin
ShellExecute(Handle,'open', 'ARENA.exe', PChar(username+#10+#13+'server'+#10+#13+'127.0.0.1'+#10+#13+inttostr(networking.gameport)+#10+#13+GameMap), nil, SW_SHOWNORMAL) ;
Networking.StartGame();
end;
end;


procedure TForm1.Ver_LabelClick(Sender: TObject);
begin
  reg.RegisterForm.Show;
end;

begin


end.
