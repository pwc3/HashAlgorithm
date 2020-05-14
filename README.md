# HashAlgorithm

Using `CommonCrypto` directly, this is how you compute a cryptographic hash:

```swift
import CommonCrypto
import Foundation

// Compute the digest of this string:
let messageString = "The quick brown fox jumps over the lazy dog"

// Convert the string to a byte array.
let messageData = Data(messageString.utf8)

// Compute the hash using CommonCrypto.
var digestData = Data(count: Int(CC_SHA224_DIGEST_LENGTH))
digestData.withUnsafeMutableBytes { (digestBuffer: UnsafeMutableRawBufferPointer) -> Void in
    messageData.withUnsafeBytes { (messageBuffer: UnsafeRawBufferPointer) -> Void in
        _ = CC_SHA224(messageBuffer.baseAddress,
                      CC_LONG(messageBuffer.count),
                      digestBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self))
    }
}

// Convert the digestData byte buffer into a hex string.
let digestString = digestData.map { String(format: "%02hhx", $0) }.joined()

// prints 730e109bd7a8a32b1cb9d9a09aa2325d2430587ddbc0c38bad911525
print(digestString)
```

Using this library, this is how you compute a cryptographic hash:

```swift
import Foundation
import HashAlgorithm

// Compute the digest of this string:
let messageString = "The quick brown fox jumps over the lazy dog"
let digest = HashAlgorithm.SHA224.digest(messageString)

// prints 730e109bd7a8a32b1cb9d9a09aa2325d2430587ddbc0c38bad911525
print(digest)
```

