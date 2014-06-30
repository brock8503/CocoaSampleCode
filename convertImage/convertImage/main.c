/*
     File: main.c
 Abstract: 
 This sample shows how to convert any image to sRGB applying Black Point
 Compensation (BPC) using ImageIO, ColorSync and vImage.
 
 To build from the command line:
 
 cc -g -O0 -o convertimage convertimage.c -Wall -framework ApplicationServices -framework Accelerate
 
 To run from the command line:
 
 ./convertimage "path to source image" "path to destination image"
 
 e.g. ./convertimage myCMYKImage.jpg mySRGBImage.jpg
 
 
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

#include <stdlib.h>
#include <Accelerate/Accelerate.h>
#include <ApplicationServices/ApplicationServices.h>

/* Enable (1) or Disable (0) blackpoint compensation for output */
#define BPC_ON (1)

/* ---------------------------------------------------------
 **  readImage
 **
 ** Creates and returns a CGImageRef and type identifier for the
 ** image specified by the provided image path.
 ** ------------------------------------------------------- */

static CGImageRef readImage(const char* imagePath, CFStringRef* imageType)
{
    CGImageRef image = NULL;
    
    CFStringRef cfpath = CFStringCreateWithCString(NULL, imagePath, kCFStringEncodingUTF8);
    
    if (cfpath)
    {
        CFURLRef url;
        
        CGImageSourceRef source;
        
        url = CFURLCreateWithFileSystemPath(NULL, cfpath, kCFURLPOSIXPathStyle, 0);
        
        CFRelease(cfpath);
        
        /* Create an image source reading from `url' */
        source = CGImageSourceCreateWithURL (url, NULL);
        
        /* create CGImageRef for the image source */
        image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        /* get and return type identitier of image source  */
        if (imageType) *imageType = CGImageSourceGetType(source);
        
        /* cleanup */
        if (url)
            CFRelease(url);
        CFRelease (source);
    }
    
    return image;
}

/* ---------------------------------------------------------
 **  createColorSyncCodeFragment
 **
 ** Creates a ColorSync transform with optional black point
 ** compensation for a given source and destination profile.
 ** Returns a code fragment from this transform for the full
 ** color conversion.
 ** The BPC parameter passed to this function determines 
 ** whether to enable or disable black point compensation
 ** during the conversion.
 ** ------------------------------------------------------- */

