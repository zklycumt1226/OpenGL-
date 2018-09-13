
//#version 300 core
//layout(location = 0) in vec3 position;
attribute vec3 position;
attribute vec2 texcoord;

varying lowp vec2 outTexCoord;

void main(){
    outTexCoord = texcoord;
    gl_Position = vec4(position.x,position.y,position.z,1.0);
}
