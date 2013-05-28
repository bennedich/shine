uniform sampler2D texture_sampler;
varying highp vec2 texture_coords_shared;

void main()
{
	gl_FragColor = texture2D(texture_sampler, texture_coords_shared);

	// TODO this should be done with correct color blending
	if (gl_FragColor.w < 0.9) {
		discard;
	}
}
