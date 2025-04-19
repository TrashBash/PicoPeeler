draw_set_colour(c_black);
draw_set_alpha(0.7);

var _s1	 = "PicoPeeler " + PICOPEELER_VERSION + " - Trash Bash";
var	_s2	 = "MODEL (LEFT / RIGHT to change):\n"
	_s2 += $"{fileIndex + 1} / {array_length(files)}: "
	_s2	+= files[fileIndex] + "\n\n";
	_s2 += "- F1 to toggle Textures\n"
	_s2 += $"- F2 to toggle Resolutions (current: {resolutions[resIndex][0]}, {resolutions[resIndex][1]})"

draw_sprite_stretched(spr_box, 0, 12, 12, 24 + max(string_width(_s1), string_width(_s2)), 24 + string_height(_s2) + 64);
draw_text(17 + 68, 19, _s1);
draw_text(17, 96, _s2);
draw_set_alpha(1);
draw_sprite_stretched(PFP, 0, 15, 15, 64, 64);
draw_set_colour(c_white);
draw_text(15 + 68, 17, _s1);
draw_text(15, 94, _s2);