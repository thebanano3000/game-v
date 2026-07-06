/// @description Dibujar jugador con sombra

draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 15, bbox_bottom - 5, x + 15, bbox_bottom + 5, false);
draw_set_alpha(1);
draw_set_color(c_white);

draw_self();

// Debug (quitar en versión final)
/*
draw_set_color(c_red);
draw_text(x, y - 50, "State: " + string(state));
draw_text(x, y - 65, "HSP: " + string(hsp));
draw_text(x, y - 80, "VSP: " + string(vsp));
draw_text(x, y - 95, "On Ground: " + string(on_ground));
draw_set_color(c_white);
*/