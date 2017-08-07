//
//  SILayeredTemplateView.m
//  Photoroute
//
//  Created by Andreas Zöllner on 17.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//
#include <stdlib.h>
#import "SILayeredTemplateView.h"
#import <SVGKit/SVGKit.h>
#import <SVGKit/CALayerExporter.h>
#import "CALayer+flipPos.h"
#import "NSString+appendToFile.h"
#import "CGPathDescription.h"
#import "SILayerView.h"
#import "SIGeometry.h"

@implementation SILayeredTemplateView

@synthesize attributes, viewArray;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        viewArray = [NSMutableArray array];
        originalSize = self.visibleRect.size;
        inResize = NO;
    }
    
    return self;
}

-(void)loadSVGFromURL:(NSURL *)svgURL {
    svgImage = [SVGKImage imageWithContentsOfURL:svgURL];
    [svgImage scaleToFitInside:self.bounds.size];
    svgLayers = [NSMutableArray array];
    [self deepScanDOM:svgImage.DOMTree inImage:svgImage];
    [super setNeedsDisplay:YES];
    [[svgImage.NSImage TIFFRepresentation] writeToFile:[[[NSFileManager defaultManager] applicationSupportDirectory]stringByAppendingPathComponent:@"test.tif"] atomically:YES];
    [self resetContents];
}

-(void)deepScanDOM:(SVGElement*) rootElement inImage:(SVGKImage*)svgImage {
    int viewNum = 0;
    for (SVGElement* elem in rootElement.childNodes) {
        NSString* objectName = nil;
        if ([elem respondsToSelector:NSSelectorFromString(@"identifier")] && elem.identifier) {
            if ([elem.identifier rangeOfString:@"Ebene"].location == NSNotFound) {
                __strong CALayer* layer = [svgImage layerWithIdentifier:elem.identifier];
                [layer flipCoordinatesForRect:self.bounds];
                layer.geometryFlipped = YES;
                NSString* pattern = @"\\{(.+):(.+)\\}";
                NSRegularExpression* keyValuePattern = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
                NSTextCheckingResult* kVMatch = [keyValuePattern firstMatchInString:elem.identifier options:0 range:NSMakeRange(0, elem.identifier.length)];
                if (kVMatch.range.location != NSNotFound) {
                    NSString* objectClassName = [elem.identifier substringWithRange:[kVMatch rangeAtIndex:1]];
                    objectName = [elem.identifier substringWithRange:[kVMatch rangeAtIndex:2]];
                    if ([objectClassName isEqualToString:@"NSImage"]) {
                        /*CALayer* maskLayer = layer;
                        CALayer* imageLayer = [CALayer layer];
                        layer = [CALayer layer];
                        imageLayer.contents = [((NSImage*)[self.attributes valueForKey:objectName]) layerContentsForContentsScale:1.0];
                        imageLayer.frame = maskLayer.frame;
                        maskLayer.frame = NSMakeRect(0, 0, maskLayer.frame.size.width, maskLayer.frame.size.height);
                        imageLayer.mask = maskLayer;
                        [layer addSublayer:imageLayer];*/
                    } else if ([objectClassName isEqualToString:@"NSString"]) {
                        CATextLayer* textLayer = (CATextLayer*)layer;
                        layer = [CALayer new];
                        layer.frame = textLayer.frame;
                        layer.name = textLayer.name;
                        textLayer.frame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
                        [((CATextLayer*)textLayer) setString:[self.attributes valueForKey:objectName]];
                        [layer addSublayer:textLayer];
                    } else if ([objectClassName isEqualToString:@"NSView"]) {
                        __strong SILayerView* newView = [self.attributes valueForKey:objectName];
                        newView.frame = layer.frame;
                        newView.wantsLayer = YES;
                        newView.layer.zPosition = NSIntegerMax;
                        viewNum++;
                        [self addSubview:newView];
                        [self.viewArray addObject:newView];
                        [newView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior context:NULL];
                        layer = nil;
                        [svgLayers addObject:@{@"layer": newView, @"svgKey": elem.identifier, @"resizeable":@(YES), @"frame": [NSValue valueWithRect:newView.frame]}];
                    }
                }
                if ([elem.identifier rangeOfString:@"/Shadow:"].location != NSNotFound) {
                    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)/Shadow:([0-9\\.]*),([0-9\\.].*),([0-9\\.]*),([0-9\\.]*),([0-9\\.]*),([0-9\\.]*),([0-9\\.]*)" options:0 error:nil];
                    NSTextCheckingResult *match = [regex firstMatchInString:elem.identifier options:0 range: NSMakeRange(0, elem.identifier.length)];
                    layer.shadowColor = [NSColor colorWithCalibratedRed:[[elem.identifier substringWithRange:[match rangeAtIndex:1]]floatValue] green:[[elem.identifier substringWithRange:[match rangeAtIndex:2]]floatValue] blue:[[elem.identifier substringWithRange:[match rangeAtIndex:3]]floatValue] alpha:[[elem.identifier substringWithRange:[match rangeAtIndex:4]]floatValue]].CGColor;
                    layer.shadowOffset = CGSizeMake([[elem.identifier substringWithRange:[match rangeAtIndex:5]]floatValue], [[elem.identifier substringWithRange:[match rangeAtIndex:6]]floatValue]);
                    layer.shadowOpacity = 1;
                    layer.shadowRadius = [[elem.identifier substringWithRange:[match rangeAtIndex:7]]floatValue];
                }
                BOOL fixed = NO;
                NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)/Fixed:((?i)YES|(?i)NO)" options:0 error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:elem.identifier options:0 range: NSMakeRange(0, elem.identifier.length)];
                if ([match range].location != NSNotFound) {
                    if ([[elem.identifier substringWithRange:[match rangeAtIndex:1]] compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                        fixed = YES;
                    } else {
                        fixed = NO;
                    }
                }
                if (layer) {
                    __strong SILayerView* myView = [[SILayerView alloc] initWithFrame:self.bounds];
                    myView.wantsLayer = YES;
                    myView.viewNum = viewNum;
                    myView.
                    viewNum++;
                    [myView.layer addSublayer:layer];
                    [self addSubview:myView];
                    [self.viewArray addObject:myView];
                    [svgLayers addObject:@{@"layer": myView, @"svgKey": elem.identifier, @"resizeable":@(NO), @"fixed":@(fixed), @"pathContents":[self extractPathsFromLayer:((CAShapeLayer*)layer)], @"frame":[NSValue valueWithRect:layer.frame], @"contentKey":objectName}];
                }
            }
        }
        if (elem.hasChildNodes) {
            [self deepScanDOM:elem inImage:svgImage];
        }
    }
}

