unit Abilities;

interface

uses SysUtils, Controls, Camera, Network, Math;


procedure Initialize;

const
//all classes
BASIC = 0;
HEAL = 1;
HASTE = 2;

//warrior
TELESTRIKE = 3;
SHIELD = 4;
JUMPSTRIKE = 5;
SPELLSTRIKE = 6;
MIGHTYBLOW = 7;
BASICWAR = 20;

//mage
MAGEDAGGER = 8;
DEATHRAY = 9;
FARSIGHT = 10;
SLOW = 11;
STUN = 12;
BASICMAG = 21;

//thief
STEALTH = 13;
POISONDAGGER = 14;
SHADOWSTEP = 15;
LIFESTEAL = 16;
HIDDENDAGGER = 17;
BACKSTAB = 18;
BASICTHIEF = 22;

//spell sets
MAGE = 0;
THIEF = 1;
WARRIOR = 2;



type
  TSpell = class
public
 function OnCooldown(): boolean;
 function SpellCost(deduct: boolean): boolean;
 constructor create(id: integer);
public
  cost: integer;
 private
  id: Integer;
  silenceable: boolean;
  cool: integer;
  cool_time: integer;
end;

type
  TSpellSet = class
public
  spell: array [0..7] of TSpell;
 procedure Cast(spell: integer);
 procedure ProcessCooldowns();
 procedure SpellImpact(spell: integer);
 constructor create(class_name: integer);
private
  class_name: integer;
end;

var
  mage_spells :   TSpellSet;
  thief_spells:   TSpellSet;
  warrior_spells: TSpellSet;

  mage_set:     array [0..7] of integer = (BASIC, MAGEDAGGER, SLOW, STUN, DEATHRAY, FARSIGHT, HEAL, HASTE);
  thief_set:    array [0..7] of integer = (BASIC, POISONDAGGER, STEALTH, LIFESTEAL, SHADOWSTEP, HIDDENDAGGER, HEAL, HASTE);
  warrior_set:  array [0..7] of integer = (BASIC, SPELLSTRIKE, JUMPSTRIKE, TELESTRIKE, SHIELD, MIGHTYBLOW, HEAL, HASTE);
  //support class

implementation

Uses Playmon, PlayerClass, Collision, Entities, Hint;

constructor TSpell.create(id: Integer);
begin
  self.id := id;

silenceable := true;

case (id) of
HASTE: silenceable := false;
HEAL: silenceable := false;
BASIC: silenceable := false;
BASICWAR: silenceable := false;
BASICMAG: silenceable := false;
BASICTHIEF: silenceable := false;
end;

case (id) of
BASIC:    self.cost := 0;
BASICMAG: self.cost := 0;
BASICWAR: self.cost := 0;
BASICTHIEF: self.cost := 0;

HEAL:     self.cost := 20;

HASTE:    self.cost := 20;
TELESTRIKE:   self.cost := 15;
SHIELD:       self.cost := 20;
JUMPSTRIKE:   self.cost := 10;
SPELLSTRIKE:  self.cost := 5;
MIGHTYBLOW:   self.cost := 30;

MAGEDAGGER:   self.cost := 10;
DEATHRAY:   self.cost := 50;
FARSIGHT:   self.cost := 100;
SLOW:       self.cost := 25;
STUN:       self.cost := 30;

STEALTH:    self.cost := 10;
POISONDAGGER: self.cost := 5;
SHADOWSTEP:   self.cost := 15;
LIFESTEAL:    self.cost := 10;
HIDDENDAGGER: self.cost := 15;
end;

case (id) of
BASIC:    self.cool := trunc((1.5)*60);
HEAL:     self.cool := trunc((5.0)*60);
HASTE:    self.cool := trunc((8.0)*60);

TELESTRIKE:   self.cool := trunc((5.0)*60);
SHIELD:       self.cool := trunc((6.0)*60);
JUMPSTRIKE:   self.cool := trunc((4.0)*60);
SPELLSTRIKE:  self.cool := trunc((1.95)*60);
MIGHTYBLOW:   self.cool := trunc((12.0)*60);

