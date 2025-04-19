cameraX		= 180;
cameraY		= 140;
cameraZ		= 110;
cameraYaw	= 105;
cameraPitch	= -25;

useTextures	= true;
resolutions	= [[128, 72], [256, 144], [512, 288], [1280, 720]];
resIndex	= 0;

ChangeBG = function()
{
	var _lID  = layer_get_id("Background");
	var _bgID = layer_background_get_id(_lID);
	layer_background_blend(_bgID, models[fileIndex].bgColor);
}

fileIndex	= 0;
files		=
[
	"chunky_tank.txt",
	"primitives.txt",
	"vehicles.txt",
	"submarine.txt",
	"toaster.txt"
];

var _l = array_length(files);
models = array_create(_l);

for (var i = 0; i < _l; i++) 
	models[i] = new PicoPeeler_Model().FromFile(files[i]);

PFP = sprite_add("https://unavatar.io/twitter/traashbash", 0, false, false, 0, 0);

display_set_gui_maximise();
display_mouse_set(window_get_width() / 2, window_get_height() / 2);
ChangeBG();