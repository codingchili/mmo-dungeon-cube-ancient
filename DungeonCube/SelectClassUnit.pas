unit SelectClassUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TSelectClass = class(TForm)
    class_select: TImage;
    ThiefSel: TImage;
    WarSel: TImage;
    MagSel: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ThiefSelClick(Sender: TObject);
    procedure WarSelClick(Sender: TObject);
    procedure MagSelClick(Sender: TObject);
    procedure ThiefSelMouseEnter(Sender: TObject);
    procedure WarSelMouseEnter(Sender: TObject);
    procedure MagSelMouseEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectClass: TSelectClass;

implementation

uses
playmon, Main, Initializer;

{$R *.dfm}

procedure TSelectClass.FormCreate(Sender: TObject);
begin
Top := trunc(screen.Height/2-selectclass.Height/2);
Left := trunc(screen.Width/2-selectclass.width/2);
player.class_selected := false;
end;

procedure TSelectClass.MagSelClick(Sender: TObject);
begin
Player := TPlayer.create(initializer.playername, 'Mage');
player.class_selected := true;

Main.skillset[READY] := Main.skillset_mage[READY];
Main.skillset[MANA] := Main.skillset_mage[MANA];
Main.skillset[COOL] := Main.skillset_mage[COOL];
self.Close;
end;

procedure TSelectClass.MagSelMouseEnter(Sender: TObject);
begin
  Player := TPlayer.create(initializer.playername, 'Mage');
player.class_selected := true;
Main.skillset[READY] := Main.skillset_mage[READY];
Main.skillset[MANA] := Main.skillset_mage[MANA];
Main.skillset[COOL] := Main.skillset_mage[COOL];
end;

procedure TSelectClass.ThiefSelClick(Sender: TObject);
begin
Player:= TPlayer.create(initializer.playername,'Thief');
player.class_selected := true;

Main.skillset[READY] := Main.skillset_thief[READY];
Main.skillset[MANA] := Main.skillset_thief[MANA];
Main.skillset[COOL] := Main.skillset_thief[COOL];

self.Close;
end;

procedure TSelectClass.ThiefSelMouseEnter(Sender: TObject);
begin
 Player := TPlayer.create(initializer.playername, 'Thief');
player.class_selected := true;
Main.skillset[READY] := Main.skillset_thief[READY];
Main.skillset[MANA] := Main.skillset_thief[MANA];
Main.skillset[COOL] := Main.skillset_thief[COOL];
end;

procedure TSelectClass.WarSelClick(Sender: TObject);
begin
Player := TPlayer.create(initializer.playername, 'Warrior');
player.class_selected := true;

Main.skillset[READY] := Main.skillset_warrior[READY];
Main.skillset[MANA] := Main.skillset_warrior[MANA];
Main.skillset[COOL] := Main.skillset_warrior[COOL];

self.Close;
end;

procedure TSelectClass.WarSelMouseEnter(Sender: TObject);
begin
 Player := TPlayer.create(initializer.playername, 'Warrior');
player.class_selected := true;
Main.skillset[READY] := Main.skillset_warrior[READY];
Main.skillset[MANA] := Main.skillset_warrior[MANA];
Main.skillset[COOL] := Main.skillset_warrior[COOL];
end;

end.
