uniform sampler2D texture_skybox;
varying highp vec2 texture_coords_shared;

void main()
{
	//gl_FragColor = texture2D(texture_skybox, vec2(texture_coords_shared.s, texture_coords_shared.t));

	gl_FragColor = texture2D(texture_skybox, texture_coords_shared);
	//gl_FragColor = texture2D(texture_skybox, vec2(0.15625,0.805));
}
