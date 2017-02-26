unit Reg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TRegisterForm = class(TForm)
    Image1: TImage;
    Edit1: TEdit;
    Image2: TImage;
    keycode: TLabel;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Function CheckRegistrationKey(key: string; isKeyGen: boolean): boolean; external 'dll/License.dll';  //check with register.dll, just to se
  procedure Check(key: string);

var
  RegisterForm: TRegisterForm;
  License: textFile;
  Registered: boolean;

implementation

uses Main;

{$R *.dfm}

procedure Check(key: string);
begin
if length(key) <> 25 then exit;

 if CheckRegistrationKey(key, true) = false
 then Registerform.Edit1.Clear
 else begin
    registered := true;

    assignFile(License, 'conf/License.dgc');
    rewrite(License);
    writeln(License, key);
    closeFile(License);

    Registerform.keycode.Caption := key;
    Main.Form1.Ver_Label.Caption := 'Licensed Version '+main.ver;
    Registerform.edit1.Visible := false;
 end;
end;

procedure TRegisterForm.Edit1Change(Sender: TObject);
begin
  check(edit1.text);
end;

procedure TRegisterForm.Edit1Click(Sender: TObject);
begin
edit1.Clear;
end;

procedure TRegisterForm.FormCreate(Sender: TObject);
var
key: string;
begin
registerform.Top := trunc(screen.Height/2-registerform.Height/2);
registerform.Left := trunc(screen.Width/2-registerform.Width/2);
//registerform.Update;

    if fileexists('conf/License.dgc') then begin
    assignFile(License, 'conf/License.dgc');
    reset(License);
    readln(License, key);
    closeFile(License);
    reg.Check(key);
 end;
end;

procedure TRegisterForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TRegisterForm.Image2Click(Sender: TObject);
begin
registerform.close;
end;

end.
