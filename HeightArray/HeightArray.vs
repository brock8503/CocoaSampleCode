#version 150

in vec3 attribPosition;
in vec3 attribTexCoord;
in vec3 attribNormal;

uniform mat4 cameraMatrix;
uniform mat4 textureMatrix;
uniform mat4 projectionMatrix;

out vec3 normal;
out vec3 texCoord; //3D texture coordinates to index into a 2D texture array

void main()
{
	normal = vec3(cameraMatrix * vec4(attribNormal, 0.0));
	gl_Position = projectionMatrix * cameraMatrix * vec4(attribPosition, 1.0);
	texCoord = vec3(textureMatrix * vec4(attribTexCoord, 1.0));
}