// MVP matrix
uniform mat4 mMat; // vert -> model
uniform mat4 vMat; // model -> cam
uniform mat4 pMat; // cam -> clip
uniform vec4 mClr;
uniform float mSize;

attribute vec3 vert;

varying vec4 clr;

void main()
{
	gl_Position = pMat * vMat * mMat * vec4(vert, 1.0);
	float d = distance(vMat[3], gl_Position);
	gl_PointSize = max(2.0, mSize/d);
	clr = mClr;
}