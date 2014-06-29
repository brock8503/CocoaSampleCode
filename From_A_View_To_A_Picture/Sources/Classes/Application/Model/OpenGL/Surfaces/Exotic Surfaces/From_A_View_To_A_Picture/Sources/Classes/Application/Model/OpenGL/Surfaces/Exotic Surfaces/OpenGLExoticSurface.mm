//---------------------------------------------------------------------------
//
//	File: OpenGLExoticSurface.mm
//
//  Abstract: Exotic surface geometry class
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms,
//  and your use, installation, modification or redistribution of this Apple
//  software constitutes acceptance of these terms.  If you do not agree with
//  these terms, please do not use, install, modify or redistribute this
//  Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Inc. may
//  be used to endorse or promote products derived from the Apple Software
//  without specific prior written permission from Apple.  Except as
//  expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright (c) 2004-2008, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------
//
// Uses techniques described by Paul Bourke 1999 - 2002
// Tranguloid Trefoil and other example surfaces by Roger Bagula
// see <http://astronomy.swin.edu.au/~pbourke/surfaces/>
//
//---------------------------------------------------------------------------

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#import <cmath>
#import <vector>

//------------------------------------------------------------------------

#import "Vector3.h"

//------------------------------------------------------------------------

#import "GeometryConstants.h"
#import "OpenGLExoticSurface.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

typedef void (*OpenGLExoticSurfaceComputeFuncPtr)(GLdouble u, GLdouble v, Math::Vector3<GLdouble> &p);

//------------------------------------------------------------------------

//------------------------------------------------------------------------

struct OpenGLExoticSurfaceVertex
{
	Math::Vector3<GLdouble>  positions;
	Math::Vector3<GLdouble>  normals;
	Math::Vector3<GLdouble>  texCoords;
};

typedef struct	OpenGLExoticSurfaceVertex OpenGLExoticSurfaceVertex;

//------------------------------------------------------------------------

typedef std::vector<OpenGLExoticSurfaceVertex>  OpenGLExoticSurfaceVertices;

//------------------------------------------------------------------------

struct OpenGLExoticSurfaceGeometry
{
	GLint  mnRows;
	GLint  mnColumns;
	
	OpenGLExoticSurfaceVertices  m_Vertices;
};

typedef struct	OpenGLExoticSurfaceGeometry OpenGLExoticSurfaceGeometry;

//------------------------------------------------------------------------

//------------------------------------------------------------------------
//
// Note that -Pi <= u <= Pi and -Pi <= v <= Pi
//
//------------------------------------------------------------------------

