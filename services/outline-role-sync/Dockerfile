FROM denoland/deno:2.7.14@sha256:564e989f4a93371e70fd8720e5dbe3e027fd4a0daad71a2b008008596ffa6492

WORKDIR /app

COPY deno.json .
COPY src/ src/

RUN deno cache src/main.ts

USER deno

EXPOSE 8080

CMD ["deno", "run", "--allow-net", "--allow-env", "src/main.ts"]
