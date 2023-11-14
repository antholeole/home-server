import { NotFoundError } from '@cloudflare/kv-asset-handler'

export class MockKvs {
    values: Map<string, string> = new Map()

    async get(key: string): Promise<string | null> {
        return this.values.get(key) ?? null
    }

    async put(key: string, value: string): Promise<void> {
        this.values.set(key, value)
    }

    async delete(key: string): Promise<void> {
        if (!this.values.delete(key)) {
            throw new NotFoundError('deleted non-existant key')
        }
    }

    clear(): void {
        this.values.clear()
    }
}


