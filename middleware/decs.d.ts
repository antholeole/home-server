declare module 'itty-router-extras' {
    class StatusError extends Error {
        public status: number;

        constructor(statusCode: number, message?: string);
    }

    function status(status: number): Response;
    function json(json: Record<string, unknown>): Response;
}

//declared vars
declare const PUBLIC_KEYS: KVNamespace
declare const REFRESH_TOKENS: KVNamespace

declare const HASURA_PASSWORD: string
declare const HASURA_ENDPOINT: string
declare const WEBHOOK_SECRET_KEY: string
declare const SECRET: string
declare const ENVIRONMENT: string