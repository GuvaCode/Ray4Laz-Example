//
// Oriented bounding box collisions
//
// 2023, Original code in c langauge by Jonathan Tainer
// 2023, Pascal translation Vadim Gunko and Jarrod Davis
//
unit collider;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath, math, sysutils;

const
  COLLIDER_VERTEX_COUNT = 7;
  COLLIDER_NORMAL_COUNT = 3;

type
  PCollider = ^TCollider;
  TCollider = record
  //En: Vertex positions in local (model) space
  //Ru: Положения вершин в локальном (модельном) пространстве
  vertLocal: array[0..COLLIDER_VERTEX_COUNT] of TVector3;

  //En: Vertex positions in global (world) space
  //Ru: Положение вершин в глобальном (мировом) пространстве
  vertGlobal: array[0..COLLIDER_VERTEX_COUNT] of TVector3;

  //En: Rotation about origin in local space
  //Ru: Вращение вокруг начала координат в локальном пространстве
  matRotate: TMatrix;

  //En: Translation applied after rotation
  //Ru: Перевод, примененный после поворота
  matTranslate: TMatrix;
  end;

  // Calculate verts, use identity matrix by default
  function CreateCollider(min,max: TVector3): TCollider;

  // Rotate object starting from origin
  procedure SetColliderRotation(col: PCollider; axis: TVector3; ang: Single);

  // Rotate objects starting from current position
  procedure AddColliderRotation(col: PCollider; axis: TVector3; ang: Single);

  // Translate object starting from origin
  procedure SetColliderTranslation(col: PCollider; pos: TVector3);

  // Translate object starting from current position
  procedure AddColliderTranslation(col: PCollider; pos: TVector3);

  function GetColliderTransform(col: PCollider): TMatrix;

  // Test if a point in global space is inside a collider
  function TestColliderPoint(col: PCollider; point: TVector3): Boolean;

  // Use separating axis theorem to detect overlap
  function TestColliderPair(a,b: PCollider): Boolean;

  // Find translation needed to resolve a collision
  function GetCollisionCorrection(a,b: PCollider): TVector3;


implementation

//*******************************************************************
// Various collider transformations. Physics engine should call these
// to apply movement to each collider.
//*******************************************************************

// Applies the matrices in the struct to the local verts to calculate
// vertex positions in global space

procedure UpdateColliderGlobalVerts(col: PCollider);
var
  matTemp: TMatrix;
  i: Integer;
begin
  matTemp := MatrixMultiply(col^.matRotate, col^.matTranslate);
  for i := 0 to COLLIDER_VERTEX_COUNT-1 do
  begin
    col^.vertGlobal[i] := Vector3Transform(col^.vertLocal[i], matTemp);
  end;
end;

function CreateCollider(min, max: TVector3): TCollider;
begin
  Result.vertLocal[0] := Vector3Create(min.x, min.y, min.z);
  Result.vertLocal[1] := Vector3Create(min.x, min.y, max.z);
  Result.vertLocal[2] := Vector3Create(min.x, max.y, min.z);
  Result.vertLocal[3] := Vector3Create(min.x, max.y, max.z);
  Result.vertLocal[4] := Vector3Create(max.x, min.y, min.z);
  Result.vertLocal[5] := Vector3Create(max.x, min.y, max.z);
  Result.vertLocal[6] := Vector3Create(max.x, max.y, min.z);
  Result.vertLocal[7] := Vector3Create(max.x, max.y, max.z);

  Result.matRotate := MatrixIdentity();
  Result.matTranslate := MatrixIdentity();
  UpdateColliderGlobalVerts(@Result);
end;

// Overwrites collider rotation matrix
// Updates global vertex positions
procedure SetColliderRotation(col: PCollider; axis: TVector3; ang: Single);
begin
  col^.matRotate := MatrixRotate(axis, ang);
  UpdateColliderGlobalVerts(col);
end;

// Multiplies current collider rotation matrix by new one
// Updates global vertex positions
procedure AddColliderRotation(col: PCollider; axis: TVector3; ang: Single);
var
  matTemp: TMatrix;
begin
  matTemp := MatrixRotate(axis, ang);
  col^.matRotate := MatrixMultiply(col^.matRotate, matTemp);
  UpdateColliderGlobalVerts(col);
end;

// Overwrites collider translation matrix
// Updates global vertex positions
procedure SetColliderTranslation(col: PCollider; pos: TVector3);
begin
   col^.matTranslate := MatrixTranslate(pos.x, pos.y, pos.z);
   UpdateColliderGlobalVerts(col);
end;

// Adds new translation matrix to current translation matrix
// Updates global vertex positions
procedure AddColliderTranslation(col: PCollider; pos: TVector3);
var
  matTemp: TMatrix;
begin
  matTemp := MatrixTranslate(pos.x, pos.y, pos.z);
  col^.matTranslate := MatrixMultiply(col^.matTranslate, matTemp);
  UpdateColliderGlobalVerts(col);
end;

// Returns overall transform, first rotation then translation
function GetColliderTransform(col: PCollider): TMatrix;
begin
  Result := MatrixMultiply(col^.matRotate, col^.matTranslate);
