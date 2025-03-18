#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 matView;
uniform mat4 matModel;
uniform mat4 matProjection;

uniform mat4 matLightView;
uniform mat4 matLightProjection;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragNormal;

// Output attributes for shadow calculations
out vec4 shadowPos;

void main() {

	// Calculate vertex position in light space
	mat4 mvpLight = matLightProjection * matLightView * matModel;
	shadowPos = mvpLight * vec4(vertexPosition, 1.0);

	// Send vertex attributes to fragment shader
	mat4 mvp = matProjection * matView * matModel;
	vec3 normal = (matModel * vec4(vertexNormal, 1)).xyz;
	vec3 offset = (matModel * vec4(0, 0, 0, 1)).xyz;
	normal -= offset;

	fragTexCoord = vertexTexCoord;
	fragColor = vertexColor;
	fragNormal = normal;
	
	// Calculate final vertex position
	gl_Position = matProjection * matView * matModel * vec4(vertexPosition, 1.0);
}
