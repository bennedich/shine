attribute vec2 vert;
attribute vec2 texture_coords;
varying highp vec2 texture_coords_shared;

void main()
{
	gl_Position = vec4(vert, 1.0, 1.0);
	texture_coords_shared = texture_coords;
}
