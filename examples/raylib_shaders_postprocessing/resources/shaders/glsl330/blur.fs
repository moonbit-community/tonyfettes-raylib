#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

const float renderWidth = 800.0;
const float renderHeight = 450.0;

void main()
{
    float x = 1.0/renderWidth;
    float y = 1.0/renderHeight;

    vec4 sum = vec4(0.0);

    // 9-tap gaussian blur on the sampled texture
    sum += texture(texture0, vec2(fragTexCoord.x - 4.0*x, fragTexCoord.y))*0.05;
    sum += texture(texture0, vec2(fragTexCoord.x - 3.0*x, fragTexCoord.y))*0.09;
    sum += texture(texture0, vec2(fragTexCoord.x - 2.0*x, fragTexCoord.y))*0.12;
    sum += texture(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y))*0.15;
    sum += texture(texture0, vec2(fragTexCoord.x, fragTexCoord.y))*0.16;
    sum += texture(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y))*0.15;
    sum += texture(texture0, vec2(fragTexCoord.x + 2.0*x, fragTexCoord.y))*0.12;
    sum += texture(texture0, vec2(fragTexCoord.x + 3.0*x, fragTexCoord.y))*0.09;
    sum += texture(texture0, vec2(fragTexCoord.x + 4.0*x, fragTexCoord.y))*0.05;

    finalColor = sum;
}
