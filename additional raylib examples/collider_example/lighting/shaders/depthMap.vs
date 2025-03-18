#version 330
//layout (location = 0) in vec3 aPos;

in vec3 vertexPosition;

uniform mat4 matModel;
uniform mat4 matLightView;
uniform mat4 matLightProjection;

void main()
{
	mat4 mvpLight = matLightProjection * matLightView * matModel;

	gl_Position = mvpLight * vec4(vertexPosition, 1.0);
}
