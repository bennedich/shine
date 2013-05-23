#ifdef GL_ES
precision highp float;
#endif

varying vec4 clr;


vec4 permute (vec4 x) {
	return mod(((x*34.0)+1.0)*x, 289.0);
}

vec4 taylorInvSqrt (vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 smoothstep (vec2 t) {
	return t*t*(3.0-2.0*t);
}

float smoothstep (float t) {
	return t*t*(3.0-2.0*t);
}

float cnoise (vec2 P)
{
	// integer and fractional coords for all four corners
	vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
	vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
	Pi = mod(Pi, 289.0); // avoid truncation effects in permutation
	vec4 ix = Pi.xzxz;
	vec4 iy = Pi.yyww;
	vec4 fx = Pf.xzxz;
	vec4 fy = Pf.yyww;
	
	vec4 i = permute(permute(ix) + iy);
	
	// gradients from 41 points on a line mapped to a diamond
	vec4 gx = 2.0 * fract(i * (1.0 / 41.0)) - 1.0;
	vec4 gy = abs(gx) - 0.5;
	vec4 tx = floor(gx + 0.5);
	gx = gx - tx;
	
	vec2 g00 = vec2(gx.x, gy.x);
	vec2 g10 = vec2(gx.y, gy.y);
	vec2 g01 = vec2(gx.z, gy.z);
	vec2 g11 = vec2(gx.w, gy.w);
	
	// normalize gradients
	vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
	g00 *= norm.x;
	g01 *= norm.y;
	g10 *= norm.z;
	g11 *= norm.w;
	
	// extrapolation from the four corners
	float n00 = dot(g00, vec2(fx.x, fy.x));
	float n10 = dot(g10, vec2(fx.y, fy.y));
	float n01 = dot(g01, vec2(fx.z, fy.z));
	float n11 = dot(g11, vec2(fx.w, fy.w));
	
	// interpolation to compute final noise value
	vec2 fade_xy = smoothstep(Pf.xy);
	vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
	float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
	return 2.3 * n_xy;
}

void main ()
{
	// discard if outside circle
	if (length(gl_PointCoord-vec2(0.5,0.5)) > 0.5) {
		discard;
	}
	
	gl_FragColor = clr;
}
