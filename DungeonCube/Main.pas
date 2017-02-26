unit Main;

//this unit contains drawing.
//instead of using screen.heigh/width use form/clientwidth.!!!

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math;

type
  TRenderForm = class(TForm)
    BroadCastServerT: TTimer;
    procedure FormDestroy(Sender: TObject);
    procedure BroadCastServerTTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FailureHandled : Boolean;

    procedure OnAsphyreCreate(Sender: TObject; Param: Pointer;
    var Handled: boolean);
    procedure OnAsphyreDestroy(Sender: TObject; Param: Pointer;
    var Handled: Boolean);
    procedure OnDeviceInit(Sender: TObject; Param: Pointer;
    var Handled: Boolean);
    procedure OnDeviceCreate(Sender: TObject; Param: Pointer;
    var Handled: Boolean);
    procedure OnTimerReset(Sender: TObject; Param: Pointer;
    var Handled: Boolean);

    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderEvent(Sender: TObject);

    procedure HandleConnectFailure();
  public
    { Public declarations }
  end;

const
  VSYNC = True;
  SPEED = 60.0;
  MAXFPS = 120;

  COOL: integer = 0;
  MANA: integer = 1;
  READY: integer = 2;

var
  RenderForm: TRenderForm;
  //images mapping
  MAP_DEAD,
  MAP_ALIVE,

  MODEL_TEAM1,
  MODEL_TEAM2,
  MODEL_STEALTH,
  MODEL_THIEF,
  MODEL_WARRIOR,
  MODEL_MAGE,

  EFF_DEATHBLAST,
  EFF_HIDDENDAGGER,
  EFF_JUMPSTRIKE,
  EFF_LIFESTEAL,
  EFF_MAGEDAGGER,
  EFF_MIGHTYBLOW,
  EFF_SHIV,
  EFF_SHORTBOW,
  EFF_SLOWGLYPH,
  EFF_SPELL,
  EFF_SPELLSTRIKE,
  EFF_STUNGLYPH,
  EFF_SWORD,
  EFF_TELESTRIKE,
  EFF_WARD,

  GUI_PINGBAR,
  GUI_CHATBAR,
  GUI_SKILLBAR,
  GUI_STATBAR,
  GUI_HP_PW_XP,

  BUFF_BLEED,
  BUFF_STUN,
  BUFF_STEALTH,
  BUFF_POISON,
  BUFF_HASTE,
  BUFF_SLOW,
  BUFF_TELESTRIKE,
  BUFF_SILENCE,
  BUFF_FARSIGHT,

  MAGE_COOL,
  MAGE_MANA,
  MAGE_READY,

  THIEF_COOL,
  THIEF_MANA,
  THIEF_READY,

  WARRIOR_COOL,
  WARRIOR_MANA,
  WARRIOR_READY,

  FOG_OF_WAR, network_input, network_output: integer;
  tick: double;

  skillset_mage:    array [0..2] of integer;
  skillset_thief:   array [0..2] of integer;
  skillset_warrior: array [0..2] of integer;

  skillset: array [0..2] of integer = (0,0,0);

implementation

uses
Initializer, Ping, Camera, Playmon, Keyboard,Entities, Chat, hint, collision, network,
AsphyreTypes, AsphyreEventTypes, AsphyreEvents, AsphyreTimer, AsphyreFactory,
AsphyreArchives, AsphyreImages, AbstractDevices, AsphyreFonts, AbstractCanvas, AsphyrePNG,
NativeConnectors, DX7Providers, WGLProviders, DX9Providers, DX10Providers,
MobControl, DX11Providers,  Vectors2, Vectors2px;

{$R *.dfm}

procedure TRenderForm.FormDestroy(Sender: TObject);
begin
  if (GameDevice <> nil) then
    GameDevice.Disconnect();
End;

procedure TRenderForm.FormResize(Sender: TObject);
begin
if (GameDevice <> nil) then begin
  DisplaySize := Point2px(ClientWidth, ClientHeight);
  GameDevice.Resize(0, DisplaySize);
end;
end;

procedure TRenderForm.HandleConnectFailure;
begin
  Timer.Enabled := false;
  Showmessage('Failed To Initialize.');
  close();
