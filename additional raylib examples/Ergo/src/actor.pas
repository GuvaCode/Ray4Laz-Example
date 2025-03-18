unit actor;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath;

type
 { TActor }
  TActor = class
  public
    Position: TVector3;
    Velocity: TVector3;
    Rotation: TQuaternion;

    constructor Create;
    function GetForward:TVector3;
    function GetBack:TVector3;
    function GetRight:TVector3;
    function GetLeft:TVector3;
    function GetUp:TVector3;
    function GetDown:TVector3;

    function TransformPoint(point: TVector3): TVector3;
    procedure RotateLocalEuler(axis: TVector3; degrees: single);
  end;

implementation

{ Actor }
constructor TActor.Create;
begin
  Position := Vector3Zero();
  Velocity := Vector3Zero();
  Rotation := QuaternionIdentity();
end;

function TActor.GetForward: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( 0, 0, 1) ,Rotation);
end;

function TActor.GetBack: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( 0, 0, -1) ,Rotation);
end;

function TActor.GetRight: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( -1, 0, 0) ,Rotation);
end;

function TActor.GetLeft: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( 1, 0, 0) ,Rotation);
end;

function TActor.GetUp: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( 0, 1, 0) ,Rotation);
end;

function TActor.GetDown: TVector3;
begin
 result:= Vector3RotateByQuaternion(Vector3Create( 0, -1, 0) ,Rotation);
end;

function TActor.TransformPoint(point: TVector3): TVector3;
var mPos, mRot, matrix: TMatrix;
begin
  mPos:= MatrixTranslate(Position.x, Position.y, Position.z);
  mRot:= QuaternionToMatrix(Rotation);
  matrix:= MatrixMultiply(mRot, mPos);
  result:= Vector3Transform(point, matrix);
end;

procedure TActor.RotateLocalEuler(axis: TVector3; degrees: single);
var radians:single;
begin
  radians:= degrees * DEG2RAD;
  Rotation:= QuaternionMultiply(Rotation, QuaternionFromAxisAngle(axis, radians));
end;

end.

