//
//  MenuView.swift
//  SwiftNES
//
//  Created by Articulate on 5/27/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Foundation
import OpenGL

let border: Int32 = 10
let margin: Int32 = 10
let initialDelay = 0.3
let repeatDelay = 0.1
let typeDelay = 0.5

var menuView: MenuView? = nil

func onChar(window: COpaquePointer, char: CUnsignedInt) {
    guard let menu = menuView else {
        return
    }
    let now = glfwGetTime()
    if now > menu.typeTime {
        menu.typeBuffer = ""
    }
    menu.typeTime = now + typeDelay
    menu.typeBuffer = menu.typeBuffer! + String(Character(UnicodeScalar(char)))
    menu.typeBuffer = menu.typeBuffer?.lowercaseString
    
    for (index, p) in menu.paths.enumerate() {
        let path = p.lastPathComponent.lowercaseString
        if path.hasPrefix(menu.typeBuffer!) {
            menu.highlight(Int32(index))
            return
        }
    }
}


class MenuView : View {
    var director: Director
    var paths: [String]
    var texture: Texture
    var nx: Int32 = 0
    var ny: Int32 = 0
    var i: Int32 = 0
    var j: Int32 = 0
    var scroll: Int32 = 0
    var t: Float64 = 0.0
    var buttons: [Bool] = [Bool]()
    var times: [Float64] = [Float64]()
    var typeBuffer: String?
    var typeTime: Float64 = 0.0
    
    init(director: Director, paths: [String]) {
        self.director = director
        self.paths = paths
        self.texture = Texture()
    }
    
    func checkButtons() {
        
    }
    
    func onPress(index: Int32) {
        
    }
    
    func onRelease(index: Int32) {
        
    }
    
    func onSelect() {
        
    }
    
    func highlight(index: Int32) {
        self.scroll = index / self.nx - (self.ny - 1) / 2
        self.clampScroll(false)
        self.i = index % self.nx
        self.j = (index - self.i) / self.nx - self.scroll
    }
    
    func enter() {
        glClearColor(0.333, 0.333, 0.333, 1)
        self.director.setTitle("Select Game")
        //  TODO: Setup bridging via Obj-C
        menuView = self
        glfwSetCharCallback(self.director.window, onChar)
        //glfwSetCharCallback(self.director.window, nil)
    }
    
    func exit() {
        glfwSetCharCallback(self.director.window, nil)
    }
    
    func update(timestamp: Float64, deltaTime: Float64) {
        self.checkButtons()
        self.texture.purge()
        let window = self.director.window
        var w: Int32 = 0
        var h: Int32 = 0
        glfwGetFramebufferSize(window, &w, &h)
        let sx: Int32 = 256 + margin * 2
        let sy: Int32 = 240 + margin * 2
        var nx: Int32 = (w - border * 2) / sx
        var ny: Int32 = (h - border * 2) / sy
        let ox: Int32 = (w - nx * sx) / 2 + margin
        let oy: Int32 = (h - ny * sy) / 2 + margin
        if nx < 1 {
            nx = 1
        }
        if ny < 1 {
            ny = 1
        }
        
        self.nx = nx
        self.ny = ny
        self.clampSelection()
        glPushMatrix()
        glOrtho(0, Float64(w), Float64(h), 0, -1, 1)
        self.texture.bind()
        for var j: Int32 = 0; j < ny; j++ {
            for var i: Int32 = 0; i < nx; i++ {
                let x = Float32(ox) + Float32(i) * Float32(sx)
                let y = Float32(oy) + Float32(j) * Float32(sy)
                let index: Int = Int(nx * (j + self.scroll) + i)
                if index >= self.paths.count {
                    continue
                }
                let path = self.paths[index]
                let (tx, ty, tw, th) = self.texture.lookup(path)
                self.drawThumbnail(x, y: y, tx: tx, ty: ty, tw: tw, th: th)
            }
        }
        self.texture.unbind()
        if Int((timestamp -  self.t) * 4) % 2 == 0 {
            let x = Float32(ox) + Float32(self.i) * Float32(sx)
            let y = Float32(oy) + Float32(self.j) * Float32(sx)
            self.drawSelection(x, y: y, p: 8, w: 4)
        }
        glPopMatrix()
    }
    
    func clampSelection() {
        if  self.i < 0 {
            self.i = self.nx - 1
        }
        if  self.i >= self.nx {
            self.i = 0
        }
        if  self.j < 0 {
            self.j = 0
            self.scroll--
        }
        if self.j >= self.ny {
            self.j = self.ny - 1
            self.scroll++
        }
        self.clampScroll(true)
    }
    
    func clampScroll(wrap: Bool) {
        let n: Int32 = Int32(self.paths.count)
        var rows = n / self.nx
        if n % self.nx > 0 {
            rows++
        }
        
        let maxScroll = rows - self.ny
        
        if self.scroll < 0 {
            if wrap {
                self.scroll = maxScroll
                self.j = self.ny - 1
            } else {
                self.scroll = 0
                self.j = 0
            }
        }
        if self.scroll > maxScroll {
            if wrap {
                self.scroll = 0
                self.j = 0
            } else {
                self.scroll = maxScroll
                self.j = self.ny - 1
            }
        }
    }
    
    func drawThumbnail(x: Float32, y: Float32, tx: Float32, ty: Float32, tw: Float32, th: Float32) {
        let sx = x + 4
        let sy = y + 4
        glDisable(GLenum(GL_TEXTURE_2D))
        glColor3f(0.2, 0.2, 0.2)
        glBegin(GLenum(GL_QUADS))
        glVertex2f(sx, sy)
        glVertex2f(sx + 256, sy)
        glVertex2f(sx + 256, sy + 240)
        glVertex2f(sx, sy + 240)
        glEnd()
        // Draw image
        glEnable(GLenum(GL_TEXTURE_2D))
        glColor3f(1, 1, 1)
        glBegin(GLenum(GL_QUADS))
        glTexCoord2f(tx, ty)
        glVertex2f(x, y)
        glTexCoord2f(tx + tw, ty)
        glVertex2f(x + 256, y)
        glTexCoord2f(tx + tw, ty + th)
        glVertex2f(x + 256, y + 240)
        glTexCoord2f(tx, ty + th)
        glVertex2f(x, y + 240)
        glEnd()
    }
    
    func drawSelection(x: Float32, y: Float32, p: Float32, w: Float32) {
        glLineWidth(w)
        glBegin(GLenum(GL_LINE_STRIP))
        glVertex2f(x - p, y - p)
        glVertex2f(x + 256 + p, y - p)
        glVertex2f(x + 256 + p, y + 240 + p)
        glVertex2f(x - p, y + 240 + p)
        glVertex2f(x - p, y - p)
        glEnd()
    }
}