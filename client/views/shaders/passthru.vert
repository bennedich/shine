// MVP matrix
uniform mat4 mMat; // vert -> model
uniform mat4 vMat; // model -> cam
uniform mat4 pMat; // cam -> clip
uniform vec4 mClr;

attribute vec3 vert;

varying vec4 clr;

void main()
{
	gl_Position = pMat * vMat * mMat * vec4(vert, 1.0);
	clr = mClr;
}
