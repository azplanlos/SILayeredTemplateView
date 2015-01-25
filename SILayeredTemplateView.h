//
//  SILayeredTemplateView.h
//  Photoroute
//
//  Created by Andreas Zöllner on 17.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SVGKit/SVGKit.h>
#import <SVGKit/CALayerExporter.h>

@interface SILayeredTemplateView : NSView {
    SVGKImage* svgImage;
    __strong NSMutableArray* svgLayers;
    NSSize originalSize;
    BOOL inResize;
}

@property (nonatomic, strong) NSDictionary* attributes;
@property (strong) NSMutableArray *viewArray;

-(void)loadSVGFromURL:(NSURL*)svgURL;

@end
