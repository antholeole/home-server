import { cryptoRandomString } from '../../src/helpers/crypto'

describe('crypto', () => {
    test('crypto random string should return a string with length', () => {
        for (let i = 0; i < 50; i++) {
            expect(cryptoRandomString(i)).toHaveLength(i)
        }
    })
})