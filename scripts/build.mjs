import { spawnSync } from "node:child_process"
import { fileURLToPath } from "node:url"

// Prisma validates datasource env names during client generation. Supply harmless
// build-only placeholders when Vercel has not injected DB URLs at build time.
// Real database URLs must still be configured in Vercel for runtime operations.
const env = { ...process.env }
const buildOnlyUrl = "postgresql://build:build@127.0.0.1:5432/build?schema=public"
env.DATABASE_URL ||= buildOnlyUrl
env.DIRECT_URL ||= env.DATABASE_URL || buildOnlyUrl

const prismaCli = fileURLToPath(new URL("../node_modules/prisma/build/index.js", import.meta.url))
const nextCli = fileURLToPath(new URL("../node_modules/next/dist/bin/next", import.meta.url))

for (const [label, args] of [
  ["Prisma Client generation", [prismaCli, "generate"]],
  ["Next.js production build", [nextCli, "build"]],
]) {
  const result = spawnSync(process.execPath, args, { env, stdio: "inherit" })
  if (result.error) {
    console.error(label + " could not start:", result.error.message)
    process.exit(1)
  }
  if (result.status !== 0) process.exit(result.status ?? 1)
}
