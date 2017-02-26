unit Playmon;

interface


uses Graphics, Windows, SysUtils, Controls, Math;

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
 function OnCooldown(silence: integer): boolean;
 function SpellCost(power: integer): boolean;
 constructor create(id: integer);
public
  cost: integer;
  range: integer;
 private
  id: Integer;
  silenceable: boolean;
  cool: integer;
  cool_time: integer;
end;


type
  TPlayer = class
 public
  name, ip, team: string;
  x, y, dir, dist, speed: double;
  color: TColor;
  size: integer;

  //abilities
  spell: array [0..7] of TSpell;

  //surface control.
  thisMedium, lastMedium: integer;

  //gamemode
  score, lose: integer;

  //playerclass
  class_name: string;
  stun, stealth, silence, regen_block, slow, poison, haste, bleed, bleedhint, poisonhint, lavahint, waterhint, farsight: integer;
  alive, class_selected: boolean;
  INT, WIS, STR, DEX, CON, stat_points, level, xp, xp_max, yi_attack: integer;
  hp, hp_max, power, power_max, hp_regen, power_regen, basic_range: double;
  con_mod, dex_mod, str_mod, int_mod, base_speed, wis_mod, speed_mod, pr_mod, mr_mod,
  spell_cool, attack_speed: double;
  spell_dmg, melee_dmg, range_dmg, pr_def, mr_def, shield, model: integer;

 //abilities
 procedure Cast(spell: integer; pos: TPoint);
 procedure ProcessCooldowns();
 procedure SpellImpact(spell: integer);

 //playerclass
 procedure levelUp();
 procedure GainExp(amount: integer);
 procedure MakeStats();
 procedure Reset();
 procedure AddStat(name: string);

 //constructor Create(); overload;
 constructor create(name, player_class: string; is_mob: boolean = false); overload;
 procedure Movement();
 function px():double;
 function py():double;
 function getX(): integer;
 function getY(): integer;
 function getSpeed(): double;
 procedure Damage(amount: double; dmg_type: integer; projectile_owner: string);
 procedure TickRegen();
 procedure StealthMode(status: string; stealth_amount: integer);
End;

procedure initialize();


var
  Player: TPlayer;
  mage_set:     array [0..7] of integer = (BASIC, MAGEDAGGER, SLOW, STUN, DEATHRAY, FARSIGHT, HEAL, HASTE);
  thief_set:    array [0..7] of integer = (BASIC, POISONDAGGER, STEALTH, LIFESTEAL, SHADOWSTEP, HIDDENDAGGER, HEAL, HASTE);
  warrior_set:  array [0..7] of integer = (BASIC, SPELLSTRIKE, JUMPSTRIKE, TELESTRIKE, SHIELD, MIGHTYBLOW, HEAL, HASTE);
  //support class

implementation

Uses Initializer, Collision, Hint, Keyboard, Camera, Entities, Network, Main;


procedure TPlayer.Reset();
begin
  hp := hp_max/3;
  power := power_max/2;

  stealth := 0;
  haste := 0;
  stun := 0;
  poison := 0;
  slow := 0;
  shield := 0;
  farsight := 0;
  bleed := 0;
  silence := 0;
  regen_block := 0;

  bleedhint := 0;
  poisonhint := 0;
  lavahint := 0;
End;


procedure TPlayer.makeStats();  //bal
begin
  hp_max := 4+(con*con_mod)+(level*5);
  power_max := 5+(wis*wis_mod)+(2*level);

  hp_regen := (0.55+CON*0.42)/60;
  power_regen := (0.55+WIS*0.42)/60;

  speed := base_speed+0.5*dex*(speed_mod)*(dex_mod/2)+(0.025*level);

  if (speed > 2.6) then
    speed := 2.6;

  spell_dmg := level*2+trunc(int_mod*(INT));    //+-20% ?
  spell_cool := wis*1.15;           //spell cd reduction 0.8% per wis
  if spell_cool > 45.0 then
    spell_cool := 45.0;

  if self.class_name = 'Mage' then
   spell_cool := spell_cool+20.0;


  attack_speed := trunc(dex_mod*dex+level/5+1);          //1% per dex n lvl

  if attack_speed > 85.0 then
    attack_speed := 85.0;


  melee_dmg := trunc(level*1.5+str_mod*(STR)+5);
  range_dmg := trunc(level*1.5+dex_mod*(dex)+5);

  pr_def := trunc(1.3*level+dex*pr_mod);
  mr_def := trunc(1.3*level+wis*mr_mod);     //grants resistance

//add gear stats HERE

  if hp > hp_max then
    hp := hp_max;
  if power > power_max then
    power := power_max;
