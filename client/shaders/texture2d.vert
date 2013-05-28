// MVP matrix
uniform mat4 mMat; // vert -> model
uniform mat4 vMat; // model -> cam
uniform mat4 pMat; // cam -> clip

attribute vec2 vert;
attribute vec2 texture_coords;

varying highp vec2 texture_coords_shared;

void main()
{
	gl_Position = pMat * vMat * mMat * vec4(vert, 1.0, 1.0);
	texture_coords_shared = texture_coords;
}
