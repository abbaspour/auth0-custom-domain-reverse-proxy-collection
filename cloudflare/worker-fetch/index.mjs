export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        url.hostname = env.AUTH0_EDGE_LOCATION;

        const newRequest = new Request(url, request);
        newRequest.headers.set('cname-api-key', env.CNAME_API_KEY);

        return await fetch(newRequest);
    }
}