static void OpenGLExoticSurfaceTranguloidTrefoil(GLdouble u,
                                                 GLdouble v,
                                                 Math::Vector3<GLdouble>  &p)
{
	GLdouble  t = v + kTwoPiThird;
	GLdouble  w = 2.0 * u;
	GLdouble  A = 2.0 + cos(t);
	GLdouble  B = 2.0 + cos(v);
	
	p.x = 2.0  * sin(3.0 * u) / B;
	p.y = 2.0  * (sin(u) + 2.0 * sin(w)) / A;
	p.z = 0.25 * (cos(u) - 2.0 * cos(w)) * A * B;
} // OpenGLExoticSurfaceTranguloidTrefoil

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceTriaxialTritorus(GLdouble u,
                                                GLdouble v,
                                                Math::Vector3<GLdouble>  &p)
{
	p.x = 2.0 * sin(u) * (1.0 + cos(v));
	p.y = 2.0 * sin(u + kTwoPiThird) * (1.0 + cos(v + kTwoPiThird));
	p.z = 2.0 * sin(u + kFourPiThird) * (1.0 + cos(v + kFourPiThird));
} // OpenGLExoticSurfaceTriaxialTritorus

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceStiletto(GLdouble u,
                                        GLdouble v,
                                        Math::Vector3<GLdouble>  &p)
{
	// reverse u and v for better distribution or points
    
	GLdouble s = u;
	GLdouble t = 0.0;
	GLdouble w = 0.0;
	
	u = v + kPi;
	v = 0.5 * (s + kPi); // convert to: 0 <= u <= 2 kPi, 0 <= v <= 2 kPi
	w = v + kTwoPiThird;
    
	t = pow(sin(w),2.0) * pow(cos(w),2.0);
	
	p.x =  4.0 * (2.0 + cos(u)) * pow(cos(v), 3.0) * sin(v);
	p.y =  4.0 * (2.0 + cos(u + kTwoPiThird)) * t;
	p.z = -4.0 * (2.0 + cos(u - kTwoPiThird)) * t;
} // OpenGLExoticSurfaceStiletto

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceSlippers(GLdouble u,
                                        GLdouble v,
                                        Math::Vector3<GLdouble>  &p)
{
	GLdouble w = u;
	GLdouble s = 0.0;
	GLdouble t = 0.0;
	
	u = v + kTwoPi;
	v = w + kPi; // convert to: 0 <= u <= 4 kPi, 0 <= v <= 2 kPi
    
	s = kTwoPiThird + v;
	t = kTwoPiThird - v;
	
	p.x =  4.0 * (2.0 + cos(u)) * pow(cos(v), 3.0) * sin(v);
	p.y =  4.0 * (2.0 + cos(u + kTwoPiThird)) * pow(cos(s), 2.0) * pow(sin(s), 2.0);
	p.z = -4.0 * (2.0 + cos(u - kTwoPiThird)) * pow(cos(t), 2.0) * pow(sin(t), 3.0);
} // OpenGLExoticSurfaceSlippers

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceMaedersOwl(GLdouble u,
                                          GLdouble v,
                                          Math::Vector3<GLdouble>  &p)
{
	GLdouble t = 0.0;
	GLdouble r = 0.0;
	GLdouble s = 0.0;
    
	u = 2.0 * (u + kPi);
	v = kTwoPiInv * (v + kPi); // convert to: 0 <= u <= 4 kPi, 0 <= v <= 1
	
	t = 2.0 * u;
	r = 0.5 * v * v;
	s = 3.0 * v;
	
	p.x =  s * cos(u) - r * cos(t);
	p.y = -s * sin(u) - r * sin(t);
	p.z =  4.0 * pow(v,1.5) * cos(1.5*u);
} // OpenGLExoticSurfaceMaedersOwl

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceDefault(GLdouble u,
                                       GLdouble v,
                                       Math::Vector3<GLdouble>  &p)
{
	p.x = 0.0;
	p.y = 0.0;
	p.z = 0.0;
} // OpenGLExoticSurfaceDefault

//------------------------------------------------------------------------
//
// From a surface type, get a function pointer for computing parametric
// values for a specific surface.
//
//------------------------------------------------------------------------

static OpenGLExoticSurfaceComputeFuncPtr OpenGLExoticSurfaceGetComputeFuncPtr(const OpenGLExoticSurfaceType surfaceType)
{
	OpenGLExoticSurfaceComputeFuncPtr glExoticSurfaceCompute = NULL;
	
	switch( surfaceType )
	{
		case kTranguloidTrefoil:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceTranguloidTrefoil;
			break;
			
		case kTriaxialTritorus:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceTriaxialTritorus;
			break;
            
		case kStilettoSurface:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceStiletto;
			break;
            
		case kSlipperSurface:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceSlippers;
			break;
            
		case kMaedersOwlSurface:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceMaedersOwl;
			break;
            
		case kDefaultSurface:
		default:
			glExoticSurfaceCompute = &OpenGLExoticSurfaceDefault;
			break;
	} // switch
	
	return glExoticSurfaceCompute;
} // OpenGLExoticSurfaceGetComputeFuncPtr

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceCreateWithType(const OpenGLExoticSurfaceType surfaceType,
                                              OpenGLExoticSurfaceGeometry *geometry)
{
	GLint       i;
	GLint       j;
	GLint       maxI    = geometry->mnRows;
	GLint       maxJ    = geometry->mnColumns;
	GLdouble    invMaxI = 1.0 / (GLdouble)maxI;
	GLdouble    invMaxJ = 1.0 / (GLdouble)maxJ;
	GLdouble    u[2]    = { 0.0, 0.0 };
	GLdouble    delta   = 0.0005;
    
	Math::Vector3<GLdouble>  position[2];
	
	OpenGLExoticSurfaceVertex  vertex;
	
	OpenGLExoticSurfaceComputeFuncPtr glExoticSurfaceCompute = OpenGLExoticSurfaceGetComputeFuncPtr( surfaceType );
    
	for( i = 0; i < maxI; i++ )
	{
		for( j = 0; j < maxJ; j++ )
		{
			u[0] = kTwoPi * (i % maxI) * invMaxI - kPi;
			u[1] = kTwoPi * (j % maxJ) * invMaxJ - kPi ;
			
			glExoticSurfaceCompute(u[0], u[1], vertex.positions);
			
			glExoticSurfaceCompute(u[0] + delta, u[1], position[0]);
			glExoticSurfaceCompute(u[0], u[1] + delta, position[1]);
			
			vertex.normals = normalv(vertex.positions, position[0], position[1]);
			
			vertex.texCoords.s = (GLdouble)i * invMaxI * 5.0;
			vertex.texCoords.t = (GLdouble)j * invMaxJ;
			
			geometry->m_Vertices.push_back(vertex);
		} // for
	} // for
} // OpenGLExoticSurfaceCreateWithType

