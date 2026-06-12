FROM thatzokay/rpi-bookworm-base:latest AS build

ENV DEBIAN_FRONTEND=noninteractive

# ===== base dependencies =====
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    m4 \
    pkg-config \
    ca-certificates \
    opam \
    libasound2-dev \
    libfftw3-dev \
    libssl-dev \
    libmad0-dev \
    libmp3lame-dev \
    libvorbis-dev \
    libogg-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libtag1-dev \
    zlib1g-dev \
    libcurl4-gnutls-dev \
    libpcre2-dev \
 && rm -rf /var/lib/apt/lists/*

# ===== ARMv6 safety flags =====
ENV CFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV CXXFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard -fpermissive"
ENV OCAMLPARAM="safe-string=1,_"

# ===== OCaml + Liquidsoap =====
RUN opam init --disable-sandboxing -y && \
    opam switch create 4.14.0 ocaml-base-compiler.4.14.0 && \
    eval $(opam env) && \
    opam update && \
    opam install -y \
      ffmpeg \
      taglib \
      mad \
      vorbis \
      lame \
      liquidsoap

WORKDIR /app

# ===== export just the liquidsoap binary =====
FROM scratch AS export
COPY --from=build /root/.opam/4.14.0/bin/liquidsoap /liquidsoap