end;

procedure TRenderForm.OnAsphyreCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  GameDevice := Factory.CreateDevice();
  GameCanvas := Factory.CreateCanvas();
  GameImages := TAsphyreImages.create();

  GameFonts := TAsphyreFonts.Create();
  GameFonts.images := GameImages;
  GameFonts.Canvas := GameCanvas;

  media_effects := TAsphyreArchive.Create();
  media_maps := TAsphyreArchive.Create();
  media_models := TAsphyreArchive.Create();
  media_gui := TAsphyreArchive.Create();
  media_deadmap := TAsphyreArchive.Create();

  media_effects.openMode := aomReadOnly;
  media_maps.openMode := aomReadOnly;
  media_models.openMode := aomReadOnly;
  media_gui.OpenMode := aomReadOnly;
  media_deadmap.OpenMode := aomReadOnly;

  ArchiveTypeAccess := ataAnyFile;

  media_effects.FileName := 'media/effects.dat';
  media_maps.FileName := 'media/'+initializer.map+'.dat';   //load initia.map.dat here?
  media_deadmap.Filename := 'media/maps.dat';
  media_models.FileName := 'media/models.dat';
  media_gui.FileName := 'media/gui.dat';
end;

procedure TRenderForm.OnAsphyreDestroy(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  Timer.Enabled := false;

  GameFonts.free;
  GameImages.free;
  media_effects.Free;
  media_maps.Free;
  media_models.Free;
  media_gui.Free;
  GameCanvas.free;
  FreeAndNil(GameDevice);
end;

procedure TRenderForm.OnDeviceCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  MAP_ALIVE  := GameImages.AddFromArchive('map.image', Media_Maps, '', False);
  MAP_DEAD   := GameImages.AddFromArchive('map_dead.image', Media_deadmap, '', False);



  EFF_DEATHBLAST    := GameImages.AddFromArchive('eff-deathblast.image', Media_effects, '', False);
  EFF_HIDDENDAGGER  := GameImages.AddFromArchive('eff-hiddendagger.image', Media_effects, '', False);
  EFF_JUMPSTRIKE    := GameImages.AddFromArchive('eff-jumpstrike.image', Media_effects, '', False);
  EFF_LIFESTEAL     := GameImages.AddFromArchive('eff-lifesteal.image', Media_effects, '', False);
  EFF_MAGEDAGGER    := GameImages.AddFromArchive('eff-magedagger.image', Media_effects, '', False);
  EFF_MIGHTYBLOW    := GameImages.AddFromArchive('eff-mightyblow.image', Media_effects, '', False);
  EFF_SHIV          := GameImages.AddFromArchive('eff-shiv.image', Media_effects, '', False);
  EFF_SHORTBOW      := GameImages.AddFromArchive('eff-shortbow.image', Media_effects, '', False);
  EFF_SLOWGLYPH     := GameImages.AddFromArchive('eff-slowglyph.image', Media_effects, '', False);
  EFF_SPELL         := GameImages.AddFromArchive('eff-spell.image', Media_effects, '', False);
  EFF_SPELLSTRIKE   := GameImages.AddFromArchive('eff-spellstrike.image', Media_effects, '', False);
  EFF_STUNGLYPH     := GameImages.AddFromArchive('eff-stunglyph.image', Media_effects, '', False);
  EFF_SWORD         := GameImages.AddFromArchive('eff-sword.image', Media_effects, '', False);
  EFF_TELESTRIKE    := GameImages.AddFromArchive('eff-telestrike.image', Media_effects, '', False);
  EFF_WARD          := GameImages.AddFromArchive('eff-ward.image', Media_effects, '', False);

  MODEL_TEAM1      := GameImages.AddFromArchive('model-team1.image', Media_models, '', False);
  MODEL_TEAM2      := GameImages.AddFromArchive('model-team2.image', Media_models, '', False);
  MODEL_STEALTH    := GameImages.AddFromArchive('model-stealth.image', Media_models, '', False);
  MODEL_THIEF      := GameImages.AddFromArchive('model-thief.image', Media_models, '', False);
  MODEL_WARRIOR    := GameImages.AddFromArchive('model-warrior.image', Media_models, '', False);
  MODEL_MAGE       := GameImages.AddFromArchive('model-mage.image', Media_models, '', False);

  GUI_PINGBAR    := GameImages.AddFromArchive('gui-pingbar.image', Media_gui, '', False);
  GUI_STATBAR    := GameImages.AddFromArchive('gui-statbar.image', Media_gui, '', False);
  GUI_SKILLBAR   := GameImages.AddFromArchive('gui-skillbar.image', Media_gui, '', False);
  GUI_CHATBAR    := GameImages.AddFromArchive('gui-chatbar.image', Media_gui, '', False);
  GUI_HP_PW_XP   := GameImages.AddFromArchive('gui-hp-pw-xp-bar.image', Media_gui, '', False);

  BUFF_BLEED      := GameImages.AddFromArchive('buff-bleed.image', Media_gui, '', False);
  BUFF_HASTE      := GameImages.AddFromArchive('buff-haste.image', Media_gui, '', False);
  BUFF_POISON     := GameImages.AddFromArchive('buff-poison.image', Media_gui, '', False);
  BUFF_SLOW       := GameImages.AddFromArchive('buff-slow.image', Media_gui, '', False);
  BUFF_STEALTH    := GameImages.AddFromArchive('buff-stealth.image', Media_gui, '', False);
  BUFF_STUN       := GameImages.AddFromArchive('buff-stun.image', Media_gui, '', False);
  BUFF_TELESTRIKE := GameImages.AddFromArchive('buff-telestrike.image', Media_gui, '', False);
  BUFF_FARSIGHT   := GameImages.AddFromArchive('buff-farsight.image', Media_gui, '', False);
  BUFF_SILENCE    := GameImages.AddFromArchive('buff-silence.image', Media_gui, '', False);

  MAGE_COOL  := GameImages.AddFromArchive('mage_cool.image', Media_gui, '', False);
  MAGE_MANA  := GameImages.AddFromArchive('mage_mana.image', Media_gui, '', False);
  MAGE_READY := GameImages.AddFromArchive('mage_ready.image', Media_gui, '', False);

  THIEF_COOL  := GameImages.AddFromArchive('thief_cool.image', Media_gui, '', False);
  THIEF_MANA  := GameImages.AddFromArchive('thief_mana.image', Media_gui, '', False);
  THIEF_READY := GameImages.AddFromArchive('thief_ready.image', Media_gui, '', False);

  WARRIOR_COOL  := GameImages.AddFromArchive('warrior_cool.image', Media_gui, '', False);
  WARRIOR_MANA  := GameImages.AddFromArchive('warrior_mana.image', Media_gui, '', False);
  WARRIOR_READY := GameImages.AddFromArchive('warrior_ready.image', Media_gui, '', False);

  FOG_OF_WAR      := GameImages.AddFromArchive('radar.image', Media_gui, '', False);

  skillset_mage[COOL]  := MAGE_COOL;
  skillset_mage[MANA]  := MAGE_MANA;
  skillset_mage[READY] := MAGE_READY;
  skillset_thief[COOL]  := THIEF_COOL;
  skillset_thief[MANA]  := THIEF_MANA;
  skillset_thief[READY] := THIEF_READY;
  skillset_warrior[COOL]  := WARRIOR_COOL;
  skillset_warrior[MANA]  := WARRIOR_MANA;
  skillset_warrior[READY] := WARRIOR_READY;



  GameImages.AddFromArchive('FONT.image', Media_gui, '', False);
  GameFonts.Insert('media/gui.dat | FONT.xml', 'FONT.image');
  GameFonts[0].Kerning := 1.00;
  GameFonts[0].Scale := 1.00;

  GameFonts.Insert('media/gui.dat | FONT.xml', 'FONT.image');
  GameFonts[1].Kerning := 1.05;
  GameFonts[1].Scale := 1.65;
  //GameFonts[0].FontSize := Point2px(20,10);


PBoolean(Param)^ := true;
end;

procedure TRenderForm.OnTimerReset(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
Timer.Reset();
end;

procedure TRenderForm.ProcessEvent(Sender: TObject);
begin
tick := tick+1.0;
if tick > main.SPEED then begin
 // writeln('Input - ' + FloatToStr(network.input) + 'B/s Output - ' + FloatToStr(network.output)+ 'B/s');
  network_input := network.input;
  network_output := network.output;
  network.input := 0;
  network.output := 0;
  tick := 0.0;
end;
  cam.Update;
  Entities.list.Orphan(0);
  text_hint.Orphan();
  Entities.list.Move();
  keyboard.Update();
  Collision.Detection();
  Player.tickRegen();
  Player.Movement;
  Player.ProcessCooldowns();

  if initializer.peermode = 'server' then begin
  Mob.TickRegen();
  Mob.AI();
  end;

  Network.Movement; //multiplayer movement
end;

procedure TRenderForm.RenderEvent(Sender: TObject);
var
  boost_pos, boost_pos2: single;
  i,j: integer;
  text_color, score_color: TColor2;
  fogrange, dist, theta: integer;
  angle: single;
  origin, middle, size: TPoint2;
  rottex: TPoint4;
begin
  text_color := cColor2($FFFF3300, $FFFF6600);
  score_color := cColor2($FF10BB40, $FF10DD20);
  boost_pos := DisplaySize.x-125;
  boost_pos2 := DisplaySize.x-195;
  fogrange := 450;
  if player.farsight > 0 then
    fogrange := 1350;

      GameCanvas.UseImagePt(GameImages[MAP_ALIVE], 0);
      GameCanvas.TexMap(pBounds4(254.0+cam.X, 254.0+cam.Y, 2250.0, 2250.0),clWhite4);

   if player.alive = false then begin
      GameCanvas.UseImagePt(GameImages[MAP_DEAD], 0);
      GameCanvas.TexMap(pBounds4(254.0+cam.X, 254.0+cam.Y, 2250.0, 2250.0),clWhite4);
    end;


 //projectiles
 with Entities.list do begin
  if length(Entity) > 0 then
  for i := 0 to length(Entity)-1 do begin

    //if Entity[i].range <= 0 then continue;

  case (Entity[i].impact) of
      TELESTRIKE: GameCanvas.UseImagePt(GameImages[EFF_TELESTRIKE], 0);
      JUMPSTRIKE: GameCanvas.UseImagePt(GameImages[EFF_JUMPSTRIKE], 0);
      SPELLSTRIKE: GameCanvas.UseImagePt(GameImages[EFF_SPELLSTRIKE], 0);
      MIGHTYBLOW: GameCanvas.UseImagePt(GameImages[EFF_MIGHTYBLOW], 0);
      BASICWAR: GameCanvas.UseImagePt(GameImages[EFF_SWORD], 0);
      MAGEDAGGER: GameCanvas.UseImagePt(GameImages[EFF_MAGEDAGGER], 0);
      DEATHRAY:GameCanvas.UseImagePt(GameImages[EFF_DEATHBLAST], 0);
      FARSIGHT: GameCanvas.UseImagePt(GameImages[EFF_WARD], 0);
      SLOW : GameCanvas.UseImagePt(GameImages[EFF_SLOWGLYPH], 0);
      STUN: GameCanvas.UseImagePt(GameImages[EFF_STUNGLYPH], 0);
      BASICMAG : GameCanvas.UseImagePt(GameImages[EFF_SPELL], 0);
      //STEALTH: GameCanvas.UseImagePt(GameImages[EFF_STEALTH], 0);
      POISONDAGGER: GameCanvas.UseImagePt(GameImages[EFF_SHIV], 0);
      LIFESTEAL: GameCanvas.UseImagePt(GameImages[EFF_LIFESTEAL], 0);
      HIDDENDAGGER: GameCanvas.UseImagePt(GameImages[EFF_HIDDENDAGGER], 0);
      BACKSTAB: GameCanvas.UseImagePt(GameImages[EFF_SWORD], 0);
      BASICTHIEF: GameCanvas.UseImagePt(GameImages[EFF_SHORTBOW], 0);
 end;



Origin := point2(Entity[i].x+cam.X, Entity[i].y+cam.Y);
Size := point2(20, 20);
Middle := point2(10, 10);
Theta := 1;
Angle := DegToRad(RadToDeg(Entity[i].dir)+90);

  GameCanvas.TexMap(pRotate4(Origin, Size, Middle, Angle, Theta), clWhite4);


  end;
 end;

// draw player
  if player.alive = true then
    if player.stealth = 0 then begin
      GameCanvas.UseImagePt(GameImages[player.model], 0);

      Origin := point2(player.x+cam.X, player.y+cam.Y);
      Size := point2(30, 30);
      Middle := point2(15, 15);
      Theta := 1;
      Angle := DegToRad(RadToDeg(player.dir)+90);

      GameCanvas.TexMap(pRotate4(Origin, Size, Middle, Angle, Theta), clWhite4);

      //GameCanvas.TexMap(pBounds4(player.x+cam.X, player.y+cam.Y, 30.0, 30.0),clWhite4);
    end else begin
      GameCanvas.UseImagePt(GameImages[MODEL_STEALTH], 0);
      GameCanvas.TexMap(pBounds4(player.x+cam.X, player.y+cam.Y, 22.0, 22.0),clWhite4);
    end;


    GameCanvas.UseImagePt(GameImages[FOG_OF_WAR], 0);
//draw fog
    if player.farsight > 0 then
    GameCanvas.TexMap(pBounds4(player.x+cam.X-(2*fogrange/2), player.y+cam.Y-(2*fogrange/2), fogrange*2, fogrange*2), clWhite4, beNormal)
    else
    GameCanvas.TexMap(pBounds4(player.x+cam.X-(2*fogrange/2), player.y+cam.Y-(2*fogrange/2), fogrange*2, fogrange*2), clWhite4, beNormal);

 //multiplayer
  for i := 1 to High(Multiplayer) do begin
      GameCanvas.UseImagePt(GameImages[Multiplayer[i].image], 0);

      dist := trunc(Math.power(player.x - Multiplayer[i].x, 2)+math.power(Player.y - Multiplayer[i].y, 2));
      dist := trunc(Math.power(dist, 0.5));


      if dist < fogrange then begin
      Origin := point2(Multiplayer[i].x+cam.X, Multiplayer[i].y+cam.Y);
      Size := point2(30, 30);
      Middle := point2(15, 15);
      Theta := 1;
      Angle := DegToRad(RadToDeg(Multiplayer[i].dir)+90);

      GameCanvas.TexMap(pRotate4(Origin, Size, Middle, Angle, Theta), clWhite4);
      end;
  end;

  //blackgrounds
  GameCanvas.UseImagePt(GameImages[GUI_CHATBAR], 0);
  GameCanvas.TexMap(pBounds4(0, DisplaySize.y-160, 415.0, 137.0),clWhite4);
  //GameCanvas.UseImagePt(GameImages[GUI_SKILLBAR], 0);
  //GameCanvas.TexMap(pBounds4(trunc(DisplaySize.x/2-237.0), DisplaySize.y-55, 439.0, 55.0),clWhite4);
  GameCanvas.UseImagePt(GameImages[GUI_PINGBAR], 0);
  GameCanvas.TexMap(pBounds4(DisplaySize.x-190, -2, 171.0, 50.0),clWhite4);
  GameCanvas.UseImagePt(GameImages[GUI_STATBAR], 0);
  GameCanvas.TexMap(pBounds4(DisplaySize.x-210, DisplaySize.y-300, 172.0, 287.0),clWhite4);

  GameCanvas.UseImagePt(GameImages[GUI_HP_PW_XP], 0);
  GameCanvas.TexMap(pBounds4(4, 3, 325.0, 28.0),clWhite4);
  GameCanvas.UseImagePt(GameImages[GUI_HP_PW_XP], 0);
  GameCanvas.TexMap(pBounds4(4, 29, 325.0, 28.0),clWhite4);
  GameCanvas.UseImagePt(GameImages[GUI_HP_PW_XP], 0);
  GameCanvas.TexMap(pBounds4(4, 54, 325.0, 28.0),clWhite4);

  //gui
  GameCanvas.FillRect(16, 17, trunc(295.0), 3, $FFFF0000, beNormal);
  GameCanvas.FillRect(16, 16, trunc((player.hp/player.hp_max)*295.0), 5, $FF00FF00, beNormal);

  GameCanvas.FillRect(16, 16, trunc((295.0 / 4) * (player.shield)), 5, $FFCCCCCC, beNormal);

  GameCanvas.FillRect(16, 43, trunc(295.0), 3, $FFFF0000, beNormal);
  GameCanvas.FillRect(16, 42, trunc((player.power/player.power_max)*295.0), 5, $FF1BB2E0, beNormal);

  GameCanvas.FillRect(16, 66, trunc(295.0), 3, $FFFF0000, beNormal);
  GameCanvas.FillRect(16, 65, trunc((player.xp/player.xp_max)*295.0), 5, $FFF7F70C, beNormal);

  //some stats
    GameFonts.Items[0].TextOut(Point2(boost_pos-45,DisplaySize.y-275), Player.class_name+' lv.'+inttostr(player.level), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-250), 'HP: '    +IntToStr(Trunc(player.hp))+'/'+IntToStr(trunc(player.hp_max)), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-225), 'PW: '    +IntTostr(trunc(player.power))+'/'+IntToStr(trunc(player.power_max)), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-200), 'XP: '    +intToStr(player.xp)+'/'+intToStr(player.xp_max), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-175), 'C-Atk: ' +intToStr(player.melee_dmg), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-150), 'R-Atk: ' +intToStr(player.range_dmg), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos,DisplaySize.y-125), 'S-Atk:'  +intToStr(player.spell_dmg), text_color);

    //stat allocation
    GameFonts.Items[0].TextOut(Point2(boost_pos2,DisplaySize.y-250), 'CON: '+intToStr(player.CON), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos2,DisplaySize.y-225),'DEX: '+intToStr(player.DEX), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos2,DisplaySize.y-200), 'STR: '+intToStr(player.STR), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos2,DisplaySize.y-175), 'INT: '+intToStr(player.INT), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos2,DisplaySize.y-150), 'WIS: '+intToStr(player.WIS), text_color);

  //def points
    GameFonts.Items[0].TextOut(Point2(boost_pos2+30,DisplaySize.y-100), 'PR-DEF: '+intToStr(player.pr_def), text_color);
    GameFonts.Items[0].TextOut(Point2(boost_pos2+30,DisplaySize.y-75), 'MR-DEF: '+intToStr(player.mr_def), text_color);
  //stat pts
    GameFonts.Items[0].TextOut(Point2(boost_pos2+30,DisplaySize.y-40), 'Stat Pts: '+intToStr(player.stat_points), text_color);

  //score
      GameFonts.Items[1].TextOut(Point2(335.0, 15.0), intToStr(player.score), score_color);
      GameFonts.Items[1].TextOut(Point2(335.0, 40.0), intToStr(player.lose), text_color);