static CFTypeRef createColorSyncCodeFragment (ColorSyncProfileRef srcProfile, ColorSyncProfileRef dstProfile, bool BPC)
{
    CFTypeRef codeFragment = NULL;
    
    if (srcProfile && dstProfile)
    {
        /* specify keys that define the profile object and the information on the usage of the profile in the transform. These are needed when creating the actual transform below. */
        const void *keys[] = {
            kColorSyncProfile,
            kColorSyncRenderingIntent,
            kColorSyncTransformTag,
            kColorSyncBlackPointCompensation
        };
        
        const void *srcVals[] = {
            srcProfile,
            /* BPC uses relative colorimetric intent for conversions */
            BPC ? kColorSyncRenderingIntentRelative: kColorSyncRenderingIntentPerceptual,
            kColorSyncTransformDeviceToPCS,
            BPC ? kCFBooleanTrue : kCFBooleanFalse
        };
        
        const void *dstVals[] = {
            dstProfile,
            /* BPC uses relative colorimetric intent for conversions */
            BPC ? kColorSyncRenderingIntentRelative: kColorSyncRenderingIntentPerceptual,
            kColorSyncTransformPCSToDevice,
            BPC ? kCFBooleanTrue : kCFBooleanFalse
        };
        
        /* create a dictionary of the transform keys for the source and destination
         profiles. */
        CFDictionaryRef srcDict = CFDictionaryCreate (
                                                      NULL,
                                                      (const void **)keys,
                                                      (const void **)srcVals,
                                                      4,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
        
        CFDictionaryRef dstDict = CFDictionaryCreate (
                                                      NULL,
                                                      (const void **)keys,
                                                      (const void **)dstVals,
                                                      4,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
        
        const void* arrayVals[] = {srcDict, dstDict, NULL};
        
        CFArrayRef profileSequence = CFArrayCreate(NULL, (const void **)arrayVals, 2, &kCFTypeArrayCallBacks);
        
        if (srcDict) CFRelease (srcDict);
        if (dstDict) CFRelease (dstDict);
        
        /* create the transform to be used for converting color */
        ColorSyncTransformRef transform = ColorSyncTransformCreate (profileSequence, NULL);
        
        if (profileSequence) CFRelease (profileSequence);
        
        /* get the code fragment specifying the full conversion */
        codeFragment = ColorSyncTransformCopyProperty(transform, kColorSyncTransformFullConversionData, NULL);
        
        if (transform) CFRelease (transform);
        
#if DEBUG
        if (codeFragment) CFShow(codeFragment);
#endif
    }
    
    return  codeFragment;
}

/* ---------------------------------------------------------
 **  initvImageCGImageFormat
 **
 ** Populates a vImage_CGImageFormat with parameters from a CGImageRef.
 ** Note: the colorspace and decode array are owned by the CGImage.
 ** If you need the vImage_CGImageFormat to outlast the CGImage, retain
 ** the colorspace and copy the decode array.
 ** ------------------------------------------------------- */

static void initvImageCGImageFormat(CGImageRef image, vImage_CGImageFormat* format) {
    format->bitsPerComponent = (unsigned int)CGImageGetBitsPerComponent(image);
    format->bitsPerPixel = (unsigned int)CGImageGetBitsPerPixel(image);
    format->colorSpace = CGImageGetColorSpace(image);
    format->bitmapInfo = CGImageGetBitmapInfo(image);
    format->renderingIntent = CGImageGetRenderingIntent(image);
    format->version = 0;
    format->decode = CGImageGetDecode(image);
}

/* ---------------------------------------------------------
 **  convertImage
 **
 **  Use vImage and the specified code fragment transform to
 **  convert the input image to the destination color space.
 **
 **  Note that this method will have some other side effects.
 **  It will flatten any image masks into the image. If output
 **  format has no alpha and an image mask is present then a
 **  flattening operation will be performed against the background
 **  color and the alpha information will be removed entirely
 **  from the image. This is easily corrected by adding an alpha
 **  channel if there isn’t one to the output format. It will also
 **  lose track of any other metadata attached to the original
 **  image because you are creating a new CGImageRef from what is
 **  just a pile of pixels. Use ImageIO to access original image
 **  metadata if needed, and possibly add relevant parts to the
 **  output image.
 ** ------------------------------------------------------- */

static CGImageRef convertImage (CGImageRef inpImage, ColorSyncProfileRef dstProfile, CFTypeRef codeFragment)
{
    CGImageRef outImage = NULL;
    
    /* Initialize source buffer */
    vImage_Buffer buf; /* a temporary buffer to hold the post conversion results */
    /* Input format of image. If it doesn't match the native format of the image, vImageBuffer_InitWithCGImage
     will convert to the format specified. */
    vImage_CGImageFormat inpFormat;
    memset(&inpFormat, 0, sizeof(vImage_CGImageFormat));
    
    /* Which format is set here is unimportant. If your image processing pipeline demands a specific format, use that. */
    initvImageCGImageFormat(inpImage, &inpFormat);
    
    /* decode input image and convert to vImage_Buffer of the requested format. buf.data will be overwritten with a malloc allocated pointer to the image data. The height, width and rowBytes of the image are also updated. */
    vImage_Error err = vImageBuffer_InitWithCGImage( &buf, &inpFormat, NULL, inpImage, kvImageNoFlags );
    
    /* If that worked, convert to the new format using the codeFragment transform provided. */
    if (err == kvImageNoError)
    {
        /* Initialize destination buffer */
        CGColorSpaceRef dstColorSpace = CGColorSpaceCreateWithPlatformColorSpace (dstProfile);
        CGFloat* backgroundColor = NULL; /* provide background color if needed */
        vImage_CGImageFormat outFormat =
        {
            .bitsPerComponent = (unsigned int)CGImageGetBitsPerComponent(inpImage), /* preserve original */
            .bitsPerPixel = (unsigned int)CGImageGetBitsPerComponent(inpImage) * (unsigned int)(CGColorSpaceGetNumberOfComponents( dstColorSpace ) + (kCGImageAlphaNone != CGImageGetAlphaInfo(inpImage))),
            .colorSpace = dstColorSpace, /* colorspace here should have same number of channels as destination image in code fragment */
            .bitmapInfo = CGImageGetBitmapInfo(inpImage),/* copy from the original */
            .version = 0,
            .decode = NULL, /* non-NULL if you want a decode array, or for float L*a*b* which needs one */
            .renderingIntent = kCGRenderingIntentDefault /* irrelevant here ; it's applied by codeFragment */
        };
        
        /* Attempt to run faster by using the conversion in place. This touches less memory and can run quicker. */
        vImage_Buffer buf2 = buf; /* temporarily set buf2 to be an alias to buf */
        
        /* create a converter to do the (BPC) conversion. */
        vImageConverterRef converter = vImageConverter_CreateWithColorSyncCodeFragment( codeFragment, &inpFormat, &outFormat, backgroundColor, kvImageNoFlags, &err );
        
        /* Check to see if the converter will work in place. */
        vImage_Error outOfPlace = vImageConverter_MustOperateOutOfPlace(converter, NULL, NULL, kvImageNoFlags);
        
        /* if it doesn't work in place, we change buf2 from an alias to buf to use its own independent buffer */
        if (outOfPlace)
            err = vImageBuffer_Init( &buf2, buf.height, buf.width, outFormat.bitsPerPixel, kvImageNoFlags ); /* allocate a second buffer */
        
        /* Do the conversion */
        if (err == kvImageNoError)
            /* you will get kvImageInvalidParameter if backgroundColor is NULL
             and the conversion needed a backgroundColor */
            err = vImageConvert_AnyToAny( converter, &buf, &buf2, NULL, kvImageNoFlags );
        
        /* Make a new image */
        
        /* Wrap the image created in buf2 with a CGImageRef. Here we pass kvImageNoAllocate to cause the CGImageRef to use the buf2.data directly as its underlying pixel buffer. This avoids a data copy. Instead the ownership of that piece of memory is transferred to the CGImageRef. If the memory needed a custom deallocator (that is, not free()) then you can pass a non-NULL deallocator callback here. In this example, we pass NULL, because the buffer was initialized by either vImageBuffer_Init or vImageBuffer_InitWithCGImage */
        if (err == kvImageNoError)
            outImage = vImageCreateCGImageFromBuffer( &buf2, &outFormat, NULL, NULL, kvImageNoAllocate, &err );	/* assumes ownership of buf2.data */
        
        /* in the case that we couldn't run in place, buf2 didn't alias buf, so we need to free buf.data */
        if (outOfPlace)
            free(buf.data);
        
        /* cleanup the colorspace we created above */
        if (dstColorSpace)
            CFRelease(dstColorSpace);
        
        /* cleanup the converter. Note: that if you plan to process a bunch of images in this way, it would be more efficient to reuse the converter rather than creating a new one each time. vImageConverterRefs that do colorspace conversion can be expensive to create, particularly those that involve multidimensional lookup tables, typically those that convert to/from CMYK. */
        vImageConverter_Release(converter);
    }
    
    return outImage;
}

/* ---------------------------------------------------------
 **  saveImage
 **
 ** Saves a CGImage of the designated type in the location
 ** specified by the image path.
 ** ------------------------------------------------------- */

static void saveImage(CGImageRef image, const char* imagePath, CFStringRef imageType)
{
    CFStringRef cfpath;
    
    cfpath = CFStringCreateWithCString(NULL, imagePath, kCFStringEncodingUTF8);
    
    if (cfpath && image)
    {
        CGImageDestinationRef dest;
        
        /* create URL for the file system path */
        CFURLRef url = CFURLCreateWithFileSystemPath(NULL,
                                                     cfpath,
                                                     kCFURLPOSIXPathStyle,
                                                     0);
        /* Create an image destination writing to `url' */
        dest = CGImageDestinationCreateWithURL(url, imageType, 1, NULL);
        /* Set the next image in the image destination */
        CGImageDestinationAddImage(dest, image, NULL);
        /* Write everything to the destination url */
        CGImageDestinationFinalize(dest);
        
        CFRelease(url);
        CFRelease(dest);
    }
    
    if (cfpath != NULL)
        CFRelease(cfpath);

}

/* ---------------------------------------------------------
 **  main
 **
 **  Convert input image to the sRGB color space and apply 
 **  black point compensation.
 ** ------------------------------------------------------- */

int main (int argc, char **argv)
{
    if (argc != 3)
    {
        fprintf (stderr, "Usage: convertimage INPUT_IMAGE OUTPUT_IMAGE\n");
        return (-1);
    }
    
    const char* srcImagePath = argv[1];
    const char* dstImagePath = argv[2];
    
    CFStringRef imageType = NULL;
    
    CGImageRef srcImage = readImage (srcImagePath, &imageType);
    
    CFDataRef srcProfileData = CGColorSpaceCopyICCProfile (CGImageGetColorSpace(srcImage));
    
    /* create profile based on the source image color space */
    ColorSyncProfileRef srcProfile = ColorSyncProfileCreate (srcProfileData, NULL);
    
    if (srcProfileData)
        CFRelease (srcProfileData);
    
    /* create sRGB destination profile */
    ColorSyncProfileRef dstProfile = ColorSyncProfileCreateWithName(kColorSyncSRGBProfile);
    
    /* create a ColorSync transform with optional black point compensation (BPC) for the given 
     source and destination profiles */
    CFTypeRef codeFragment = createColorSyncCodeFragment (srcProfile, dstProfile, BPC_ON /* BPC */);
    
    if (srcProfile)
        CFRelease(srcProfile);
    
    /* convert source image to the destination color space using black point compensation */
    CGImageRef dstImage = convertImage (srcImage, dstProfile, codeFragment);
    
    /* cleanup */
    if (srcImage)
        CFRelease(srcImage);
    if (dstProfile)
        CFRelease(dstProfile);
    if (codeFragment)
        CFRelease (codeFragment);
    
    /* save the converted image */
    saveImage (dstImage, dstImagePath, imageType);
    
    if (dstImage)
        CFRelease (dstImage);
    
    return 0;
}
