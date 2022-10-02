FROM ghcr.io/proganon/srvpl:v1.0.1
RUN swipl -g "pack_install(canny_tudor, [interactive(false)])"
