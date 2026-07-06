/// @description Lógica principal de movimiento

// ==================== INPUT ====================
var _key_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var _key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var _key_down = keyboard_check(vk_down) || keyboard_check(ord("S"));
var _key_jump = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("Z"));
var _key_jump_held = keyboard_check(vk_space) || keyboard_check(ord("Z"));
var _key_dash = keyboard_check_pressed(vk_shift) || keyboard_check_pressed(ord("X"));

var _move_input = _key_right - _key_left;

// ==================== DETECCIÓN DE SUELO Y PAREDES ====================
on_ground = place_meeting(x, y + 1, obj_wall);

on_wall = false;
wall_direction = 0;

if (vsp >= 0 && !on_ground) {
    if (place_meeting(x + 1, y, obj_wall) && _key_right) {
        on_wall = true;
        wall_direction = 1;
    }
    else if (place_meeting(x - 1, y, obj_wall) && _key_left) {
        on_wall = true;
        wall_direction = -1;
    }
}

// ==================== COYOTE TIME Y JUMP BUFFER ====================
if (on_ground) {
    coyote_timer = COYOTE_TIME;
} else {
    coyote_timer = max(0, coyote_timer - 1);
}

if (_key_jump) {
    jump_buffer = JUMP_BUFFER;
} else {
    jump_buffer = max(0, jump_buffer - 1);
}

// ==================== SISTEMA DE DOBLE TAP (CORRER) ====================
if (_move_input != 0) {
    if (_move_input != last_direction && last_direction != 0) {
        if (double_tap_timer > 0) {
            can_run = true;
        }
        double_tap_timer = DOUBLE_TAP_TIME;
    }
    last_direction = _move_input;
} else {
    can_run = false;
    last_direction = 0;
}

double_tap_timer = max(0, double_tap_timer - 1);

if (_move_input == 0) {
    can_run = false;
}

if (keyboard_check(vk_shift)) {
    can_run = true;
}

// ==================== DASH ====================
if (dash_cooldown_timer > 0) dash_cooldown_timer--;

if (_key_dash && dash_cooldown_timer <= 0 && state != PLAYER_STATE.DASH) {
    state = PLAYER_STATE.DASH;
    dash_timer = DASH_DURATION;
    dash_cooldown_timer = DASH_COOLDOWN + DASH_DURATION;
    dash_direction = facing;
    vsp = 0;
}

if (state == PLAYER_STATE.DASH) {
    hsp = dash_direction * MOVE_DASH_SPEED;
    dash_timer--;
    
    if (dash_timer % 3 == 0) {
        var _trail = instance_create_depth(x, y, depth + 1, obj_dash_trail);
        _trail.sprite_index = sprite_index;
        _trail.image_index = image_index;
        _trail.image_xscale = image_xscale;
    }
    
    if (dash_timer <= 0) {
        state = PLAYER_STATE.IDLE;
        hsp = dash_direction * MOVE_WALK_SPEED;
    }
    
    x += hsp;
    
    sprite_index = sprite_dash;
    image_xscale = dash_direction;
    
    exit;
}

// ==================== AGACHARSE CON CAMBIO DE MÁSCARA ====================
if (on_ground && _key_down && state != PLAYER_STATE.DASH) {
    is_crouching = true;
    mask_index = mask_index_crouch;
} else if (!_key_down || !on_ground) {
    var _old_mask = mask_index;
    mask_index = mask_index_normal;
    
    if (!place_meeting(x, y, obj_wall)) {
        is_crouching = false;
    } else {
        mask_index = mask_index_crouch;
    }
}

// ==================== SALTO ====================
var _can_jump = (on_ground || coyote_timer > 0);
var _can_wall_jump = on_wall && !on_ground;

if (jump_buffer > 0 && (_can_jump || _can_wall_jump)) {
    jump_buffer = 0;
    coyote_timer = 0;
    
    if (_can_wall_jump) {
        hsp = -wall_direction * JUMP_WALL_FORCE_X;
        vsp = JUMP_WALL_FORCE_Y;
        facing = -wall_direction;
        state = PLAYER_STATE.JUMP;
    } else {
        vsp = JUMP_FORCE;
        state = PLAYER_STATE.JUMP;
    }
}

