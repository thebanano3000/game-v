/// @description Inicialización completa del jugador

// ==================== CONSTANTES DE MOVIMIENTO ====================
#macro MOVE_WALK_SPEED 2.5
#macro MOVE_RUN_SPEED 5.0
#macro MOVE_CROUCH_SPEED 1.2
#macro MOVE_WALLSLIDE_SPEED 1.5
#macro MOVE_DASH_SPEED 8.0

#macro JUMP_FORCE -11
#macro JUMP_WALL_FORCE_X 6
#macro JUMP_WALL_FORCE_Y -10
#macro GRAVITY 0.5
#macro MAX_FALL_SPEED 10

#macro DASH_DURATION 12
#macro DASH_COOLDOWN 30
#macro DOUBLE_TAP_TIME 15

#macro COYOTE_TIME 6
#macro JUMP_BUFFER 5

// ==================== ESTADOS ====================
enum PLAYER_STATE {
    IDLE,
    WALK,
    RUN_START,
    RUN,
    CROUCH,
    CROUCH_WALK,
    JUMP,
    FALL,
    WALLSLIDE,
    DASH
}

// ==================== VARIABLES DE MOVIMIENTO ====================
state = PLAYER_STATE.IDLE;
hsp = 0;
vsp = 0;
facing = 1;

on_ground = false;
on_wall = false;
wall_direction = 0;

double_tap_timer = 0;
last_direction = 0;
can_run = false;

dash_timer = 0;
dash_cooldown_timer = 0;
dash_direction = 1;

is_crouching = false;

coyote_timer = 0;
jump_buffer = 0;

// ==================== SPRITES VISUALES ====================
sprite_idle = spr_player_idle;
sprite_walk = spr_player_walk;
sprite_run_start = spr_player_run_start;
sprite_run = spr_player_run;
sprite_crouch = spr_player_crouch;
sprite_crouch_walk = spr_player_crouch_walk;
sprite_dash = spr_player_dash;
sprite_wallslide = spr_player_wallslide;
sprite_jump = spr_player_jump;

// ==================== MÁSCARAS DE COLISIÓN ====================
mask_index_normal = spr_player_mask;
mask_index_crouch = spr_player_mask_crouch;
mask_index = mask_index_normal;

// ==================== CONFIGURACIÓN DE SPRITE ====================
image_speed = 1;