MAGEDAGGER:   self.cool := trunc((1.95)*60);
DEATHRAY:   self.cool := trunc((6.0)*60);
FARSIGHT:   self.cool := trunc((12.0)*60);
SLOW:       self.cool := trunc((3.25)*60);
STUN:       self.cool := trunc((4.75)*60);

STEALTH:    self.cool := trunc((8.0)*60);
POISONDAGGER: self.cool := trunc((2.95)*60);
SHADOWSTEP:   self.cool := trunc((6.0)*60);
LIFESTEAL:    self.cool := trunc((5.5)*60);
HIDDENDAGGER: self.cool := trunc((12.0)*60);
end;
end;

function TSpell.OnCooldown(): boolean;
begin
      if (player.PlayerClass.silence > 0) and (self.cool_time = 0) then begin
       if not silenceable then
        result := false else
        result := true;
      end else
        if (self.cool_time > 0) then
          result := true
        else
          result := false;
end;

function TSpell.SpellCost(deduct: boolean): boolean;
begin
  if player.PlayerClass.power < self.cost then
      result := false
    else
      result := true;
end;

procedure TSpellSet.Cast(spell: integer);
var
  pi, r, step, dir, dist, low_dist, attack_range, x, y: double;
  slowballs, i, item, attack_bonus, speed, id: integer;
  attack_type: integer;
  impact_type: integer;
begin
id := self.spell[spell].id;

with self.spell[spell] do begin

//----------------------------- BASIC ATTACK --------------------------------------
  if id = BASIC then begin
    if Player.PlayerClass.alive = false then
      if Blocks.Collide(trunc(mouse.CursorPos.X-cam.X), trunc(mouse.CursorPos.Y-cam.Y)) = false then begin
        player.x := mouse.CursorPos.X-cam.X;                //revive effects
        player.y := mouse.CursorPos.Y-cam.y;
        player.PlayerClass.reset;
        player.PlayerClass.alive := true;
        Network.SendXY();
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
        exit;
      end;

        attack_range := player.PlayerClass.basic_range;
        attack_bonus := 0;
        attack_type := ABILITIES.BASIC;
        speed := 6;

        if Player.PlayerClass.class_name = 'Mage' then begin
          attack_bonus := trunc((player.PlayerClass.spell_dmg-player.PlayerClass.melee_dmg)/2);
          attack_type := ABILITIES.BASICMAG;
        end;

      if player.PlayerClass.class_name = 'Warrior' then begin
        if random(4) = 1 then
          attack_bonus := player.PlayerClass.melee_dmg+trunc(player.PlayerClass.melee_dmg/2.5);

          attack_type := ABILITIES.BASICWAR;

      if player.PlayerClass.yi_attack > 0 then begin
        attack_type := ABILITIES.TELESTRIKE;
        attack_bonus := trunc(player.PlayerClass.melee_dmg/2.5); //+150% dmg
        player.PlayerClass.yi_attack := 0;
        attack_range := 16.5;
      end;
      end;

      if player.PlayerClass.class_name = 'Thief' then
       attack_type := ABILITIES.BASICTHIEF;


      if player.PlayerClass.stealth > 0 then begin
        if player.PlayerClass.class_name = 'Thief' then
        attack_type := ABILITIES.BACKSTAB;
        attack_range := 14.5;
        player.StealthMode('Backstab!', 0);
        attack_bonus := trunc(player.PlayerClass.DEX*player.PlayerClass.DEX_mod*0.5);
        Network.SendXY();
      end;

      Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, attack_range,
      (attack_bonus)+player.PlayerClass.melee_dmg, speed,attack_type, player.name);
      cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
      exit;
    end;


//------------------------  FAR SIGHT ------------------------------------------

