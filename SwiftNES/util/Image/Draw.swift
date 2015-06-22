//
//  Draw.swift
//  SwiftNES
//
//  Created by David Green on 6/2/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

private let m: UInt32 = 1 << 16 - 1

enum Op: Int {
    case Over = 0, Src
}

protocol Drawer {
    func Draw(dst: Image, r: Rectangle, src: Image, sp: Point)
}

private func clip(dst: Image, inout r: Rectangle, src: Image, inout sp: Point, mask: Image?, inout mp: Point) {
    let orig = r.Min
    r = r.Intersect(dst.Bounds())
    r = r.Intersect(src.Bounds().Add(orig.Sub(mp)))
    if mask != nil {
        r = r.Intersect(mask!.Bounds().Add(orig.Sub(mp)))
    }
    
    let dx = r.Min.X - orig.X
    let dy = r.Min.Y - orig.Y
    if dx == 0 && dy == 0 {
        return
    }
    sp.X += dx
    sp.Y += dy
    mp.X += dx
    mp.Y += dy
}

private func processBackward(dst: Image, r: Rectangle, src: Image, sp: Point) -> Bool {
    return dst === src &&
        (r.Overlaps(r.Add(sp.Sub(r.Min))) &&
        sp.Y < r.Min.Y || (sp.Y == r.Min.Y && sp.X < r.Min.X))

}

func Draw(dst: Image, r: Rectangle, src: Image, sp: Point, op: Op) {
    DrawMask(dst, r: r, src: src, sp: sp, mask: nil, mp: Point(), op: op)
}

func DrawMask(dst: Image, var r: Rectangle, src: Image, var sp: Point, mask: Image?, var mp: Point, op: Op) {
    clip(dst, r: &r, src: src, sp: &sp, mask: mask, mp: &mp)
    if r.Empty() {
        return
    }
    
    switch dst {
    case let dst0 as RGBAImage:
        if op == .Over {
            if mask == nil {
                switch src {
                case let src0 as UniformImage:
                    drawFillOver(dst0, r: r, src: src0)
                    return
                case let src0 as RGBAImage:
                    drawCopyOver(dst0, r: r, src: src0, sp: sp)
                    return
                default:
                    break
                }
            } else if let mask0 = mask as? AlphaImage {
                switch src {
                case let src0 as UniformImage:
                    drawGlyphOver(dst0, r: r, src: src0, mask: mask0, mp: mp)
                    return
                default:
                    break
                }
            }
        } else {
            if mask == nil {
                switch src {
                case let src0 as UniformImage:
                    drawFillSrc(dst0, r: r, src: src0)
                    return
                case let src0 as RGBAImage:
                    drawCopySrc(dst0, r: r, src: src0, sp: sp)
                    return
                default:
                    break
                }
            }
        }
        drawRGBA(dst0, r: r, src: src, sp: sp, mask: mask, mp: mp, op: op)
        return
    default:
        break
    }
    var (x0, x1, dx) = (r.Min.X, r.Max.X, 1)
    var (y0, y1, dy) = (r.Min.Y, r.Max.Y, 1)
    if processBackward(dst, r: r, src: src, sp: sp) {
        (x0, x1, dx) = (x1 - 1, x0 - 1, -1)
        (y0, y1, dy) = (y1 - 1, y0 - 1, -1)
    }
    
    var out = RGBAColor()
    var sy = sp.Y + y0 - r.Min.Y
    var my = mp.Y + y0 - r.Min.Y
    for var y = y0; y != y1; (y, sy, my) = (y + dy, sy + dy, my + dy) {
        var sx = sp.X + x0 - r.Min.X
        var mx = mp.X + x0 - r.Min.X
        for var x = x0; x != x1; (x, sx, mx) = (x + dx, sx + dx, mx + dx) {
            var ma = UInt32(m)
            if mask != nil {
                (_, _, _, ma) = mask!.At(mx, my).RGBA()
            }
            switch ma {
            case 0:
                if op == .Over {
                    //  No-op
                } else {
                    dst.Set(x, y, c: TransparentColor)
                }
            case  _ where ma == m && op == .Src:
                dst.Set(x, y, c: src.At(sx, sy))
            default:
                let (sr, sg, sb, sa) = src.At(sx, sy).RGBA()
                if op == .Over {
                    let (dr, dg, db, da) = dst.At(x, y).RGBA()
                    let a = m - (sa * ma / m)
                    out.R = UInt8(((dr * a + sr * ma) / m) >> 8)
                    out.G = UInt8(((dg * a + sg * ma) / m) >> 8)
                    out.B = UInt8(((db * a + sb * ma) / m) >> 8)
                    out.A = UInt8(((da * a + sa * ma) / m) >> 8)
                } else {
                    out.R = UInt8((sr * ma / m) >> 8)
                    out.G = UInt8((sg * ma / m) >> 8)
                    out.B = UInt8((sb * ma / m) >> 8)
                    out.A = UInt8((sa * ma / m) >> 8)
                }
                dst.Set(x, y, c: out)
                
            }
        }
    }
    
}

