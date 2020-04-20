//
//  HashAlgorithm.swift
//  HashAlgorithm
//
//  Copyright 2020 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import CommonCrypto
import Foundation

/**
 Provides a convenient interface to the one-shot hashing functions provided by CommonCrypto. The MD2, MD4, and MD5 algorithms are excluded because they are cryptographically broken and have been deprecated by Apple.
 */
public enum HashAlgorithm {

    case SHA1
    case SHA224
    case SHA256
    case SHA384
    case SHA512

    /// The appropriate digest length for this algorithm.
    private var digestLength: Int32 {
        switch self {
        case .SHA1:   return CC_SHA1_DIGEST_LENGTH
        case .SHA224: return CC_SHA224_DIGEST_LENGTH
        case .SHA256: return CC_SHA256_DIGEST_LENGTH
        case .SHA384: return CC_SHA384_DIGEST_LENGTH
        case .SHA512: return CC_SHA512_DIGEST_LENGTH
        }
    }

    /// The CommonCrypto hash function signature.
    typealias HashFunction = (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?

    /// The appropriate hash function for each algorithm.
    private var hashFunction: HashFunction {
        switch self {
        case .SHA1:   return CC_SHA1
        case .SHA224: return CC_SHA224
        case .SHA256: return CC_SHA256
        case .SHA384: return CC_SHA384
        case .SHA512: return CC_SHA512
        }
    }

    /**
     Computes the digest of the specified string. Converts the `String` to a `Data` value (via `Data(messageString.utf8)`) which is then passed to the `HashAlgorithm.digest(_:)` function.

     We use `Data(messageString.utf8)` instead of `messageString.data(using: .utf8)` as the latter will fail on an invalid string, returning `nil`. The former will gracefully handle an invalid string. See [this discussion on the Swift forum](https://forums.swift.org/t/can-encoding-string-to-data-with-utf8-fail/22437) for further details.

     - Parameter messageString: Computes the digest of the UTF-8 encoding of this string.

     - Returns: A `Digest` value containing the computed digest.
     */
    public func digest(_ messageString: String) -> Digest {
        return digest(Data(messageString.utf8))
    }

    /**
     Computes the digest of the specified byte buffer.

     - Parameter messageData: Computers the digest of this byte buffer.

     - Returns: A `Digest` value containing the computed digest.
     */
    public func digest(_ messageData: Data) -> Digest {
        var digestData = Data(count: Int(digestLength))

        digestData.withUnsafeMutableBytes { (digestBuffer: UnsafeMutableRawBufferPointer) -> Void in
            messageData.withUnsafeBytes { (messageBuffer: UnsafeRawBufferPointer) -> Void in
                _ = hashFunction(messageBuffer.baseAddress,
                                 CC_LONG(messageBuffer.count),
                                 digestBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self))
            }
        }

        return Digest(data: digestData)
    }
}

/**
 Contains the result of the `HashAlgorithm.digest(_:)` operation. This is simply a wrapper around a `Data` value that provides a `description` property containing a hexadecimal representation of the `Data` value.
 */
public struct Digest: CustomStringConvertible, Codable, Hashable, Equatable {

    /// The byte buffer containing the digest.
    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    /// Returns the byte buffer formatted as a hexadecimal string (i.e., two characters `[0-9a-f]` per byte).
    public var description: String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