-(NSArray*)extractPathsFromLayer:(CALayer*)layer {
    NSMutableArray* array = [NSMutableArray array];
    for (CALayer* sublayer in layer.sublayers) {
        SILayerDescription* layerDesc = [SILayerDescription new];
        layerDesc.frame = sublayer.frame;
        layerDesc.name = sublayer.name;
        if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            // extract path
            CGPathRef path = ((CAShapeLayer*) sublayer).path;
            layerDesc.pathDescription = [CGPathDescription pathDescriptionFromPath:path];
            layerDesc.fillColor = [NSColor colorWithCGColor:((CAShapeLayer*)sublayer).fillColor];
            layerDesc.strokeWidth = ((CAShapeLayer*)sublayer).lineWidth;
            if (((CAShapeLayer*)sublayer).strokeColor)
                layerDesc.strokeColor = [NSColor colorWithCGColor:((CAShapeLayer*)sublayer).strokeColor];
        } else if (((CALayer*)sublayer).mask) {
            if ([((CALayer*)sublayer).mask isKindOfClass:[CAShapeLayer class]]) {
                // extract path
                CGPathRef path = ((CAShapeLayer*) ((CALayer*)sublayer).mask).path;
                
                //SILayerDescription* layerDesc = [SILayerDescription new];
                layerDesc.pathDescription = [CGPathDescription pathDescriptionFromPath:path];
                layerDesc.frame = ((CAShapeLayer*) ((CALayer*)sublayer).mask).frame;
                layerDesc.name = ((CAShapeLayer*) ((CALayer*)sublayer).mask).name;
                layerDesc.fillColor = [NSColor colorWithCGColor:((CAShapeLayer*) ((CALayer*)sublayer).mask).fillColor];
                layerDesc.strokeWidth = ((CAShapeLayer*) ((CALayer*)sublayer).mask).lineWidth;
                layerDesc.strokeColor = [NSColor colorWithCGColor:((CAShapeLayer*) ((CALayer*)sublayer).mask).strokeColor];
                //[array addObject:layerDesc];
            }
            if (((CALayer*)sublayer).mask.sublayers.count > 0) {
                [array addObjectsFromArray:[self extractPathsFromLayer:((CALayer*)sublayer).mask]];
            }
        } else if ([sublayer isKindOfClass:[CATextLayer class]]) {
            layerDesc.font = (__bridge NSFont *)(((CATextLayer*)sublayer).font);
            layerDesc.strokeWidth = ((CATextLayer*)sublayer).fontSize;
            layerDesc.fillColor = [NSColor colorWithCGColor:((CATextLayer*)sublayer).foregroundColor];
            layerDesc.textContent = ((CATextLayer*)sublayer).string;
        }
        if (sublayer.shadowColor  && CGColorGetAlpha(sublayer.shadowColor) > 0) {
            layerDesc.shadow = [NSShadow new];
            layerDesc.shadow.shadowColor = [NSColor colorWithCGColor:sublayer.shadowColor];
            layerDesc.shadow.shadowOffset = sublayer.shadowOffset;
            layerDesc.shadow.shadowBlurRadius = sublayer.shadowRadius;
        } else {
            layerDesc.shadow = nil;
        }
        [array addObject:layerDesc];
        if (((CALayer*)sublayer).sublayers.count > 0) {
            [array addObjectsFromArray:[self extractPathsFromLayer:sublayer]];
        }
    }
    if (layer.mask) {

    }
    return [NSArray arrayWithArray:array];
}