//mouse over hint
  GameFonts.Items[0].TextOut(Point2(hover_hint.x, hover_hint.y), hover_hint.text, hover_hint.getColor());
//fps
  GameFonts.Items[0].TextOut(Point2(DisplaySize.x-200, 8), 'FPS: '+inttostr(Timer.FrameRate), text_color);
//ping
  GameFonts.Items[0].TextOut(Point2(DisplaySize.x-200, 24), 'Ping: '+IntToStr(Ping.RoundTripMs), text_color);
//data-rate
  GameFonts.Items[0].TextOut(Point2(DisplaySize.x-200, 40), 'In  '+IntToStr(main.network_input)+'B/s Out '+IntToStr(main.network_output)+'B/s', text_color);
//hints
  for i := 0 to Length(text_hint.Hints)-1 do begin
    if text_hint.Hints[i].lifetime > 0 then
      GameFonts.Items[0].TextOut(Point2(text_hint.Hints[i].x+cam.X, text_hint.Hints[i].y+cam.Y), text_hint.Hints[i].text, text_hint.Hints[i].getColor);
  end;

//chat
  for i := 0 to Length(Chat.Session.Chatters)-1 do
    GameFonts.Items[0].TextOut(Point2(8, DisplaySize.y-145+(i*16)), Chat.Session.Chatters[i].name+': '+Chat.Session.Chatters[i].text, text_color);

  if keyboard.in_chat = true then
     GameFonts.Items[0].TextOut(Point2(8, DisplaySize.y-22), player.name+': '+keyboard.chat_string, hover_hint.getColor);

