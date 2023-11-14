import { Crypto } from '@peculiar/webcrypto'
import makeServiceWorkerEnv from 'service-worker-mock'
import { MockKvs } from './fixtures/mock_kvs'
import encryptWorkersKv from 'encrypt-workers-kv'


declare const global: Record<string, unknown>

// eslint-disable-next-line no-undef
global.crypto = new Crypto()
Object.assign(global, makeServiceWorkerEnv())

global.PUBLIC_KEYS = new MockKvs()
global.REFRESH_TOKENS = new MockKvs()
global.encryptWorkersKv = encryptWorkersKv
global.HASURA_ENDPOINT = 'asdadi19042398489238499'
global.WEBHOOK_SECRET_KEY = 'asdkaiskdaisk'

