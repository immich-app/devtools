FROM denoland/deno:2.1.4

WORKDIR /app

COPY deno.json .
COPY src/ src/

RUN deno cache src/main.ts

USER deno

EXPOSE 8080

CMD ["deno", "run", "--allow-net", "--allow-env", "src/main.ts"]