-(void)resetContents {
    CGFloat scaleFactor = scaleFactorForScaleFromSizeToSize(originalSize, self.visibleRect.size);
    for (NSDictionary* dict in svgLayers) {
        if ([[dict valueForKey:@"resizeable"] boolValue]) {
            NSView* myView = [dict valueForKey:@"layer"];
            if (inResize) {
                myView.frame = NSRectScaleByFactor([[dict valueForKey:@"frame"] rectValue], scaleFactor);
                [myView setNeedsDisplay:YES];
            }
        } else {
          if ([[dict valueForKey:@"fixed"] boolValue] == NO || inResize == YES) {
            NSArray* paths = [dict valueForKey:@"pathContents"];
            CALayer* layer = [[CALayer alloc] init];
            layer.geometryFlipped = YES;
            layer.name = [dict valueForKey:@"svgKey"];
            NSString* pattern = @"\\{(.+):(.+)\\}";
            NSRegularExpression* keyValuePattern = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
              NSTextCheckingResult* kVMatch = [keyValuePattern firstMatchInString:[dict valueForKey:@"svgKey"] options:0 range:NSMakeRange(0, ((NSString*)[dict valueForKey:@"svgKey"]).length)];
            NSString* objectClassName = nil;
            NSString* objectName = nil;
            if (kVMatch.range.location != NSNotFound) {
                  objectClassName = [[dict valueForKey:@"svgKey"] substringWithRange:[kVMatch rangeAtIndex:1]];
                  objectName = [[dict valueForKey:@"svgKey"] substringWithRange:[kVMatch rangeAtIndex:2]];
            }
            for (SILayerDescription* layerDesc in paths) {
                CALayer* shapeLayer;
                if (layerDesc.font) {
                    shapeLayer = [CATextLayer layer];
                    ((CATextLayer*)shapeLayer).font = (__bridge CFTypeRef)(layerDesc.font);
                    ((CATextLayer*)shapeLayer).fontSize = layerDesc.strokeWidth*scaleFactor;
                    ((CATextLayer*)shapeLayer).foregroundColor = layerDesc.fillColor.CGColor;
                    ((CATextLayer*)shapeLayer).string = [self.attributes valueForKey:[dict valueForKey:@"contentKey"]];
                } else {
                    shapeLayer = [CAShapeLayer layer];
                    CGPathRef path = [layerDesc.pathDescription pathRepresentationToFitInSize:self.bounds.size originalSize:originalSize];                    ((CAShapeLayer*)shapeLayer).path = path;
                    
                    /*if (layerDesc.fillColor && layerDesc.fillColor.alphaComponent > 0) {
                        float num = (float)arc4random_uniform(100)/100;
                        float num2 = (float)arc4random_uniform(100)/100;
                        float num3 = (float)arc4random_uniform(100)/100;
                        NSLog(@"fill shape %f/%f/%f", num, num2,num3);
                        ((CAShapeLayer*)shapeLayer).fillColor = [NSColor colorWithCalibratedRed:num green:num2 blue:num3 alpha:1].CGColor;
                    } else {*/
                        ((CAShapeLayer*)shapeLayer).fillColor = layerDesc.fillColor.CGColor;
                    //}
                    ((CAShapeLayer*)shapeLayer).lineWidth = layerDesc.strokeWidth*scaleFactor;
                    ((CAShapeLayer*)shapeLayer).strokeColor = layerDesc.strokeColor.CGColor;
                    if ([objectClassName isEqualToString:@"NSImage"]) {
                        
                    }
                }
                if (layerDesc.shadow) {
                    shapeLayer.shadowRadius = layerDesc.shadow.shadowBlurRadius*scaleFactor;
                    shapeLayer.shadowColor = layerDesc.shadow.shadowColor.CGColor;
                    shapeLayer.shadowOffset =  NSMakeSize(layerDesc.shadow.shadowOffset.width*scaleFactor, layerDesc.shadow.shadowOffset.height*scaleFactor);
                    shapeLayer.shadowOpacity = 1;
                }
                NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                                   [NSNull null], @"onOrderOut",
                                                   [NSNull null], @"sublayers",
                                                   [NSNull null], @"contents",
                                                   [NSNull null], @"bounds",
                                                   nil];
                shapeLayer.actions = newActions;
                shapeLayer.frame = layerDesc.frame;
                shapeLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
                shapeLayer.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
                shapeLayer.contentsGravity = kCAGravityResizeAspect;
                [layer addSublayer:shapeLayer];
            }
            __strong SILayerView* newView = [dict valueForKey:@"layer"];
            newView.wantsLayer = YES;
            if (newView) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:0];
                [CATransaction setDisableActions:YES];
                layer.frame = NSRectScaleByFactor([[dict valueForKey:@"frame"] rectValue], scaleFactor);
                
                NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                                   [NSNull null], @"onOrderOut",
                                                   [NSNull null], @"sublayers",
                                                   [NSNull null], @"contents",
                                                   [NSNull null], @"bounds",
                                                   nil];
                layer.actions = newActions;
                newView.layer = layer;
                layer.zPosition = newView.viewNum;
                newView.frame = self.bounds;
                [CATransaction commit];
            } else {
                NSLog(@"stored view not valid for '%@'", [dict valueForKey:@"svgKey"]);
            }
        } else {
            __strong NSView* myView = [dict valueForKey:@"layer"];
            myView.frame = self.bounds;
        }
        }
    }
    //[self sortSubviewsUsingFunction:&viewCompareByTag context:NULL];
}

NSComparisonResult viewCompareByTag(SILayerView *firstView, SILayerView *secondView, void *context) {
    if ([firstView isKindOfClass:[SILayerView class]] && [secondView isKindOfClass:[SILayerView class]]) {
        return ([firstView viewNum] < [secondView viewNum]) ? NSOrderedAscending : NSOrderedDescending;
    } else {
        if ([firstView isKindOfClass:[SILayerView class]]) return NSOrderedAscending;
        return NSOrderedDescending;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[NSView class]] && !inResize) {
        [self resetContents];
    }
}

-(void)viewWillStartLiveResize {
    inResize = YES;
    [super viewWillStartLiveResize];
}

-(void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    [self resetContents];
    inResize = NO;
}

-(void)setNeedsDisplay:(BOOL)flag {
    [self resetContents];
    [super setNeedsDisplay:flag];
}

-(void)dealloc {
    NSLog(@"dealloc template view");
    for (SILayerView* subview in self.subviews) {
        [subview removeObserver:self forKeyPath:@"frame"];
    }
}

@end
