unit Dungeon_KeyGen;

interface

uses
FastShareMem,
  System.SysUtils,
  ClipBoard,
    WinApi.Windows, Vcl.StdCtrls, Vcl.Imaging.pngimage,
 Winapi.Messages,System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    background: TImage;
    generate: TImage;
    key: TLabel;
    generate_active: TImage;
    Image1: TImage;
    procedure backgroundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure generateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure generateMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Function CheckRegistrationKey(key: string; isKeyGen: boolean): boolean; external '../dll/License.dll';  //check with register.dll, just to se

var
  Form1: TForm1;                                                    // |value|
  letters : array [0..62] of string = ('e','9','q','C','0','B','p','y','t','m','i','A','6','E','x','2','s','F','d','5','G','J','l','K','M','f','w','L','r','z','H','o','3','b','N','h','8','I','O','Q','T','4','R','u','S','c','Y','W','n','Y','7','V','k','X','g','Z','a','Y','1','D','P','j','U');
  theKey: string;
  tries, average, count: integeR;

implementation

{$R *.dfm}

Function MakeRegistrationKey(): string; export; //generate key format
var
  j,w: integeR;
  key: string;
  clipboard: TClipBoard;
begin
 Randomize;
 key := '';
 tries := 0;
 count := count+1;

  repeat
  key := '';

      for j := 1 to 25 do
      key := key+letters[random(62)];

  tries := tries+1;
  until
  CheckRegistrationKey(key, true) = true;     //true parameter - do not add to blacklist, test key

 average := tries+average;
 form1.key.Caption := 'Avg: '+inttostr(average DIV count)+':  '+key;

 clipboard := TClipBoard.Create;
  Clipboard.AsText := key;

 //MakeRegistrationKey;
end;

procedure TForm1.backgroundMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
form1.Top := trunc(screen.Height/2-form1.Height/2);
form1.Left := trunc(screen.Width/2-form1.Width/2);

  screen.Cursors[0] := LoadCursor(HInstance, 'MAINCUR');
  screen.Cursor := screen.Cursors[0];
end;

procedure TForm1.generateMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
generate.Visible := false;
generate_active.visible := true;
form1.Update;
MakeRegistrationKey();
end;

procedure TForm1.generateMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 generate.Visible := true;
generate_active.visible := false;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
form1.Close;
end;

end.
