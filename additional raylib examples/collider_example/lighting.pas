unit lighting;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, rlgl, raymath;

const
 SHADOWMAP_VS_FILE = 'lighting/shaders/depthMap.vs';
 SHADOWMAP_FS_FILE = 'lighting/shaders/depthMap.fs';
 MODEL_VS_FILE = 'lighting/shaders/model.vs';
 MODEL_FS_FILE = 'lighting/shaders/model.fs';
 DEPTH_FS_FILE = 'lighting/shaders/depth.fs';

 SHADOW_CAMERA_POSITION: TVector3 = (x:10.0; y:10.0; z:10.0);
 SHADOW_CAMERA_TARGET:   TVector3 = (x:0.0; y:0.0; z:0.0);
 SHADOW_CAMERA_UP:       TVector3 = (x:0.0; y:1.0; z:0.0);
 SHADOW_CAMERA_FOVY = 45.0;

 SHADOW_BUFFER_WIDTH = 2048*2;   //todo lo hi

 MAX_MODELS = 8;

var
 // Point light camera
 shadowCamera: TCamera;

 // Render target for shadow camera
 shadowBuffer: TRenderTexture;

 shadowMapShader: TShader;
 modelShader: TShader;
 depthShader: TShader;

 // Various shader locs
 modelShaderLightViewLoc: integer;
 modelShaderLightProjLoc: integer;
 modelShaderLightDirLoc: integer;
 shadowShaderLightViewLoc: integer;
 shadowShaderLightProjLoc: integer;

 // Buffer to keep track of models used in shadow calculations
 modelArr: array[0..MAX_MODELS] of PModel;
 modelCount: integer;

procedure InitLighting();

procedure EndLighting();

procedure SetLightPosition(position: TVector3);

procedure SetLightTarget(target: TVector3);

procedure LightingAddModel(modelPtr: PModel);

procedure BeginDepthMode();

procedure EndDepthMode();

procedure BeginViewMode(camera: TCamera);

procedure EndViewMode();

procedure DrawDepthBuffer(rect: TRectangle);

implementation
uses math;

