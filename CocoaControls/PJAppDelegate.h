//
//  PJAppDelegate.h
//  CocoaControls
//
//  Created by 平江 on 14-8-18.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PJAppDelegate : NSObject <NSApplicationDelegate,
    NSOutlineViewDataSource, NSOutlineViewDelegate> {
    NSArray *_windowsArray;
    NSMutableArray *_windowNames;
    NSMutableDictionary *_windowControllers;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSOutlineView *outlineView;

- (IBAction)closeAllControlWindow:(id)sender;

@end
