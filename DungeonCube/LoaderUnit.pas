unit LoaderUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Samples.Gauges, Vcl.ComCtrls, CommCtrl, Vcl.StdCtrls;

type
  TLoader = class(TForm)
    BrandLogo: TImage;
    LoadBar: TImage;
    LoadText: TImage;
    NameLogo: TImage;
    status: TLabel;
    SlowLoad: TTimer;
    LoadBar_fill: TImage;
    procedure FormCreate(Sender: TObject);
    procedure SlowLoadTimer(Sender: TObject);
    procedure SetLoadText(text: string);
    procedure SetProgress(prog: integer);
    procedure FinishLoading();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Loader: TLoader;

implementation

{$R *.dfm}

uses Main, SelectClassUnit;

procedure TLoader.SetLoadText(text: string);
begin
  Status.Caption := text;
  application.ProcessMessages;
end;

procedure TLoader.FinishLoading();
begin
  SlowLoad.Enabled := true;
end;

procedure TLoader.SetProgress(prog: integer);
begin
  loadbar_fill.Width := trunc(loadbar.Width/100*prog);
end;

procedure TLoader.FormCreate(Sender: TObject);
begin
BrandLogo.Top := TRUNC(screen.Height / 2 - BrandLogo.Height *2.35);
BrandLogo.Left := trunc(screen.Width /2 - BrandLogo.Width / 1.8 );

NameLogo.Top := BrandLogo.Top+225;
NameLogo.left := trunc(screen.Width /2 - NameLogo.Width / 2.0);

LoadBar.Top := trunc(screen.Height - loadbar.Height - 30);
Loadbar.left := trunc(screen.Width / 2 - loadbar.Width /2);

LoadBar_fill.Top := trunc(screen.Height - loadbar.Height - 30);
Loadbar_fill.left := trunc(screen.Width / 2 - loadbar.Width /2);
LoadBar_fill.Width := 0;

Status.Top := LoadBar_fill.Top+95;
status.Left := LoadBar_fill.Left+15;

LoadText.Top := trunc(screen.Height - loadbar.Height - loadtext.Height - 15);
LoadText.Left := trunc(screen.Width / 2 - loadtext.Width / 2);
end;

procedure TLoader.SlowLoadTimer(Sender: TObject);
begin
  SlowLoad.Enabled := false;
  Main.RenderForm.Visible := true;
  SelectClassUnit.SelectClass.visible := true;
  Application.ShowMainForm := true;
  Self.Close;
end;

end.