if id = FARSIGHT then begin
  player.PlayerClass.farsight := 4*(60);
  cool_time := trunc(cool-(cool/100)*player.PlayerClass.spell_cool);
  hint.text_hint.RollUp('haste', 'Farsight!', trunc(0.5*player.size+player.x+random(50)-75), trunc(player.y-player.size+random(50)-25), true);

  {Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 0.0,
  0.0, 0.0,attack_type, player.name);
      NetFire();}
  exit;
end;

//------------------------ JUMP STRIKE -----------------------------------------
if id = JUMPSTRIKE then begin

  attack_type := ABILITIES.JUMPSTRIKE;
  low_dist := 200.0;
  dist := 200.0;
  attack_range := 14;
  speed := 6;

  for i := 1 to High(Network.Multiplayer) do begin
    dist := power(player.x - Multiplayer[i].x, 2)+power(Player.y - Multiplayer[i].y, 2);
    dist := power(dist, 0.5);

      if dist < low_dist then begin
        item := i;
        low_dist := dist;
      end;
  end;

  if (low_dist < 85.0) then begin
    player.x := Multiplayer[item].x+random(50)-25;
    player.y := Multiplayer[item].y+random(50)-25;
    Network.SendXY;
    Entities.list.Fire(player.x, player.y, Multiplayer[item].x+cam.X, Multiplayer[item].y+cam.Y, attack_range, player.PlayerClass.melee_dmg, speed, attack_type, player.name);
    cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
  end else begin
    player.PlayerClass.power := player.PlayerClass.power+10;
    cool := 30; //10/60 -
  end;
end;


//----------------------  HIDDEN DAGGER -------------------------------------
//invisible Trap. Draw only if owner = YOU.

if id = HIDDENDAGGER then begin
        Entities.list.Fire(player.x+player.size/2+8, player.y+player.size/2+8, mouse.CursorPos.X, mouse.CursorPos.Y, 60*(60), Player.PlayerClass.spell_dmg, 0.0, ABILITIES.HIDDENDAGGER, player.name);
        //Entities.list.Entity[length(entities.list.Entity)-1].size := 25;
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
end;

//--------------------- STEALTH ---------------------------
if id = STEALTH then begin
      if player.PlayerClass.stealth > 0 then begin
        Player.StealthMode('Unstealth!', 0);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
        Network.SendXY();
        exit;
      end;

        Player.StealthMode('Stealth!', 10*(60));
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
        Network.SendXY();
        exit;
    end;

// ------------------------- HEAL ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +dmg
  if id = HEAL then begin
        player.PlayerClass.hp := player.PlayerClass.hp+player.PlayerClass.CON*(player.PlayerClass.con_mod*0.3); //1 mana = 1.5 hp
        hint.text_hint.RollUp('heal', '+'+inttostr(trunc(player.PlayerClass.CON*(player.PlayerClass.con_mod*0.3))), trunc(player.x+random(50)-25), trunc(player.y-player.size+random(50)-25), true);
        cool_time := (cool);
        Network.SendXY();
        exit;
      end;
// ------------------------- HASTE ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +80% dmg
  if id = HASTE then begin
        player.PlayerClass.haste := trunc(3.25*60);
        if player.PlayerClass.class_name = 'warrior' then inc(player.PlayerClass.haste, trunc(1.75*60));
        hint.text_hint.RollUp('haste', 'Haste!', trunc(0.5*player.size+player.x+random(50)-35), trunc(player.y-player.size+random(50)-25), true);
        cool_time := cool;
        Network.SendXY(player.dist);
        exit;
    end;

    // ------------------------- YI STRIKE ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +80% dmg
  if id = TELESTRIKE then
   if Blocks.Collide(trunc(mouse.CursorPos.X-cam.X), trunc(mouse.CursorPos.Y-cam.Y)) = false then begin

        player.PlayerClass.haste := trunc(1.25*60); //1.25 second haste!

        dir := ArcTan2(mouse.CursorPos.Y-cam.Y-(player.y+player.size/2-2), mouse.CursorPos.X-cam.X-(player.x+player.size/2-2));
        dist :=(power(player.x-(mouse.CursorPos.X-cam.X)+player.size/2-2, 2))+power(player.y-(mouse.cursorpos.Y-cam.Y)+player.size/2-2, 2);
        dist := power(dist, 0.5);

        if dist > 355.0 then
        dist := 355.0;

        player.x := player.x+dist*Cos(dir);
        player.y := player.y+dist*Sin(dir);

        if player.PlayerClass.class_name = 'Warrior' then
        player.PlayerClass.yi_attack := trunc(4*60);

        Network.SendXY();
        Network.SendXY(player.dist); //stop player after hastey
        hint.text_hint.RollUp('haste', 'Teleport!', trunc(0.5*player.size+player.x+random(50)-25), trunc(player.y-player.size+random(50)-25), true);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        exit;
    end;

