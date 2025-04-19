var _change = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
fileIndex = clamp(fileIndex + _change, 0, array_length(files) - 1);

if (_change != 0)
	ChangeBG();
	
if (keyboard_check_pressed(vk_f1))
	useTextures = !useTextures;
	
if (keyboard_check_pressed(vk_f2))
{
	resIndex = (resIndex + 1) % 4;
	surface_resize(application_surface, resolutions[resIndex][0], resolutions[resIndex][1]);
}

var _windowCenterX = window_get_width() / 2;
var _windowCenterY = window_get_height() / 2;

var _mouseDeltaX = window_mouse_get_x() - _windowCenterX;
var _mouseDeltaY = window_mouse_get_y() - _windowCenterY;

cameraYaw	-= 0.05 * _mouseDeltaX;
cameraPitch -= 0.05 * _mouseDeltaY;
cameraPitch = clamp(cameraPitch, -89, 89);

window_mouse_set(_windowCenterX, _windowCenterY);


var _cameraForwardX		= dcos(cameraYaw) * dcos(cameraPitch);
var _cameraForwardY		= -dsin(cameraYaw) * dcos(cameraPitch);
var _cameraForwardZ		= dsin(cameraPitch);

var _forwardMovement	= keyboard_check(ord("W")) - keyboard_check(ord("S"));
var _strafeMovement		= keyboard_check(ord("A")) - keyboard_check(ord("D"));
var _verticalMovement	= keyboard_check(vk_space) - keyboard_check(vk_shift);

var _sinCameraYaw		= dsin(cameraYaw);
var _cosCameraYaw		= dcos(cameraYaw);

cameraX += 2 * (_forwardMovement * _cosCameraYaw - _strafeMovement * _sinCameraYaw);
cameraY += 2 * (-_forwardMovement * _sinCameraYaw - _strafeMovement * _cosCameraYaw);
cameraZ += 2 * _verticalMovement;

viewMatrix = matrix_build_lookat(
	cameraX, cameraY, cameraZ,
	cameraX + _cameraForwardX, cameraY + _cameraForwardY, cameraZ + _cameraForwardZ,
	0, 0, 1
);

projectionMatrix = matrix_build_projection_perspective_fov(
	90,
	room_width / room_height,
	1,
	3000
);