class MockRequest {
    private body: Record<string, unknown>
    public headers: Map<string, unknown>
    

    async json(): Promise<Record<string, unknown>> {
        return this.body
    }

    constructor(body: Record<string, unknown>, headers: Record<string, unknown>) {
        this.body = body
        this.headers = new Map(Object.entries(headers))
    }
}

export const mockRequest = (body: Record<string, unknown>, headers: Record<string, unknown> = {}): Request => {
    return new MockRequest(body, headers) as unknown as Request
}