End;


constructor TPlayer.create(name, player_class: string; is_mob: boolean = false);
var
i: integer;
begin
  randomize;

  score := 0;
  lose := 0;

  x := -2500.0;
  y := -2500.0;
  size := 14;
  team := 'team2';

if is_mob = true then
  repeat
     randomize;
      x := random(3000)+300.0;
      y := random(3000)+300.0;
      size := 24;
      team := 'mob';
  until
      (Collision.blocks.MediumType(trunc(x), trunc(y)) = Collision.WALKABLE) or
      (Collision.blocks.MediumType(trunc(x), trunc(y)) = Collision.WATER);


  class_name := player_class;


  if (class_name = 'Thief') then model := Main.MODEL_THIEF;
  if (class_name = 'Warrior') then model := Main.MODEL_WARRIOR;
  if (class_name = 'Mage') then model := Main.MODEL_MAGE;
  


  self.name := name;
  xp := 0;
  hp := 0;
  stealth := 0;

  INT := 5;
  CON := 5;
  WIS := 5;
  DEX := 5;
  STR := 5;
  level := 0;
  stat_points := 6;

  base_speed := 1.1;
  speed_mod := 0.08;
  hp_max := 100;
  xp_max := 100;
  power := 0;
  power_max := 100;

  slow := 0;
  haste := 0;
  poison := 0;
  stun := 0;
  poisonhint := 0;
  yi_attack := 0;
  bleed := 0;
  bleedhint := 0;

  pr_mod := 0.5;
  mr_mod := 0.5;
  con_mod := 13.5;

  dex_mod := 1.25;
  str_mod := 0.90;
  int_mod := 3.50;
  wis_mod := 12.0;
  hp_regen := 5;
  power_regen := 0.85;

  if player_class = 'Warrior' then begin
    con_mod := 21.0;
    str_mod := 1.95;
    pr_mod := 1.25;
    basic_range := 14.5;

    for i := 0 to 7 do
      spell[i] := TSpell.create(warrior_set[i]);

  end;

  if player_class = 'Thief' then begin
    dex_mod := 2.15;
    pr_mod := 0.75;
    wis_mod := 14.5;
    con_mod := 15.2;
    str_mod := 1.15;
    basic_range := 45.0;

    for i := 0 to 7 do
      spell[i] := TSpell.create(thief_set[i]);

  end;

  if player_class = 'Mage' then begin
    mr_mod := 0.92;
    wis_mod := 18.5;
    int_mod := 5.2;
    dex_mod := 1.25;
    basic_range := 75.0;

    for i := 0 to 7 do
      spell[i] := TSpell.create(mage_set[i]);

  end;

  makestats();
  levelUp();
End;



procedure TPlayer.levelUp();
begin
  xp := 0;
  Inc(level);
  stat_points := stat_points+round(level/2)+2;
  xp_max :=  Trunc(100*level/4);

  hp := hp+Trunc(hp_max/4);
  power := hp+Trunc(power_max/3);

  if level > 1 then
  hint.text_hint.RollUp('experience', 'Level Up!', trunc(self.x-8), trunc(self.y), true);

  makestats();
End;

procedure TPlayer.gainExp(amount: integer);
begin
  xp := xp+amount;

  if xp > xp_max then
    levelUp();
End;

procedure TPlayer.AddStat(name:string);
begin
  if stat_points < 1 then exit;
  if name = 'DEX' then inc(DEX);
  if name = 'STR' then inc(STR);
  if name = 'CON' then inc(CON);
  if name = 'INT' then inc(INT);
  if name = 'WIS' then inc(WIS);

  dec(stat_points);
  makestats();
End;

function TPlayer.getX: integer;
begin
result := trunc(x);
end;

function TPlayer.getY: integer;
begin
 result := trunc(y);
end;

function TPlayer.getSpeed(): double;
begin
result := speed;

if slow > 0 then
  result := result*0.72;

if haste > 0 then
  result := result*1.28;

if (Blocks.MediumType(self.getX, self.getY) = Collision.WATER) then
 result := result*0.68;


if stun > 0 then
  result := 0.0;
end;

function TPlayer.px():double;
begin
  if (stealth > 0) or (alive = false) then result := -500 else
  result := x;
End;

function TPlayer.py():double;
begin
  if (stealth > 0) or (alive = false)  then result := -500 else
  result := y;
End;



procedure TPlayer.Movement();
begin
if self.dist <= 0.0 then exit;

if stun > 0 then
  exit;

 self.dist := self.dist-self.getSpeed;
 x := x+getSpeed*Cos(dir);
 y := y+getSpeed*Sin(dir);

