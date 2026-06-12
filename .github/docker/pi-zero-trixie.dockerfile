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
    libmp3lame-dev \
    libflac-dev \
    libogg-dev \
    zlib1g-dev \
    libcurl4-gnutls-dev \
    libpcre3-dev \
 && rm -rf /var/lib/apt/lists/*

# ===== ARMv6 safety flags (IMPORTANT) =====
ENV CFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV CXXFLAGS="-marm -march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV OCAMLPARAM="safe-string=1,_"

# ===== OCaml + Liquidsoap =====
# ffmpeg/taglib/mad/vorbis are omitted: ffmpeg segfaults under QEMU
# user-mode emulation (likely a NEON/VFP codec-init path unsupported by
# QEMU's armv6 TCG) and taglib.0.3.10's C++ stubs depend on taglib1 APIs
# removed in trixie's taglib2 headers. flac covers FLAC decoding and lame
# covers MP3 output, which is all that's needed for FLAC playback.
RUN opam init --disable-sandboxing -y && \
    opam switch create 4.14.0 ocaml-base-compiler.4.14.0 && \
    eval $(opam env) && \
    opam update && \
    opam install -y \
      flac \
      lame \
      liquidsoap

WORKDIR /app

# ===== export just the liquidsoap binary =====
FROM scratch AS export
COPY --from=build /root/.opam/4.14.0/bin/liquidsoap /liquidsoap
