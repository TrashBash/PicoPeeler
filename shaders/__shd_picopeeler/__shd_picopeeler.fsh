varying vec2	v_vTexcoord;
varying vec4	v_vColour;
varying vec3	v_vNormal;

uniform float	u_UseTexture;

void decodeFlags(float alpha, out bool noshade, out bool doublesided, out bool notex)
{
	float scaled = floor(alpha * 255.0 + 0.5);

	noshade     = mod(scaled, 2.0) >= 1.0;
	doublesided = mod(floor(scaled / 2.0), 2.0) >= 1.0;
	notex       = mod(floor(scaled / 4.0), 2.0) >= 1.0;
}

void main()
{
	bool noshade;
    bool doublesided;
    bool notex;
	
	decodeFlags(v_vColour.a, noshade, doublesided, notex);
	
	// Cull backfaces
	if (gl_FrontFacing == false && doublesided == false)
		discard;
	
	vec4 base_col = vec4(1.0);
	if (notex == false && u_UseTexture == 1.0)
		base_col = texture2D( gm_BaseTexture, v_vTexcoord );
	else
		base_col = vec4(v_vColour.rgb, 1.0);


	if (base_col.a < 0.01)
		discard;	

	if (noshade == false)
	{		
		vec3 sun_dir	= vec3(-1.0, -0.8, -1.0);
		vec3 light_col	= vec3(1.0);
		float diffuse	= max(0.0, dot(normalize(sun_dir), v_vNormal));
		vec3 c			= vec3(0.0);
		c				+= vec3(0.65) * light_col * diffuse;
		c				+= vec3(0.55) * light_col;
		base_col		*= vec4(c, 1.0);
	}
		
    gl_FragColor = vec4(min(base_col.rgb, 1.0), 1.0);
}
