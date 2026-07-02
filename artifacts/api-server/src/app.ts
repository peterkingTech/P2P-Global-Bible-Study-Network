import express, { type Express } from "express";
import cors from "cors";
import pinoHttp from "pino-http";
import { createProxyMiddleware } from "http-proxy-middleware";
import router from "./routes";
import { logger } from "./lib/logger";

const app: Express = express();

app.use(
  pinoHttp({
    logger,
    serializers: {
      req(req) {
        return {
          id: req.id,
          method: req.method,
          url: req.url?.split("?")[0],
        };
      },
      res(res) {
        return {
          statusCode: res.statusCode,
        };
      },
    },
  }),
);
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api", router);

// ── Flutter dev-server proxy ──────────────────────────────────────────────────
// Forward all non-/api requests to the Flutter web dev server so the Replit
// preview can display the app at the root URL.
const flutterTarget = `http://localhost:${process.env["FLUTTER_PORT"] ?? "8082"}`;

app.use(
  createProxyMiddleware({
    target: flutterTarget,
    changeOrigin: true,
    ws: true,
    on: {
      error: (_err, _req, res) => {
        // Flutter dev server not yet ready — return a friendly retry page.
        if (res && "writeHead" in res) {
          (res as import("http").ServerResponse).writeHead(503, {
            "Content-Type": "text/html",
            "Retry-After": "3",
          });
          (res as import("http").ServerResponse).end(
            `<!DOCTYPE html><html><head><meta charset="utf-8">
            <meta http-equiv="refresh" content="3">
            <title>Starting…</title></head>
            <body style="font-family:sans-serif;display:flex;align-items:center;
              justify-content:center;height:100vh;margin:0;background:#06110D;color:#9FE1CB">
            <p>Flutter app is starting up… refreshing in 3 s</p></body></html>`,
          );
        }
      },
    },
  }),
);

export default app;
