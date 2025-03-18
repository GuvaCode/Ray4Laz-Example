unit SpaceShip;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath, actor, MathUtils, math, rlgl;

type
  PTrailRung = ^TrailRung;
  TrailRung = record
    LeftPoint:  TVector3;
    RightPoint: TVector3;
    TimeToLive: Single;
  end;

{ TShip }
 TShip = class(TActor)
   public
     InputForward:Single;
     InputLeft:Single;
     InputUp:Single;
     InputPitchDown:Single;// = 0;
     InputRollRight:Single;// = 0;
     InputYawLeft:Single;// = 0;
     MaxSpeed:Single;// = 20;
     ThrottleResponse:Single;// = 10;
     TurnRate:Single;// = 180;
     TurnResponse:Single;// 10;
     Length:Single;// 1.0f;
     Width:Single;// 1.0f;
     ModelScale:Single;
     TrailColor: TColorB;// DARKGREEN;
     constructor Create(const modelPath, texturePath: PChar; Color: TColorB); virtual;
     destructor Destroy; override;
     procedure Update(deltaTime: Single);
     procedure Draw(showDebugAxes: Boolean);
     procedure DrawTrail;
   private
	ShipModel: TModel;
	ShipColor: TColorB;
	RungCount: integer;
        Rungs: array [0..15] of TrailRung;
        SmoothForward:Single;
	SmoothLeft:Single;
	SmoothUp:Single;
	SmoothPitchDown:Single;
	SmoothRollRight:Single;
	SmoothYawLeft:Single;
	VisualBank:Single;
        LastRungPosition: TVector3;
        RungIndex: integer;
        procedure PositionActiveTrailRung();
   end;

 { TCrosshair }

 TCrosshair = class
   public
     constructor Create(const modelPath: PChar); virtual;
     destructor Destroy; override;
     procedure PositionCrosshairOnShip(const Ship: TShip; distance: Single);
     procedure DrawCrosshair;
//	void PositionCrosshairOnShip(const Ship& ship, float distance);
//	void DrawCrosshair() const;

  private
    CrosshairModel: TModel;
 end;

implementation
const RungDistance = 2.0;
const RungTimeToLive = 2.0;

{ TCrosshair }

constructor TCrosshair.Create(const modelPath: PChar);
begin
  	CrosshairModel := LoadModel(modelPath);
end;

destructor TCrosshair.Destroy;
begin
        	UnloadModel(CrosshairModel);
  inherited Destroy;
end;

procedure TCrosshair.PositionCrosshairOnShip(const Ship: TShip; distance: Single);
var crosshairPos: TVector3;
    crosshairTransform: TMatrix;
begin
  crosshairPos := Vector3Add(Vector3Scale(ship.GetForward(), distance), ship.Position);
  crosshairTransform := MatrixTranslate(crosshairPos.x, crosshairPos.y, crosshairPos.z);
  crosshairTransform := MatrixMultiply(QuaternionToMatrix(ship.Rotation), crosshairTransform);
  CrosshairModel.transform := crosshairTransform;
end;

procedure TCrosshair.DrawCrosshair;
begin
  BeginBlendMode(BLEND_ADDITIVE);
  rlDisableDepthTest();

  DrawModel(CrosshairModel, Vector3Zero(), 1, DARKGREEN);
  //DrawModelWires(Model, Vector3Zero(), 1, DARKGREEN);

  rlEnableDepthTest();
  EndBlendMode();
end;

{ TShip }
constructor TShip.Create(const modelPath, texturePath: PChar; Color: TColorB);
var texture: TTexture2D;
begin
  ModelScale:=1;
  MaxSpeed:= 20;
  ThrottleResponse:= 10;
  TurnRate:= 180;
  TurnResponse:= 10;
  Length:= 1.0;
  Width:= 1.0;
  TrailColor:= DARKGREEN;
  RungCount:= 16;
  texture := LoadTexture(texturePath);
  texture.mipmaps := 0;
  SetTextureFilter(texture, TEXTURE_FILTER_POINT);
  ShipModel := LoadModel(modelPath);
  ShipModel.materials[0].maps[MATERIAL_MAP_ALBEDO].texture := texture;

  Rotation := QuaternionFromEuler(0, 0, 0);
  ShipColor := Color;
  LastRungPosition := Position;
end;

destructor TShip.Destroy;
begin
  UnloadModel(ShipModel);
  inherited Destroy;
end;

procedure TShip.Update(deltaTime: Single);
var forwardSpeedMultipilier,autoSteerInput,targetVisualBank: single;
    targetVelocity: TVector3;
    visualRotation:TQuaternion;
    transform: TMatrix;
    i:integer;
begin
// Give the ship some momentum when accelerating.
  SmoothForward := SmoothDamp(SmoothForward, InputForward, ThrottleResponse, deltaTime);
  SmoothLeft := SmoothDamp(SmoothLeft, InputLeft, ThrottleResponse, deltaTime);
  SmoothUp := SmoothDamp(SmoothUp, InputUp, ThrottleResponse, deltaTime);
