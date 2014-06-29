/*
     File: OpenGLText.mm
 Abstract: 
 Utility toolkit for generating an OpenGL text from a string reference.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#pragma mark -
#pragma mark Headers

// GLKit Math
#import <GLKit/GLKMath.h>

// OpenGL core profile
#import <OpenGL/gl3.h>

// OpenGL utilities header
#import "OpenGLShaders.h"
#import "OpenGLTexture.h"
#import "OpenGLTransforms.h"
#import "OpenGLVertexArray.h"

// OpenGL text header
#import "OpenGLText.h"

#pragma mark -
#pragma mark Private - Data Structures

struct GLTextUniforms
{
	GLuint	mnSampler2D;	// Sampler 2D for a texture
	GLuint  mnMVP;			// Model-view-Projection uniform
}; // GLTextUniforms

typedef struct GLTextUniforms  GLTextUniforms;

union GLTextTransform
{
	GLKVector4 m_Ortho2D;	// Orthographic 2D vector transform
	
	struct
	{
		GLfloat     mnZoom;			// Zooming within a viewport
		GLfloat     mnFovy;			// Field-of-view within a viewport
		GLKMatrix4  m_ModelView;	// Model-view transformation matrix for perspective correct text
	};
}; // GLTextTransform

typedef union GLTextTransform  GLTextTransform;

struct GLTextProgram
{
	GLuint          mnPID;		// Program object ID
	GLuint          mnVAO;		// VAO id
	GLobjects       m_SID;		// Vertex and fragment shader IDs respectively
	GLTextUniforms  m_UID;		// Uniform IDs
}; // Program

typedef struct GLTextProgram  GLTextProgram;

struct GLText
{
	GLuint			  mnTID;			// Texture ID
    GLenum            mnFactor[2];      // Blend function source factor
	NSPoint           m_Position;		// Text position
	NSSize            m_Size;			// Bounding rectangle limits
	NSRect            m_Bounds;			// Text view bounds
	GLTextTransform   m_Transform;		// Transformations
	GLTextProgram     m_Program;		// Program Object
	GLVertexArrayRef  mpVertices;       // VAO encapsulation
}; // Text

typedef struct GLText  GLText;

#pragma mark -
#pragma mark Private - Utilities - Texture

// Generate texture from context's bitmap
static inline bool GLTextCreateTexture2D(const GLchar * const pString,
										 const GLchar * const pFontName,
										 const CGFloat nFontSize,
										 const CTTextAlignment nAlignment,
										 GLTextRef pText)
{
    CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};

	pText->mnTID = GLTexture2DCreateFromString(pString,
											   pFontName,
											   nFontSize,
											   nAlignment,
											   color,
											   pText->m_Size);
    
    return bool(pText->mnTID);
} // GLTextCreateTexture2D

// Generate texture from context's bitmap
static inline bool GLTextCreateTexture2D(const GLstring &rString,
										 const GLstring &rFontName,
										 const CGFloat nFontSize,
										 const CTTextAlignment nAlignment,
										 GLTextRef pText)
{
    CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    
	pText->mnTID = GLTexture2DCreateFromString(rString,
											   rFontName,
											   nFontSize,
											   nAlignment,
											   color,
											   pText->m_Size);
    
    return bool(pText->mnTID);
} // GLTextCreateTexture2D

// Generate texture from context's bitmap
static inline bool GLTextCreateTexture2D(CFStringRef pString,
										 CFStringRef pFontName,
										 const CGFloat nFontSize,
										 const CTTextAlignment nAlignment,
										 GLTextRef pText)
{
    CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    
	pText->mnTID = GLTexture2DCreateFromString(pString,
											   pFontName,
											   nFontSize,
											   nAlignment,
											   color,
											   pText->m_Size);
    
    return bool(pText->mnTID);
} // GLTextCreateTexture2D

// Generate texture from context's bitmap
static inline bool GLTextCreateTexture2D(CFAttributedStringRef pAttrString,
										 GLTextRef pText)
{
    CFRange range = CFRangeMake(0, CFAttributedStringGetLength(pAttrString));

	pText->mnTID = GLTexture2DCreateFromString(pAttrString,
											   range,
											   pText->m_Size);
    
    return bool(pText->mnTID);
} // GLTextCreateTexture2D

#pragma mark -
#pragma mark Private - Utilities - Quad

// Create a quad for perspective text
static inline void GLTextQuadCreatePerspective(const GLchar * const pVertex,
                                               const GLchar * const pColor,
                                               const GLfloat * const pColors,
                                               const GLchar * const pTexCoords,
                                               GLTextRef pText)
{
	pText->mpVertices = GLVertexArrayCreateQuad(pText->m_Program.mnPID,
												pVertex,
												pColor,
												pColors,
												pTexCoords);
	
	if( pText->mpVertices != NULL )
	{
		pText->m_Program.mnVAO = GLVertexArrayGetVAO(pText->mpVertices);
	} // if
} // GLTextQuadCreatePerspective

// Create a quad for non-perspective text
static inline void GLTextQuadCreateNonPerspective(const GLchar * const pColor,
                                                  const GLfloat * const pColors,
                                                  const GLchar * const pTexCoords,
                                                  GLTextRef pText)
{
	pText->mpVertices = GLVertexArrayCreateQuad(pText->m_Program.mnPID,
												pColor,
												pColors,
												pTexCoords);
	
	if( pText->mpVertices != NULL )
	{
		pText->m_Program.mnVAO = GLVertexArrayGetVAO(pText->mpVertices);
	} // if
} // GLTextQuadCreateNonPerspective

#pragma mark -
#pragma mark Private - Utilities - Bounds

// Set the text view bounds
static inline bool GLTextSetBounds(const NSRect &rBounds,
								   GLTextRef pText)
{
	pText->m_Bounds = rBounds;
	
	return !NSEqualRects(rBounds, pText->m_Bounds);
} // GLTextSetBounds

#pragma mark -
#pragma mark Private - Utilities - Transformations

// Calculate the orthographic 2D linear transformation
static GLKVector4 GLTextTransformGetOrtho2D(const NSRect &rBounds,
											GLTextRef pText)
{
	// Set the text-view bounds
	GLTextSetBounds(rBounds, pText);
	
	// Compute the orthographic 2D linear transformation
	GLfloat x = 2.0f / pText->m_Bounds.size.width;
	GLfloat y = 2.0f / pText->m_Bounds.size.height;
	
	GLKVector4 v;
	
	v.x = pText->m_Size.width  * x;
	v.y = pText->m_Size.height * y;
	v.z = pText->m_Position.x  * x - 1.0f;
	v.w = pText->m_Position.y  * y - 1.0f;;
	
	return v;
} // GLTextTransformGetOrtho2D

// Compute a linear transformation with a frustum
static GLKMatrix4 GLTextTransformGetMVP(const NSRect &rBounds,
										GLTextRef pText)
{
	// Set the text-view bounds
	GLTextSetBounds(rBounds, pText);
	
	// Create a MVP linear transformation using a frustum
	return GLTransformCreateModelViewProjection(pText->m_Bounds,
												pText->m_Transform.mnZoom,
												pText->m_Transform.m_ModelView);
} // GLTextTransformGetMVP

// Compute the model-view-projection linear transformation
static GLKMatrix4 GLTextTransformGetMVP(const NSRect &rBounds,
										const GLKVector4 &rRotate,
										const GLKVector3 &rTranslate,
										GLTextRef pText)
{
	// Set the text-view bounds
	GLTextSetBounds(rBounds, pText);
	
	// Compute the the model-view linear transformation
	pText->m_Transform.m_ModelView = GLTransformCreateModelView(pText->m_Bounds,
																pText->m_Size,
																rRotate,
																rTranslate);
	
	// Compute a linear transformation with a prespective projection
	return GLTransformCreateModelViewProjection(pText->m_Bounds,
												pText->m_Transform.mnFovy,
												1.0f,
												100.0f,
												pText->m_Transform.m_ModelView);
} // GLTextTransformGetMVP

#pragma mark -
#pragma mark Private - Utilities - Uniforms

// Enable the uniform assocated with a model-view-projection linear transformation
static void GLTextUniformEnableMVP(const GLchar * pName,
								   const NSRect &rBounds,
								   const GLKVector4 &rRotate,
								   const GLKVector3 &rTranslate,
								   GLTextRef pText)
{
	// Compute the model-view-projection linear transformation
	GLKMatrix4 mvp = GLTextTransformGetMVP(rBounds, rRotate, rTranslate, pText);
	
	// Enable the program object
	glUseProgram(pText->m_Program.mnPID);
	
	// Cache the uniform location
	pText->m_Program.m_UID.mnMVP = glGetUniformLocation(pText->m_Program.mnPID, pName);
	
	// Update the mvp linear transformation
	glUniformMatrix4fv(pText->m_Program.m_UID.mnMVP, 1, GL_FALSE, mvp.m);
} // GLTextUniformEnableMVP

// Enable the uniform assocated with a orthographic 2D transformation
static void GLTextUniformEnableOrtho2D(const GLchar * const pName,
									   const NSRect &rBounds,
                                       GLTextRef pText)
{
	// Calculate the orthographic 2D linear transformation
	pText->m_Transform.m_Ortho2D = GLTextTransformGetOrtho2D(rBounds, pText);
	
	// Enable the program object
	glUseProgram(pText->m_Program.mnPID);
	
	// Cache the uniform location
	pText->m_Program.m_UID.mnMVP = glGetUniformLocation(pText->m_Program.mnPID, pName);
	
	// Set the orthographic 2D linear transformation
	glUniform4f(pText->m_Program.m_UID.mnMVP,
				pText->m_Transform.m_Ortho2D.v[0],
				pText->m_Transform.m_Ortho2D.v[1],
				pText->m_Transform.m_Ortho2D.v[2],
				pText->m_Transform.m_Ortho2D.v[3]);
} // GLTextUniformEnableOrtho2D

// Enable the sampler 2D uniform assocated with a texture
static inline void GLTextUniformEnableSampler2D(const GLchar * const pName,
												GLTextRef pText)
{
	// Use the program object
	glUseProgram(pText->m_Program.mnPID);
	
	// Cache the sampler 2D uniform location
    pText->m_Program.m_UID.mnSampler2D = glGetUniformLocation(pText->m_Program.mnPID, pName);
    
    // 0 for GL_TEXTURE0
    glUniform1i(pText->m_Program.m_UID.mnSampler2D, 0);
} // GLTextUniformEnableSampler2D

#pragma mark -
#pragma mark Private - Utilities - Shaders

// These are the basic steps to create program object.
// It is best to also check and validate at each stage.
static bool GLTextCreateProgram(const GLchar **pShaders,
                                GLlocations &rAttributes,
                                GLlocations &rFragments,
                                GLTextRef pText)
{
	// Compile the vertex and fragment shaders
	
	pText->m_Program.m_SID = GLShadersCreate(pShaders[0], pShaders[1]);
	
	if( !pText->m_Program.m_SID.empty() )
	{
		// Create a program object from the compiled shader
		pText->m_Program.mnPID = GLProgramCreate(pText->m_Program.m_SID, rAttributes, rFragments);
	} // if
	
    return bool(pText->m_Program.mnPID);
} // GLTextCreateProgram

#pragma mark -
#pragma mark Private - Utilities - Constructor

// Create an OpenGL Text object opaque data reference
static GLTextRef GLTextCreate(const GLint &rValue)
{
    GLTextRef pText = new GLText;
    
    if( pText != NULL )
    {
		// Clear the sturcture
		memset(pText, rValue, sizeof(GLText));
        
        // Blend function source factor
        pText->mnFactor[0] = GL_SRC_ALPHA;

        // Blend function destination factor
        pText->mnFactor[1] = GL_ONE;
    } // if
    
    return pText;
} // GLTextCreate

#pragma mark -
#pragma mark Private - Utilities - Acquire

// Acquire a program object, shaders, vao, and buffers for a perspective text
static bool GLTextAcquirePerspective(const NSRect &rBounds,
                                     const GLfloat * const pColors,
                                     GLTextRef pText)
{
    // Create attributes associative array
    const GLuint  attribKeys[3] = { 0, 1, 2 };
    const GLchar *attribVals[3] = { "position", "texCoords", "colors" };
    
    GLlocations attributes = GLLocationsCreate(3, attribKeys, attribVals);
    
    // Create fragment data associative array
    const GLuint  colorKeys[1]  = { 0 };
    const GLchar *colorVals[1]  = { "fragColor" };
    
    GLlocations fragments = GLLocationsCreate(1, colorKeys, colorVals);
    
    // Default vertex and fragment shaders
    const GLchar *kShaders[2] =
    {
        // Vertex shader
        "#version 150\n"
        "uniform mat4 mvp;\n"
        "in vec2 position;\n"
        "in vec2 texCoords;\n"
        "in vec4 colors;\n"
        "out block\n"
        "{\n"
        "    vec2 texCoords;\n"
        "    vec4 colors;\n"
        "} outData;\n"
        "void main()\n"
        "{\n"
        "   outData.colors    = colors;\n"
        "	outData.texCoords = texCoords;\n"
        "	gl_Position = mvp * vec4(position,0.0,1.0);\n"
        "}\n",
        
        // Fragment shader
        "#version 150\n"
        "uniform sampler2D tex;\n"
        "in block\n"
        "{\n"
        "	vec4 colors;\n"
        "	vec2 texCoords;\n"
        "} inData;\n"
        "out vec4 fragColor;\n"
        "void main()\n"
        "{\n"
        "   vec4 tex2D = texture(tex, inData.texCoords);\n"
        "	fragColor = tex2D * inData.colors;\n"
        "}\n"
    };
    
    // Create a program object from shaders, attributes and fragment data
    bool bSuccess = GLTextCreateProgram(kShaders, attributes, fragments, pText);
    
    if( bSuccess )
    {
        // Initial zoom value
        pText->m_Transform.mnZoom = 1.0f;
        
        // Initial field-of-view
        pText->m_Transform.mnFovy = GLKMathDegreesToRadians(45.0f);
        
        // Rotation parameters are { θ, x, y, z }
        const GLKVector4 rotate = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
        
        // Translation in the rectangular Cartesian coordinatines
        const GLKVector3 translate = GLKVector3Make(0.0f, 0.0f, 0.5f);
        
        // Enable th model-view-projection matrix
        GLTextUniformEnableMVP("mvp", rBounds, rotate, translate, pText);
        
        // Enable the sampler 2D
        GLTextUniformEnableSampler2D("tex", pText);
        
        // Create a triangle fan
        GLTextQuadCreatePerspective("position", "colors", pColors, "texCoords", pText);
    } // if
    
    // Clear fragment data associative array
    GLLocationsDelete(fragments);
    
    // Clear attributes associative array
    GLLocationsDelete(attributes);
    
    return bSuccess;
} // GLTextAcquirePerspective

// Acquire a program object, shaders, vao, and buffers for a nonperspective text
static bool GLTextAcquireNonPerspective(const NSRect &rBounds,
                                        const NSPoint &rPosition,
                                        const GLfloat * const pColors,
                                        GLTextRef pText)
{
    // Create attributes associative array
    const GLuint  attribKeys[2] = { 3, 4 };
    const GLchar *attribVals[2] = { "positions", "colors" };
    
    GLlocations attributes = GLLocationsCreate(2, attribKeys, attribVals);
    
    // Create fragment data associative array
    const GLuint  colorKeys[1]  = { 0 };
    const GLchar *colorVals[1]  = { "fragColor" };
    
    GLlocations fragments = GLLocationsCreate(1, colorKeys, colorVals);
    
    // create HUD vertex and fragment shader sources
    const GLchar *kShaders[2] =
    {
        // Vertex Shader
        "#version 150\n"
        "uniform vec4 ortho;\n"
        "in vec4 colors;\n"
        "in vec2 positions;\n"
        "out block\n"
        "{\n"
        "    vec4 colors;\n"
        "    vec2 texCoords;\n"
        "} outData;\n"
        "void main()\n"
        "{\n"
        "   outData.colors    = colors;\n"
        "	outData.texCoords = positions;\n"
        "	gl_Position = vec4(positions * ortho.xy + ortho.zw, 0.0, 1.0);\n"
        "}\n",
        
        // Fragment Shader
        "#version 150\n"
        "uniform sampler2D tex;\n"
        "in block\n"
        "{\n"
        "	vec4 colors;\n"
        "	vec2 texCoords;\n"
        "} inData;\n"
        "out vec4 fragColor;\n"
        "void main()\n"
        "{\n"
        "   vec4 tex2D = texture(tex, inData.texCoords);\n"
        "	fragColor = tex2D * inData.colors;\n"
        "}\n"
    };
    
    // Create a program object from shaders, attributes and fragment data
    bool bSuccess = GLTextCreateProgram(kShaders, attributes, fragments, pText);
    
    if( bSuccess )
    {
        // Set text position within a view
        pText->m_Position = rPosition;
        
        // Enable the uniforms
        GLTextUniformEnableOrtho2D("ortho", rBounds, pText);
        
        // Enable sampler 2D
        GLTextUniformEnableSampler2D("tex", pText);
        
        // Create a triangle fan
        GLTextQuadCreateNonPerspective("colors", pColors, "positions", pText);
    } // if
    
    // Clear fragment data associative array
    GLLocationsDelete(fragments);
    
    // Clear attributes associative array
    GLLocationsDelete(attributes);
    
    return bSuccess;
} // GLTextAcquireNonPerspective

#pragma mark -
#pragma mark Private - Utilities - Blending

static inline bool GLTextCheckBlending(const GLenum nFactor)
{
    bool bSuccess = false;
    
    switch(nFactor)
    {
        case GL_ZERO:
        case GL_ONE:
        case GL_SRC_COLOR:
        case GL_ONE_MINUS_SRC_COLOR:
        case GL_SRC_ALPHA:
        case GL_ONE_MINUS_SRC_ALPHA:
        case GL_DST_ALPHA:
        case GL_ONE_MINUS_DST_ALPHA:
        case GL_DST_COLOR:
        case GL_ONE_MINUS_DST_COLOR:
        case GL_SRC_ALPHA_SATURATE:
            bSuccess = true;
            break;
            
        default:
            break;
    } // switch
    
    return bSuccess;
} // GLTextCheckBlending

#pragma mark -
#pragma mark Public - Utilities - Accessors

// Specify how the red, green, blue, and alpha source and
// destination blending factors are computed
void GLTextSetBlending(const GLenum nSrc,
                       const GLenum nDst,
                       GLTextRef pText)
{
    // Check the source and destination blending factors
    GLenum nSFactor = GLTextCheckBlending(nSrc) ? nSrc : GL_SRC_ALPHA;
    GLenum nDFactor = GLTextCheckBlending(nDst) ? nDst : GL_ONE;
    
    // Blend function source factor
    pText->mnFactor[0] = nSFactor;
    
    // Blend function destination factor
    pText->mnFactor[1] = nDFactor;
} // GLTextSetBlending

// Set field-of-view for prespective correct text
void GLTextSetFieldOfView(const GLfloat nFovy,
						  GLTextRef pText)
{
	pText->m_Transform.mnFovy = GLKMathDegreesToRadians(nFovy);
} // GLTextSetFieldOfView

// Set the text zoom for perspective projection
void GLTextSetZoom(const GLfloat nDeltaY,
                   GLTextRef pText)
{
    pText->m_Transform.mnZoom += 0.01f * nDeltaY;
    
    if( pText->m_Transform.mnZoom < 0.05f )
    {
        pText->m_Transform.mnZoom = 0.05f;
    } // if
    else if( pText->m_Transform.mnZoom > 2.0f )
    {
        pText->m_Transform.mnZoom = 2.0f;
    } // else if
} // GLTextSetZoom

// Set the uniform assocated with a model-view-projection linear transformation
void GLTextSetMVP(const NSRect &rBounds,
				  const GLKVector4 &rRotate,
				  const GLKVector3 &rTranslate,
				  GLTextRef pText)
{
	// Compute the model-view-projection linear transformation
	GLKMatrix4 mvp = GLTextTransformGetMVP(rBounds, rRotate, rTranslate, pText);
	
	// Enable the program object
	glUseProgram(pText->m_Program.mnPID);
	
	// Update the mvp linear transformation
	glUniformMatrix4fv(pText->m_Program.m_UID.mnMVP, 1, GL_FALSE, mvp.m);
} // GLTextSetUniformMVP

// Set the uniform assocated with a frustum linear transformation
void GLTexSetPrespective(const NSRect &rBounds,
						 GLTextRef pText)
{
	// Compute the mvp linear transformation
	GLKMatrix4 mvp = GLTextTransformGetMVP(rBounds, pText);
	
	// Update the projection matrix
	glUseProgram(pText->m_Program.mnPID);
	
	// Set the mvp linear transformation unifrom
	glUniformMatrix4fv(pText->m_Program.m_UID.mnMVP, 1, GL_FALSE, mvp.m);
} // GLTexSetPrespective

// Set the uniform assocated with a orthographic 2D transformation
void GLTextSetOrthographic(const NSRect &rBounds,
						   GLTextRef pText)
{
	// Calculate the orthographic 2D linear transformation
	pText->m_Transform.m_Ortho2D = GLTextTransformGetOrtho2D(rBounds, pText);
	
	// Enable the program object
	glUseProgram(pText->m_Program.mnPID);
	
	// Set the orthographic 2D linear transformation
	glUniform4f(pText->m_Program.m_UID.mnMVP,
				pText->m_Transform.m_Ortho2D.v[0],
				pText->m_Transform.m_Ortho2D.v[1],
				pText->m_Transform.m_Ortho2D.v[2],
				pText->m_Transform.m_Ortho2D.v[3]);
} // GLTextSetOrthographic

#pragma mark -
#pragma mark Public - Utilities - Rendering

// Render a text into an OpenGL view
void GLTextDisplay(const GLTextRef pText)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    {
        // Specify pixel arithmetic.
		glBlendFunc(pText->mnFactor[0], pText->mnFactor[1]);
        
        // Select both front and back-facing polygon rasterization
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        
		glUseProgram(pText->m_Program.mnPID);
		glBindVertexArray(pText->m_Program.mnVAO);
		
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, pText->mnTID);
        
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    }
    glDisable(GL_BLEND);
} // GLTextDisplay

#pragma mark -
#pragma mark Public - Constructors

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(const GLchar * const pString,
								  const GLchar * const pFontName,
								  const CGFloat nFontSize,
								  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
								  const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
        if( GLTextCreateTexture2D(pString, pFontName, nFontSize, nAlignment, pText) )
        {
            // Acquire a program object from shaders, attributes and fragment data
            bool bSuccess = GLTextAcquirePerspective(rBounds, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreatePerspective

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(const GLchar * const pString,
									 const GLchar * const pFontName,
									 const CGFloat nFontSize,
									 const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
		// Create a texture from a string
        if( GLTextCreateTexture2D(pString, pFontName, nFontSize, nAlignment, pText) )
        {
            // Acquire a program object, shaders, vao, and buffers for a nonperspective text
            bool bSuccess = GLTextAcquireNonPerspective(rBounds, rPosition, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreateNonPerspective

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(const GLstring &rString,
								  const GLstring &rFontName,
								  const CGFloat nFontSize,
								  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
								  const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
        if( GLTextCreateTexture2D(rString, rFontName, nFontSize, nAlignment, pText) )
        {
            // Acquire a program object from shaders, attributes and fragment data
            bool bSuccess = GLTextAcquirePerspective(rBounds, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreatePerspective

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(const GLstring &rString,
									 const GLstring &rFontName,
									 const CGFloat nFontSize,
									 const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
		// Create a texture from a string
        if( GLTextCreateTexture2D(rString, rFontName, nFontSize, nAlignment, pText) )
        {
            // Acquire a program object, shaders, vao, and buffers for a nonperspective text
            bool bSuccess = GLTextAcquireNonPerspective(rBounds, rPosition, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreateNonPerspective

// Create program object, shaders, vao, and buffers for a perspective text
GLTextRef GLTextCreatePerspective(CFStringRef pString,
                                  CFStringRef pFontName,
                                  const CGFloat nFontSize,
                                  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
                                  const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
        if( GLTextCreateTexture2D(pString, pFontName, nFontSize, nAlignment, pText) )
        {            			
            // Acquire a program object from shaders, attributes and fragment data
            bool bSuccess = GLTextAcquirePerspective(rBounds, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreatePerspective

// Create a program object, shaders, vao, and buffers for a nonperspective text
GLTextRef GLTextCreateNonPerspective(CFStringRef pString,
                                     CFStringRef pFontName,
                                     const CGFloat nFontSize,
                                     const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
                                     const NSPoint &rPosition,
                                     const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
		// Create a texture from a string
        if( GLTextCreateTexture2D(pString, pFontName, nFontSize, nAlignment, pText) )
        {
            // Acquire a program object, shaders, vao, and buffers for a nonperspective text
            bool bSuccess = GLTextAcquireNonPerspective(rBounds, rPosition, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreateNonPerspective

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(CFAttributedStringRef pAttrString,
								  const NSRect &rBounds,
								  const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
        if( GLTextCreateTexture2D(pAttrString, pText) )
        {
            // Acquire a program object from shaders, attributes and fragment data
            bool bSuccess = GLTextAcquirePerspective(rBounds, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreatePerspective

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(CFAttributedStringRef pAttrString,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors)
{
    GLTextRef pText = GLTextCreate(0x0);
    
    if( pText != NULL )
    {
		// Create a texture from a string
        if( GLTextCreateTexture2D(pAttrString, pText) )
        {
            // Acquire a program object, shaders, vao, and buffers for a nonperspective text
            bool bSuccess = GLTextAcquireNonPerspective(rBounds, rPosition, pColors, pText);
            
            // If shaders did not compile and link
            if( !bSuccess )
            {
                glDeleteTextures(1, &pText->mnTID);
                
                delete pText;
                
                pText = NULL;
            } // if
		} // if
    } // if
    
    return pText;
} // GLTextCreateNonPerspective

#pragma mark -
#pragma mark Public - Destructor

// Delete program object, shaders, vao, and buffers
void GLTextDelete(GLTextRef pText)
{
    if( pText != NULL )
    {
        glDeleteProgram(pText->m_Program.mnPID);
        glDeleteTextures(1, &pText->mnTID);
		
		GLVertexArrayDelete(pText->mpVertices);
		GLShadersDelete(pText->m_Program.m_SID);
        
        delete pText;
        
        pText = NULL;
    } // if
} // GLTextDelete