//------------------------- COOLS AND STUFF ;) ------------------------------------------------

if (player.class_selected = true) then
 for i := 0 to High(Player.spell) do begin //go from spell 1 to 8 and inc portion
 //set image map
         GameCanvas.UseImagePx(GameImages[skillset[READY]], pBounds4(i*55, 0, 55.0, 55.0));

 if player.spell[i].OnCooldown(player.silence) = true then //drawOnCool
    GameCanvas.UseImagePx(GameImages[skillset[COOL]], pBounds4(i*55, 0, 55.0, 52.0))
    else
    if player.spell[i].SpellCost(trunc(player.power)) = false then //drawNoMana
        GameCanvas.UseImagePx(GameImages[skillset[MANA]], pBounds4(i*55, 0, 55.0, 52.0));

  GameCanvas.TexMap(pBounds4(trunc(DisplaySize.x/2-237.0+i*55), DisplaySize.y-55, 52.0, 52.0), clWhite4);
 end;

 //-------------------------------------- BUFFS DEBUFFS -------------------------------------
j := 10;

if player.silence > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_SILENCE], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.silence/60)), text_color);
  j := j+41;
end;

if player.farsight > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_FARSIGHT], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.farsight/60)), text_color);
  j := j+41;
end;

if player.poison > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_POISON], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.poison/60)), text_color);
  j := j+41;
