unit Hint;

interface

uses Graphics, Windows, Sysutils, AsphyreTypes;

type
THint = class
  text, style: string; //style: damage, heal, poison, stealth, unstealth, spawn...
  color: TColor;
  lifetime: integer;
  x, y: double;
 constructor Create();
 function getColor(): TColor2;
End;

const
  MAXMESSAGES = 5000; //400
  MAXNOTICES = 1;
  scroll_speed = 0.8;

type
TModule = class
  Hints: array of THint;
 procedure RollUp(style, text: string; x,y: integer; broadcast: boolean);
 procedure Orphan();
End;

procedure initialize();

var
  text_hint: TModule;
  i: integer;
  hover_hint: THint;

implementation

uses Network;

function Thint.getColor(): TColor2;
begin
  if style = 'chat'       then result := cColor2($FFFFFFFF, $FFFFFFFF);
  if style = 'physical'   then result := cColor2($FFFF0000, $FFFF0000);
  if style = 'mr-damage'  then result := cColor2($FF871F78, $FF871F78);
  if style = 'poison'     then result := cColor2($FF00FF00, $FF00FF00);
  if style = 'heal'       then result := cColor2($FF8db600, $FF8db600);
  if style = 'haste'      then result := cColor2($FFFF6600, $FFFF6600);
  if style = 'slow'       then result := cColor2($FF00FFFF, $FF00FFFF);
  if style = 'stealth'    then result := cColor2($FFCCCCCC, $FFCCCCCC);
  if style = 'experience' then result := cColor2($FFFFFF00, $FFFFFF00);
  if style = 'stun'       then result := cColor2($FFCC0040, $FFCC0040);
  if style = 'hover'      then result := cColor2($FF18e99f, $FF18e99f);
End;

constructor Thint.Create();
begin
  style := '0';
  text := '';
  x := 50;
  y := 50;
  lifetime := 100;
End;

procedure TModule.orphan();
var
  i: integer;
begin
  for i := 0 to length(text_hint.Hints)-1 do
    if text_hint.hints[i].lifetime > 0 then begin
      text_hint.hints[i].lifetime := text_hint.hints[i].lifetime-1;
      text_hint.Hints[i].Y := text_hint.Hints[i].Y-scroll_speed;
    end;
End;

procedure TModule.RollUp(style, text: string; x,y: integer; broadcast: boolean);
var
  i, lifetime: integer;
begin
  if broadcast = true then begin
    Network.SendHint(style, text, x, y);
    exit;
  end;

  lifetime := 80;
  if text = 'DEAD!' then begin
    lifetime := 185;
    y := y+20;
  end;

  for i := 0 to length(text_hint.Hints)-2 do begin
    text_hint.Hints[i].style := text_hint.Hints[i+1].style;
    text_hint.Hints[i].text := text_hint.Hints[i+1].text;
    text_hint.Hints[i].x := text_hint.Hints[i+1].x;
    text_hint.Hints[i].y := text_hint.Hints[i+1].y;
    text_hint.Hints[i].lifetime := text_hint.Hints[i+1].lifetime;
  end;

  text_hint.Hints[MAXMESSAGES-1].style := style;
  text_hint.Hints[MAXMESSAGES-1].text := text;
  text_hint.Hints[MAXMESSAGES-1].x := x;
  text_hint.Hints[MAXMESSAGES-1].y := y;
  text_hint.Hints[MAXMESSAGES-1].lifetime := lifetime;
End;

procedure Initialize();
var
  i: integer;
begin
  text_hint := TModule.create;
  SetLength(text_hint.Hints, MAXMESSAGES);

  for i := 0 to MAXMESSAGES-1 do
    text_hint.Hints[i] := THint.Create;

  hover_hint := THint.Create;
  hover_hint.style := 'hover';



End;


begin
END.
