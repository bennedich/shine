#ifdef GL_ES
precision highp float;
#endif

varying vec3 clr;

void main()
{
	gl_FragColor = vec4(clr, 1.0);
}
