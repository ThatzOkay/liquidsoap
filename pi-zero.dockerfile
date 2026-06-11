FROM debian:bullseye

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
    libcurl4-openssl-dev \
    libmad0-dev \
    libmp3lame-dev \
    libvorbis-dev \
    libogg-dev \
 && rm -rf /var/lib/apt/lists/*

# ===== ARMv6 safety flags (IMPORTANT) =====
ENV CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=hard"
ENV OCAMLPARAM="safe-string=1"

# ===== OCaml + Liquidsoap =====
RUN opam init --disable-sandboxing -y && \
    opam switch create 4.14.0 && \
    eval $(opam env) && \
    opam install liquidsoap -y

WORKDIR /app
COPY stream.liq /app/stream.liq

CMD ["liquidsoap", "/app/stream.liq"]
