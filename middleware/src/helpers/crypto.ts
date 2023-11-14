const charset = 
    '123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()?'


export const cryptoRandomString = (len: number): string => {
    const values = new Uint32Array(len)
    crypto.getRandomValues(values)
    let result = ''

    for (let i = 0; i < len; i++) {
        result += charset[values[i] % charset.length]
    }

    return result
}
