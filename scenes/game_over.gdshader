shader_type canvas_item;

uniform float height =1.0;
uniform float frequency = 50.0;
uniform float speed = 4.0;

void vertex() {
 VERTEX.y += height * sin((frequency * UV.x) + (speed * TIME));
}