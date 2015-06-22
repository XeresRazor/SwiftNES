//
//  io.swift
//  SwiftNES
//
//  Created by Articulate on 6/4/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

//  MARK: Errors

let ErrShortWrite: Error? = NewError("short write")
let ErrShortBuffer: Error? = NewError("short buffer")
let EOF: Error? = NewError("EOF")
let ErrUnexpectedEOF: Error? = NewError("unexpected EOF")
let ErrNoProgress: Error? = NewError("Multiple Read calls return no data or error")

typealias ByteArray = ArraySlice<UInt8>

//  MARK: Protocols

// Reader is the interface that wraps the basic Read method.
//
// Read reads up to p.capacity bytes into p.  It returns the number of bytes
// read (0 <= n <= p.capacity).  Even if Read
// returns n < p.capacity, it may use all of p as scratch space during the call.
// If some data is available but not p.capacity bytes, Read conventionally
// returns what is available instead of waiting for more.
//
// When Read encounters an error or end-of-file condition after
// successfully reading n > 0 bytes, it returns the number of
// bytes read.
protocol Reader {
    func Read(p: ByteArray) -> (Int, Error?)
}

//  Writes up to p.capacity bytes from p. Returns the number of bytes written
protocol Writer {
    func Write(p: ByteArray) -> (Int, Error?)
}

//  Returns whether or not Close succeeded.
protocol Closer {
    func Close() -> Error?
}

enum Whence: Int {
    case Set = 0, Seek, End
}

//  Seek sets the offset for the next Read or Write to offset, interpreted according to Whence.
//  Returns the new offset.
//  Returning a negative offset means the seek failed (typically -1 will be returned.)
protocol Seeker {
    func Seek(offset: Int64, whence: Whence) -> (Int64, Error?)
}

protocol ReadWriter: Reader, Writer {}

protocol ReadCloser: Reader, Closer {}

protocol WriteCloser: Writer, Closer {}

protocol ReadWriteCloser: Reader, Writer, Closer {}

protocol ReadSeeker: Reader, Seeker {}

protocol WriteSeeker: Writer, Seeker {}

protocol ReadWriteSeeker: Reader, Writer, Seeker {}

protocol ReaderFrom {
    func ReadFrom(r: Reader) -> (Int64, Error?)
}

protocol WriterTo {
    func WriteTo(w: Writer) -> (Int64, Error?)
}

protocol ReaderAt {
    func ReadAt(p: ByteArray, off: Int64) -> (Int, Error?)
}

protocol WriterAt {
    func WriteAt(p: ByteArray, off: Int64) -> (Int, Error?)
}

protocol ByteReader {
    func ReadByte() -> (UInt8, Error?)
}

protocol ByteScanner: ByteReader {
    func UnreadByte() -> Error?
}

protocol ByteWriter {
    func WriteByte(c: UInt8) -> Error?
}


//  MARK: Functions

func ReadAtLeast(r: Reader, buf:ByteArray, min: Int) -> (Int, Error?) {
    if buf.count < min {
        return (0, ErrShortBuffer)
    }
    var n = 0
    var err: Error? = nil
    while n < min && err == nil {
        var nn: Int
        (nn, err) = r.Read(buf[n..<buf.count])
        n += nn
    }
    if n >= min {
        err = nil
    } else if n > 0 && err === EOF {
        err = ErrUnexpectedEOF
    }
    return (n, err)
}

func ReadFull(r: Reader, buf: ByteArray) -> (Int, Error?) {
    return ReadAtLeast(r, buf, buf.count)
}
