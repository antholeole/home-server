FROM rust:1.67

WORKDIR /src

RUN cargo install cargo-watch
CMD ["cargo", "watch", "-x", "run", "-w", "src"]