private func drawFillOver(dst: RGBAImage, r: Rectangle, src: UniformImage) {
    let (sr, sg, sb, sa) = src.RGBA()
    let a = (m - sa) * 0x101
    var i0 = dst.PixOffset(r.Min.X, r.Min.Y)
    var i1 = i0 + r.Dx() * 4
    for var y = r.Min.Y; y != r.Max.Y; y++ {
        for var i = i0; i < i1; i += 4 {
            let dr = UInt32(dst.Pix[i+0])
            let dg = UInt32(dst.Pix[i+1])
            let db = UInt32(dst.Pix[i+2])
            let da = UInt32(dst.Pix[i+3])
            
            let fr = (dr * a / m + sr) >> 8
            let fg = (dg * a / m + sg) >> 8
            let fb = (db * a / m + sb) >> 8
            let fa = (da * a / m + sa) >> 8
            
            dst.Pix[i + 0] = UInt8(fr)
            dst.Pix[i + 1] = UInt8(fg)
            dst.Pix[i + 2] = UInt8(fb)
            dst.Pix[i + 3] = UInt8(fa)
        }
        i0 += dst.Stride
        i1 += dst.Stride
    }
}

private func drawFillSrc(dst: RGBAImage, r: Rectangle, src: UniformImage) {
    let (sr, sg, sb, sa) = src.RGBA()
    var i0 = dst.PixOffset(r.Min.X, r.Min.Y)
    var i1 = i0 + r.Dx() * 4
    for var y = r.Min.Y; y != r.Max.Y; y++ {
        for var i = i0; i < i1; i += 4 {
            let fr = sr >> 8
            let fg = sg >> 8
            let fb = sb >> 8
            let fa = sa >> 8
            
            dst.Pix[i + 0] = UInt8(fr)
            dst.Pix[i + 1] = UInt8(fg)
            dst.Pix[i + 2] = UInt8(fb)
            dst.Pix[i + 3] = UInt8(fa)
        }
        i0 += dst.Stride
        i1 += dst.Stride
    }
}

