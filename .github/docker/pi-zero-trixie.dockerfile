FROM thatzokay/rpi-trixie-base:latest AS build

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
    zlib1g-dev \
    libcurl4-gnutls-dev \
    libpcre3-dev \
 && rm -rf /var/lib/apt/lists/*

# ===== ARMv6 safety flags (IMPORTANT) =====
ENV CFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV CXXFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV OCAMLPARAM="safe-string=1,_"

# ===== OCaml + Liquidsoap =====
# taglib.0.3.10's C++ stubs depend on taglib1 APIs (TagLib::uint,
# FileRef::create) that were removed in the taglib2 headers shipped in
# trixie, and there is no taglib2-compatible ocaml-taglib release.
# Metadata is still available via the ffmpeg decoder, so taglib is dropped.
RUN opam init --disable-sandboxing -y && \
    opam switch create 4.14.0 ocaml-base-compiler.4.14.0 && \
    eval $(opam env) && \
    opam update && \
    opam install -y \
      ffmpeg \
      mad \
      vorbis \
      lame \
      liquidsoap

WORKDIR /app

# ===== export just the liquidsoap binary =====
FROM scratch AS export
COPY --from=build /root/.opam/4.14.0/bin/liquidsoap /liquidsoap
