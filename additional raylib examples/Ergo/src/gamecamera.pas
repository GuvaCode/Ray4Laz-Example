unit GameCamera;

{$mode ObjFPC}{$H+}

interface

uses
 raylib, SpaceShip, Raymath, MathUtils;

type
  { TGameCamera }
  TGameCamera = class
    public
      constructor Create(isPerspective:boolean; fieldOfView: single); virtual;
      procedure FollowShip(const Ship: TShip; deltaTime: Single);
      procedure MoveTo(position_, target, up: TVector3; deltaTime: Single);
      procedure SetPosition(position_ ,target, up: TVector3);
      procedure Begin3DDrawing;
      procedure EndDrawing;
      function GetPosition: TVector3;
      function GetTarget: TVector3;
      function GetUp: TVector3;
      function GetFovy: Single;
    private
      Camera: TCamera3D;
      SmoothPosition: TVector3;
      SmoothTarget: TVector3;
      SmoothUp: TVector3;
  end;




implementation

{ TGameCamera }

constructor TGameCamera.Create(isPerspective: boolean; fieldOfView: single);
begin
  Camera.position := Vector3Create( 0, 10, -10 );
  Camera.target := Vector3Create( 0, 0, 0 );
  Camera.up := Vector3Create( 0, 1, 0 );


  Camera.fovy := fieldOfView;

  if isPerspective then
    Camera.projection:=CAMERA_PERSPECTIVE
      else
        Camera.projection:= CAMERA_ORTHOGRAPHIC;

  SmoothPosition := Vector3Zero();
  SmoothTarget := Vector3Zero();
  SmoothUp := Vector3Zero();
end;

procedure TGameCamera.FollowShip(const Ship: TShip; deltaTime: Single);
var pos, shipForwards, target, up: TVector3;
begin
  pos := ship.TransformPoint(Vector3Create( 0, 1, -3 ));
  shipForwards := Vector3Scale(ship.GetForward(), 25);
  target := Vector3Add(ship.Position, shipForwards);
  up := ship.GetUp();

  MoveTo(pos, target, up, deltaTime);
end;

procedure TGameCamera.MoveTo(position_, target, up: TVector3; deltaTime: Single);
begin
  Camera.position := SmoothDamp(
  	Camera.position, position_,
  	10, deltaTime);

  Camera.target := SmoothDamp(
  	Camera.target, target,
  	5, deltaTime);

  Camera.up := SmoothDamp(
  	Camera.up, up,
  	5, deltaTime);
end;

procedure TGameCamera.SetPosition(position_, target, up: TVector3);
begin
  Camera.position := position_;
  Camera.target := target;
  Camera.up := up;

  SmoothPosition := position_;
  SmoothTarget := target;
  SmoothUp := up;
end;

procedure TGameCamera.Begin3DDrawing;
begin
  	BeginMode3D(Camera);
end;

procedure TGameCamera.EndDrawing;
begin
 	EndMode3D();
end;

function TGameCamera.GetPosition: TVector3;
begin
  result:=Camera.position;
end;

function TGameCamera.GetTarget: TVector3;
begin
  result:=Camera.target;
end;

function TGameCamera.GetUp: TVector3;
begin
 result:=Camera.up;
end;

function TGameCamera.GetFovy: Single;
begin
  result:=Camera.fovy;
end;

end.

