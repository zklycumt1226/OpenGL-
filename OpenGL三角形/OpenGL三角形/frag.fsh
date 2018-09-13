
//#version 300 core

//out vec4 color

uniform sampler2D textureImg;
varying lowp vec2 outTexCoord;

void main(){
    
    gl_FragColor = texture2D(textureImg,outTexCoord);
//    gl_FragColor = vec4(1.0,0.0,0.0,1.0);
}
