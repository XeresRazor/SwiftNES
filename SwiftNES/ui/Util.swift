//
//  Util.swift
//  SwiftNES
//
//  Created by Articulate on 5/27/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Foundation
import OpenGL

func createTexture() ->UInt32 {
    var texture: UInt32 = 0
    glGenTextures(1, &texture)
    glBindTexture(GLenum(GL_TEXTURE_2D), texture)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    return texture
}
