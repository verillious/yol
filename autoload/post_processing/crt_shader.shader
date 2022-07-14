shader_type canvas_item;

const float PI = 3.14159265359;

uniform vec4 corner_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool show_vignette = true;
uniform float vignette_size : hint_range(0.0, 100.0, 0.01) = 4.0;
uniform float vignette_opacity : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform bool show_horizontal_scan_lines = true;
uniform float horizontal_scan_lines_amount : hint_range(0.0, 320, 0.1) = 180.0;
uniform float horizontal_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float boost : hint_range(1.0, 2.0, 0.01) = 1.2;
uniform bool show_ca = true;
uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = 0.5;

uniform int pixel_size = 1;
uniform bool show_grain = true;

uniform float grain_amount = 0.05; //grain amount
uniform bool colored = false; //colored noise?
uniform float color_amount = 0.6;
uniform float grain_size = 1.6; //grain particle size (1.5 - 2.5)
uniform float lum_amount = 1.0;

// Amount of detail.
uniform int octaves = 4;

// Opacity of the output fog.
uniform float starting_amplitude: hint_range(0.0, 0.5) = 0.5;

// Rate of pattern within the fog.
uniform float starting_frequency = 1.0;

// Shift towards transparency (clamped) for sparser fog.
uniform float shift: hint_range(-1.0, 0.0) = -0.2;

// Direction and speed of travel.
uniform vec2 velocity = vec2(1.0, 1.0);

// Color of the fog.
uniform vec4 fog_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0);

// Noise texture; OpenSimplexNoise is great, but any filtered texture is fine.
uniform sampler2D noise;

float rand(vec2 uv) {
	float amplitude = starting_amplitude;
	float frequency = starting_frequency;
	float output = 0.0;
	for (int i = 0; i < octaves; i++) {
		output += texture(noise, uv * frequency).x * amplitude;
		amplitude /= 2.0;
		frequency *= 2.0;
	}
	return clamp(output + shift, 0.0, 1.0);
}

//a random texture generator, but you can also use a pre-computed perturbation texture
vec4 rnm(vec2 tc)
{
  	float n =  sin(dot(tc + vec2(TIME,TIME),vec2(12.9898,78.233))) * 43758.5453;
	float noiseR =  fract(n)*2.0-1.0;
    float noiseG =  fract(n*1.2154)*2.0-1.0;
    float noiseB =  fract(n*1.3453)*2.0-1.0;
    float noiseA =  fract(n*1.3647)*2.0-1.0;
    return vec4(noiseR,noiseG,noiseB,noiseA);
}

