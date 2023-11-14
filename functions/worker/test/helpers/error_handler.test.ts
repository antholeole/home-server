import { StatusError } from 'itty-router-extras'
import { errorHandler } from '../../src/helpers/error_handler'


const mockDebugGetter = jest.fn()
jest.mock('../../src/constants', () => ({
   ...jest.requireActual('../../src/constants'),
   get DEBUG() {
      return mockDebugGetter()
   },
}))


describe('test error handler', () => {
   const statusMessage = 'message'

   test('debug should throw', async () => {
      mockDebugGetter.mockReturnValue(true)

      expect(() => errorHandler(new Error(statusMessage)))
         .toThrow(new Error(statusMessage))
   })

   describe('on unknown error', () => {
      const unknownError = new Error(statusMessage)

      beforeEach(() => {
         mockDebugGetter.mockReturnValue(false)
      })

      test('should return 400', async () => {
         expect(await errorHandler(unknownError).json()).toEqual({
            'message': statusMessage,
            'code': 400
         })
      })

      test('should return unown error on no message', async () => {
         expect(await errorHandler(Error()).json()).toEqual({
            'message': 'unknown error',
            'code': 400
         })
      })
   })

   test('should status and message on statusError', async () => {
      const statusCode = 415

      mockDebugGetter.mockReturnValue(false)

      expect(await errorHandler(new StatusError(statusCode, statusMessage)).json()).toEqual({
         'message': statusMessage,
         'code': statusCode
      })
   })
})