// Flying in reverse should be slower.

 forwardSpeedMultipilier := ifthen(SmoothForward > 0.0, 1.0, 0.33);

 targetVelocity := Vector3Zero();

 targetVelocity := Vector3Add(
 targetVelocity,Vector3Scale(GetForward(), MaxSpeed * forwardSpeedMultipilier * SmoothForward));

     targetVelocity := Vector3Add(
  		targetVelocity,
  		Vector3Scale(GetUp(), MaxSpeed * {.5f}0.5 * SmoothUp));

        targetVelocity := Vector3Add(
  		targetVelocity,
  		Vector3Scale(GetLeft(), MaxSpeed * 0.5 * SmoothLeft));

  	Velocity := SmoothDamp(Velocity, targetVelocity, 2.5, deltaTime);
  	Position := Vector3Add(Position, Vector3Scale(Velocity, deltaTime));

        // Give the ship some inertia when turning. These are the pilot controlled rotations.
        SmoothPitchDown := SmoothDamp(SmoothPitchDown, InputPitchDown, TurnResponse, deltaTime);
        SmoothRollRight := SmoothDamp(SmoothRollRight, InputRollRight, TurnResponse, deltaTime);
        SmoothYawLeft := SmoothDamp(SmoothYawLeft, InputYawLeft, TurnResponse, deltaTime);

        RotateLocalEuler(Vector3Create(0, 0, 1), SmoothRollRight * TurnRate * deltaTime);
        RotateLocalEuler(Vector3Create(1, 0, 0), SmoothPitchDown * TurnRate * deltaTime);
        RotateLocalEuler(Vector3Create(0, 1, 0), SmoothYawLeft * TurnRate * deltaTime);

	// Auto-roll to align to horizon
	if (abs(GetForward().y) < 0.8) then
	begin
	  autoSteerInput := GetRight().y;
	  RotateLocalEuler(Vector3Create( 0, 0, 1 ), autoSteerInput * TurnRate * 0.5 * deltaTime);
	end;

	// When yawing and strafing, there's some bank added to the model for visual flavor.
        targetVisualBank := (-30 * DEG2RAD * SmoothYawLeft) + (-15 * DEG2RAD * SmoothLeft);
	VisualBank := SmoothDamp(VisualBank, targetVisualBank, 10, deltaTime);
	visualRotation := QuaternionMultiply(Rotation, QuaternionFromAxisAngle(Vector3Create( 0, 0, 1 ), VisualBank));

        	// Sync up the raylib representation of the model with the ship's position so that processing
	// doesn't have to happen at the render stage.

        transform := MatrixTranslate(Position.x, Position.y, Position.z);
	transform := MatrixMultiply(QuaternionToMatrix(visualRotation), transform);
        transform := MatrixMultiply(MatrixScale(ModelScale,ModelScale,ModelScale),transform);

        ShipModel.transform := transform;

        // The currently active trail rung is dragged directly behind the ship for a smoother trail.
        	PositionActiveTrailRung();
        	if (Vector3Distance(Position, LastRungPosition) > RungDistance)  then
        	begin
        	 RungIndex := (RungIndex + 1) mod RungCount;
        	 LastRungPosition := Position;
        	end;

        	for i:=0 to RungCount -1 do /// (int i = 0; i < RungCount; ++i)
        	Rungs[i].TimeToLive -= deltaTime;


end;

procedure TShip.Draw(showDebugAxes: Boolean);
begin
  DrawModel(ShipModel, Vector3Zero, 1, ShipColor);
  if (showDebugAxes) then
  begin
    //BeginBlendMode(BLEND_ADDITIVE);
    DrawLine3D(Position, Vector3Add(Position, GetForward()),ColorCreate( 0, 0, 255, 255 ));
    DrawLine3D(Position, Vector3Add(Position, GetLeft()), ColorCreate( 255, 0, 0, 255 ));
    DrawLine3D(Position, Vector3Add(Position, GetUp()), ColorCreate( 0, 255, 0, 255 ));
    //EndBlendMode();
  end;
end;

procedure TShip.DrawTrail;
var i: integer;
    thisRung,nextRung: TrailRung;
    color,fill: TColorB;
begin
  BeginBlendMode(BLEND_ADDITIVE);
  rlDisableDepthMask();

  	for i:=0 to RungCount -1 do //(int i = 0; i < RungCount; ++i)
  	begin
  		if  (Rungs[i].TimeToLive <= 0) then continue;

  		thisRung := Rungs[i mod RungCount];

  		color := TrailColor;
  		color.a := 255 * Round(thisRung.TimeToLive / RungTimeToLive);
  	        fill := color;
  		fill.a := Round(color.a / 4);

  		// The current rung is dragged along behind the ship, so the crossbar shouldn't be drawn.
  		// If the crossbar is drawn when the ship is slow, it looks weird having a line behind it.
  		if (i <> RungIndex)  then
  			DrawLine3D(thisRung.LeftPoint, thisRung.RightPoint, color);

  		nextRung := Rungs[(i + 1) mod RungCount];
  		if (nextRung.TimeToLive > 0) and (thisRung.TimeToLive < nextRung.TimeToLive) then
  		begin
  			DrawLine3D(nextRung.LeftPoint, thisRung.LeftPoint, color);
  			DrawLine3D(nextRung.RightPoint, thisRung.RightPoint, color);

  			DrawTriangle3D(thisRung.LeftPoint, thisRung.RightPoint, nextRung.LeftPoint, fill);
  			DrawTriangle3D(nextRung.LeftPoint, thisRung.RightPoint, nextRung.RightPoint, fill);

  			DrawTriangle3D(nextRung.LeftPoint, thisRung.RightPoint, thisRung.LeftPoint, fill);
  			DrawTriangle3D(nextRung.RightPoint, thisRung.RightPoint, nextRung.LeftPoint, fill);
  		end;
  	end;

  	rlDrawRenderBatchActive();
  	rlEnableDepthMask();
  	EndBlendMode();
end;

procedure TShip.PositionActiveTrailRung;
var halfWidth, halfLength: single;
begin
  Rungs[RungIndex].TimeToLive := RungTimeToLive;
  halfWidth := Width / 2.0;
  halfLength := Length / 2.0;
  Rungs[RungIndex].LeftPoint := TransformPoint(Vector3Create( -halfWidth, 0.0, -halfLength ));
  Rungs[RungIndex].RightPoint := TransformPoint(Vector3Create( halfWidth, 0.0, -halfLength ));
end;

end.