end;

if player.slow > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_SLOW], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.slow/60)), text_color);
  j := j+41;
end;

if player.stun > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_STUN], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.stun/60)), text_color);
  j := j+41;
end;

if player.haste > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_HASTE], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.haste/60)), text_color);
  j := j+41;
end;

if player.yi_attack > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_TELESTRIKE], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.yi_attack/60)), text_color);
  j := j+41;
end;

if player.stealth > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_STEALTH], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.stealth/60)), text_color);
  j := j+41;
end;

if player.bleed > 0 then begin
  GameCanvas.UseImagePt(GameImages[BUFF_BLEED], 0);
  GameCanvas.TexMap(pBounds4(j, 80, 40.0, 40.0),clWhite4);
  GameFonts.Items[0].TextOut(Point2(j+14.0, 120.0), inttostr(trunc(player.bleed/60)), text_color);
end;



End;

procedure TRenderForm.TimerEvent(Sender: TObject);
begin
  if (not NativeAsphyreConnect.Init()) then
    exit();

    if (GameDevice <> nil) and (GameDevice.IsAtFault()) then begin
      if (not FailureHandled) then
      HandleConnectFailure();
      FailureHandled := True;
      exit;
    end;

    if (GameDevice = nil) or (not GameDevice.Connect()) then
    exit;

    GameDevice.Render(RenderEvent, $00000);
    Timer.Process();
