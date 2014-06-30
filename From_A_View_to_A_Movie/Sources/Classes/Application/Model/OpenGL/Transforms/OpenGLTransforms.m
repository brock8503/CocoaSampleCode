/*
     File: OpenGLTransforms.m
 Abstract: 
 OpenGL utilities to matain MVP linear transformations.
 
  Version: 1.2
 
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

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLTransforms.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------------------

struct OpenGLVector
{
	GLdouble x;
	GLdouble y;
	GLdouble z;
};

typedef struct	OpenGLVector OpenGLVector;

//---------------------------------------------------------------------------------------

struct OpenGLClippingPlanes
{
	GLdouble left;
	GLdouble right;
	GLdouble top;
	GLdouble bottom;
	GLdouble near;
	GLdouble far;
};

typedef struct	OpenGLClippingPlanes  OpenGLClippingPlanes;

//---------------------------------------------------------------------------------------

struct OpenGLCamera
{
	OpenGLVector position;		// View position
	OpenGLVector direction;		// View direction vector
	OpenGLVector directionUp;	// View up direction
	GLdouble     aperture;		// camera aperture
	NSSize       size;			// current window/screen width & height
	NSPoint      origin;		// coordinate origins;
};

typedef struct	OpenGLCamera OpenGLCamera;

//---------------------------------------------------------------------------------------

struct OpenGLObjectSpin
{
	GLfloat world[4];
	GLfloat body[4];
	GLfloat trackball[4];
};

typedef struct	OpenGLObjectSpin OpenGLObjectSpin;

//---------------------------------------------------------------------------------------

struct OpenGLObjectTracking
{
	OpenGLObjectSpin  spin;			// 3d object spin states
	NSPoint           startPoint;	// dolly pan start point
};

typedef struct	OpenGLObjectTracking OpenGLObjectTracking;

//---------------------------------------------------------------------------------------

struct OpenGLObjectPhysics
{
	GLfloat spin[3];
	GLfloat velocity[3];
	GLfloat acceleration[3];
};

typedef struct	OpenGLObjectPhysics OpenGLObjectPhysics;

//---------------------------------------------------------------------------------------

struct OpenGLObject
{
	GLfloat               maxRadius;
	OpenGLObjectTracking  tracking;
	OpenGLObjectPhysics   physics;
};

typedef struct	OpenGLObject OpenGLObject;

//---------------------------------------------------------------------------------------

struct OpenGLStates
{
	BOOL mouseIsDown;
	BOOL dolly;
	BOOL pan;
	BOOL trackball;
	BOOL rotate;
};

typedef struct	OpenGLStates OpenGLStates;

//---------------------------------------------------------------------------------------

struct OpenGLTransformsData
{
	OpenGLCamera          camera;
	OpenGLClippingPlanes  planes;
	OpenGLObject          object;
	OpenGLStates          states;
};

typedef struct	OpenGLTransformsData OpenGLTransformsData;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Constants

//---------------------------------------------------------------------------------------

static const GLuint    kOpenGLTransformDataSize   = sizeof(OpenGLTransformsData);
static const GLfloat   kMaximumVelocity           = 2.0f;
static const GLdouble  kNearMinTolerance          = 0.00001;
static const GLdouble  kNearMaxTolerance          = 1.0;
static const GLdouble  kPI_D                      = (GLdouble)M_PI;
static const GLdouble  kHalfDegrees2Radians       = kPI_D / 360.0;
static const GLdouble  kCameraApertureScale       = -1.0 / 200.0;
static const GLdouble  kCameraPositionDollyZScale = -1.0 / 300.0;
static const GLdouble  kCameraPositionPanZScale   = -1.0 / 900.0;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLTransforms

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Default Initializer

//---------------------------------------------------------------------------------------
//
// Create a GL Context to use - i.e. init the superclass
//
//---------------------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		mpTransforms = (OpenGLTransformsDataRef)calloc(1, kOpenGLTransformDataSize);
		
		if( mpTransforms != NULL )
		{
			// Set State to rotate
			
			mpTransforms->states.rotate =  YES;
			
			// Object's maximum radius
			
			mpTransforms->object.maxRadius = 7.0f;
			
			// Object's initial states
			
			mpTransforms->object.physics.velocity[0] = 0.3;
			mpTransforms->object.physics.velocity[1] = 0.1;
			mpTransforms->object.physics.velocity[2] = 0.2;
			
			mpTransforms->object.physics.acceleration[0] =  0.003;
			mpTransforms->object.physics.acceleration[1] = -0.005;
			mpTransforms->object.physics.acceleration[2] =  0.004;
			
			// Camera initializations
			
			mpTransforms->camera.aperture      = 40.0;
			mpTransforms->camera.position.z    = -10.0;
			mpTransforms->camera.direction.z   = 10.0;
			mpTransforms->camera.directionUp.y = 1.0;
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Interaction - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                             From the default initializer." );
		}  // else
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------------------

- (id) initWithData:(NSData *)theData
{
	self = [super init];
	
	if( self )
	{
		mpTransforms = (OpenGLTransformsDataRef)calloc(1, kOpenGLTransformDataSize);
		
		if( mpTransforms != NULL )
		{
			// View attributes initilizations
			
			[theData getBytes:mpTransforms];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Object - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                        From the designated initializer using data." );
		}  // else
	} // if
	
	return( self );
} // initWithData

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	// View memory container isn't needed
	
	if( mpTransforms != NULL )
	{
		free( mpTransforms );
		
		mpTransforms = NULL;
	} //if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Scene Accessors

//---------------------------------------------------------------------------------------

- (NSData *) data
{
	return [NSData dataWithBytes:mpTransforms
						  length:kOpenGLTransformDataSize];
} // data

//---------------------------------------------------------------------------------------

- (BOOL) setData:(NSData *)theData
{
	BOOL bSuccess = theData != nil;
	
	if( bSuccess )
	{
		[theData getBytes:mpTransforms];
	} // if
	
	return bSuccess;
} // setData

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Rotation Accessors

//---------------------------------------------------------------------------------------

- (BOOL) rotation
{
	return( mpTransforms->states.rotate );
} // rotation

//---------------------------------------------------------------------------------------

- (void) setRotation:(const BOOL)theRotationState
{
	mpTransforms->states.rotate = theRotationState;
} // setRotation

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Updating Scene

//---------------------------------------------------------------------------------------
//
// Update the projection matrix based on camera and object bounds
//
//---------------------------------------------------------------------------------------

- (void) updateClippingPlanes
{
	GLdouble radians   = 0.0;
	GLdouble wd2       = 0.0;
	GLdouble maxRadius = 0.5 * mpTransforms->object.maxRadius;
	GLdouble ratio     = (GLdouble)(mpTransforms->camera.size.width/mpTransforms->camera.size.height);
	
	// set projection
	
	mpTransforms->planes.near = -(maxRadius + mpTransforms->camera.position.z);
	
	if( mpTransforms->planes.near < kNearMinTolerance )
	{
		mpTransforms->planes.near = kNearMinTolerance;
	} // if
	else if( mpTransforms->planes.near < kNearMaxTolerance )
	{
		mpTransforms->planes.near = kNearMaxTolerance;
	} // if
	
	mpTransforms->planes.far = maxRadius - mpTransforms->camera.position.z;
	
	radians = kHalfDegrees2Radians * mpTransforms->camera.aperture;
	wd2     = mpTransforms->planes.near * tan(radians);
	
	if( ratio >= 1.0 )
	{
		mpTransforms->planes.left   = -ratio * wd2;
		mpTransforms->planes.right  =  ratio * wd2;
		mpTransforms->planes.top    =  wd2;
		mpTransforms->planes.bottom = -wd2;
	} // if
	else
	{
		mpTransforms->planes.left   = -wd2;
		mpTransforms->planes.right  =  wd2;
		mpTransforms->planes.top    =  wd2 / ratio;
		mpTransforms->planes.bottom = -wd2 / ratio;
	} // else
} // updateClippingPlanes

//---------------------------------------------------------------------------------------

- (void) updateProjection
{
	[self updateClippingPlanes];
	
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	
	glFrustum(mpTransforms->planes.left,
			  mpTransforms->planes.right,
			  mpTransforms->planes.bottom,
			  mpTransforms->planes.top,
			  mpTransforms->planes.near,
			  mpTransforms->planes.far );
	
	glMatrixMode( GL_MODELVIEW );
} // updateProjection

//---------------------------------------------------------------------------------------
//
// Updates the contexts model object matrix for object and camera moves
//
//---------------------------------------------------------------------------------------

- (void) updateModelView
{
	// move object
	
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	gluLookAt(mpTransforms->camera.position.x,
			  mpTransforms->camera.position.y,
			  mpTransforms->camera.position.z,
			  mpTransforms->camera.position.x + mpTransforms->camera.direction.x,
			  mpTransforms->camera.position.y + mpTransforms->camera.direction.y,
			  mpTransforms->camera.position.z + mpTransforms->camera.direction.z,
			  mpTransforms->camera.directionUp.x,
			  mpTransforms->camera.directionUp.y,
			  mpTransforms->camera.directionUp.z);
	
	// if we have trackball rotation to map (this is the test one
	// would want as it can be explicitly 0.0f)
	
	if( mpTransforms->object.tracking.spin.trackball[0] != 0.0f )
	{
		glRotatef(mpTransforms->object.tracking.spin.trackball[0],
				  mpTransforms->object.tracking.spin.trackball[1],
				  mpTransforms->object.tracking.spin.trackball[2],
				  mpTransforms->object.tracking.spin.trackball[3]);
	} // if
	
	// accumlated world rotation via trackball
	
	glRotatef(mpTransforms->object.tracking.spin.world[0],
			  mpTransforms->object.tracking.spin.world[1],
			  mpTransforms->object.tracking.spin.world[2],
			  mpTransforms->object.tracking.spin.world[3]);
	
	// object itself rotating applied after camera rotation
	
	glRotatef(mpTransforms->object.tracking.spin.body[0],
			  mpTransforms->object.tracking.spin.body[1],
			  mpTransforms->object.tracking.spin.body[2],
			  mpTransforms->object.tracking.spin.body[3]);
	
	// reset animation rotations (do in all cases to prevent rotating
	// while moving with trackball)
	
	mpTransforms->object.physics.spin[0] = 0.0f;
	mpTransforms->object.physics.spin[1] = 0.0f;
	mpTransforms->object.physics.spin[2] = 0.0f;
} // updateModelView

//---------------------------------------------------------------------------------------

- (void) updateObjectVelocityAtIndex:(const GLshort)theIndex
								time:(const GLfloat)theTime
{
	mpTransforms->object.physics.velocity[theIndex] += theTime * mpTransforms->object.physics.acceleration[theIndex];
	
	if( mpTransforms->object.physics.velocity[theIndex] > kMaximumVelocity )
	{
		mpTransforms->object.physics.acceleration[theIndex] *= -1.0f;
		mpTransforms->object.physics.velocity[theIndex]      =  kMaximumVelocity;
	} // if
	else if( mpTransforms->object.physics.velocity[theIndex] < -kMaximumVelocity )
	{
		mpTransforms->object.physics.acceleration[theIndex] *= -1.0f;
		mpTransforms->object.physics.velocity[theIndex]      = -kMaximumVelocity;
	} // else if
} // updateObjectVelocity

//---------------------------------------------------------------------------------------

- (void) updateObjectSpinAtIndex:(const GLshort)theIndex
							time:(const GLfloat)theTime
{
	mpTransforms->object.physics.spin[theIndex] += theTime * mpTransforms->object.physics.velocity[theIndex];
	
	if( mpTransforms->object.physics.spin[theIndex] > 360.0f )
	{
		mpTransforms->object.physics.spin[theIndex] -= 360.0f;
	} // while
	else if( mpTransforms->object.physics.spin[theIndex] < -360.0f )
	{
		mpTransforms->object.physics.spin[theIndex] += 360.0f;
	} // while
} // updateObjectSpin

//---------------------------------------------------------------------------------------

- (void) updateObjectTrackingSpin
{
	GLfloat spin[4] = {0.0f, 0.0f, 0.0f, 0.0f};
	
	spin[0] = mpTransforms->object.physics.spin[0];
	spin[1] = 1.0f;
	
	[self add:spin
		   to:mpTransforms->object.tracking.spin.body];
	
	spin[0] = mpTransforms->object.physics.spin[1];
	spin[1] = 0.0f;
	spin[2] = 1.0f;
	
	[self add:spin
		   to:mpTransforms->object.tracking.spin.body];
	
	spin[0] = mpTransforms->object.physics.spin[2];
	spin[2] = 0.0f;
	spin[3] = 1.0f;
	
	[self add:spin
		   to:mpTransforms->object.tracking.spin.body];
} // updateObjectTrackingSpin

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Updating Scene

//---------------------------------------------------------------------------------------
//
// Given a delta time in seconds and current rotation acceleration, velocity and
// position, update overall object rotation, as well as skip pauses - for values
// that are greater than 10.0.
//
//---------------------------------------------------------------------------------------

- (BOOL) updateRotation:(const CFAbsoluteTime)theTime
{
	BOOL rotationUpdated = NO;
	
	if( mpTransforms->states.rotate )
	{
		CFAbsoluteTime  timeNow   = CFAbsoluteTimeGetCurrent();
		CFAbsoluteTime  timeDelta = timeNow - theTime;
		
		// Change the state of the object by updating the
		// object's rotation state for the time
		
		if( timeDelta <= 10.0 )
		{
			if( !mpTransforms->states.mouseIsDown && !mpTransforms->states.trackball )
			{
				GLfloat t = timeDelta * 20.0f;
				GLshort i;
				
				for( i = 0; i < 3; i++ )
				{
					[self updateObjectVelocityAtIndex:i
												 time:t];
					
					[self updateObjectSpinAtIndex:i
											 time:t];
				} // for
				
				[self updateObjectTrackingSpin];
				
				rotationUpdated = YES;
			} // if
		} // if
	} // if
	
	return rotationUpdated;
} // updateRotation

//---------------------------------------------------------------------------------------
//
// Handles resizing of OpenGL object, if the window dimensions change, window dimensions
// update, viewports reset, and projection matrix update.
//
//---------------------------------------------------------------------------------------

- (BOOL) updateView:(const NSRect *)theBounds
{
	BOOL viewBoundsChanged = NO;
	
	if( ( mpTransforms->camera.size.width  != theBounds->size.width  )
	   || ( mpTransforms->camera.size.height != theBounds->size.height ) )
	{
		viewBoundsChanged = YES;
	} // if
	
	GLsizei width  = (GLsizei)theBounds->size.width;
	GLsizei height = (GLsizei)theBounds->size.height;
	
	mpTransforms->camera.size = theBounds->size;
	
	glViewport( 0, 0, width, height );
	
	// Update projection matrix
	
	[self updateProjection];
	
	// update model-view matrix for the 3D object
	
	[self updateModelView];
	
	return viewBoundsChanged;
} // updateView

//---------------------------------------------------------------------------------------

- (BOOL) updateCameraAperture:(const GLdouble)theDelta
{
	BOOL cameraApertureUpdated = NO;
	
	if( theDelta )
	{
		GLdouble deltaAperture = kCameraApertureScale * mpTransforms->camera.aperture * theDelta;
		
		mpTransforms->camera.aperture += deltaAperture;
		
		if( mpTransforms->camera.aperture < 0.1 )
		{
			// do not let aperture <= 0.1
			
			mpTransforms->camera.aperture = 0.1;
		} // if
		
		if( mpTransforms->camera.aperture > 179.9 )
		{
			// do not let aperture >= 180
			
			mpTransforms->camera.aperture = 179.9;
		} // if
		
		// update projection matrix
		
		[self updateProjection];
		
		cameraApertureUpdated = YES;
	} // if
	
	return cameraApertureUpdated;
} // updateCameraAperture

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Moving Camera in 3D Space

//---------------------------------------------------------------------------------------
//
// Move camera in z axis
//
//---------------------------------------------------------------------------------------

- (void) mouseDolly:(const NSPoint *)theLocation
{
	GLdouble dollyDelta = (GLdouble)(mpTransforms->object.tracking.startPoint.y - theLocation->y);
	GLdouble dolly      = kCameraPositionDollyZScale * mpTransforms->camera.position.z * dollyDelta;
	
	mpTransforms->camera.position.z += dolly;
	
	// do not let z = 0.0
	
	if( mpTransforms->camera.position.z == 0.0 )
	{
		mpTransforms->camera.position.z = 0.0001;
	} // if
	
	mpTransforms->object.tracking.startPoint = *theLocation;
} // mouseDolly

//---------------------------------------------------------------------------------------
//
// Move camera in x/y plane
//
//---------------------------------------------------------------------------------------

- (void) mousePan:(const NSPoint *)theLocation
{
	GLdouble factor = kCameraPositionPanZScale * mpTransforms->camera.position.z;
	
	GLdouble panX = factor * ((GLdouble)(mpTransforms->object.tracking.startPoint.x - theLocation->x));
	GLdouble panY = factor * ((GLdouble)(mpTransforms->object.tracking.startPoint.y - theLocation->y));
	
	mpTransforms->camera.position.x -= panX;
	mpTransforms->camera.position.y -= panY;
	
	mpTransforms->object.tracking.startPoint = *theLocation;
} // mousePan

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Interacting With the Mouse

//---------------------------------------------------------------------------------------
//
// Left Mouse
//
//---------------------------------------------------------------------------------------

- (void) mouseIsDown:(NSPoint *)theLocation
{
	theLocation->y = mpTransforms->camera.size.height - theLocation->y;
	
	mpTransforms->states.dolly     = NO;	// no dolly
	mpTransforms->states.pan       = NO;	// no pan
	mpTransforms->states.trackball = YES;
	
	[self start:theLocation
		 origin:&mpTransforms->camera.origin
		   size:&mpTransforms->camera.size];
	
	mpTransforms->states.mouseIsDown = YES;
} // mouseIsDownUpdate

//---------------------------------------------------------------------------------------
//
// Pan
//
//---------------------------------------------------------------------------------------

- (void) rightMouseIsDown:(NSPoint *)theLocation
{
	theLocation->y = mpTransforms->camera.size.height - theLocation->y;
	
	if( mpTransforms->states.trackball )
	{
		// if we are currently tracking, end trackball
		
		if( mpTransforms->object.tracking.spin.trackball[0] != 0.0 )
		{
			[self add:mpTransforms->object.tracking.spin.trackball
				   to:mpTransforms->object.tracking.spin.world];
		} // if
		
		mpTransforms->object.tracking.spin.trackball[0] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[1] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[2] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[3] = 0.0f;
	} // if
	
	mpTransforms->object.tracking.startPoint = *theLocation;
	
	mpTransforms->states.dolly       = NO;	// no dolly
	mpTransforms->states.pan         = YES;
	mpTransforms->states.trackball   = NO;	// no trackball
	mpTransforms->states.mouseIsDown = YES;
} // rightMouseIsDownUpdate

//---------------------------------------------------------------------------------------
//
// Dolly
//
//---------------------------------------------------------------------------------------

- (void) otherMouseIsDown:(NSPoint *)theLocation
{
	theLocation->y = mpTransforms->camera.size.height - theLocation->y;
	
	if( mpTransforms->states.trackball )
	{
		// if we are currently tracking, end trackball
		
		if( mpTransforms->object.tracking.spin.trackball[0] != 0.0 )
		{
			[self add:mpTransforms->object.tracking.spin.trackball
				   to:mpTransforms->object.tracking.spin.world];
		} // if
		
		mpTransforms->object.tracking.spin.trackball[0] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[1] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[2] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[3] = 0.0f;
	} // if
	
	mpTransforms->object.tracking.startPoint = *theLocation;
	
	mpTransforms->states.dolly       = YES;
	mpTransforms->states.pan         = NO;	// no pan
	mpTransforms->states.trackball   = NO;	// no trackball
	mpTransforms->states.mouseIsDown = YES;
} // otherMouseIsDownUpdate

//---------------------------------------------------------------------------------------

- (void) mouseIsUp
{
	if( mpTransforms->states.dolly )
	{
		// end dolly
		
		mpTransforms->states.dolly = NO;
	} // if
	else if( mpTransforms->states.pan )
	{
		// end pan
		
		mpTransforms->states.pan = NO;
	} // else if
	else if( mpTransforms->states.trackball )
	{
		// end trackball
		
		mpTransforms->states.trackball = NO;
		
		if( mpTransforms->object.tracking.spin.trackball[0] != 0.0 )
		{
			[self add:mpTransforms->object.tracking.spin.trackball
				   to:mpTransforms->object.tracking.spin.world ];
		} // if
		
		mpTransforms->object.tracking.spin.trackball[0] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[1] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[2] = 0.0f;
		mpTransforms->object.tracking.spin.trackball[3] = 0.0f;
	} // else if
	
	mpTransforms->states.mouseIsDown = NO;
} // mouseIsUp

//---------------------------------------------------------------------------------------

- (void) mouseIsDragged:(NSPoint *)theLocation
{
	theLocation->y = mpTransforms->camera.size.height - theLocation->y;
	
	if( mpTransforms->states.trackball )
	{
		[self roll:theLocation
				to:mpTransforms->object.tracking.spin.trackball];
	} // if
	else if( mpTransforms->states.dolly )
	{
		[self mouseDolly:theLocation];
		
		// update projection matrix (not normally done on draw)
		
		[self updateProjection];
	} // else if
	else if( mpTransforms->states.pan )
	{
		[self mousePan:theLocation];
	} // if
} // mouseIsDragged

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