private func drawCopyOver(dst: RGBAImage, r: Rectangle, src: RGBAImage, sp: Point) {
    var dx = r.Dx(), dy = r.Dy()
    var d0 = dst.PixOffset(r.Min.X, r.Min.Y)
    var s0 = src.PixOffset(sp.X, sp.Y)
    var ddelta, sdelta: Int
    var i0, i1, idelta: Int
    
    if r.Min.Y < sp.Y || r.Min.Y == sp.Y && r.Min.X <= sp.X {
        ddelta = dst.Stride
        sdelta = src.Stride
        (i0, i1, idelta) = (0, dx * 4, 4)
    } else {
        d0 += (dy - 1) * dst.Stride
        s0 += (dy - 1) * src.Stride
        ddelta = -dst.Stride
        sdelta = -src.Stride
        (i0, i1, idelta) = ((dx - 1) * 4, -4, -4)
    }
    for ; dy > 0; dy-- {
        var dpix = dst.Pix[d0..<dst.Pix.count]
        let spix = src.Pix[s0..<dst.Pix.count]
        for var i = i0; i != i1; i += idelta {
            let sr = UInt32(spix[i + 0]) * 0x101
            let sg = UInt32(spix[i + 1]) * 0x101
            let sb = UInt32(spix[i + 2]) * 0x101
            let sa = UInt32(spix[i + 3]) * 0x101
            
            let dr = UInt32(dpix[i + 0])
            let dg = UInt32(dpix[i + 1])
            let db = UInt32(dpix[i + 2])
            let da = UInt32(dpix[i + 3])
            
            let a = (m - sa) * 0x101
            
            dpix[i + 0] = UInt8((dr * a / m + sr) >> 8)
            dpix[i + 1] = UInt8((dg * a / m + sg) >> 8)
            dpix[i + 2] = UInt8((db * a / m + sb) >> 8)
            dpix[i + 3] = UInt8((da * a / m + sa) >> 8)
        }
        d0 += ddelta
        s0 += sdelta
    }
}

private func drawCopySrc(dst: RGBAImage, r: Rectangle, src: RGBAImage, sp: Point) {
    var (n, dy) = (4 * r.Dx(), r.Dy())
    var d0 = dst.PixOffset(r.Min.X, r.Min.Y)
    var s0 = src.PixOffset(sp.X, sp.Y)
    var ddelta, sdelta: Int
    if r.Min.Y <= sp.Y {
        ddelta = dst.Stride
        sdelta = src.Stride
    } else {
        d0 += (dy - 1) * dst.Stride
        s0 += (dy - 1) * src.Stride
        ddelta = -dst.Stride
        sdelta = -src.Stride
    }
    for ; dy > 0; dy-- {
        for i in 0 ..< n {
            dst.Pix[d0 + i] = src.Pix[s0 + i]
        }
        d0 += ddelta
        s0 += sdelta
    }
}

private func drawGlyphOver(dst: RGBAImage, r: Rectangle, src: UniformImage, mask: AlphaImage, mp: Point) {
    var i0 = dst.PixOffset(r.Min.X, r.Min.Y)
    var i1 = i0 + r.Dx() * 4
    var mi0 = mask.PixOffset(mp.X, mp.Y)
    let (sr, sg, sb, sa) = src.RGBA()
    
//    var alphaMap = bitmapFromImage(mask)
    
    for var y = r.Min.Y, my = mp.Y; y != r.Max.Y; y++, my++ {
        for var i = i0, mi = mi0; i < i1; i += 4, mi++ {
            var ma = UInt32(mask.Pix[mi])
            if ma == 0 {
                continue
            }
            ma |= ma << 8
            
            let dr = UInt32(dst.Pix[i + 0])
            let dg = UInt32(dst.Pix[i + 1])
            let db = UInt32(dst.Pix[i + 2])
            let da = UInt32(dst.Pix[i + 3])
            
            let a = (m - (sa * ma / m)) * 0x101
            
            let dstR = ((dr * a + sr * ma) / m) >> 8
            let dstG = ((dg * a + sg * ma) / m) >> 8
            let dstB = ((db * a + sb * ma) / m) >> 8
            let dstA = ((da * a + sa * ma) / m) >> 8
            
            dst.Pix[i + 0] = UInt8(dstR)
            dst.Pix[i + 1] = UInt8(dstG)
            dst.Pix[i + 2] = UInt8(dstB)
            dst.Pix[i + 3] = UInt8(dstA)
//            var map = bitmapFromImage(dst)
//            map.samplesPerPixel
        }
        i0 += dst.Stride
        i1 += dst.Stride
        mi0 += mask.Stride
    }
}

private func drawRGBA(dst: RGBAImage, r: Rectangle, src: Image, sp: Point, mask: Image?, mp: Point, op: Op) {
    print("drawRGBA not implemented!")
}
