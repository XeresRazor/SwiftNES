//
//  Geometry.swift
//  SwiftNES
//
//  Created by Articulate on 6/2/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

struct Point {
    var X, Y: Int
    
    init() {
        self.X = 0
        self.Y = 0
    }
    init(_ x: Int, _ y: Int) {
        self.X = x
        self.Y = y
    }
    
    func Add(q: Point) -> Point {
        return Point(self.X + q.X, self.Y + q.Y)
    }
    
    func Sub(q: Point) -> Point {
        return Point(self.X - q.X, self.Y - q.Y)
    }
    
    func Mul(k: Int) -> Point {
        return Point(self.X * k, self.Y * k)
    }
    
    func Div(k: Int) -> Point {
        return Point(self.X / k, self.Y / k)
    }
    
    func In(r: Rectangle) -> Bool {
        return r.Min.X <= self.X && self.X < r.Max.X && r.Min.Y <= self.Y && self.Y < r.Max.Y
    }
    
    func Mod(r: Rectangle) -> Point {
        let w = r.Dx(), h = r.Dy()
        var p = self.Sub(r.Min)
        p.X = p.X % w
        if p.X < 0 {
            p.X += w
        }
        
        p.Y = p.Y % h
        if p.Y < 0 {
            p.Y += h
        }
        return p.Add(r.Min)
    }
    
    func Eq(q: Point) -> Bool {
        return self.X == q.X && self.Y == q.Y
    }
}

let ZP = Point(0, 0)


struct Rectangle {
    var Min, Max: Point
    
    init(_ min: Point, _ max: Point) {
        self.Min = min
        self.Max = max
    }
    
    init(var _ x0: Int, var _ y0: Int, var _ x1: Int, var _ y1: Int) {
        if x0 > x1 {
            (x0, x1) = (x1, x0)
        }
        if y0 > y1 {
            (y0, y1) = (y1, y0)
        }
        self.init(Point(x0, y0), Point(x1, y1))
    }
    
    func Dx() -> Int {
        return self.Max.X - self.Min.X
    }
    
    func Dy() -> Int {
        return self.Max.Y - self.Min.Y
    }
    
    func Size() -> Point {
        return Point(self.Max.X - self.Min.X, self.Max.Y - self.Min.Y)
    }
    
    func Add(p: Point) -> Rectangle {
        return Rectangle(self.Min.X + p.X, self.Min.Y + p.Y, self.Max.X + p.X, self.Max.Y + p.Y)
    }
    
    func Sub(p: Point) -> Rectangle {
        return Rectangle(self.Min.X - p.X, self.Min.Y - p.Y, self.Max.X - p.X, self.Max.Y - p.Y)
    }
    
    func Inset(n: Int) -> Rectangle {
        var r = self
        if r.Dx() < 2 * n {
            r.Min.X = (r.Min.X + r.Max.X) / 2
            r.Max.X = r.Min.X
        } else {
            r.Min.X += n
            r.Max.X -= n
        }
        if r.Dy() < 2 * n {
            r.Min.Y = (r.Min.Y + r.Max.Y) / 2
            r.Max.Y = r.Min.Y
        } else {
            r.Min.Y += n
            r.Max.Y -= n
        }
        return r
    }
    
    func Intersect(s: Rectangle) -> Rectangle {
        var r = self
        if r.Min.X < s.Min.X {
            r.Min.X = s.Min.X
        }
        if r.Min.Y < s.Min.Y {
            r.Min.Y = s.Min.Y
        }
        if r.Max.X > s.Max.X {
            r.Max.X = s.Max.X
        }
        if r.Max.Y > s.Max.Y {
            r.Max.Y = s.Max.Y
        }
        if r.Min.X > r.Max.X || r.Min.Y > r.Max.Y {
            return ZR
        }
        return r
    }
    
    func Union(s: Rectangle) -> Rectangle {
        var r = self
        if r.Min.X > s.Min.X {
            r.Min.X = s.Min.X
        }
        if r.Min.Y > s.Min.Y {
            r.Min.Y = s.Min.Y
        }
        if r.Max.X < s.Max.X {
            r.Max.X = s.Max.X
        }
        if r.Max.Y < s.Max.Y {
            r.Max.Y = s.Max.Y
        }
        return r
    }
    
    func Empty() -> Bool {
        return self.Min.X >= self.Max.X || self.Min.Y >= self.Max.Y
    }
    
    func Eq(s: Rectangle) -> Bool {
        return self.Min.X == s.Min.X && self.Min.Y == s.Min.Y && self.Max.X == s.Max.X && self.Max.Y == s.Max.Y
    }
    
    func Overlaps(s: Rectangle) -> Bool {
        let r = self
        return r.Min.X < s.Max.X && s.Min.X < r.Max.X && r.Min.Y < s.Max.Y && s.Min.Y < r.Max.Y
    }
    
    func In(s: Rectangle) -> Bool {
        let r = self
        if r.Empty() {
            return true
        }
        // Note that r.Max is an exclusive bound for r, so that r.In(s)
        // does not require that r.Max.In(s).
        return s.Min.X <= r.Min.X && r.Max.X <= s.Max.X && s.Min.Y <= r.Min.Y && r.Max.Y <= s.Max.Y
    }
    
    func Canon() -> Rectangle {
        var r = self
        if r.Max.X < r.Min.X {
            (r.Min.X, r.Max.X) = (r.Max.X, r.Min.X)
        }
        if r.Max.Y < r.Min.Y {
            (r.Min.Y, r.Max.Y) = (r.Max.Y, r.Min.Y)
        }
        return r
    }
}

let ZR = Rectangle(Point(0, 0), Point(0, 0))
