//
//  Image.swift
//  SwiftNES
//
//  Created by Articulate on 6/2/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift
import Cocoa
// Config holds an image's color model and dimensions.

struct Config {
    var ColorModel: Model
    var Width, Height: Int
}

// Image is a finite rectangular grid of color.Color values taken from a color
// model.
protocol Image: class {
    func ColorModel() -> Model
    func Bounds() -> Rectangle
    func At(x: Int, _ y: Int) -> Color
    func Set(x: Int, _ y: Int, c: Color)
}

class RGBAImage: Image {
    var Pix: [UInt8]
    var Stride: Int
    var Rect: Rectangle
    
    convenience init() {
        self.init(r: ZR)
    }
    
    init(r: Rectangle) {
        self.Rect = r
        self.Stride = r.Dx() * 4
        self.Pix = Array<UInt8>(count: r.Dx() * r.Dy() * 4, repeatedValue: 0)
    }
    
    init(Pix: [UInt8], Stride: Int, Rect: Rectangle) {
        self.Pix = Pix
        self.Stride = Stride
        self.Rect = Rect
    }
    
    convenience init(pngData: [UInt8]) {
        let pngImage = NSImage(data: NSData(bytes: pngData, length: pngData.count))
        if let image = pngImage {
            let imageRep = image.representations[0] as NSImageRep
            let width = Int(imageRep.pixelsWide)
            let height = Int(imageRep.pixelsHigh)
            
            if width < 1 || height < 1 {
                self.init()
                return
            }
            
            let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                pixelsWide: width,
                pixelsHigh: height,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSCalibratedRGBColorSpace,
                bytesPerRow: width * 4,
                bitsPerPixel: 32)!
            let ctx = NSGraphicsContext(bitmapImageRep: rep)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrentContext(ctx)
            image.drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation: .CompositeCopy, fraction: 1.0)
            ctx?.flushGraphics()
            NSGraphicsContext.restoreGraphicsState()
            
            self.init(r:Rectangle(0, 0, width, height))
            
            for var y = 0; y < height; y++ {
                for var x = 0; x < width; x++ {
                    var pixel = Array<Int>(count: 4, repeatedValue: 0)
                    rep.getPixel(&pixel, atX: x, y: y)
                    let color = RGBAColor(UInt8(pixel[0]), UInt8(pixel[1]), UInt8(pixel[2]), UInt8(pixel[3]))
                    self.Set(x, y, c: color)
                }
            }
//            let bitmap = bitmapFromImage(self)
//            print("")
        } else {
            self.init()
        }
    }
    
    func ColorModel() -> Model {
        return RGBAModel
    }
    
    func Bounds() -> Rectangle {
        return self.Rect
    }
    
    func At(x: Int, _ y: Int) -> Color {
        return self.RGBAAt(x, y)
    }
    
    func RGBAAt(x: Int, _ y: Int) -> RGBAColor {
        if !(Point(x, y).In(self.Rect)) {
            return RGBAColor()
        }
        let i = self.PixOffset(x, y)
        return RGBAColor(self.Pix[i + 0], self.Pix[i + 1], self.Pix[i + 2], self.Pix[i + 3])
    }
    
    func PixOffset(x: Int, _ y: Int) -> Int {
        return (y - self.Rect.Min.Y) * self.Stride + (x - self.Rect.Min.X) * 4
    }
    
    func Set(x: Int, _ y: Int, c: Color) {
        if !(Point(x, y).In(self.Rect)) {
            return
        }
        let i = self.PixOffset(x, y)
        let c1 = RGBAModel.Convert(c) as! RGBAColor
        self.Pix[i + 0] = c1.R
        self.Pix[i + 1] = c1.G
        self.Pix[i + 2] = c1.B
        self.Pix[i + 3] = c1.A
    }
    
    func SetRGBA(x: Int, _ y: Int, c: RGBAColor) {
        if !(Point(x, y).In(self.Rect)) {
            return
        }
        let i = self.PixOffset(x, y)
        self.Pix[i + 0] = c.R
        self.Pix[i + 1] = c.G
        self.Pix[i + 2] = c.B
        self.Pix[i + 3] = c.A
    }
    
    func SubImage(var r: Rectangle) -> Image {
        r = r.Intersect(self.Rect)
        if r.Empty() {
            return RGBAImage()
        }
        let i = self.PixOffset(r.Min.X, r.Min.Y)
        return RGBAImage(Pix: [UInt8](self.Pix[i..<self.Pix.count]), Stride: self.Stride, Rect: r)
    }
    
    func Opaque() -> Bool {
        if self.Rect.Empty() {
            return true
        }
        
        var (i0, i1) = (3, self.Rect.Dx() * 4)
        for var y = self.Rect.Min.Y; y < self.Rect.Max.Y; y++ {
            for var i = i0; i < i1; i += 4 {
                if self.Pix[i] != 0xff {
                    return false
                }
            }
            i0 += self.Stride
            i1 += self.Stride
        }
        return true
    }
}

class AlphaImage: Image {
    var Pix: [UInt8]
    var Stride: Int
    var Rect: Rectangle
    
    convenience init() {
        self.init(r: ZR)
    }
    
    init(r: Rectangle) {
        self.Rect = r
        self.Stride = r.Dx()
        self.Pix = Array<UInt8>(count: r.Dx() * r.Dy(), repeatedValue: 0)
    }
    
    init(Pix: [UInt8], Stride: Int, Rect: Rectangle) {
        self.Pix = Pix
        self.Stride = Stride
        self.Rect = Rect
    }
    
    func ColorModel() -> Model {
        return AlphaModel
    }
    
    func Bounds() -> Rectangle {
        return self.Rect
    }
    
    func At(x: Int, _ y: Int) -> Color {
        return self.AlphaAt(x, y)
    }

    func AlphaAt(x: Int, _ y: Int) -> AlphaColor {
        if !(Point(x, y).In(self.Rect)) {
            return AlphaColor()
        }
        let i = self.PixOffset(x, y)
        return AlphaColor(self.Pix[i])
    }
    
    func PixOffset(x: Int, _ y: Int) -> Int {
        return ((y - self.Rect.Min.Y) * self.Stride) + ((x - self.Rect.Min.X) * 1)
    }
    
    func Set(x: Int, _ y: Int, c: Color) {
        if !(Point(x, y).In(self.Rect)) {
            return
        }
        let i = self.PixOffset(x, y)
        let c1 = AlphaModel.Convert(c) as! AlphaColor
        self.Pix[i] = c1.A
    }
    
    func SetAlpha(x: Int, _ y: Int, c: AlphaColor) {
        if !(Point(x, y).In(self.Rect)) {
            return
        }
        let i = self.PixOffset(x, y)
        self.Pix[i] = c.A
    }
    
    func SubImage(var r: Rectangle) -> Image {
        r = r.Intersect(self.Rect)
        if r.Empty() {
            return AlphaImage()
        }
        let i = self.PixOffset(r.Min.X, r.Min.Y)
        return AlphaImage(Pix: [UInt8](self.Pix[i..<self.Pix.count]), Stride: self.Stride, Rect: r)
    }
    
    func Opaque() -> Bool {
        if self.Rect.Empty() {
            return true
        }
        var (i0, i1) = (0, self.Rect.Dx() * 4)
        for var y = self.Rect.Min.Y; y < self.Rect.Max.Y; y++ {
            for var i = i0; i < i1; i++ {
                if self.Pix[i] != 0xff {
                    return false
                }
            }
            i0 += self.Stride
            i1 += self.Stride
        }
        return true
    }
}