if dist <= 0.0 then
SendXY(self);
End;

procedure tPlayer.StealthMode(status: string; stealth_amount: integer);
begin
  stealth := stealth_amount;
  Network.SendXY(self);
  hint.text_hint.RollUp('stealth', status, trunc(x-8), trunc(y-size-5), true);
end;

procedure Initialize();
begin
Player := TPlayer.create(initializer.playername, 'Warrior');
End;


//---------------------- DEAL AND CALCULATE DAMAGE ---------------------------------
procedure TPlayer.Damage(amount: double; dmg_type: integer; projectile_owner: string);
var
  rand_x, rand_y: integer;
  amount_full: double;
begin
  amount_full := amount;
  rand_x := -trunc(self.size/2)+random(40)-20;
  rand_y := 0;
  amount := amount+random(trunc(amount/5.0))-random(trunc(amount/2.5));

  //shield out the damage. --
  if shield > 0 then begin
     hint.text_hint.RollUp('heal', 'Block!', trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
     dec(shield);
     exit;
  end;

  //stop regeneration for 5 seconds
  regen_block := 300;

  if stealth > 0 then
    StealthMode('Revealed!', 0);

  if dmg_type = playmon.SLOW then begin
    inc(slow, 180); //3.0 sec slow
    amount := amount-mr_def;

    hint.text_hint.RollUp('slow', 'Slow!', trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

    if dmg_type = DEATHRAY then begin
    inc(slow, 220); //3.5 sec slow
    inc(stun, 60);   //1s stun

    amount := (amount-mr_def)/4;
    hint.text_hint.RollUp('poison', 'Lifesuck!', trunc(self.x+rand_x-30), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = SPELLSTRIKE then begin
    amount := (amount-mr_def)/4;
    inc(silence, silence+180); //add 3 second silence
    hint.text_hint.RollUp('mr-damage', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = JUMPSTRIKE then begin
    amount := (amount-pr_def)/4;
    hint.text_hint.RollUp('physical', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = MAGEDAGGER then begin
    inc(slow, 90); //1.5 sec slow
    amount := (amount-pr_def);
    hint.text_hint.RollUp('physical', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = LIFESTEAL then begin
    amount := (amount-mr_def);
    hint.text_hint.RollUp('poison', 'Lifesuck!', trunc(self.x+rand_x-30), trunc(self.y-self.size+rand_y), true);
  end;

  if (dmg_type = POISONDAGGER) then begin
    amount := 5+amount*1.0-mr_def;

    inc(slow, 90); //1.5 sec slow
    inc(poison, 180+trunc(amount_full*0.1325)*60); //2.5 second poison  5 dex = 1.00sec
    hint.text_hint.RollUp('poison', 'Poison!', trunc(self.x+rand_x-20), trunc(self.y-self.size+rand_y), true);
  end;

    if (dmg_type = HIDDENDAGGER) then begin
    amount := 5+amount*1.0-mr_def;

    inc(stun, 60);
    inc(slow, 180); //2 sec slow
    hint.text_hint.RollUp('experience', 'Trap!', trunc(self.x+rand_x-10), trunc(self.y-self.size+rand_y), true);
  end;

  if (dmg_type = BACKSTAB) then begin
    amount := amount-pr_def;

    inc(stun, 30); //0.5 sec stun
    inc(slow, 90); //1.0 sec slow
    hint.text_hint.RollUp('stealth', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x-20), trunc(self.y-self.size+rand_y), true);
  end;

  if (dmg_type = TELESTRIKE) then begin
    inc(bleed,(12)*60); //1.5 sec slow
    inc(slow, 2*(60)); //bleed attack applies 2 sec slow

    hint.text_hint.RollUp('physical', 'Bleeding!', trunc(self.x+rand_x-20), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = STUN then begin
    amount := amount-mr_def;

    inc(slow,210); //1,5 secod slow
    inc(stun,120); //2 second stun+1 second slow
    self.dist := 0;
    hint.text_hint.RollUp('stun', 'Stun!', trunc(self.x+rand_x-20), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = MIGHTYBLOW then begin
    amount := amount-mr_def;
    //inc(slow,300); //
    inc(stun, 150); //2,5 second stun per hit
    self.dist := 0;
    hint.text_hint.RollUp('stun', 'Stun!', trunc(self.x+rand_x-20), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = BASIC then begin
    amount := amount-pr_def;
    hint.text_hint.RollUp('physical', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = BASICWAR then begin
    amount := amount-pr_def;
    hint.text_hint.RollUp('physical', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

  if dmg_type = BASICTHIEF then begin
    amount := amount-pr_def;
    hint.text_hint.RollUp('physical', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;

    if dmg_type = BASICMAG then begin
    amount := amount-mr_def;
    hint.text_hint.RollUp('mr-damage', '-'+inttostr(trunc(amount)), trunc(self.x+rand_x), trunc(self.y-self.size+rand_y), true);
  end;


  if (amount < amount_full/4) and not (amount_full = 0) then
      amount := amount_full/4;

  hp := hp-amount;

  if hp < 1 then begin
    Network.SendXP(projectile_owner, level*2+25);
    self.lose := self.lose+level*2+25;
  end else begin
    Network.SendXP(projectile_owner, level);
    self.lose := self.lose+level;
  end;

  //Network.SendXY(self.dist); //update movement statuses
End;


procedure Tplayer.tickRegen();  //ticks regen, controls alive status, controls effect duration
var
UpdateSpeed: boolean;
begin

if alive = false then
  exit;

  if hp < 1 then begin
    hint.text_hint.RollUp('stealth', 'DEAD!', trunc(x), trunc(y-size), true);
    //sleep(0);
    alive := false;
    x := -500;
    y := -500;
    hp := 0;
    Network.SendXY(self);
  end;

  if alive = false then
    exit;

        if stealth = 1 then
         StealthMode('Revealed!', 0);

    thisMedium := Collision.blocks.MediumType(trunc(y), trunc(x));

      if (slow = 1) or (stun = 1) or (haste = 1) or (thisMedium <> lastMedium) then updateSpeed := true else
       updateSpeed := false;

     {writeln('----------------------------------');
     writeln('slow: ' + inttostr(slow) + ' stun: ' + inttostr(stun) + ' haste: ' + inttostr(haste));
     writeln('Lastmedium: ' + inttostr(lastmedium) + ' Thismedium: ' + inttostr(thismedium));
     writeln('updateSpeed: ' + booltostr(updateSpeed));
     writeln('hp: ' + inttostr(trunc((self.hp))));
     writeln('----------------------------------');   }

    if updateSpeed = true then
       Network.Send2XY(self, dist); //resume normal movement
       //writeln('network trigger.');

    lastMedium := thisMedium;

  if poison > 0 then
    dec(poison) else
    poisonhint := 0;
  if slow > 0 then
    dec(slow);
  if stun > 0 then
    dec(stun);
  if haste > 0 then
    dec(haste);
  if yi_attack > 0 then
    dec(yi_attack);
  if bleed > 0 then
    dec(bleed);
  if farsight > 0 then
    dec(farsight);
  if stealth > 0 then
    dec(stealth);
  if silence > 0 then
    dec(silence);
  if regen_block > 0 then
    dec(regen_block);

     if Blocks.MediumType(self.getX, self.getY) = LAVA then begin
       inc(lavahint);

       bleed := 300;

       hp := hp-(hp_max/7)/60;  //poison dmg = 1*con

       if lavahint = 60 then begin
       lavahint := 0;
       hint.text_hint.RollUp('physical', 'LAVA!', trunc(0.5*size+x-25), trunc(y), true);
       end;
     end;


     if Blocks.MediumType(self.getX, self.getY) = WATER then begin
       inc(waterhint);

       if poison > 0 then begin
         hint.text_hint.RollUp('heal', 'CLEANSE', trunc(0.5*size+x+random(50)-25), trunc(y), true);
         poison := 0;
       end;

       hp := hp+(hp_max/80)/60;  //poison dmg = 1*con

       if waterhint = 60 then begin
       waterhint := 0;

       if self.hp < self.hp_max then
        hint.text_hint.RollUp('heal', '+'+inttostr(trunc(hp_max/50)), trunc(0.5*size+x+random(50)-25), trunc(y), true);
       end;
     end;



  if bleed > 0 then begin
   hp := hp-(hp/14)/60;  //poison dmg = 1*con

    inc(bleedhint);

    if stealth > 0 then
      StealthMode('Revealed!', 0);

    if bleedhint = 60 then begin
      bleedhint := 0;
      hint.text_hint.RollUp('physical', '-'+inttostr(trunc(hp/14)), trunc(0.5*size+x+random(50)-25), trunc(y), true);
    end;
  end;

                                                                                          //7.5% per tick/sec
  if poison > 0 then begin
   hp := hp-((hp_max)/25)/60;  //poison dmg = 1*con

    inc(poisonhint);

    if stealth > 0 then
      StealthMode('Revealed!', 0);

    if poisonhint = 60 then begin
      poisonhint := 0;
      hint.text_hint.RollUp('poison', '-'+inttostr(trunc(hp_max/15)), trunc(0.5*size+x+random(50)-25), trunc(y), true);
    end;
  end;

  if stealth > 0 then begin

  if self.class_name = 'Thief' then  //thief class bonus to stealth
    power := power-(5/60)-power_regen  //draw 6.5 mana /sec
    else
    power := power-(10/60)-power_regen;

    if power <= 0 then begin
      stealth := 0;
      hint.text_hint.RollUp('stealth', 'Unstealth!', trunc(x), trunc(y-size), true);
      Network.SendXY(self);
    end;
  end;

  if (regen_block = 0) then begin
    hp := hp+hp_regen;
    power := power+power_regen;
  end;

  if stealth > 0 then hp := hp+hp_regen*(2.65); //+165% hp regen in stealth


  if hp > hp_max then
    hp := hp_max;
  if power > power_max then
    power := power_max;


End;

constructor TSpell.create(id: Integer);
begin
  self.id := id;

silenceable := true;

case (id) of
BASIC: range := 25;
BASICMAG  : range := 75;
BASICWAR : range := 15;
BASICTHIEF  : range := 45;
HASTE     : range := 250;
HEAL       : range := 450;
TELESTRIKE : range := 355;
SHIELD     : range := 400;
JUMPSTRIKE : range := 75;
MIGHTYBLOW  : range := 28;
MAGEDAGGER  : range := 25;
DEATHRAY   : range := 500;
FARSIGHT   : range := 335;
SLOW       : range := 26;
STUN       : range := 250;
STEALTH    : range := 120;
POISONDAGGER : range := 45;
SHADOWSTEP   : range := 135;
LIFESTEAL    : range := 45;
HIDDENDAGGER : range := 350;
SPELLSTRIKE: range := 45;
end;

case (id) of
HASTE: silenceable := false;
HEAL: silenceable := false;
BASIC: silenceable := false;
BASICWAR: silenceable := false;
BASICMAG: silenceable := false;
BASICTHIEF: silenceable := false;
MAGEDAGGER: silenceable := false;
end;

case (id) of
BASIC:    self.cost := 0;
BASICMAG: self.cost := 0;
BASICWAR: self.cost := 0;
BASICTHIEF: self.cost := 0;

HEAL:     self.cost := 20;
HASTE:    self.cost := 15;

TELESTRIKE:   self.cost := 20;
SHIELD:       self.cost := 20;
JUMPSTRIKE:   self.cost := 10;
SPELLSTRIKE:  self.cost := 10;
MIGHTYBLOW:   self.cost := 35;

MAGEDAGGER:   self.cost := 10;
DEATHRAY:   self.cost := 30;
FARSIGHT:   self.cost := 75;
SLOW:       self.cost := 20;
STUN:       self.cost := 30;

STEALTH:    self.cost := 5;
POISONDAGGER: self.cost := 10;
SHADOWSTEP:   self.cost := 15;
LIFESTEAL:    self.cost := 20;
HIDDENDAGGER: self.cost := 30;
end;

case (id) of
BASIC:    self.cool := trunc((1.3)*60);
HEAL:     self.cool := trunc((6.0)*60);
HASTE:    self.cool := trunc((8.0)*60);

TELESTRIKE:   self.cool := trunc((5.0)*60);
SHIELD:       self.cool := trunc((10.0)*60);
JUMPSTRIKE:   self.cool := trunc((4.0)*60);
SPELLSTRIKE:  self.cool := trunc((3.5)*60);
MIGHTYBLOW:   self.cool := trunc((12.0)*60);

MAGEDAGGER:   self.cool := trunc((1.95)*60);
DEATHRAY:   self.cool := trunc((6.0)*60);
FARSIGHT:   self.cool := trunc((12.0)*60);
SLOW:       self.cool := trunc((3.25)*60);
STUN:       self.cool := trunc((5.0)*60);

STEALTH:    self.cool := trunc((8.0)*60);
POISONDAGGER: self.cool := trunc((2.95)*60);
SHADOWSTEP:   self.cool := trunc((6.0)*60);
LIFESTEAL:    self.cool := trunc((5.5)*60);
HIDDENDAGGER: self.cool := trunc((12.0)*60);
end;
end;

function TSpell.OnCooldown(silence: integer): boolean;
begin
      if (self.cool_time = 0) and (silence > 0) then begin
       if not silenceable then
        result := false else
        result := true;
      end else
        if (self.cool_time > 0) then
          result := true
        else
          result := false;
end;

function TSpell.SpellCost(power: integer): boolean;
begin
  if power < self.cost then
      result := false
    else
      result := true;
end;

procedure TPlayer.Cast(spell: integer; pos: TPoint);
var
  pi, r, step, dir, dist, low_dist, attack_range, x, y: double;
  slowballs, i, item, attack_bonus, speed, id, base_dmg: integer;
  attack_type: integer;
  impact_type: integer;
begin
id := self.spell[spell].id;
//writeln('CASTING SPELL: ' + inttostr(spell) + ' WITH ID: ' + inttostr(id));


//----------------------------- BASIC ATTACK --------------------------------------
  if id = BASIC then begin
    if self.alive = false and self.class_selected = true then
      if Blocks.Collide(trunc(Pos.X-cam.X), trunc(Pos.Y-cam.Y)) = false then begin
        self.x := pos.X-cam.X;                //revive effects
        self.y := Pos.Y-cam.y;
        self.reset;
        self.alive := true;
        Network.SendXY(self);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.attack_speed);
        exit;
      end;

        attack_range := self.basic_range;
        attack_bonus := 0;
        attack_type := BASIC;
        speed := 6;

        if self.class_name = 'Mage' then begin
          attack_bonus := trunc(-self.melee_dmg);
          attack_type := BASICMAG;
          base_dmg := self.spell_dmg;
        end;

      if self.class_name = 'Warrior' then begin
        if random(4) = 1 then
          attack_bonus := trunc(self.melee_dmg/2.5);
          base_dmg := self.melee_dmg;

          attack_type := BASICWAR;

      if self.yi_attack > 0 then begin
        attack_type := TELESTRIKE;
        attack_bonus := trunc(self.melee_dmg/2.5); //+150% dmg
        self.yi_attack := 0;
        attack_range := 17.0;
      end;
      end;

      if self.class_name = 'Thief' then begin
          base_dmg := self.range_dmg;
          attack_type := BASICTHIEF;
      end;


      if self.stealth > 0 then begin
        if self.class_name = 'Thief' then
        attack_type := BACKSTAB;
        attack_range := BASICWAR+2;
        self.StealthMode('Backstab!', 0);
        attack_bonus := trunc(self.DEX*self.DEX_mod*0.16+self.melee_dmg*1.4);
        Network.SendXY(self);
      end;

      Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, pos.X, pos.Y, attack_range,
      (attack_bonus)+base_dmg, speed, attack_type, self.name);
      self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.attack_speed);
    end;


//------------------------  FAR SIGHT ------------------------------------------

if id = playmon.FARSIGHT then begin
  self.farsight := 4*(60);
  self.spell[spell].cool_time := trunc(self.spell[spell].cool-(self.spell[spell].cool/100)*self.spell_cool);
  hint.text_hint.RollUp('haste', 'Farsight!', trunc(0.5*self.size+self.x+random(50)-75), trunc(self.y-self.size+random(50)-25), true);

  {Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, mouse.CursorPos.X, mouse.CursorPos.Y, 0.0,
  0.0, 0.0,attack_type, self.name);
      NetFire();}
end;

//------------------------ JUMP STRIKE -----------------------------------------
if id = JUMPSTRIKE then begin

  attack_type := JUMPSTRIKE;
  low_dist := 80.0;
  dist := 80.0;
  attack_range := 14;
  speed := 6;

  for i := 0 to High(Network.Multiplayer) do begin
  if (self.name = Network.Multiplayer[i].name) or (Network.Multiplayer[i].hp < 1) then continue;


    dist := Math.power(self.x - Multiplayer[i].x, 2)+Math.power(self.y - Multiplayer[i].y, 2);
    dist := Math.power(self.dist, 0.5);


      if dist < low_dist then begin
        item := i;
        low_dist := dist;
      end;
  end;

  if (low_dist < self.spell[spell].range) then begin
    self.x := Multiplayer[item].x+random(50)-25;
    self.y := Multiplayer[item].y+random(50)-25;
    Network.SendXY(self);
    Entities.list.Fire(self.x, self.y, Multiplayer[item].x+cam.X, Multiplayer[item].y+cam.Y, attack_range, self.melee_dmg, speed, attack_type, self.name);
    self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
  end else begin
    self.power := self.power+10;
    self.spell[spell].cool := 30; //0.5 sec
  end;
end;


//----------------------  HIDDEN DAGGER -------------------------------------
//invisible Trap. Draw only if owner = YOU.

if id = HIDDENDAGGER then begin
        Entities.list.Fire(self.x+self.size/2+8, self.y+self.size/2+8, pos.X, Pos.Y, 60*(60), self.spell_dmg, 0.0, HIDDENDAGGER, self.name);
        //Entities.list.Entity[length(entities.list.Entity)-1].size := 25;
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
end;

//--------------------- STEALTH ---------------------------
if id = playmon.STEALTH then begin

      if self.stealth > 0 then begin
        self.StealthMode('Unstealth!', 0);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        Network.SendXY(self);
      end;

        self.StealthMode('Stealth!', trunc(self.INT*0.2+4*(60)));
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        Network.SendXY(self);
end;

// ------------------------- HEAL ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +dmg
  if id = HEAL then begin
        self.hp := self.hp+self.CON*(self.con_mod*0.3+spell_dmg*0.5); //1 mana = 1.5 hp
        hint.text_hint.RollUp('heal', '+'+inttostr(trunc(self.CON*(self.con_mod*0.3))), trunc(self.x+random(50)-25), trunc(self.y-self.size+random(50)-25), true);
        self.spell[spell].cool_time := (self.spell[spell].cool);
        Network.SendXY(self);
      end;
// ------------------------- HASTE ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +80% dmg
  if id = playmon.HASTE then begin
        self.haste := trunc(3.25*60);
        if self.class_name = 'warrior' then inc(self.haste, trunc(1.75*60));
        hint.text_hint.RollUp('haste', 'Haste!', trunc(0.5*self.size+self.x+random(50)-35), trunc(self.y-self.size+random(50)-25), true);
        self.spell[spell].cool_time := self.spell[spell].cool;
        Network.Send2XY(self, self.dist);
    end;

    // ------------------------- YI STRIKE ---------------------------------------
// Enters stealth, which draws mana and heals. Power attack from stealth with +80% dmg
  if id = TELESTRIKE then
   if Blocks.Collide(trunc(Pos.X-cam.X), trunc(Pos.Y-cam.Y)) = false then begin

        self.haste := trunc(1.25*60); //1.25 second haste!

        dir := ArcTan2(Pos.Y-cam.Y-(self.y+self.size/2-2), Pos.X-cam.X-(self.x+self.size/2-2));
        dist :=(Math.power(self.x-(Pos.X-cam.X)+self.size/2-2, 2))+Math.power(self.y-(pos.Y-cam.Y)+self.size/2-2, 2);
        dist := Math.power(dist, 0.5);

        if dist > self.spell[spell].range then
        dist := self.spell[spell].range;

        self.x := self.x+dist*Cos(dir);
        self.y := self.y+dist*Sin(dir);

        if self.class_name = 'Warrior' then
        self.yi_attack := trunc(4*60);

        Network.SendXY(self);
        Network.Send2XY(self, self.dist); //stop player after hastey
        hint.text_hint.RollUp('haste', 'Teleport!', trunc(0.5*self.size+self.x+random(50)-25), trunc(self.y-self.size+random(50)-25), true);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
    end;

//-------------------------- SLOWBALL --------------------------------------------------
  if id = playmon.SLOW then begin
        try
        slowballs := 10;
        r := 36.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(self.x+self.size/2-2+r*0.5*cos(i*step),
                             self.y+self.size/2-2+r*0.5*sin(i*step),
                             self.x+r*cos(i*step)+cam.X, self.y+r*sin(i*step)+cam.Y, self.spell[spell].range,
                             self.spell_dmg, 1.95, playmon.SLOW, self.name);

        end;

        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        except
        //
        end;
  end;


//--------------------------------  SPELL STRIKE -------------------------------
  if id = SPELLSTRIKE then begin                                                                                                                        //MAGICCCCCCCCS
        Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, Pos.X, Pos.Y, self.spell[spell].range, self.spell_dmg, 6.4, SPELLSTRIKE, self.name);
       self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
  end;


  //-------------------------- MIGHTY STRIKES --------------------------------------------------
  if id = MIGHTYBLOW then begin
        try
        slowballs := 9;
        r := 36.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(self.x+self.size/2-2+r*0.5*cos(i*step),
                             self.y+self.size/2-2+r*0.5*sin(i*step),
                             self.x+r*cos(i*step)+cam.X, self.y+r*sin(i*step)+cam.Y, self.spell[spell].range,
                             self.melee_dmg*0.3+self.spell_dmg*0.6, 0.65, MIGHTYBLOW, self.name);


        end;

        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        except
        //
        end;
  end;




//---------------------------- POISON SHIV ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = POISONDAGGER then begin
        Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, Pos.X, Pos.Y, self.spell[spell].range, self.DEX, 6.4, POISONDAGGER, self.name);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
  end;


//---------------------------- SHADOWSTEP ---------------------------------------------
    if id = SHADOWSTEP then
   if Blocks.Collide(trunc(Pos.X-cam.X), trunc(Pos.Y-cam.Y)) = false then begin

        inc(self.stealth, trunc(4*(60)+0.2*self.INT)); //1.25 second haste!
        inc(self.haste, trunc(1.6*(60)+0.08*self.INT)); //2 second haste

        hint.text_hint.RollUp('haste', 'Shadowstep!', trunc(0.5*self.size+self.x+random(50)-25), trunc(self.y-self.size+random(50)-25), true);

        dir := ArcTan2(Pos.Y-cam.Y-(self.y+self.size/2-2), Pos.X-cam.X-(self.x+self.size/2-2));
        dist :=(Math.power(self.x-(Pos.X-cam.X)+self.size/2-2, 2))+Math.power(self.y-(pos.Y-cam.Y)+self.size/2-2, 2);
        dist := Math.power(dist, 0.5);

        if dist > self.spell[spell].range then
        dist := self.spell[spell].range;

        self.x := self.x+dist*Cos(dir);
        self.y := self.y+dist*Sin(dir);

        Network.SendXY(self);
        Network.Send2XY(self, self.dist); //stop player after hastey
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
    end;



  //---------------------------- MAGE DAGGER ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = MAGEDAGGER then begin

        Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, Pos.X, Pos.Y, self.spell[spell].range, self.melee_dmg*1.2, 5.5, MAGEDAGGER, self.name);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.attack_speed);
  end;

    //---------------------------- SHIELD ---------------------------------------------
//deals poison damage over time, and slows briefly
  if id = playmon.SHIELD then begin

        self.shield := 1+trunc(self.INT*0.08);
        if self.shield > 4 then
          self.shield := 4;
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        hint.text_hint.RollUp('heal', 'Shield!', trunc(self.x-20), trunc(self.y), true);
  end;


//---------------------------- ORB OF STUNNING ---------------------------------------------
//deals poison damage over time, and slows briefly

  if id = playmon.STUN then begin
      if self.stealth > 0 then
        self.StealthMode('Unstealth!', 0);

      Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, Pos.X, Pos.Y, self.spell[spell].range, self.spell_dmg, 3.0, playmon.STUN, self.name);
      self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool); //7 second cd
  end;

//---------------------------- LIFESTEAK ---------------------------------------------
//life steaksteal
  if id = LIFESTEAL then begin
        Entities.list.Fire(self.x+self.size/2-2, self.y+self.size/2-2, Pos.X, Pos.Y, self.spell[spell].range, self.spell_dmg, 6.5, LIFESTEAL, self.name);
        self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
  end;

    // ------------------------- DEATHBLAST ---------------------------------------
  if id = DEATHRAY then begin
        try
        speed := 3;
        slowballs := 10;
        r := 18.0;
        pi := 3.141592;
        step := (2*pi)/slowballs;
        impact_type := DEATHRAY;


        dist :=(Math.power(self.x-(Pos.X-cam.X)+self.size/2-2, 2))+Math.power(self.y-(pos.Y-cam.Y)+self.size/2-2, 2);
        dist := Math.power(dist, 0.5);

        if dist < self.spell[spell].range then begin

        for i := 0 to slowballs-1 do begin                                                                                                                               //slowball-trigger mini //slowball = exploision shard
          Entities.list.Fire(Pos.X+r*8*cos(i*step)-cam.X,
                             Pos.Y+r*8*sin(i*step)-cam.Y,
                             Pos.X+r*cos(i*step),
                             Pos.Y+r*sin(i*step), 35,
                             self.spell_dmg, speed, impact_type, self.name);

        end;

          self.poison := (5)*60; //deathray poison your soul
          self.spell[spell].cool_time := trunc((self.spell[spell].cool)-(self.spell[spell].cool/100)*self.spell_cool);
        end;
        except
        //
        end;
  end;
End;


procedure TPlayer.ProcessCooldowns();
var
i : integer;
begin
  for I := 0 to High(self.spell) do
  if self.spell[i].cool_time > 0 then
    dec(self.spell[i].cool_time);

end;

procedure TPlayer.SpellImpact(spell: integer);
var
heal: integer;
begin
  if (spell = LIFESTEAL) or (spell = DEATHRAY) then begin
    heal := trunc(2*self.level+
    self.int_mod*self.INT/2);
    self.hp := self.hp+heal;
    text_hint.RollUp('heal', '+'+inttostr(heal), trunc(self.x-random(10)+5), trunc(self.y), true);
  end;

    //gan exp on trap sprung.
    if (spell = HIDDENDAGGER) then begin
    text_hint.RollUp('experience', 'Trap Sprung!', trunc(self.x-random(12)+5), trunc(self.y), true);
    self.GainExp(15);
    end;

  //mage will regain mana on-hit
  if self.class_name = 'Mage' then
   self.power := self.power+self.level + 2 + self.STR*0.6;

end;


begin
END.
