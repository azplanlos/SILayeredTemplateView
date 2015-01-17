//
//  SILayeredTemplateView.m
//  Photoroute
//
//  Created by Andreas Zöllner on 17.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "SILayeredTemplateView.h"
#import <SVGKit/SVGKit.h>
#import "CALayer+flipPos.h"

@implementation SILayeredTemplateView

@synthesize attributes;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
    }
    
    return self;
}

-(void)loadSVGFromURL:(NSURL *)svgURL {
    svgImage = [SVGKImage imageWithContentsOfURL:svgURL];
    [svgImage scaleToFitInside:self.bounds.size];
    [self deepScanDOM:svgImage.DOMTree inImage:svgImage];
    [self setNeedsDisplay:YES];
    NSLog(@"superview %f", [self.superview isFlipped]);
    [[svgImage.NSImage TIFFRepresentation] writeToFile:[[[NSFileManager defaultManager] applicationSupportDirectory]stringByAppendingPathComponent:@"test.tif"] atomically:YES];
}

-(void)deepScanDOM:(SVGElement*) rootElement inImage:(SVGKImage*)svgImage {
    for (SVGElement* elem in rootElement.childNodes) {
        if ([elem respondsToSelector:NSSelectorFromString(@"identifier")] && elem.identifier) {
            if ([elem.identifier rangeOfString:@"Ebene"].location == NSNotFound) {
                CALayer* layer = [svgImage layerWithIdentifier:elem.identifier];
                [layer flipCoordinatesForRect:self.bounds];
                NSLog(@"SVG element '%@' (%@) bounds: %0.0f/%0.0f/%0.0f/%0.0f", elem.identifier,layer.className, layer.frame.origin.x, layer.frame.origin.y, layer
                      .frame.size.width, layer.frame.size.height);
                layer.geometryFlipped = YES;
                NSString* pattern = @"\\{(.+):(.+)\\}";
                NSRegularExpression* keyValuePattern = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
                NSTextCheckingResult* kVMatch = [keyValuePattern firstMatchInString:elem.identifier options:0 range:NSMakeRange(0, elem.identifier.length)];
                if (kVMatch.range.location != NSNotFound) {
                    NSString* objectClassName = [elem.identifier substringWithRange:[kVMatch rangeAtIndex:1]];
                    NSString* objectName = [elem.identifier substringWithRange:[kVMatch rangeAtIndex:2]];
                    NSLog(@"key value object '%@' of type %@", objectName, objectClassName);
                    if ([objectClassName isEqualToString:@"NSImage"]) {
                        CALayer* maskLayer = layer;
                        CALayer* imageLayer = [CALayer layer];
                        layer = [CALayer layer];
                        imageLayer.contents = [((NSImage*)[self.attributes valueForKey:objectName]) layerContentsForContentsScale:1.0];
                        imageLayer.frame = maskLayer.frame;
                        maskLayer.frame = NSMakeRect(0, 0, maskLayer.frame.size.width, maskLayer.frame.size.height);
                        imageLayer.mask = maskLayer;
                        [layer addSublayer:imageLayer];
                    } else if ([objectClassName isEqualToString:@"NSString"]) {
                        NSLog(@"string content: %@", ((CATextLayer*)layer).string);
                        [((CATextLayer*)layer) setString:[self.attributes valueForKey:objectName]];
                    } else if ([objectClassName isEqualToString:@"NSView"]) {
                        NSView* newView = [self.attributes valueForKey:objectName];
                        newView.frame = layer.frame;
                        [self addSubview:newView];
                        layer = nil;
                    }
                }
                if ([elem.identifier rangeOfString:@"/Shadow:"].location != NSNotFound) {
                    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"/Shadow:(.*)/(.*)/(.*)/(.*),(.*),(.*),(.*)" options:0 error:nil];
                    NSTextCheckingResult *match = [regex firstMatchInString:elem.identifier options:0 range: NSMakeRange(0, elem.identifier.length)];
                    layer.shadowColor = [NSColor colorWithCalibratedRed:[[elem.identifier substringWithRange:[match rangeAtIndex:1]]floatValue] green:[[elem.identifier substringWithRange:[match rangeAtIndex:2]]floatValue] blue:[[elem.identifier substringWithRange:[match rangeAtIndex:3]]floatValue] alpha:[[elem.identifier substringWithRange:[match rangeAtIndex:4]]floatValue]].CGColor;
                    layer.shadowOffset = CGSizeMake([[elem.identifier substringWithRange:[match rangeAtIndex:5]]floatValue], [[elem.identifier substringWithRange:[match rangeAtIndex:6]]floatValue]);
                    layer.shadowOpacity = 1;
                    layer.shadowRadius = [[elem.identifier substringWithRange:[match rangeAtIndex:7]]floatValue];
                }
                if (layer) {
                    NSView* myView = [[NSView alloc] initWithFrame:self.bounds];
                    myView.wantsLayer = YES;
                    [myView.layer addSublayer:layer];
                    [self addSubview:myView];
                }
            }
        }
        if (elem.hasChildNodes) {
            [self deepScanDOM:elem inImage:svgImage];
        }
    }
}

-(void)resetContents {
    //[self setSubviews:[NSArray array]];
    //[self deepScanDOM:svgImage.DOMTree inImage:svgImage];
}

-(void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    //NSLog(@"resize");
    [super resizeSubviewsWithOldSize:oldSize];
    [self resetContents];
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize {
    //NSLog(@"resize2");
    [super resizeWithOldSuperviewSize:oldSize];
    [self resetContents];
}

@end
