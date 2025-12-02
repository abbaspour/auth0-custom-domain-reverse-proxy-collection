/**
 * Copyright (c) Auth0 Product Architecture Team - https://auth0.com
 * Author: Amin Abbaspour
 */
import {Context, Hono} from 'hono';

/**
 * Environment variables interface for the worker
 *
 * CNAME_API_KEY: API key for the Auth0 custom domain
 * AUTH0_EDGE_LOCATION: Hostname of the backend Auth0 edge location
 */
interface Env {
    Bindings: {
        CNAME_API_KEY: string;
        AUTH0_EDGE_LOCATION: string;
    };
}

const app = new Hono<Env>();

app.onError((err, c) => {
    console.log(`stack trace: ${err.stack}`);
    return c.text(`Internal Server Error: ${err.message}`, 500);
});

async function proxy(c: Context<Env>): Promise<Response> {
    const request = new Request(c.req.raw);
    const url = new URL(request.url);
    url.hostname = c.env.AUTH0_EDGE_LOCATION;
    request.headers.set('cname-api-key', c.env.CNAME_API_KEY);
    return await fetch(url, request);
}

app.all('/*', async (c) => {
    return proxy(c);
});

// noinspection JSUnusedGlobalSymbols
export default app;
