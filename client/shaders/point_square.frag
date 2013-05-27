#ifdef GL_ES
precision highp float;
#endif

varying vec4 clr;

void main ()
{
	gl_FragColor = clr;
}
