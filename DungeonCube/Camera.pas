unit Camera;

interface

//scrolls with mouse, defines cam bounds

uses Controls, Forms;

type
  Tcam = class
  X,Y, speed, zoom, zoom_delta: double;
  x_max, x_min, y_max, y_min: integer;
 constructor create();
 procedure Update;
 Procedure focus(x_,y_: integer);
 procedure zoom_in();
 procedure zoom_out();
end;

var
  cam: Tcam;

implementation


constructor Tcam.create();
begin
  X := -800;
  Y := -800;
  zoom_delta := 0.1;
  x_min := -2310;
  x_max := 60;
  y_min := -2310;
  y_max := 60;
  speed := 16.0;
  zoom := 1.0;
end;

procedure Tcam.focus(x_,y_: integer);
begin
  x := x_;
  y := y_;
end;

procedure TCam.Zoom_in;
begin
  zoom := zoom+zoom_delta;
end;

procedure TCam.Zoom_out;
begin
  zoom := zoom-zoom_delta;
end;

procedure Tcam.Update;
var
  mx,my: double;
begin
  mx := 0.0;
  my := 0.0;

  if mouse.CursorPos.X < 3 then
    mx := +speed;
  if mouse.CursorPos.Y < 3 then
    my := +speed;
  if mouse.CursorPos.X > screen.Width-3 then
    mx := -speed;
  if mouse.CursorPos.Y > screen.Height-3 then
    my := -speed;

  if (mx <> 0.0) and (my <> 0.0) then begin
    mx := mx/1.35;
    my := my/1.35;
  end;

  if (x+mx > x_min) and (x+mx < x_max) then x := x+mx;
  if (y+my > y_min) and (y+my < y_max) then y := y+my;

End;


begin
  //writeln('Initiating Camera.. ');
  cam := TCam.create;
END.