float fade(float t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float pnoise3D(vec3 p)
{
    vec3 pi = 0.00390625*floor(p);
    pi = vec3(pi.x+0.001953125, pi.y+0.001953125, pi.z+0.001953125);
    vec3 pf = fract(p);     // Fractional part for interpolation

    // Noise contributions from (x=0, y=0), z=0 and z=1
    float perm00 = rnm(pi.xy).a ;
    vec3 grad000 = rnm(vec2(perm00, pi.z)).rgb * 4.0;
    grad000 = vec3(grad000.x - 1.0, grad000.y - 1.0, grad000.z - 1.0);
    float n000 = dot(grad000, pf);
    vec3 grad001 = rnm(vec2(perm00, pi.z + 0.00390625)).rgb * 4.0;
    grad001 = vec3(grad001.x - 1.0, grad001.y - 1.0, grad001.z - 1.0);
    float n001 = dot(grad001, pf - vec3(0.0, 0.0, 1.0));

    // Noise contributions from (x=0, y=1), z=0 and z=1
    float perm01 = rnm(pi.xy + vec2(0.0, 0.00390625)).a ;
    vec3 grad010 = rnm(vec2(perm01, pi.z)).rgb * 4.0;
    grad010 = vec3(grad010.x - 1.0, grad010.y - 1.0, grad010.z - 1.0);
    float n010 = dot(grad010, pf - vec3(0.0, 1.0, 0.0));
    vec3 grad011 = rnm(vec2(perm01, pi.z + 0.00390625)).rgb * 4.0;
    grad011 = vec3(grad011.x - 1.0, grad011.y - 1.0, grad011.z - 1.0);
    float n011 = dot(grad011, pf - vec3(0.0, 1.0, 1.0));

    // Noise contributions from (x=1, y=0), z=0 and z=1
    float perm10 = rnm(pi.xy + vec2(0.00390625, 0.0)).a ;
    vec3  grad100 = rnm(vec2(perm10, pi.z)).rgb * 4.0;
    grad100 = vec3(grad100.x - 1.0, grad100.y - 1.0, grad100.z - 1.0);
    float n100 = dot(grad100, pf - vec3(1.0, 0.0, 0.0));
    vec3  grad101 = rnm(vec2(perm10, pi.z + 0.00390625)).rgb * 4.0;
    grad101 = vec3(grad101.x - 1.0, grad101.y - 1.0, grad101.z - 1.0);
    float n101 = dot(grad101, pf - vec3(1.0, 0.0, 1.0));

    // Noise contributions from (x=1, y=1), z=0 and z=1
    float perm11 = rnm(pi.xy + vec2(0.00390625, 0.00390625)).a ;
    vec3  grad110 = rnm(vec2(perm11, pi.z)).rgb * 4.0;
    grad110 = vec3(grad110.x - 1.0, grad110.y - 1.0, grad110.z - 1.0);
    float n110 = dot(grad110, pf - vec3(1.0, 1.0, 0.0));
    vec3  grad111 = rnm(vec2(perm11, pi.z + 0.00390625)).rgb * 4.0;
    grad111 = vec3(grad111.x - 1.0, grad111.y - 1.0, grad111.z - 1.0);
    float n111 = dot(grad111, pf - vec3(1.0, 1.0, 1.0));

    // Blend contributions along x
    vec4 n_x = mix(vec4(n000, n001, n010, n011), vec4(n100, n101, n110, n111), fade(pf.x));

    // Blend contributions along y
    vec2 n_xy = mix(n_x.xy, n_x.zw, fade(pf.y));

    // Blend contributions along z
    float n_xyz = mix(n_xy.x, n_xy.y, fade(pf.z));

    // We're done, return the final noise value.
    return n_xyz;
}

//2d coordinate orientation thing
vec2 coordRot(vec2 screen_size, vec2 tc, float angle)
{
    float aspect = screen_size.x/screen_size.y;
    float rotX = ((tc.x*2.0-1.0)*aspect*cos(angle)) - ((tc.y*2.0-1.0)*sin(angle));
    float rotY = ((tc.y*2.0-1.0)*cos(angle)) + ((tc.x*2.0-1.0)*aspect*sin(angle));
    rotX = ((rotX/aspect)*0.5+0.5);
    rotY = rotY*0.5+0.5;
    return vec2(rotX,rotY);
}

void fragment() {
	vec2 screen_size = vec2(1.0 / SCREEN_PIXEL_SIZE.x, 1.0 / SCREEN_PIXEL_SIZE.y);
	vec2 uv = UV;
	vec2 screen_uv = SCREEN_UV;

	vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;

	if(pixel_size > 0){
		int even_size = (pixel_size+1 / 2) * 2;
		vec2 pos = SCREEN_UV / SCREEN_PIXEL_SIZE;
		vec2 square = vec2(float(even_size));
		vec2 top_left = floor(pos / square) * square;
		vec3 total = vec3(0);
		for (int x = int(top_left.x); x < int(top_left.x) + even_size; x++){
			for (int y = int(top_left.y); y < int(top_left.y) + even_size; y++){
				if (show_ca && aberration_amount > 0.0) {
					float adjusted_amount = aberration_amount / screen_size.x;
					total.r += texture(SCREEN_TEXTURE, vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE + vec2(adjusted_amount, 0)).r;
					total.g += texture(SCREEN_TEXTURE, vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE).g;
					total.b += texture(SCREEN_TEXTURE, vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE - vec2(adjusted_amount, 0)).b;
				}
				else {
					total += texture(SCREEN_TEXTURE, vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE).rgb;
				}
			}
		}
		color = total / float(even_size * even_size);
	} else {
		if (show_ca && aberration_amount > 0.0) {
			float adjusted_amount = aberration_amount / screen_size.x;
			color.r = texture(SCREEN_TEXTURE, vec2(screen_uv.x + adjusted_amount, screen_uv.y)).r;
			color.g = texture(SCREEN_TEXTURE, screen_uv).g;
			color.b = texture(SCREEN_TEXTURE, vec2(screen_uv.x - adjusted_amount, screen_uv.y)).b;
		}
	}

	if (show_vignette) {
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = clamp(pow((screen_size.x / vignette_size) * vignette, vignette_opacity), 0.0, 1.0);
		color *= vignette;
	}

	if (show_horizontal_scan_lines) {
		float s = sin(screen_uv.y * screen_size.y * PI);
		s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		vec4 scan_line = vec4(vec3(pow(s, horizontal_scan_lines_opacity)), 1.0);
		color *= scan_line.rgb;
	}

	if (show_horizontal_scan_lines) {
		color *= boost;
	}

	// Fill the blank space of the corners, left by the curvature, with black.
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		color = corner_color.rgb;
	}


	if (show_grain)
	{
	    vec3 rotOffset = vec3(1.425,3.892,5.835); //rotation offset values
	    vec2 rotCoordsR = coordRot(screen_size, UV, TIME + rotOffset.x);
	    vec3 n = vec3(pnoise3D(vec3(rotCoordsR*vec2(screen_size.x/grain_size,screen_size.y/grain_size),0.0)));

	    vec3 lumcoeff = vec3(0.299,0.587,0.114);
	    float luminance = mix(0.0,dot(color, lumcoeff),lum_amount);
	    float lum = smoothstep(0.2,0.0,luminance);
	    lum += luminance;

	    n = mix(n,vec3(0.0),pow(lum,4.0));
	    color = color+n*grain_amount;
	}

	COLOR = vec4(color, 1.0);
}
