attribute vec3	in_Position;    
attribute vec3	in_Normal;      
attribute vec4	in_Colour;      
attribute vec2	in_TextureCoord;

varying vec2	v_vTexcoord;
varying vec4	v_vColour;
varying vec3	v_vNormal;

void main()
{
    // Base Position & Normal
    vec4 object_space_pos = vec4(in_Position, 1.0);
	vec4 object_space_norm = vec4(in_Normal, 0.0);
	
	// Camera and Vertex Vector
	vec3 cameraPos = -(gm_Matrices[MATRIX_VIEW][3] * gm_Matrices[MATRIX_VIEW]).xyz;
	vec3 vertexPos =  (gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz;
	
	// Normal Vector
	v_vNormal = normalize((gm_Matrices[MATRIX_WORLD] * object_space_norm).xyz);
	
	// Color, Texture Coordinates and Position
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
	
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
}
