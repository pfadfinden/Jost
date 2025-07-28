FROM python:3.12-bookworm
COPY --from=ghcr.io/astral-sh/uv:0.8.3 /uv /uvx /bin/

RUN curl -L -O https://github.com/source-foundry/ttfautohint-build/archive/v1.8.3.2.tar.gz \
    && tar -xzvf v1.8.3.2.tar.gz \
    && cd ttfautohint-build-1.8.3.2 \
    && make

# Change the working directory to the `app` directory
WORKDIR /app

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

ENV PATH="/app/.venv/bin:/root/ttfautohint-build/local/bin/:$PATH"

# Copy the project into the image
ADD . /app

# Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

CMD ["/app/scripts/build-alternative-charset.sh"]