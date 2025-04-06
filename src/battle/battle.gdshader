shader_type canvas_item;

uniform float SoftRange = 0.02;   // 境目を半透明にする幅
uniform float Value = 0.0;        // フェード値
uniform sampler2D Mask;

void fragment()
{
    float rangedValue = Value * (SoftRange * 2.0 + 1.0) - SoftRange;
    float maskValue = texture(Mask, UV).r;
    float minValue = rangedValue - SoftRange;
    float maxValue = rangedValue + SoftRange;
    float alpha = smoothstep(minValue, maxValue, maskValue);
    COLOR = vec4(vec3(0.0), alpha);
}
