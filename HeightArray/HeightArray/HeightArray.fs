#version 150

uniform sampler2DArray sampler; //2D texture array

in vec3 normal;
in vec3 texCoord;

out vec4 fragColor;

void main (void) 
{
	vec3 b0 = normalize(normal);
	vec3 coord = texCoord;
	coord.z = floor(coord.z);
	vec4 a = texture(sampler, coord);
	coord.z += 1.0;
	vec4 b = texture(sampler, coord);
	fragColor = mix(a, b, fract(texCoord.z));
}