end;

//*******************************************************************
//		COLLISION DETECTION STUFF BEGINS HERE
//*******************************************************************

// Point-box collision
function TestColliderPoint(col: PCollider; point: TVector3): Boolean;
var
  i: Integer;
  min, max, cur: TVector3;
  invTransform: TMatrix;
begin
  min := col^.vertLocal[0];
  max := col^.vertLocal[0];
  for i := 1 to COLLIDER_VERTEX_COUNT-1 do
  begin
    cur := col^.vertLocal[i];
    min.x := math.Min(min.x, cur.x);
    min.y := math.Min(min.y, cur.y);
    min.z := math.Min(min.z, cur.z);
    max.x := math.Max(max.x, cur.x);
    max.y := math.Max(max.y, cur.y);
    max.z := math.Max(max.z, cur.z);
  end;

  invTransform := MatrixInvert(GetColliderTransform(col));
  point := Vector3Transform(point, invTransform);

  Result := (point.x < max.x) and (point.x > min.x) and
  (point.y < max.y) and (point.y > min.y) and
  (point.z < max.z) and (point.z > min.z);
end;

// First check along each face normal
// Then check along the cross products of the pairs of the face normals
//
// vec must point to a buffer large enough to store 15 Vector3
procedure GetCollisionVectors(a, b: PCollider; vec: PVector3);
var
  x, y, z: TVector3;
  i, j, k: Integer;
begin
  x := Vector3Create(1.0, 0.0, 0.0);
  y := Vector3Create(0.0, 1.0, 0.0);
  z := Vector3Create(0.0, 0.0, 1.0);

  vec[0] := Vector3Transform(x, a^.matRotate);
  vec[1] := Vector3Transform(y, a^.matRotate);
  vec[2] := Vector3Transform(z, a^.matRotate);

  vec[3] := Vector3Transform(x, b^.matRotate);
  vec[4] := Vector3Transform(y, b^.matRotate);
  vec[5] := Vector3Transform(z, b^.matRotate);

  i := 6;
  for j := 0 to 2 do
  begin
    for k := 3 to 5 do
    begin
      if Vector3Equals(vec[j], vec[k])>0 then
      vec[i] := x
   else
      vec[i] := Vector3Normalize(Vector3CrossProduct(vec[j], vec[k]));
      Inc(i);
    end;
  end;
end;

// Iterate through all verts, project on test vector, find min and max values
// Returns min and max in x and y members, respectively
function GetColliderProjectionBounds(col: PCollider; vec: TVector3): TVector2;
var
  bounds: TVector2;
  proj: Single;
  i: Integer;
begin
  proj := Vector3DotProduct(col^.vertGlobal[0], vec);
  bounds.x := proj;
  bounds.y := proj;
  for i := 1 to COLLIDER_VERTEX_COUNT-1 do
  begin
    proj := Vector3DotProduct(col^.vertGlobal[i], vec);
    bounds.x := Min(bounds.x, proj);
    bounds.y := Max(bounds.y, proj);
  end;
  Result := bounds;
end;

function BoundsOverlap(a, b: TVector2): boolean;
begin
  if a.x > b.y then Exit(False);
  if b.x > a.y then Exit(False);
  Result := True;
end;

// Calculate the amount of overlap along the axis being checked
function GetOverlap(a, b: TVector2): single;
begin
  if a.x > b.y then Exit(0.0);
  if b.x > a.y then Exit(0.0);
  if a.x > b.x then
    Result := b.y - a.x
  else
  Result := b.x - a.y;
end;

function TestColliderPair(a, b: PCollider): Boolean;
var
  testVec: array[0..14] of TVector3;
  apro, bpro: TVector2;
  i: Integer;
begin
  GetCollisionVectors(a, b, @testVec);
  for i := 0 to 14 do
  begin
    apro := GetColliderProjectionBounds(a, testVec[i]);
    bpro := GetColliderProjectionBounds(b, testVec[i]);
    if not BoundsOverlap(apro, bpro) then Exit(False);
  end;
  Result := True;
end;

// Returns a displacement vector that, when added to the position of
// collider 'a', will resolve the collision. It examines the
// correction needed for each test vector (normals and their cross
// products) and returns the smallest one. If the returned vector is
// zero then the colliders do not overlap.
function GetCollisionCorrection(a, b: PCollider): TVector3;
var
  overlapMin, overlap: Single;
  overlapDir: TVector3;
  testVec: array[0..14] of TVector3;
  apro, bpro: TVector2;
  i: Integer;
begin
  overlapMin := 100.0;
  overlapDir := Vector3Zero;
  GetCollisionVectors(a, b, @testVec);
  for i := 0 to 14 do
  begin
    apro := GetColliderProjectionBounds(a, testVec[i]);
    bpro := GetColliderProjectionBounds(b, testVec[i]);
    overlap := GetOverlap(apro, bpro);
    if overlap = 0.0 then Exit(Vector3Zero);
    if Abs(overlap) < Abs(overlapMin) then
    begin
     overlapMin := overlap;
     overlapDir := testVec[i];
    end;
  end;
Result := Vector3Scale(overlapDir, overlapMin);
end;




end.
