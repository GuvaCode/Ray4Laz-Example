unit SpaceDust;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath, rlgl;

type
  { TSpaceDust }
  TSpaceDust = class
    public
      constructor Create(size: single; count:integer); virtual;
      procedure UpdateViewPosition(viewPosition: TVector3);
      procedure Draw(viewPosition, velocity: TVector3; drawDots: boolean);
    private
       Points: array of TVector3;
       Colors: array of TColorB;
       Extent: Single;
   end;


implementation

function GetPrettyBadRandomFloat( min,  max: single):single;
var value:single;
begin
  value := GetRandomValue(Round(min) * 1000, Round(max) * 1000);
  value /= 1000;
  result:= value;
end;

{ TSpaceDust }
constructor TSpaceDust.Create(size: single; count: integer);
var point: TVector3;
    color: TColorB;
    i: integer;
begin
   Extent := size * 0.5;
   SetLength(Points,count);
   SetLength(Colors,count);
  for i:=0 to count-1 do
  begin
    point := Vector3Create(
    GetPrettyBadRandomFloat(-Extent, Extent),
    GetPrettyBadRandomFloat(-Extent, Extent),
    GetPrettyBadRandomFloat(-Extent, Extent));

    Points[i]:= point;

    color := ColorCreate(GetRandomValue(192, 255),
                         GetRandomValue(192, 255),
  		         GetRandomValue(192, 255),255);

    Colors[i]:= Color;
  end;
end;

procedure TSpaceDust.UpdateViewPosition(viewPosition: TVector3);
var size:single; i: integer;
begin
  size := Extent * 2;
  for i:=0 to Length(Points) -1 do
  begin
    if (Points[i].x > viewPosition.x + Extent) then Points[i].x -= size;
    if (Points[i].x < viewPosition.x - Extent) then Points[i].x += size;

    if (Points[i].y > viewPosition.y + Extent) then Points[i].y -= size;
    if (Points[i].y < viewPosition.y - Extent) then Points[i].y += size;

    if (Points[i].z > viewPosition.z + Extent) then Points[i].z -= size;
    if (Points[i].z < viewPosition.z - Extent) then Points[i].z += size;
   end;
end;

procedure TSpaceDust.Draw(viewPosition, velocity: TVector3; drawDots: boolean);
var i:integer;  distance, farLerp, cubeSize: single;
    farAlpha: integer;
begin
  BeginBlendMode(BLEND_ADDITIVE);
  for i:=0 to Length(Points) -1 do
  begin
    distance := Vector3Distance(viewPosition, Points[i]);
    farLerp := Clamp(Normalize(distance, Extent * 0.9, Extent), 0, 1);
    farAlpha := round(Lerp(255, 0, farLerp));

    cubeSize := 0.01;

    if (drawDots) then
    begin
      DrawSphereWires(Points[i], cubeSize, 2, 4,
      ColorCreate(Colors[i].r, Colors[i].g, Colors[i].b, farAlpha));
    end;

    DrawLine3D(Vector3Add(Points[i], Vector3Scale(velocity, 0.01)),
    Points[i], ColorCreate(Colors[i].r, Colors[i].g, Colors[i].b, farAlpha));
  end;

  rlDrawRenderBatchActive();
  EndBlendMode();
end;

end.

