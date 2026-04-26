FROM denoland/deno:2.7.12@sha256:9c47e8b8fa41e91fe2dd1448888244a56c4ec90124333d5341319b043a3a6ca0

WORKDIR /app

COPY deno.json .
COPY src/ src/

RUN deno cache src/main.ts

USER deno

EXPOSE 8080

CMD ["deno", "run", "--allow-net", "--allow-env", "src/main.ts"]
