//
//  ui.swift
//  SwiftNES
//
//  Created by Articulate on 5/15/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Cocoa
import OpenGL

let width: Int32 = 256
let height: Int32 = 240
let scale: Int32 = 3
let title = "NES"

struct ui {
    
    init()
    {
/*
        // we need a parallel OS thread to avoid audio stuttering
        runtime.GOMAXPROCS(2)
        
        // we need to keep OpenGL calls on a single thread
        runtime.LockOSThread()
*/
    }
    
    static func run(paths: [String])
    {
        //  Initialize Audio
        
        //  Initialize glfw
        if glfwInit() !=  GL_TRUE {
            fatalError("Unable to initialize glfw")
        }
        
        //  Create window
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1)
        let window = glfwCreateWindow(width * scale, height * scale, title.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil)
        if window == nil {
            fatalError("Unable to create window.")
        }
        glfwMakeContextCurrent(window)
        
        //  Initialize OpenGL
        glEnable(GLenum(GL_TEXTURE_2D))
        
        //  Run our Director
        let director = Director(window: window)
        director.start(paths)
        
        // Cleanup
        glfwTerminate()
    }
}

