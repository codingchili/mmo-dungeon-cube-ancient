unit PatcherUnit;

interface

  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, IdHTTP, IdComponent, ShellAPi;

type
  TForm1 = class(TForm)
    loaded_none: TImage;
    loaded_all: TImage;
    Timer1: TTimer;
    status: TLabel;
    filename: TLabel;
    procedure loaded_noneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure loaded_allMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  text_status, file_status: string;
  URL: string = 'http://www.datagig.se/dungeon/data/';    //change this.
  patch_size: integer = 1;
  total_dl: integer = 0;
  new_ver: double = 0.0;
  file_progress: integer = 0;


implementation

{$R *.dfm}


procedure Download(fileUrl, fileName: string);
var
  Http: TIdHTTP;
  MS: TMemoryStream;
begin
  Http := TIdHTTP.Create(nil);
  Http.ConnectTimeout := 300;
  try
  try
    MS := TMemoryStream.Create;
    try
      Http.OnWork:= form1.HttpWork;
      Http.Get(fileUrl, MS);    //go through all the files here
      MS.SaveToFile(fileName);
    finally
      MS.Free;
    end;
  finally
    Http.Free;
  end;
  except
        if (fileexists('conf/Patch.dat')) then begin
        text_status := 'Requested File not Available.';
        form1.status.caption := text_status;
        application.ProcessMessages;
        sleep(800);
        application.Terminate;
  end;
      //form1.status.Caption := 'Current Version v'+FormatFloat('0.00', new_ver);
      //ShellExecute(0, 'open', 'Lobby.exe', nil, nil, SW_SHOWNORMAL);
      //application.Terminate;
  end;
end;

procedure TForm1.HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  Http: TIdHTTP;
  ContentLength: Int64;
  Percent: Integer;
begin
  Http := TIdHTTP(ASender);
   ContentLength := Http.Response.ContentLength;

   if (Pos('chunked', LowerCase(Http.Response.TransferEncoding)) = 0) and
      (ContentLength > 0) then
    begin

    Percent := 100*(total_dl+AWorkCount) div patch_size;
    File_Progress := AWorkCount;

    if percent > 100 then
     percent := 100;
    if text_status <> 'Checking Version..  ' then
     status.Caption := text_status+FormatFloat('0.00',(total_dl+AWorkCount)/1000000)+'/'+FormatFloat('0.00',(patch_size)/1000000)+' MB - ' + inttostr(percent) + '%';
    filename.Caption := file_status;
    form1.loaded_all.Width := trunc(percent/100*405);
    //form1.Refresh;
    //form1.repaint;
    //form1.Update;
    application.ProcessMessages;
  end;
end;

procedure SetTransparent(Aform: TForm; AValue: Boolean);
begin
  Form1.TransparentColor := AValue;
  Form1.TransparentColorValue := Form1.Color;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
SetTransparent(Self, True);

form1.Top := trunc(screen.Height/2-form1.Height/2)-30;
form1.Left := trunc(screen.Width/2-form1.Width/2);
loaded_all.Width := 0;

if not DirectoryExists('conf') then mkdir('conf');
if not DirectoryExists('dll') then mkdir('dll');
if not DirectoryExists('media') then mkdir('media');
if not DirectoryExists('patch') then mkdir('patch');
if not DirectoryExists('tool')  then mkdir('tool');

  screen.Cursors[0] := LoadCursor(HInstance, 'MAINCUR');
  screen.Cursor := screen.Cursors[0];
end;

procedure TForm1.loaded_noneMouseDown(Sender: TObject; Button: TMouseButton;
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

function GetSize(fileUrl: string): integer;
var
  Http: TIdHTTP;
begin
  Http := TIdHTTP.Create(nil);
  Http.ConnectTimeout := 90;
  try
    Http.Head(fileUrl);
  try
    result := Http.Response.ContentLength;
  except
    showmessage('Failed to get file size.');
    ShellExecute(0, 'open', 'Lobby.exe', NIL, NIL, SW_SHOWNORMAL);
    //application.Terminate;
  end;
  finally
    Http.Free;
  end;
end;

procedure Patch();
var
  patch, verFile:TextFile;
  ver: double;
  temp: string;
  patch_files: TStringList;
  i: integer;
begin
try
  patch_files := TStringList.Create;
  text_status := 'Getting Version..  ';
  form1.status.caption := text_status;

  if not fileexists('conf/Version.inf') then
    ver := 0.0;

  if fileexists('conf/Version.inf') then begin
    AssignFile(verFile, 'conf/Version.inf');
    reset(verFile);
    readln(verFile, temp);
    ver := SafeFloat(temp);
    new_ver := ver;
    closeFile(verFile);
  end;

  text_status := 'Checking Version..  ';
  form1.status.caption := text_status;

  Download(URL + 'conf/Patch.dat', 'conf/Patch.dat');

  AssignFile(patch, 'conf/Patch.dat');
  reset(patch);

  repeat
    readln(patch, temp);
    new_ver := safeFloat(temp);
    readln(patch, temp);
      if ver < new_ver then
        patch_files.Add(temp);
  until
  eof (patch);
  closeFile(patch);

    text_status := 'Fetching patch info..  ';
  form1.status.caption := text_status;

  for i := 0 to patch_files.Count-1 do begin;
    form1.status.Caption := '   Reading Data..';
    form1.filename.Caption := patch_files.Strings[i];
    Application.ProcessMessages;
    patch_size := patch_size+GetSize(URL+patch_files.Strings[i]);
  end;

  for i := 0 to patch_files.Count-1 do begin
    text_status := 'File '+inttostr(i+1)+'/'+inttostr(patch_files.count)+'.. ';
    file_status := 'Updating.. '+patch_files.Strings[i];

    form1.Update;
    Download(URL+patch_files.Strings[i], patch_files.Strings[i]);
    total_dl := total_dl+file_progress;
  end;
  AssignFile(verFile, 'conf/Version.inf');
  rewrite(verFile);
  writeln(verFile, FloatToStr(new_ver));
  closeFile(verFile);
  except
        if not(fileexists('conf/Patch.dat')) then begin
        text_status := 'Patch data unavailable.';
        form1.status.caption := text_status;
        application.ProcessMessages;
        sleep(800);
        end;
  end;
      form1.status.Caption := 'Current Version v'+FormatFloat('0.00', new_ver);
      ShellExecute(0, 'open', 'Lobby.exe', nil, nil, SW_SHOWNORMAL);
      application.Terminate;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
timer1.Enabled := false;
Patch();
end;

procedure TForm1.loaded_allMouseDown(Sender: TObject; Button: TMouseButton;
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

end.