//-------------------------- SLOWBALL --------------------------------------------------
  if id = SLOW then begin
        try
        slowballs := 10;
        r := 36.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(player.x+player.size/2-2+r*0.5*cos(i*step),
                             player.y+player.size/2-2+r*0.5*sin(i*step),
                             player.x+r*cos(i*step)+cam.X, player.y+r*sin(i*step)+cam.Y, 32,
                             Player.PlayerClass.spell_dmg, 1.95, ABILITIES.SLOW, player.name);

        end;

        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
      exit;
        except
        //
        end;
  end;


//--------------------------------  SPELL STRIKE -------------------------------
  if id = SPELLSTRIKE then begin                                                                                                                        //MAGICCCCCCCCS
        Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 45, player.PlayerClass.spell_dmg, 6.4, ABILITIES.SPELLSTRIKE, player.name);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
  end;


  //-------------------------- MIGHTY STRIKES --------------------------------------------------
  if id = MIGHTYBLOW then begin
        try
        slowballs := 9;
        r := 36.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(player.x+player.size/2-2+r*0.5*cos(i*step),
                             player.y+player.size/2-2+r*0.5*sin(i*step),
                             player.x+r*cos(i*step)+cam.X, player.y+r*sin(i*step)+cam.Y, 26,
                             Player.PlayerClass.melee_dmg, 0.65, ABILITIES.MIGHTYBLOW, player.name);

        end;

        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
      exit;
        except
        //
        end;
  end;




//---------------------------- POISON SHIV ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = POISONDAGGER then begin
        Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 45, Player.PlayerClass.DEX, 6.4, ABILITIES.POISONDAGGER, player.name);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        exit;
  end;


//---------------------------- SHADOWSTEP ---------------------------------------------
    if id = SHADOWSTEP then
   if Blocks.Collide(trunc(mouse.CursorPos.X-cam.X), trunc(mouse.CursorPos.Y-cam.Y)) = false then begin

        inc(player.PlayerClass.stealth, 2*(60)); //1.25 second haste!

        hint.text_hint.RollUp('haste', 'Shadowstep!', trunc(0.5*player.size+player.x+random(50)-25), trunc(player.y-player.size+random(50)-25), true);

        dir := ArcTan2(mouse.CursorPos.Y-cam.Y-(player.y+player.size/2-2), mouse.CursorPos.X-cam.X-(player.x+player.size/2-2));
        dist :=(power(player.x-(mouse.CursorPos.X-cam.X)+player.size/2-2, 2))+power(player.y-(mouse.cursorpos.Y-cam.Y)+player.size/2-2, 2);
        dist := power(dist, 0.5);

        if dist > 135.0 then
        dist := 135.0;

        player.x := player.x+dist*Cos(dir);
        player.y := player.y+dist*Sin(dir);

        Network.SendXY();
        Network.SendXY(player.dist); //stop player after hastey
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        exit;
    end;



  //---------------------------- MAGE DAGGER ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = MAGEDAGGER then begin

        Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 25, Player.PlayerClass.melee_dmg, 5.5, ABILITIES.MAGEDAGGER, player.name);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.attack_speed);
        exit;
  end;

    //---------------------------- SHIELD ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = SHIELD then begin

        player.PlayerClass.shield := 4;
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        hint.text_hint.RollUp('heal', 'Shield!', trunc(player.x-20), trunc(player.y), true);
        exit;
  end;


