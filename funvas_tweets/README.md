# funvas_tweets

Collection of [`funvas`][funvas] animations tweeted [@creativemaybeno][Twitter].  
You can find all of them in the timeline :)

## Shaders

All shaders for animations live in the `shaders/` subdirectory and are named according to their
corresponding animation (e.g. `50.dart`, `50.glsl`, and `50.sprv`). Shaders are written in GLSL
in `shaders/glsl/` and then compiled to SPRV in `shaders/spir-v/` using the following command:

```sh
glslc --target-env=opengl -fshader-stage=frag -o shaders/spir-v/42.sprv shaders/glsl/42.glsl
```

Note that this requires the [Vulkan SDK](https://www.lunarg.com/vulkan-sdk/).
