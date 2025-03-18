program gpu_particles;

{$mode objfpc}{$H+}

uses 
cmem, 
rlgl,
raylib, raygui, raymath;

const
  screenWidth = 800;
  screenHeight = 800;

var
  shaderCode: PChar;
  shaderData, computeShader, numParticles, i: integer;
  particleShader: TShader;
  positions, velocities: PVector4;

  ssbo0, ssbo1, ssbo2: integer;
  particleVao: integer;
  vertices: array [0..2] of TVector3;

  camera: TCamera;
  time,
  timeScale,
  sigma,
  rho,
  beta,
  particleScale,
  instances_x1000: single;

  deltaTime: single;
  numInstances: integer;

  projection, view: TMatrix;

function GetRandomFloat(from, to_: single): single;
begin
  result := from + (to_ - from) * ( GetRandomValue(0, maxint) / maxint);
end;

function Vector4Create(aX: single; aY: single; aZ: single; aW: Single): TVector4;
begin
  Result.x := aX;
  Result.y := aY;
  Result.z := aZ;
  Result.w := aW;
end;


begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'GPU Particles');

  // Compute shader for updating particles.
  shaderCode := LoadFileText('Shaders/particle_compute.glsl');
  shaderData := rlCompileShader(shaderCode, RL_COMPUTE_SHADER);
  computeShader := rlLoadComputeShaderProgram(shaderData);
  UnloadFileText(shaderCode);

  // Shader for constructing triangles and drawing.
  particleShader := LoadShader('Shaders/particle_vertex.glsl','Shaders/particle_fragment.glsl');

  // Now we prepare the buffers that we connect to the shaders.
  // For each variable we want to give our particles, we create one buffer
  // called a Shader Storage Buffer Object containing a single variable type.
  //
  // We will use only Vector4 as particle variables, because data in buffers
  // requires very strict alignment rules.
  // You can send structs, but if not properly aligned will introduce many bugs.
  // For information on the std430 buffer layout see:
  // https://www.khronos.org/opengl/wiki/Interface_Block_(GLSL).
  //
  // Number of particles should be a multiple of 1024, our workgroup size (set in shader).
  numParticles := 1024*100;
  positions :=  MALLOC(numParticles*sizeof(TVector4) );
  velocities := MALLOC(numParticles*sizeof(TVector4) );

  for i := 0 to numParticles do
  begin
    positions[i] := Vector4Create( GetRandomFloat(-0.5, 0.5), GetRandomFloat(-0.5, 0.5), GetRandomFloat(-0.5, 0.5), 0);
    velocities[i] := Vector4Create( 0.0, 0.0, 0.0, 0.0);
  end;

  // Load three buffers: Position, Velocity and Starting Position. Read/Write=RL_DYNAMIC_COPY.
  ssbo0 := rlLoadShaderBuffer(numParticles*sizeof(TVector4), @positions, RL_DYNAMIC_COPY);
  ssbo1 := rlLoadShaderBuffer(numParticles*sizeof(TVector4), @velocities, RL_DYNAMIC_COPY);
  ssbo2 := rlLoadShaderBuffer(numParticles*sizeof(TVector4), @positions, RL_DYNAMIC_COPY);

  // For instancing we need a Vertex Array Object.
  // Raylib Mesh* is inefficient for millions of particles.
  // For info see: https://www.khronos.org/opengl/wiki/Vertex_Specification
  particleVao := rlLoadVertexArray();
  rlEnableVertexArray(particleVao);

  // Our base particle mesh is a triangle on the unit circle.
  // We will rotate and stretch the triangle in the vertex shader.
  vertices[0] := Vector3Create(-0.86, -0.5, 0.0);
  vertices[1] := Vector3Create(-0.86, -0.5, 0.0);
  vertices[2] := Vector3Create(0.0, 1.0, 0.0);

  // Configure the vertex array with a single attribute of vec3.
  // This is the input to the vertex shader.
  rlEnableVertexAttribute(0);
  rlLoadVertexBuffer(@vertices, sizeof(vertices),  false); // dynamic=false
  rlSetVertexAttribute(0, 3, RL_FLOAT, false, 0, 0);
  rlDisableVertexArray(); // Stop editing.

  camera := Camera3DCreate(Vector3Create(2, 2, 2), Vector3Zero, Vector3Create(0,1,0),35.0,CAMERA_PERSPECTIVE);
  time := 0;
  timeScale := 0.2;
  sigma := 10;
  rho := 28;
  beta := 8.0/3.0;
  particleScale := 1.0;
  instances_x1000 := 100.0;

  // Main game loop
  while not WindowShouldClose() do
    begin
      deltaTime := GetFrameTime();
      numInstances := Trunc (instances_x1000 / 1000 * numParticles);
      UpdateCamera(@camera, CAMERA_ORBITAL);

      // Compute Pass.
      rlEnableShader(computeShader);

      // Set our parameters. The indices are set in the shader.
      rlSetUniform(0, @time, SHADER_UNIFORM_FLOAT, 1);
      rlSetUniform(1, @timeScale, SHADER_UNIFORM_FLOAT, 1);
      rlSetUniform(2, @deltaTime, SHADER_UNIFORM_FLOAT, 1);
      rlSetUniform(3, @sigma, SHADER_UNIFORM_FLOAT, 1);
      rlSetUniform(4, @rho, SHADER_UNIFORM_FLOAT, 1);
      rlSetUniform(5, @beta, SHADER_UNIFORM_FLOAT, 1);

      rlBindShaderBuffer(ssbo0, 0);
      rlBindShaderBuffer(ssbo1, 1);
      rlBindShaderBuffer(ssbo2, 2);

      // We have numParticles/1024 workGroups. Each workgroup has size 1024.
      rlComputeShaderDispatch(numParticles div 1024, 1, 1);
      rlDisableShader();


        BeginDrawing();
        ClearBackground(BLACK);

        // Render Pass.
          BeginMode3D(camera);
          rlEnableShader(particleShader.id);

          // Because we use rlgl, we must take care of matrices ourselves.
          // We need to only pass the projection and view matrix.
          // These will be used to make the particle face the camera and such.
          projection := rlGetMatrixProjection();
          view := GetCameraMatrix(camera);

          SetShaderValueMatrix(particleShader, 0, projection);
          SetShaderValueMatrix(particleShader, 1, view);
          SetShaderValue(particleShader, 2, @particleScale, SHADER_UNIFORM_FLOAT);

          rlBindShaderBuffer(ssbo0, 0);
          rlBindShaderBuffer(ssbo1, 1);

          // Draw the particles. Instancing will duplicate the vertices.
          rlEnableVertexArray(particleVao);
          rlDrawVertexArrayInstanced(0, 3, numInstances);
          rlDisableVertexArray();
          rlDisableShader();

          DrawCubeWires(Vector3Zero, 1.0, 1.0, 1.0, DARKGRAY);
          EndMode3D();

          // GUI Pass.
          GuiSlider(RectangleCreate( 550, 10, 200, 10 ), 'Particles x1000', TextFormat('%.2f', instances_x1000), @instances_x1000, 0, 1000);
          GuiSlider(RectangleCreate( 550, 25, 200, 10 ), 'Particle Scale', TextFormat('%.2f', particleScale), @particleScale, 0, 5);
          GuiSlider(RectangleCreate( 550, 40, 200, 10 ), 'Speed', TextFormat('%.2f', timeScale), @timeScale, 0, 1.0);
          GuiSlider(RectangleCreate( 650, 70, 100, 10 ), 'Sigma', TextFormat('%2.1f', sigma), @sigma, 0, 20);
          GuiSlider(RectangleCreate( 650, 85, 100, 10 ), 'Rho', TextFormat('%2.1f', rho), @rho, 0, 30);
          GuiSlider(RectangleCreate( 650, 100, 100, 10 ), 'Beta', TextFormat('%2.1f', beta), @beta, 0, 10);

          time += deltaTime;

          if (GuiButton(RectangleCreate( 350, 10, 100, 20 ), 'Restart (Space)') > 0) or (IsKeyPressed(KEY_SPACE)) then
          time := 0;

          if GuiButton(RectangleCreate( 280, 10, 60, 20 ), 'Reset') > 0 then
          begin
            time := 0;
            timeScale := 0.2;
            sigma := 10;
            rho := 28;
            beta := 8.0/3.0;
            particleScale := 1.0;
            instances_x1000 := 100.0;
          end;

          DrawFPS(10, 10);
          DrawText(TextFormat('N=%d', numInstances), 10, 30, 20, DARKGRAY);

      EndDrawing();
    end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.

