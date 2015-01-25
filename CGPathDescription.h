//
//  CGPathDescription.h
//  Photoroute
//
//  Created by Andreas Zöllner on 18.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//
#import "GTMGeometryUtils.h"
#import <Foundation/Foundation.h>

@interface CGPathDescription : NSObject

@property (strong) NSMutableArray* pointArray;
+(CGPathDescription*)pathDescriptionFromPath:(CGPathRef)pathref;

-(CGPathRef)pathRepresentation;
-(CGPathRef)pathRepresentationToFitInSize:(NSSize)size originalSize:(NSSize)oldSize;
@end


@interface CGPathPoint : NSObject
@property (strong) NSMutableArray* points;
@property (assign) CGPathElementType type;

@end

@interface SILayerDescription : NSObject
@property (strong) CGPathDescription* pathDescription;
@property (strong) NSColor* fillColor;
@property (strong) NSColor* strokeColor;
@property (strong) NSString* name;
@property (assign) NSInteger strokeWidth;
@property (strong) NSString* textContent;
@property (strong) NSFont* font;
@property (assign) NSRect frame;
@property (strong) NSShadow* shadow;
@property (assign) BOOL isMaskLayer;
@end