package utils

import (
	"math/rand"
	"time"
	"unsafe"
)

// To stupid to implement this ultra fast random 36 char ID generator on my own.
// Copied from https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go
// Enhanced by ChatGPT.
func GenerateID() string {
	const idLength int = 36
	const letterBytes string = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const letterIdxBits int = 6
	const letterIdxMask int = 1 << letterIdxBits - 1
	const letterIdxMax int = 63 / letterIdxBits

	var src = rand.NewSource(time.Now().UnixNano())

	b := make([]byte, idLength)

	for i, cache, remain := idLength - 1, src.Int63(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = src.Int63(), letterIdxMax
		}
		if idx := int(cache & int64(letterIdxMask)); idx < len(letterBytes) {
			b[i] = letterBytes[idx]
			i--
		}
		cache >>= letterIdxBits
		remain--
	}

	return *(*string)(unsafe.Pointer(&b))
}