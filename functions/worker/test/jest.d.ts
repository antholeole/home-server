declare namespace jest {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  interface Matchers<R, T> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    toThrowStatusError: T extends () => Promise<any> | any
    ? (status: number, message?: string) => Promise<CustomMatcherResult>
    : 'Expected contents of "expect" to be a function returning a value or promise'
  }
}