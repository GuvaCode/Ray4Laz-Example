#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragNormal;

in vec3 fragPosition;
in vec4 shadowPos;

// Input uniform values
uniform sampler2D texture0;
uniform sampler2D texture1;
//uniform sampler2D shadowMap;
uniform vec4 colDiffuse;
uniform vec3 lightDir;

// Output fragment color
out vec4 finalColor;

float ShadowCalc(vec4 p, float bias) {
	vec3 projCoords = p.xyz / p.w;
	projCoords = projCoords * 0.5 + 0.5;

	float shadow = 0.0;
	vec2 texelSize = 1.0 / textureSize(texture1, 0);
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			float pcfDepth = texture(texture1, projCoords.xy + vec2(x, y) * texelSize).r;
			shadow += projCoords.z - bias < pcfDepth ? 1.0 : 0.0;
		}
	}
	shadow /= 25.0;
	shadow = max(shadow, 0.4);
	return shadow;
}

void main() {
	vec4 texelColor = texture(texture0, fragTexCoord);
//	float bias = max(0.00005 * (1.0 - dot(fragNormal, lightDir)), 0.0);
	float bias = 0;
	float shadow = ShadowCalc(shadowPos, bias);


	float illum = 0.5 - (0.5 * dot(normalize(lightDir), normalize(fragNormal)));
	shadow = min(illum, shadow);
	
	finalColor = texelColor * colDiffuse * shadow;
	finalColor.a = 1.0;
}


