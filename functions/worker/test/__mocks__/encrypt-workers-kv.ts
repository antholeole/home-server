export class NotFoundError extends Error {
    constructor() {
        super()
    }
}

export const putEncryptedKV = async (mockKv: KVNamespace, key: string, value: string, secret: string): Promise<void> => {
    mockKv.put(key, `${value}${secret}`)
}

export const getDecryptedKV = async (mockKv: KVNamespace, key: string, secret: string): Promise<ArrayBuffer> => {
    const value = await mockKv.get(key)

    if (value === null || value == undefined) {
        throw new NotFoundError()
    }

    return new TextEncoder().encode(value.slice(0, -secret.length))
}
