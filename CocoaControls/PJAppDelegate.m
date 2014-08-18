//
//  PJAppDelegate.m
//  CocoaControls
//
//  Created by 平江 on 14-8-18.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "PJAppDelegate.h"

@interface PJAppDelegate()

- (void)loadCocoaControlWindows;
- (NSWindowController*)createWindowController:(NSDictionary *)dict;
- (NSWindowController*)getWindowController:(NSString *)name;

- (void)onDoubleClickedRow:(id) sender;

@end

@implementation PJAppDelegate

- (void)loadCocoaControlWindows {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"windows" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSLog(@"loading %@-%@ %@", dict[@"name"], dict[@"version"], dict[@"description"]);
    
    _windowsArray = dict[@"windows"];
    for (NSDictionary *windowDict in _windowsArray) {
        [_windowNames addObject:windowDict[@"name"]];
    }
}
- (NSWindowController*)createWindowController:(NSDictionary *)dict {
    NSString *title = [NSString stringWithFormat:@"%@ - %@", dict[@"name"], dict[@"description"]];
    NSLog(@"Create window controller %@", title);
    NSWindowController* wc = [[NSClassFromString(dict[@"class"]) alloc] init];
    [wc.window setTitle:title];
    [_windowControllers setObject:wc forKey:dict[@"name"]];
    
    return wc;
}

- (NSWindowController*)getWindowController:(NSString *)name {
    id foundWC = [_windowControllers objectForKey:name];
    if (foundWC) {
        return foundWC;
    }
    
    NSUInteger found = [_windowsArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"name"] isEqualToString:name]) {
            return YES;
        }
        
        return NO;
    }];
    
    if (found != NSNotFound) {
        NSDictionary *windowDict = _windowsArray[found];
        return [self createWindowController: windowDict];
    }
    
    return nil;
}

- (void)onDoubleClickedRow:(id) sender {
    NSUInteger row = [self.outlineView clickedRow];
    NSUInteger col = [self.outlineView clickedColumn];
    id colView = [self.outlineView viewAtColumn:col row:row makeIfNecessary:NO];
    //NSLog(@"row: %ld, col: %ld, sender = %@", row, col, colView);
    NSTableCellView *cell = (NSTableCellView *)colView;
    if (cell) {
        NSString *selectedName = [cell.textField stringValue];
        //NSLog(@"Prepare for show window %@", selectedName);
        NSWindowController *wc = [self getWindowController:selectedName];
        [wc showWindow:self];
    }
}

- (void)awakeFromNib {
    if (!_windowControllers) {
        _windowControllers = [[NSMutableDictionary alloc] init];
        _windowNames = [[NSMutableArray alloc] init];
        [self loadCocoaControlWindows];
    }
    
    [self.outlineView setDoubleAction:@selector(onDoubleClickedRow:)];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#pragma mark -
#pragma mark OutlineView DataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    //NSLog(@"OutlineView DataSource numberOfChildrenOfItem %@, %ld", item, [_windowNames count]);
    if (!item) {
        return 1;
    }
    
    if ([item isEqualToString:@"Windows"]) {
        return [_windowNames count];
    }
    
    return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    //NSLog(@"OutlineView DataSource child %@", item);
    if (!item) {
        return @"Windows";
    }
    
    if ([item isEqualToString:@"Windows"]) {
        return [_windowNames objectAtIndex:index];
    }
    
    return nil;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    //NSLog(@"OutlineView DataSource isItemExpandable %@", item);
    if (!item || [item isEqualToString:@"Windows"]) {
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark OutlineView Delegate
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    //NSLog(@"OutlineView Delegate viewForTableColumn %@", item);
    NSInteger level = [outlineView levelForItem:item];
    NSTableCellView *cell = nil;
    if (level > 0) {
        cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:outlineView];
        [cell.textField setStringValue:item];
    } else {
        cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:outlineView];
        [cell.textField setStringValue:@"Windows"];
    }
    
    return cell;
}


- (IBAction)closeAllControlWindow:(id)sender {
    for (NSString *key in _windowControllers) {
        NSWindowController *wc = _windowControllers[key];
        [wc close];
    }
}
@end
