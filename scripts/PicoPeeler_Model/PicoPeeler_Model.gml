#macro PICOCAD_STAMP				"picocad"
#macro PICOCAD_TEXTURE_WIDTH		128
#macro PICOCAD_TEXTURE_HEIGHT		128
#macro PICOCAD_OBJSTART_TOKEN		"{"
#macro PICOCAD_OBJEND_TOKEN			"}"
#macro PICOCAD_STRING_TOKEN			"'"
#macro PICOCAD_FACE_ATTR_NOSHADE	"noshade"
#macro PICOCAD_FACE_ATTR_NOTEX		"notex"
#macro PICOCAD_FACE_ATTR_DBLSIDED	"dbl"

function PicoPeeler_Model() constructor
{
	name		= "";
	fileName	= "";
	bgColor		= c_dkgray;
	model		= undefined;
	texture		= undefined;
	
	static PICOCAD_COLORS =
	[
		#000000,	#1d2b53,	#7e2553,	#008751,	
		#ab5236,	#5f574f,	#c2c3c7,	#fff1e8,	
		#ff004d,	#ffa300,	#ffec27,	#00e436,
		#29adff,	#83769c,	#ff77a8,	#ffccaa,
	];

	static __PP_AssembleModel = function(_data)
	{
		var _mdl			= new __pp.PP_Model();
		var _meshCount		= array_length(_data.values);
		_mdl.meshes			= array_create(_meshCount);
		
		var _calcFaceNormal = function(_vertices, _count)
		{
			var cross = function(a, b)
			{
				return [
					a[1]*b[2] - a[2]*b[1],
					a[2]*b[0] - a[0]*b[2],
					a[0]*b[1] - a[1]*b[0]
				];
			};

			for (var i = 0; i < _count; i++)
			{
				var v0 = _vertices[i].position;
				var v1 = _vertices[(i + 1) % _count].position;
				var v2 = _vertices[(i + 2) % _count].position;

				var d0 = [v0[0] - v1[0], v0[1] - v1[1], v0[2] - v1[2]];
				var d1 = [v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]];

				var n = cross(d1, d0);
				var len = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);

				if (len > 0)
					return [n[0] / len, n[1] / len, n[2] / len];
			}

			return [1, 0, 0];
		};
					
		// Process each mesh
		for (var i = 0; i < _meshCount; i++)
		{
			var _meshData		= _data.values[i];
			var _mesh			= new __pp.PP_Mesh(_meshData.name);

			var _vertData		= _meshData.v.values;
			var _faceData		= _meshData.f.values;

			var _vertexCount	= array_length(_vertData);
			var _faceCount		= array_length(_faceData);

			var _pos			= _meshData.pos.values;
			var _polygon		= array_create(4);

			// Face loop
			for (var f = 0; f < _faceCount; f++)
			{
				var _face		= _faceData[f];
				var _indices	= _face.values;
				var _col		= _face.c;
				var _uv			= _face.uv.values;
				var _count		= array_length(_indices);
				var _color		= PICOCAD_COLORS[_col];

				var _flags = 0;
				    _flags += (struct_exists(_face, PICOCAD_FACE_ATTR_NOSHADE)		? 1 : 0);
				    _flags += (struct_exists(_face, PICOCAD_FACE_ATTR_DBLSIDED)		? 2 : 0);
				    _flags += (struct_exists(_face, PICOCAD_FACE_ATTR_NOTEX)		? 4 : 0);
				
				// Construct polygon
				for (var j = 0; j < _count; j++)
				{
					var _vi		= _indices[j] - 1;
					var _uvi	= j * 2;

					var _v	= new __pp.PP_Vertex();
					_v.position = variable_clone(_vertData[_vi].values);
					
					// Flip on Z Axis
					_v.position[2] = -_v.position[2]; 
					
					_v.position[0] += _pos[0];
					_v.position[1] += _pos[1];
					_v.position[2] += -_pos[2];
					
					_v.texCoord = [_uv[_uvi] / 16, _uv[_uvi + 1] / 16];
					_v.color	= _color;
					_v.alpha	= _flags;
					
					_polygon[j] = _v;
				}

				var _normal = _calcFaceNormal(_polygon, _count);
				for (var j = 0; j < _count; j++) 
					_polygon[j].normal = _normal;

				// Triangulate
				switch (_count)
				{
					// Triangle
					case 3:	array_push(_mesh.vertices, _polygon[0], _polygon[1], _polygon[2]);
							break;
					
					// Quad
					case 4:	array_push(_mesh.vertices, _polygon[0], _polygon[1], _polygon[2], _polygon[0], _polygon[2], _polygon[3]);
							break;
					
					// N-Gon
					default:
						for (var p = 0; p < _count - 2; p++)
							array_push(_mesh.vertices, _polygon[0], _polygon[p + 1], _polygon[p + 2]);
							break;
						
				}
			}

			_mesh.FromVertices(__pp.vertexFormat);			
			_mdl.meshes[i] = _mesh;
		}
		
		return _mdl;
	};
	
	static __PP_ReadNumber = function(_s)
	{
		var _start = index;

		while (__PP_IsNumericChar(string_char_at(_s, index)))
			index++;

		return string_copy(_s, _start, index - _start);
	}
	
	static __PP_ReadObject = function(_s)
	{
		// Skip '{'
		index++; 
		
		var _obj = {};

		while (true)
		{
			var _c = string_char_at(_s, index);

			// End of object
			if (_c == PICOCAD_OBJEND_TOKEN) 
			{
				index++;
				break;
			}

			var _key = undefined;

			// Check for key-value
			if (_c >= "a" && _c <= "z") 
			{
				var _start = index;
				repeat (string_length(_s) - index + 1) 
				{
					if (string_char_at(_s, index) == "=")
						break;
					
					index++;
				}
				
				_key = string_copy(_s, _start, index - _start);
				
				// Skip '='
				index++; 
			}

			var _value = __PP_ReadValue(_s);

			if (_key != undefined)
				_obj[$ _key] = _value;
			else
			{
				if (!struct_exists(_obj, "values"))
					_obj.values = [];
					
				array_push(_obj.values, _value);
			}

			if (string_char_at(_s, index) == ",")
				index++;
		}

		return _obj;
	};
	
	static __PP_ReadString = function(_s)
	{
		var _start	= index;
		var _end	= string_pos_ext(PICOCAD_STRING_TOKEN, _s, index + 1);
		
		if (_end == 0)
			__pp_trace($"[error] No end for string value: {_s}");

		index = _end + 1;
		return string_copy(_s, _start + 1, _end - _start - 1);
	}
	
	static __PP_ReadValue = function(_s)
	{
		var _c = string_char_at(_s, index);
		switch (_c) 
		{
			case PICOCAD_OBJSTART_TOKEN:	return __PP_ReadObject(_s);
			case PICOCAD_STRING_TOKEN:		return __PP_ReadString(_s);
			default:
				if (__PP_IsNumericChar(_c))
					return real(__PP_ReadNumber(_s));
				else
					__pp_trace($"[error] Unknown value: {_c}");
		}
	}
	
	static __PP_IsNumericChar = function(_c) {
		return _c == "-" || _c == "." || (_c >= "0" && _c <= "9");
	}
	
	static Draw = function(_tex = true)
	{
		shader_set(__shd_picopeeler);
		shader_set_uniform_f(shader_get_uniform(__shd_picopeeler, "u_UseTexture"), _tex)
		
			model.Draw();
		
		shader_reset();
	}
	
	static FromFile = function(_file)
	{
		var _timer = get_timer();
		
		if (!file_exists(_file))
		{
			__pp_trace($"Aborting load. Could not find file: {_file}");
			return false;
		}
		
		var _fileBuffer = buffer_load(_file);
		if (_fileBuffer == -1)
		{
			__pp_trace("Aborting load. Something went wrong when loading the file");
			return false;
		}
		
		var _string	= buffer_read(_fileBuffer, buffer_string);
			_string = string_replace_all(_string, " ", "");
			_string = string_replace_all(_string, "\n", "");
			_string = string_replace_all(_string, "\t", "");
			_string = string_replace_all(_string, "\r", "");
			_string = string_replace_all(_string, "\f", "");
			_string = string_replace_all(_string, "\v", "");
			
		var _headerEnd		= string_pos_ext("{", _string, 0);
		var _header			= string_copy(_string, 0, _headerEnd -1);
		var _headerValues	= string_split(_header, ";");
		
		if (_headerValues[0] != PICOCAD_STAMP)
		{
			__pp_trace("Aborting load. Doesn't seem to be a valid picoCAD file.");
			return false;
		}
		
		name			= _headerValues[1];
		var _zoomLvl	= real(_headerValues[2]);
		bgColor			= PICOCAD_COLORS[real(_headerValues[3])];
		var _alpha		= real(_headerValues[4]);
		
		// Remove header and split into data (meshes) and texture
		var _body		= string_split(string_delete(_string, 1, _headerEnd), "%");
		var _dataStr	= _body[0];
		var _texStr		= _body[1];
		
		var _picoDat	= PP_ParsePicoDAT(_dataStr);
		var _picoTex	= PP_ParsePicoTEX(_texStr, _alpha);
		
		model = __PP_AssembleModel(_picoDat);
		model.texture = _picoTex;
		
		_timer = (get_timer() - _timer) / 1000;
		__pp_trace($"picoCAD Model -{name}- loaded in {_timer} ms ({_timer / 1000} sec)");
		return self;
	}
	
	static PP_ParsePicoDAT = function(_dataString)
	{
		struct_set(self, "index", 0);
			var _data = __PP_ReadObject(_dataString);
		struct_remove(self, "index");
		return _data;
	}
	
	static PP_ParsePicoTEX = function(_texString, _alpha)
	{
		var _len			= PICOCAD_TEXTURE_WIDTH * PICOCAD_TEXTURE_HEIGHT;
		var _imageBuffer	= buffer_create(_len * 4, buffer_fixed, 1);

		for (var i = 0; i < _len; i++)
		{
			var _hexVal = string_char_at(_texString, i + 1);
			if (_hexVal == "")
				continue;
				
			var _val = real($"0x{_hexVal}");
			var _col = PICOCAD_COLORS[_val];
			
			buffer_write(_imageBuffer, buffer_u8, color_get_red(_col));
			buffer_write(_imageBuffer, buffer_u8, color_get_green(_col));
			buffer_write(_imageBuffer, buffer_u8, color_get_blue(_col));
			buffer_write(_imageBuffer, buffer_u8, _val == _alpha ? 0 : 255);
		}
		
		var _surface = surface_create(PICOCAD_TEXTURE_WIDTH, PICOCAD_TEXTURE_HEIGHT);
		surface_set_target(_surface);
			draw_clear_alpha(c_white, 0);
		surface_reset_target();
		
		// Create Image
		buffer_set_surface(_imageBuffer, _surface, 0);
			var _spr = sprite_create_from_surface(_surface, 0, 0, PICOCAD_TEXTURE_WIDTH, PICOCAD_TEXTURE_HEIGHT, false, false, 0, 0);
		surface_free(_surface);
		
		buffer_delete(_imageBuffer);
		return _spr;
	}
}