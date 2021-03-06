//
//  main.swift
//  SwiftNES
//
//  Created by Articulate on 5/15/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Foundation



func paths() ->[String]
{
    var arg: String
    let args = Process.arguments
    if args.count == 2
    {
        arg = args[1]
    }
    else
    {
        arg = NSFileManager().currentDirectoryPath
    }
    
    var isDir : ObjCBool = false
    if NSFileManager().fileExistsAtPath(arg, isDirectory: &isDir) {
        if isDir
        {
            var result = [String]()
            do {
                let files = try NSFileManager().contentsOfDirectoryAtPath(arg)
                for file in files
                {
                    if file.pathExtension == "nes"
                    {
                        result.append(arg.stringByAppendingPathComponent(file as String))
                    }
                }
            } catch _ {
            }
            return result
        }
        else
        {
            return[arg]
        }
    }
    return[]
}

//  Main()
let filePaths = paths()
if filePaths.count == 0
{
    fatalError("No rom files specified or found")
}
ui.run(filePaths)
