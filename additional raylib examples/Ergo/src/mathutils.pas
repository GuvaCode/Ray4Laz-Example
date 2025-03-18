unit MathUtils;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath;

function SmoothDamp(from, to_: Single   ; speed, dt: Single): Single;
function SmoothDamp(from, to_: TVector3 ; speed, dt: Single): TVector3;
function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;
function Projection(pos: TVector3; matView, matPerps: TMatrix): TVector4;

//Vector4 project(Vector3 pos, Matrix matView, Matrix matPerps) {

implementation

function SmoothDamp(from, to_: Single; speed, dt: Single): Single;
begin
  result:= Lerp(from, to_, 1 - exp(-speed * dt));
end;

function SmoothDamp(from, to_: TVector3; speed, dt: Single): TVector3;
begin
  result:= Vector3Create(Lerp(from.x, to_.x, 1 - exp(-speed * dt)),
                         Lerp(from.y, to_.y, 1 - exp(-speed * dt)),
		         Lerp(from.z, to_.z, 1 - exp(-speed * dt)));
end;

function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;
begin
  result:= QuaternionSlerp( from, to_, 1 - exp(-speed * dt));
end;

function Projection(pos: TVector3; matView, matPerps: TMatrix): TVector4;
var temp, result_: TVector4;
begin
  temp.x := matView.m0*pos.x + matView.m4*pos.y + matView.m8*pos.z + matView.m12;
  temp.y := matView.m1*pos.x + matView.m5*pos.y + matView.m9*pos.z + matView.m13;
  temp.z := matView.m2*pos.x + matView.m6*pos.y + matView.m10*pos.z + matView.m14;
  temp.w := matView.m3*pos.x + matView.m7*pos.y + matView.m11*pos.z + matView.m15;

  result_.x := matPerps.m0 * temp.x + matPerps.m4 * temp.y + matPerps.m8 * temp.z + matPerps.m12 * temp.w;
  result_.y := matPerps.m1 * temp.x + matPerps.m5 * temp.y + matPerps.m9 * temp.z + matPerps.m13 * temp.w;
  result_.z := matPerps.m2 * temp.x + matPerps.m6 * temp.y + matPerps.m10 * temp.z + matPerps.m14 * temp.w;
  result_.w := -temp.z;

  if result_.w <> 0.0 then
  begin
    result_.w := (1.0/result_.w)/0.75;
    // Perspective division
    result_.x *= result_.w;
    result_.y *= result_.w;
    result_.z *= result_.w;
    result := result_;
  end
  else
    result := result_;
end;

end.

