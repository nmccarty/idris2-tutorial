FROM docker.io/opensuse/tumbleweed:latest

# Install dependencies
RUN zypper ref && \
    zypper --non-interactive install --allow-downgrade -t pattern devel_basis && \
    zypper --non-interactive install \
        chezscheme \
        git \
        rakudo \
        gmp-devel \
        nodejs22 \
        rustup && \
    zypper clean

# Install pack (Idris2 package manager)
RUN echo "scheme" | bash -c "$(curl -fsSL https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash)"

# Add the pack store bin to the path
ENV PATH="/root/.pack/bin:$PATH"

# Update pack
RUN pack update-db && pack switch latest

# Install katla for code highlighting
RUN pack install-app katla

# Add the raku bin to the path
ENV PATH="/root/.raku/bin:/usr/share/perl6/site/bin:$PATH"

# Install zef
RUN git clone https://github.com/ugexe/zef.git /root/.zef-src && \
    cd /root/.zef-src && \
    raku -I. bin/zef install .

# Update zef db
RUN zef update

# Install raku dependencies
RUN zef install File::Temp && \
    zef install Shell::Command && \
    zef install paths

# Install iutils
RUN git clone https://git.stranger.systems/Idris/iutils-raku.git /home/developer/.iutils-src && \
    cd /home/developer/.iutils-src && \
    zef install .

# Setup rust
ENV PATH="/root/.cargo/bin:$PATH"
RUN rustup toolchain install stable

# Install mdbook and extensions
RUN cargo install mdbook && \
    cargo install mdbook-alerts