end;

procedure TRenderForm.OnDeviceInit(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  DisplaySize := Point2px(ClientWidth, ClientHeight);
  GameDevice.SwapChains.Add(Self.Handle, DisplaySize);
  GameDevice.SwapChains.Items[0].VSync := VSYNC;
  GameCanvas.Antialias := true;
end;



procedure TRenderForm.BroadCastServerTTimer(Sender: TObject);
begin
//broadcast the game onto the local network.
  Network.BroadCast('HELLO!-GAMESERVER');
End;


procedure TRenderForm.FormCreate(Sender: TObject);
begin
  //ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.ShowMainForm := false;

  Factory.UseProvider(idDirectX11); //dx7, dx9, dx10, dx11, openGL
  EventAsphyreCreate.Subscribe(ClassName, OnAsphyreCreate);
  EventAsphyreDestroy.Subscribe(ClassName, OnAsphyreDestroy);
  EventDeviceInit.Subscribe(ClassName, OnDeviceInit);
  EventDeviceCreate.Subscribe(ClassName, OnDeviceCreate);
  EventTimerReset.Subscribe(ClassName, OnTimerReset);

  Timer.MaxFPS := MAXFPS;
  Timer.Speed := SPEED;
  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.Enabled := True;

  FailureHandled := False;
End;


begin
END.
