// material
//uniform vec3 m_ambient;
//uniform vec3 m_diffuse;
//uniform vec3 m_specular;
//uniform float m_shininess;

// light
uniform vec3 l_ambient;
uniform vec3 l_diffuse;
//uniform vec3 l_specular;
uniform vec3 l_position;

// MVP matrix
uniform mat4 mMat; // vert -> model
uniform mat4 vMat; // model -> cam
uniform mat4 pMat; // cam -> clip

attribute vec3 vert;
attribute vec3 norm;

varying vec3 clr;

void main()
{
	//gl_PointSize = 5.0;
	
	vec4 g_vert = mMat * vec4(vert, 1.0);
	vec4 g_norm = normalize(mMat * vec4(norm, 0.0));
	
	gl_Position = pMat * vMat * mMat * vec4(vert, 1.0);
	
	// diffuse directional
	float dCosIncidence = dot(g_norm.xyz, l_position); // use position as direction
	dCosIncidence = clamp(dCosIncidence, 0.0, 1.0);
	
	// resulting color
	clr = l_diffuse * dCosIncidence + l_ambient;
}