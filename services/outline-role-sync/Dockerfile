FROM denoland/deno:2.8.3@sha256:438618d8c0678c3154fc77ad6edad61f38cbc42803a181e7908d3e2c9e645022

WORKDIR /app

COPY deno.json .
COPY src/ src/

RUN deno cache src/main.ts

USER deno

EXPOSE 8080

CMD ["deno", "run", "--allow-net", "--allow-env", "src/main.ts"]
