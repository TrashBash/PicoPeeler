#macro  PICOPEELER_VERSION  "0.1.0"
#macro  PICOPEELER_DATE     "19/04/2025"

__pp_trace("by TrashBash. Version ", $"[{PICOPEELER_VERSION}]", $" [{PICOPEELER_DATE}]");

function __pp_trace()
{
	var _string = "[PicoPeeler] ";
	var _idx	= 0;
	
	repeat (argument_count)
		_string += string(argument[_idx++]);
    
	show_debug_message(_string + "\n ");
}

__pp();
function __pp()
{	
	static PP_Model = function(_name) constructor
	{
		name			= _name;
		texture			= -1;
		meshes			= [];
		
		static Draw = function()
		{
			var _tex = sprite_get_texture(texture, 0);
			var _idx = 0; repeat (array_length(meshes))
			{
				meshes[_idx++].Submit(_tex);
			}
		}
	}
	
	static PP_Mesh = function(_name) constructor
	{
		name					= _name;
		vertexBuffer			= undefined;
		vertices				= [];
		
		static FromVertices = function(_format)
		{
			var _count	 = array_length(vertices);
			vertexBuffer = vertex_create_buffer_ext(_count * 36);
			
			vertex_begin(vertexBuffer, _format);
			var _idx = 0; repeat (_count)
			{
				var _v = vertices[_idx++];
				vertex_position_3d(vertexBuffer,	_v.position[0], _v.position[1], _v.position[2]);
				vertex_color(vertexBuffer,			_v.color,		_v.alpha / 255);
				vertex_normal(vertexBuffer,			_v.normal[0],	_v.normal[1],	_v.normal[2]);
				vertex_texcoord(vertexBuffer,		_v.texCoord[0], _v.texCoord[1]);
			}
			vertex_end(vertexBuffer);
		}
		
		static Submit = function(_texture)
		{
			vertex_submit(vertexBuffer, pr_trianglelist, _texture);
		}
	}
	
	static PP_Vertex = function(_x = 0, _y = _x, _z = _x) constructor
	{
		position	= [_x, _y, _z];
		color		= c_white;
		normal		= [0, 0, 1];
		texCoord	= [0, 0];
		alpha		= 1;
	}
	
	static vertexFormat = 0;
	vertex_format_begin();			
	vertex_format_add_position_3d();
	vertex_format_add_color();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	vertexFormat = vertex_format_end();
}
