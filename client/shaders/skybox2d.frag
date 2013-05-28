uniform sampler2D texture_skybox;
varying highp vec2 texture_coords_shared;

void main()
{
	gl_FragColor = texture2D(texture_skybox, texture_coords_shared);
}
