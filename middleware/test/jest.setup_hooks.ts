import { StatusError } from 'itty-router-extras'
import { MockKvs } from './fixtures/mock_kvs'
import { enableFetchMocks } from 'jest-fetch-mock'
import atob from 'atob'
import btoa from 'btoa'

global.btoa = btoa
global.atob = atob

global.afterEach(() => {
  const kvs = [PUBLIC_KEYS, REFRESH_TOKENS];

  (kvs as unknown as MockKvs[]).forEach(kv => kv.clear())
})


global.beforeAll(() => {
  enableFetchMocks()

  process.on('unhandledRejection', (err) => {
    fail(err)
  })

  expect.extend({
    async toThrowStatusError(resp: () => (Promise<Response> | Response), expected: number, message: string): Promise<jest.CustomMatcherResult> {
      try {
        await resp()
      } catch (e: unknown) {
        if (!(e instanceof StatusError)) {
          return {
            message: () => `handler threw ${JSON.stringify(e, null, '\t')} instead of StatusError`,
            pass: false
          }
        }

        const statusError = e as StatusError

        if (statusError.status != expected) {
          return {
            message: () => `handler threw status ${statusError.status} (${statusError.message}), not ${expected}`,
            pass: false
          }
        }

        if (message && statusError.message != message) {
          return {
            message: () => `handler threw status ${statusError.status} with incorrect message (${statusError.message}), not ${message}`,
            pass: false
          }
        }

        return {
          message: () => 'pass',
          pass: true
        }
      }
      return {
        message: () => 'handler did not throw',
        pass: false,
      }
    },
  })
})