# Build stage - utilise une image officielle Rust pour un build reproductible
FROM rust:1.82-bookworm AS builder

# Variables pour build reproductible
ENV CARGO_INCREMENTAL=0
ENV RUSTFLAGS="-C target-feature=+crt-static"

WORKDIR /app

# Copie les fichiers de dépendances d'abord (cache layer)
COPY Cargo.toml Cargo.lock* ./

# Crée un dummy main.rs pour builder les dépendances
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release --target x86_64-unknown-linux-gnu || true
RUN rm -rf src

# Copie le vrai code source
COPY src ./src

# Build final avec timestamp fixe pour reproductibilité
RUN touch -t 202401010000 src/main.rs && \
    cargo build --release --target x86_64-unknown-linux-gnu

# Runtime stage - image minimale
FROM gcr.io/distroless/cc-debian12

WORKDIR /app

# Copie le binaire depuis le builder
COPY --from=builder /app/target/x86_64-unknown-linux-gnu/release/poc-sig /app/poc-sig

EXPOSE 3000

ENTRYPOINT ["/app/poc-sig"]
