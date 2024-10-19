#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

/* ------------------------------------------------------------------- */
//   Sliding Titles v1.0 by @trplnr 
/*
    CONFIGURATION:
      TITLE_OFFSET - Determines how close it is to the top.
                     Approaching 0 puts it higher,
                     Approaching 1 puts it more at the center.

      TITLE SCALE  - Size of the title.
                     Approaching 0 makes it smaller,
                     Approaching 1 makes it bigger.

      NO_FADE      - Determines if it does the fade animation or not.
                     false = Fade off,
                     true = Fade on.
*/
float TITLE_OFFSET = 0.225;
float TITLE_SCALE = 0.75;
bool FADE = false;

/* ------------------------------------------------------------------- */

float guiScale = (round(ScreenSize.x * ProjMat[0][0] / 2));

void main() {
    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;

    mat4 TransformMat = mat4(1.0);
    
    // Select title text
    if (Position.z == 2400.12 || Position.z == 2400.06 || Position.z == 2400.0) {
        // renamed for convenience
        float t = vertexColor.a;

        // ease in out
        float pos = t * t * (3.0 - 2.0 * t);

        // how close it is to the top of the screen
        float offset = TITLE_OFFSET * TITLE_SCALE;

        // its 1.1 to account for subtitle, tries its best to scale with gui scale
        float finalPos = 1.1 - pos * offset * guiScale; 

        // math
        TransformMat = mat4(mat3(TITLE_SCALE));
        TransformMat[3].y = finalPos;
        
        /* All of that unpacked:
            
            TITLE_SCALE, 0.0, 0.0, 0.0,
            0.0, TITLE_SCALE, 0.0, 0.0,
            0.0, 0.0, TITLE_SCALE, 0.0,
            0.0, finalPos, 0.0, 1.0
            
        */

        // no fade plz
        if (!FADE) {
            vertexColor.a = 1.0;
        }
    }

    gl_Position = TransformMat * ProjMat * ModelViewMat * vec4(Position, 1.0);
}