//------------------------------------------------------------------------

static void OpenGLExoticSurfaceCreateVertex(const GLint index,
                                            OpenGLExoticSurfaceGeometry *geometry)
{
	glNormal3dv(geometry->m_Vertices[index].normals.array);
	glTexCoord2dv(geometry->m_Vertices[index].texCoords.array);
	glVertex3dv(geometry->m_Vertices[index].positions.array);
} // OpenGLExoticSurfaceCreateVertex

//------------------------------------------------------------------------

static GLuint OpenGLExoticSurfaceCreateDisplayList(OpenGLExoticSurfaceGeometry *geometry)
{
	GLuint  displayList = 0;
	
	GLint maxI = geometry->mnRows;
	GLint maxJ = geometry->mnColumns;
	
	if( (maxI > 0) && (maxJ > 0) )
	{
		displayList = glGenLists(1);
		
		glNewList(displayList, GL_COMPILE);
		{
			GLint   i;
			GLint   j;
			GLint   k;
			GLint   l;
			GLint   m;
			
			for( i = 0; i < maxI; i++ )
			{
				glBegin(GL_TRIANGLE_STRIP);
				
				for( j = 0; j <= maxJ; j++ )
				{
					m = j % maxJ;
					
					k = (i % maxI) * maxJ + m;
					
					OpenGLExoticSurfaceCreateVertex(k, geometry);
					
					l = ((i + 1) % maxI) * maxJ + m;
					
					OpenGLExoticSurfaceCreateVertex(l, geometry);
				} // for
				
				glEnd();
			} // for
		}
		glEndList();
	} // if
	
	return displayList;
} // OpenGLExoticSurfaceCreateDisplayList

//------------------------------------------------------------------------

static GLuint OpenGLExoticSurfaceCreateWithProperties(const OpenGLExoticSurfaceType surfaceType,
                                                      const GLuint subdivisions,
                                                      const GLuint xyRatio)
{
	OpenGLExoticSurfaceGeometry  geometry;
    
	geometry.mnRows    = subdivisions * xyRatio;
	geometry.mnColumns = subdivisions;
    
	// Build surface
    
	OpenGLExoticSurfaceCreateWithType(surfaceType, &geometry);
    
	// Now get the display list
    
	GLuint displayList = OpenGLExoticSurfaceCreateDisplayList(&geometry);
	
	return displayList;
} // OpenGLExoticSurfaceCreateWithProperties

//------------------------------------------------------------------------

//------------------------------------------------------------------------

@implementation OpenGLExoticSurface

//------------------------------------------------------------------------

//------------------------------------------------------------------------

- (id) initExoticSurfaceWithType:(const OpenGLExoticSurfaceType)theSurfaceType
					subdivisions:(const GLuint)theSubdivisions
						   ratio:(const GLuint)theRatio
{
	self = [super init];
	
	if( self )
	{
		mnDisplayList = OpenGLExoticSurfaceCreateWithProperties(theSurfaceType,
                                                                theSubdivisions,
                                                                theRatio);
	} // if
	
	return self;
} // initExoticSurfaceWithType

//------------------------------------------------------------------------

- (void) dealloc
{
	// delete the last used display list
	
	if( mnDisplayList )
	{
		glDeleteLists(mnDisplayList, 1);
	} // if
	
	[super dealloc];
} // dealloc

//------------------------------------------------------------------------

- (GLuint) displayList
{
	return mnDisplayList;
} // displayList

//------------------------------------------------------------------------

- (void) callList
{
	glCallList( mnDisplayList );
} // callList

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------
