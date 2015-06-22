//
//  Texture.swift
//  SwiftNES
//
//  Created by Articulate on 5/27/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Cocoa
import OpenGL

let textureSize = 4096
let textureDim = textureSize / 256
let textureCount = textureDim * textureDim

class Texture {
    var texture: UInt32
    var lookup = [String: Int]()
    var reverse = Array<String>(count: textureCount, repeatedValue: "")
    var access = Array<Int>(count: textureCount, repeatedValue: -1)
    var counter: Int = 0
    var ch: EBChannel = EBChannel(bufferCapacity: 1024)
    
    init() {
        let texture = createTexture()
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), GLint(0), GLint(GL_RGBA),
            GLsizei(textureSize), GLsizei(textureSize),
            0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        self.texture = texture
    }
    
    func purge() {
        while true {
            var path: AnyObject?
            let r = self.ch.tryRecv(&path)
            if r == .OK {
                let pathString = path as! String
                self.lookup.removeValueForKey(pathString)
            } else {
                return
            }
        }
    }
    
    func bind() {
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
    }
    
    func unbind() {
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    func lookup(path: String) -> (x: Float32, y: Float32, dx: Float32, dy: Float32) {
        if let index = self.lookup[path] {
            return self.coord(index)
        } else {
            return self.coord(self.load(path))
        }
    }
    
    func mark(index: Int) {
        self.counter++
        self.access[index] = self.counter
    }
    
    func lru() -> Int {
        var minIndex = 0
        var minValue = self.counter + 1
        for (i, n) in self.access.enumerate() {
            if n < minValue{
                minIndex = i
                minValue = n
            }
        }
        return minIndex
    }
    
    func coord(index: Int) -> (x: Float32, y: Float32, dx: Float32, dy: Float32) {
        let x = Float32(index % textureDim) / Float32(textureDim)
        let y = Float32(index / textureDim) / Float32(textureDim)
        let dx = 1.0 / Float32(textureDim)
        let dy = dx * Float32(240) / Float32(256)
        return (x, y, dx, dy)
    }
    
    func load(path: String) -> Int {
        let index = self.lru()
        self.lookup.removeValueForKey(self.reverse[index])
        self.mark(index)
        self.lookup[path] = index
        self.reverse[index] = path
        let x = Int32((index % textureDim) * 256)
        let y = Int32((index / textureDim) * 256)
        let im = self.loadThumbnail(path)
        let size = im.Rect.Size()
        glTexSubImage2D(GLenum(GL_TEXTURE_2D), 0, x, y, Int32(size.X), Int32(size.Y), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), im.Pix)
        
        return index
    }
    
    func loadThumbnail(romPath: String) -> RGBAImage {
        var name = romPath.lastPathComponent
        name = name.stringByDeletingPathExtension
        name = name.stringByReplacingOccurrencesOfString("_", withString: " ", options: .LiteralSearch, range: nil)
        name = name.capitalizedString
        
        let im = createGenericThumbnail(name)
        
        return im
    }
    
    func downloadThumbnail(romPath: String, hash: String) -> Bool {
        return false
    }
}