function LoadRenderTextureWithDepthTexture(width, height: integer): TRenderTexture2D;
var target: TRenderTexture2D;
begin
  target.id := rlLoadFramebuffer();   // Load an empty framebuffer
  if target.id > 0 then
  begin
    rlEnableFramebuffer(target.id);

    // Create color texture (default to RGBA)
    target.texture.id := rlLoadTexture(nil, width, height, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
    target.texture.width := width;
    target.texture.height := height;
    target.texture.format := PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
    target.texture.mipmaps := 1;

    // Create depth texture
    target.depth.id := rlLoadTextureDepth(width, height, false);
    target.depth.width := width;
    target.depth.height := height;
    target.depth.format := 19;
    target.depth.mipmaps := 1;

    // Attach color texture and depth texture to FBO
    rlFramebufferAttach(target.id, target.texture.id, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(target.id, target.depth.id, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_TEXTURE2D, 0);

    // Check if fbo is complete with attachments (valid)
    if rlFramebufferComplete(target.id) then TRACELOG(LOG_INFO, 'FBO: [ID %i] Framebuffer object created successfully', target.id);
    rlDisableFramebuffer();
  end
  else TRACELOG(LOG_WARNING, 'FBO: Framebuffer object can not be created');
  result:= target;
end;

procedure LoadShaders;
begin
  shadowMapShader := LoadShader(SHADOWMAP_VS_FILE, SHADOWMAP_FS_FILE);
  modelShader := LoadShader(MODEL_VS_FILE, MODEL_FS_FILE);
  depthShader := LoadShader(nil, DEPTH_FS_FILE);
  modelShaderLightViewLoc := GetShaderLocation(modelShader, 'matLightView');
  modelShaderLightProjLoc := GetShaderLocation(modelShader, 'matLightProjection');
  modelShaderLightDirLoc := GetShaderLocation(modelShader, 'lightDir');
  shadowShaderLightViewLoc := GetShaderLocation(shadowMapShader, 'matLightView');
  shadowShaderLightProjLoc := GetShaderLocation(shadowMapShader, 'matLightProjection');
end;

procedure UnloadShaders;
begin
  UnloadShader(shadowMapShader);
  UnloadShader(modelShader);
  UnloadShader(depthShader);
end;

procedure InitLighting;
begin
  LoadShaders();
  shadowBuffer := LoadRenderTextureWithDepthTexture(SHADOW_BUFFER_WIDTH, SHADOW_BUFFER_WIDTH);
  shadowCamera.position := SHADOW_CAMERA_POSITION;
  shadowCamera.target := SHADOW_CAMERA_TARGET;
  shadowCamera.up := SHADOW_CAMERA_UP;
  shadowCamera.fovy := SHADOW_CAMERA_FOVY;
  shadowCamera.projection := CAMERA_ORTHOGRAPHIC;
end;

procedure EndLighting;
begin
  UnloadShaders();
  UnloadRenderTexture(shadowBuffer);
end;

procedure SetLightPosition(position: TVector3);
begin
  shadowCamera.position := position;
end;

procedure SetLightTarget(target: TVector3);
begin
  shadowCamera.target := target;
end;

procedure LightingAddModel(modelPtr: PModel);
var i: integer;
begin
  if modelCount-1 < MAX_MODELS then
  begin
  // Apply depth texture to model metalness loc
  for i := 0 to modelPtr^.materialCount -1 do    // (int i = 0; i < modelPtr->materialCount; i++)
  modelPtr^.materials[i].maps[MATERIAL_MAP_METALNESS].texture := shadowBuffer.depth;

  // Add model pointer to array
  modelArr[modelCount] := modelPtr;
  Inc(modelCount);
  end;

end;

procedure BeginDepthMode;
var aspect: single;
    top, right: double;
    lightView, lightProj: TMatrix;
    lightDir: TVector3;
    i: integer;
begin
  // Calculate shader variables
  aspect := shadowBuffer.depth.width /  shadowBuffer.depth.height;
  top := RL_CULL_DISTANCE_NEAR * tan(shadowCamera.fovy * 0.5 * DEG2RAD);
  right := top * aspect;
  lightView := GetCameraMatrix(shadowCamera);
  lightProj := MatrixPerspective(shadowCamera.fovy, aspect, RL_CULL_DISTANCE_NEAR, RL_CULL_DISTANCE_FAR);
  lightDir := Vector3Normalize(Vector3Subtract(shadowCamera.target, shadowCamera.position));

  // Update shader variables
  SetShaderValueMatrix(modelShader, modelShaderLightViewLoc, lightView);
  SetShaderValueMatrix(modelShader, modelShaderLightProjLoc, lightProj);
  SetShaderValue(modelShader, modelShaderLightDirLoc, @lightDir, SHADER_UNIFORM_VEC3);
  SetShaderValueMatrix(shadowMapShader, shadowShaderLightViewLoc, lightView);
  SetShaderValueMatrix(shadowMapShader, shadowShaderLightProjLoc, lightProj);

  // Set shadow map shader
  for i := 0 to modelCount -1 do // (int i = 0; i < modelCount; i++) {
  modelArr[i]^.materials[0].shader := shadowMapShader;

  BeginTextureMode(shadowBuffer);
  ClearBackground(BLANK);
  BeginMode3D(shadowCamera);

  rlSetCullFace(RL_CULL_FACE_FRONT);
end;

procedure EndDepthMode;
begin
  rlSetCullFace(RL_CULL_FACE_BACK);

  EndMode3D();
  EndTextureMode();
end;

procedure BeginViewMode(camera: TCamera);
var i: integer;
begin
  for i :=0 to modelCount -1  do  // (int i = 0; i < modelCount; i++) {
  modelArr[i]^.materials[0].shader := modelShader;
  BeginMode3D(camera);
end;

procedure EndViewMode;
begin
  EndMode3D();
end;

procedure DrawDepthBuffer(rect: TRectangle);
begin
  BeginShaderMode(depthShader);

  DrawTexturePro(shadowBuffer.depth,
  RectangleCreate( 0.0, 0.0, shadowBuffer.texture.width, shadowBuffer.texture.height ),
  rect,
  Vector2Create ( 0.0, 0.0 ),
  0.0, WHITE);

  EndShaderMode();
end;



end.