if (!_key_jump_held && vsp < JUMP_FORCE * 0.5) {
    vsp = JUMP_FORCE * 0.5;
}

// ==================== MOVIMIENTO HORIZONTAL ====================
if (state != PLAYER_STATE.DASH) {
    var _target_speed = 0;
    
    if (_move_input != 0 && !is_crouching) {
        if (can_run) {
            if (state == PLAYER_STATE.WALK || state == PLAYER_STATE.IDLE) {
                state = PLAYER_STATE.RUN_START;
            } else if (state == PLAYER_STATE.RUN_START && image_index >= image_number - 1) {
                state = PLAYER_STATE.RUN;
            } else if (state != PLAYER_STATE.RUN_START) {
                state = PLAYER_STATE.RUN;
            }
            _target_speed = _move_input * MOVE_RUN_SPEED;
        } else {
            state = PLAYER_STATE.WALK;
            _target_speed = _move_input * MOVE_WALK_SPEED;
        }
        facing = _move_input;
    } else if (_move_input != 0 && is_crouching) {
        _target_speed = _move_input * MOVE_CROUCH_SPEED;
        state = PLAYER_STATE.CROUCH_WALK;
        facing = _move_input;
    } else if (is_crouching) {
        _target_speed = 0;
        state = PLAYER_STATE.CROUCH;
    } else if (!on_ground) {
        if (vsp < 0) state = PLAYER_STATE.JUMP;
        else state = PLAYER_STATE.FALL;
    } else {
        state = PLAYER_STATE.IDLE;
    }
    
    var _accel = on_ground ? 0.4 : 0.15;
    hsp = lerp(hsp, _target_speed, _accel);
}

// ==================== GRAVEDAD Y WALL SLIDE ====================
if (!on_ground && state != PLAYER_STATE.DASH) {
    if (on_wall && vsp > 0) {
        state = PLAYER_STATE.WALLSLIDE;
        vsp = min(vsp, MOVE_WALLSLIDE_SPEED);
        
        if (vsp > 0 && random(1) < 0.3) {
            instance_create_depth(x + wall_direction * 10, y + random(20), depth + 1, obj_dust);
        }
    } else {
        vsp += GRAVITY;
        vsp = min(vsp, MAX_FALL_SPEED);
    }
}

// ==================== APLICAR MOVIMIENTO CON COLISIONES ====================
if (hsp != 0) {
    if (place_meeting(x + hsp, y, obj_wall)) {
        var _step_height = 8;
        if (!place_meeting(x + hsp, y - _step_height, obj_wall)) {
            y -= _step_height;
        } else {
            while (!place_meeting(x + sign(hsp), y, obj_wall)) {
                x += sign(hsp);
            }
            hsp = 0;
        }
    }
    x += hsp;
}

if (vsp != 0) {
    if (place_meeting(x, y + vsp, obj_wall)) {
        while (!place_meeting(x, y + sign(vsp), obj_wall)) {
            y += sign(vsp);
        }
        vsp = 0;
    }
    y += vsp;
}

// ==================== ACTUALIZAR SPRITES ====================
switch (state) {
    case PLAYER_STATE.IDLE:
        sprite_index = sprite_idle;
        break;
    case PLAYER_STATE.WALK:
        sprite_index = sprite_walk;
        break;
    case PLAYER_STATE.RUN_START:
        sprite_index = sprite_run_start;
        break;
    case PLAYER_STATE.RUN:
        sprite_index = sprite_run;
        break;
    case PLAYER_STATE.CROUCH:
        sprite_index = sprite_crouch;
        break;
    case PLAYER_STATE.CROUCH_WALK:
        sprite_index = sprite_crouch_walk;
        break;
    case PLAYER_STATE.JUMP:
    case PLAYER_STATE.FALL:
        sprite_index = sprite_jump;
        break;
    case PLAYER_STATE.WALLSLIDE:
        sprite_index = sprite_wallslide;
        break;
    case PLAYER_STATE.DASH:
        sprite_index = sprite_dash;
        break;
}

if (hsp != 0 && state != PLAYER_STATE.DASH) {
    image_xscale = facing;
}

if (hsp != 0 && on_ground) {
    image_speed = (state == PLAYER_STATE.RUN) ? 1.5 : 1;
} else {
    image_speed = 1;
}