//---------------------------- ORB OF STUNNING ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = STUN then begin
      if player.PlayerClass.stealth > 0 then
        Player.StealthMode('Unstealth!', 0);

      Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 250, Player.PlayerClass.spell_dmg, 3.0, ABILITIES.STUN, player.name);
      cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool); //7 second cd
      exit;
  end;

//---------------------------- LIFESTEAK ---------------------------------------------
//life steaksteal
  if id = LIFESTEAL then begin
        Entities.list.Fire(player.x+player.size/2-2, player.y+player.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 45, Player.PlayerClass.spell_dmg, 6.5, ABILITIES.LIFESTEAL, player.name);
        cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        exit;
  end;

    // ------------------------- DEATHBLAST ---------------------------------------
  if id = DEATHRAY then begin
        try
        speed := 3;
        slowballs := 10;
        r := 18.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;
        impact_type := ABILITIES.DEATHRAY;


        dist :=(power(player.x-(mouse.CursorPos.X-cam.X)+player.size/2-2, 2))+power(player.y-(mouse.cursorpos.Y-cam.Y)+player.size/2-2, 2);
        dist := power(dist, 0.5);

        if dist < 500 then begin

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(Mouse.CursorPos.X+r*8*cos(i*step)-cam.X,
                             Mouse.CursorPos.Y+r*8*sin(i*step)-cam.Y,
                             mouse.CursorPos.X+r*cos(i*step),
                             mouse.CursorPos.Y+r*sin(i*step), 35,
                             Player.PlayerClass.spell_dmg, speed, impact_type, player.name);

        end;

          player.PlayerClass.poison := (3)*60; //deathray poison your soul
          cool_time := trunc((cool)-(cool/100)*player.PlayerClass.spell_cool);
        end;
        except
        //
        end;
  end;
end;

End;


constructor TSpellSet.create(class_name: integer);
begin
  self.class_name := class_name;
end;

procedure TSpellSet.ProcessCooldowns();
var
i : integer;
begin
  for I := 0 to High(self.spell) do
  if self.spell[i].cool_time > 0 then
    dec(self.spell[i].cool_time);

end;

procedure TSpellSet.SpellImpact(spell: integer);
var
heal: integer;
begin
  if (spell = ABILITIES.LIFESTEAL) or (spell = ABILITIES.DEATHRAY) then begin
    heal := trunc(2*Player.PlayerClass.level+
    player.PlayerClass.int_mod*player.PlayerClass.INT/2);
    player.PlayerClass.hp := player.PlayerClass.hp+heal;
    text_hint.RollUp('heal', '+'+inttostr(heal), trunc(player.x-random(10)+5), trunc(player.y), true);
  end;

    if (spell = ABILITIES.HIDDENDAGGER) then begin
    text_hint.RollUp('experience', 'Trap Sprung!', trunc(player.x-random(12)+5), trunc(player.y), true);
    player.PlayerClass.GainExp(15);
    end;

  if player.PlayerClass.class_name = 'mage' then
   player.PlayerClass.power := player.PlayerClass.power+4;

end;


procedure Initialize();
var
  i: integer;
begin
  mage_spells    := TSpellSet.Create(MAGE);
  thief_spells   := TSpellSet.Create(THIEF);
  warrior_spells := TSpellSet.Create(WARRIOR);

  for i := 0 to 7 do begin
   mage_spells.spell[i] := TSpell.create(mage_set[i]);
   thief_spells.spell[i] := TSpell.create(thief_set[i]);
   warrior_spells.spell[i] := TSpell.create(warrior_set[i]);
  end;


end;


end.
