//
//  Director.swift
//  SwiftNES
//
//  Created by Articulate on 5/27/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Cocoa
import OpenGL

protocol View {
    func enter()
    func exit()
    func update(timestamp: Float64, deltaTime: Float64)
}

class Director {
    var window: COpaquePointer
    var view: View?
    var menuView: View?
    var timestamp: Float64 = 0
    
    init(window: COpaquePointer) {
       self.window = window
    }
    
    func setTitle(title: String) {
        glfwSetWindowTitle(self.window, title.cStringUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func setView(view: View?) {
        if self.view != nil {
            self.view?.exit()
        }
        self.view = view
        if self.view != nil {
            self.view?.enter()
        }
        self.timestamp = glfwGetTime()
    }
    
    func step() {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let timestamp = glfwGetTime()
        let dt = timestamp - self.timestamp
        self.timestamp = timestamp
        if self.view != nil {
            self.view?.update(timestamp, deltaTime: dt)
        }
    }
    
    func start(paths: [String]) {
        self.menuView = MenuView(director: self, paths: paths)
        if paths.count == 1 {
            self.playGame(paths[0])
        } else {
            self.showMenu()
        }
        self.run()
    }
    
    func run() {
        while glfwWindowShouldClose(self.window) == 0 {
            self.step()
            glfwSwapBuffers(self.window)
            glfwPollEvents()
        }
        self.setView(nil)
    }
    
    func playGame(path: String) {
        
    }
    
    func showMenu() {
        self.setView(self.menuView)
    }
}

