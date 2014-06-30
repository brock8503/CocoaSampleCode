InstancedArrays

================================================================================
DESCRIPTION:

A common use case in OpenGL is to be able to draw a group of similar objects that share vertex data, primitive count and type, multiple times. The ARB_instanced_arrays extension provides a means of accelerating such use cases while minimizing the number of draw calls and the amount of duplicate data. This extension introduces an array "divisor" for generic vertex array attributes, which when non-zero specifies that the attribute is "instanced". An instanced attribute does not advance per-vertex as usual, but rather after every <divisor> instances are rendered.

This sample demonstrates how to use instancing. By specifying transform data in instanced attributes, one can, in concert with the instancing draw call, draw multiple instances of an object with one draw call.

Usage:
Press 'space' to toggle the animation.

================================================================================
BUILD REQUIREMENTS:

OS X v10.8 or later, Xcode 4.6 or later

================================================================================
RUNTIME REQUIREMENTS:

OS X v10.8 or later

================================================================================
PACKAGING LIST:

OpenGLRenderer.h/.mm
The renderer class creates and draws the OpenGL shaders. This is where we set up instancing and draw the set of gears with one single instancing draw call.

GLView.h/.mm
The OpenGL view. It delegates to the renderer class for drawing.

InstancedArraysAppDelegate.h/.m
The application delegate.

TriToothedGearFlatModel.h
This file contains the vertex data of a triangle toothed gear model.

vertexShaderFlat.vs
The vertex shader, which uses instanced attributes, for drawing the gears. 

fragmentShaderFlat.fs
The fragment shader for drawing the gears.

================================================================================
Copyright (C) 2010~2013 Apple Inc. All rights reserved.