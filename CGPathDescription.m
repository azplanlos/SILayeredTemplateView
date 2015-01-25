//
//  CGPathDescription.m
//  Photoroute
//
//  Created by Andreas Zöllner on 18.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "CGPathDescription.h"

@interface CGPathDescription ()
    void myCGPathApplierFunc (void *info, const CGPathElement *element);

@end

@implementation CGPathDescription
@synthesize pointArray;

+(CGPathDescription*)pathDescriptionFromPath:(CGPathRef)pathref {
    CGPathDescription* myDesc = [CGPathDescription new];
    NSMutableArray* pathContents = [NSMutableArray array];
    CGPathApply(pathref, (__bridge void *)(pathContents), myCGPathApplierFunc);
    NSLog(@"path contains %i points", pathContents.count);
    myDesc.pointArray = pathContents;
    return myDesc;
}

-(CGPathRef)pathRepresentation {
    CGMutablePathRef myPath = CGPathCreateMutable();
    for (CGPathPoint* point in pointArray) {
        if (point.type == kCGPathElementMoveToPoint) {
            NSPoint pointVal = [[point.points objectAtIndex:0] pointValue];
            CGPathMoveToPoint(myPath, NULL, pointVal.x, pointVal.y);
        } else if (point.type == kCGPathElementAddLineToPoint) {
            NSPoint pointVal = [[point.points objectAtIndex:0] pointValue];
            CGPathAddLineToPoint(myPath, NULL, pointVal.x, pointVal.y);
        } else if (point.type == kCGPathElementAddCurveToPoint) {
            NSPoint pointVal = [[point.points objectAtIndex:0] pointValue];
            NSPoint pointVal1 = [[point.points objectAtIndex:1] pointValue];
            NSPoint pointVal2 = [[point.points objectAtIndex:2] pointValue];
            CGPathAddCurveToPoint(myPath, NULL, pointVal.x, pointVal.y, pointVal1.x, pointVal1.y, pointVal2.x, pointVal2.y);
        } else if (point.type == kCGPathElementAddQuadCurveToPoint) {
            NSPoint pointVal = [[point.points objectAtIndex:0] pointValue];
            NSPoint pointVal1 = [[point.points objectAtIndex:1] pointValue];
            CGPathAddQuadCurveToPoint(myPath, NULL, pointVal.x, pointVal.y, pointVal1.x, pointVal1.y);
        } else if (point.type == kCGPathElementCloseSubpath) {
            CGPathCloseSubpath(myPath);
        }
    }
    return myPath;
}

-(CGPathRef)pathRepresentationToFitInSize:(NSSize)size originalSize:(NSSize)oldSize {
    CGPathRef pathRef = [self pathRepresentation];
    CGFloat boundingBoxAspectRatio = oldSize.width/oldSize.height;
    CGFloat viewAspectRatio = size.width/size.height;
    
    CGFloat scaleFactor = 1.0;
    if (boundingBoxAspectRatio > viewAspectRatio) {
        // Width is limiting factor
        scaleFactor = size.width/oldSize.width;
    } else {
        // Height is limiting factor
        scaleFactor = size.height/oldSize.height;
    }
    
    
    // Scaling the path ...
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    // Scale down the path first
    scaleTransform = CGAffineTransformScale(scaleTransform, scaleFactor, scaleFactor);
    // Then translate the path to the upper left corner
    scaleTransform = CGAffineTransformTranslate(scaleTransform, 0, 0);
    
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(pathRef,
                                                              &scaleTransform);
    
    CGPathRelease(pathRef); // release the copied path
    return scaledPath;
}

@end

void myCGPathApplierFunc (void *info, const CGPathElement *element) {
    CGPathPoint* myPoint = [CGPathPoint new];
    myPoint.type = element->type;
    int numPoints = 1;
    if (element->type ==
        kCGPathElementAddCurveToPoint) {
        numPoints = 3;
    } else if (element->type == kCGPathElementAddQuadCurveToPoint) {
        numPoints = 2;
    } else if (element->type == kCGPathElementCloseSubpath) {
        numPoints = 0;
    }
    for (int i = 0; i<numPoints; i++) {
        NSValue* apoint = [NSValue valueWithPoint:NSPointFromCGPoint(element->points[i])];
        [myPoint.points addObject:apoint];
    }
    [((__bridge NSMutableArray*)info) addObject:myPoint];
}

@implementation CGPathPoint

@synthesize points, type;

-(id)init {
    self = [super init];
    points = [NSMutableArray array];
    return self;
}

@end

@implementation SILayerDescription

@synthesize textContent, font, name, strokeColor, fillColor, strokeWidth, frame, pathDescription, shadow;

@end