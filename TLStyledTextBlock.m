//
//  TLStyledTextBlock.m
//  TLCommon
//
//  Created by Joshua Bleecher Snyder on 10/26/09.
//

#import "TLStyledTextBlock.h"
#import "TLStyledTextFragment.h"
#import "TLStyledTextStyle.h"
#import "NSString_TLCommon.h"
#import "CGGeometry_TLCommon.h"
#import "TLMacros.h"

#pragma mark -

@interface TLStyledTextBlock ()

- (CGFloat)maxFontHeightInLine:(NSArray *)line;

@property(nonatomic, retain, readwrite) NSMutableArray *lines;
@property(nonatomic, retain, readwrite) NSMutableDictionary *originalFragmentForNewFragment;
@property(nonatomic, retain, readwrite) NSMutableDictionary *newFragmentsForOriginalFragment;
@property(nonatomic, assign, readwrite) CGFloat lineWidth;

@end


#pragma mark -

@implementation TLStyledTextBlock

@synthesize lines;
@synthesize lineWidth;
@synthesize originalFragmentForNewFragment;
@synthesize newFragmentsForOriginalFragment;

- (id)init {
  if(self = [super init]) {
    self.lines = [NSMutableArray array];
    self.originalFragmentForNewFragment = [NSMutableDictionary dictionary];
    self.newFragmentsForOriginalFragment = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (TLStyledTextBlock *)blockWithFragments:(NSArray *)textFragments lineWidth:(CGFloat)width {
  TLStyledTextBlock *block = [[[TLStyledTextBlock alloc] init] autorelease];
  block.lineWidth = width;
  
  NSMutableArray *currentLine = [NSMutableArray array];
  CGFloat currentLineWidth = block.lineWidth;  
  for(TLStyledTextFragment *fragment in textFragments) {
    TLDebugLog(@"fragment %@", fragment);
    NSArray *subfragments = [fragment subfragmentsRenderableOnLinesOfWidth:block.lineWidth firstLineWidth:currentLineWidth];
    TLDebugLog(@"subfragments %@", subfragments);
    NSUInteger numberOfSubfragments = [subfragments count];
    for(NSUInteger i = 0; i < numberOfSubfragments; i++) {
      TLStyledTextFragment *subfragment = [subfragments objectAtIndex:i];
      if(![subfragment isKindOfClass:[NSNull class]]) {
        [currentLine addObject:subfragment];
        currentLineWidth -= [subfragment width];
        [block.originalFragmentForNewFragment setObject:fragment forKey:[NSValue valueWithPointer:subfragment]];
      }
      if(i < numberOfSubfragments - 1) {
        // on the last line, wait for the first line of the next round to make a new line,
        // so they can share
        [block.lines addObject:currentLine];
        currentLine = [NSMutableArray array];
        currentLineWidth = block.lineWidth;
      }
    }
    [block.newFragmentsForOriginalFragment setObject:subfragments forKey:[NSValue valueWithPointer:fragment]];
  }
  // pick up the very last line which would otherwise be forgotten
  [block.lines addObject:currentLine];

  // triming trailing whitespace on all lines
  TLDebugLog(@"lines %@", block.lines);
  for(NSArray *line in block.lines) {
    TLDebugLog(@"line %@", line);
    TLStyledTextFragment *lastFragment = [line lastObject];
    lastFragment.text = [lastFragment.text stringByTrimmingSuffixCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  }
  
  return block;
}

- (CGFloat)maxFontHeightInLine:(NSArray *)line {
  CGFloat maxFontHeight = 0.0f;
  for(TLStyledTextFragment *fragment in line) {
    maxFontHeight = MAX(maxFontHeight, [fragment.style.font leading]);
  }
  return maxFontHeight;
}

- (CGFloat)height {
  CGFloat height = 0.0f;
  for(NSArray *line in self.lines) {
    height += [self maxFontHeightInLine:line];
  }
  return height;
}

- (void)renderAtPoint:(CGPoint)point textAlignment:(UITextAlignment)textAlignment {
  CGFloat runningYOffset = 0.0f;
  for(NSArray *line in self.lines) {
    CGFloat maxFontHeight = [self maxFontHeightInLine:line];
    CGFloat runningXOffset = 0.0f;
    // first pass: lay out the line and calculate the total width
    for(TLStyledTextFragment *fragment in line) {
      CGFloat fragmentWidth = [fragment width];
      fragment.renderRect = CGRectMake(point.x + runningXOffset,
                                       point.y + runningYOffset + OffsetToCenterFloatInFloat([fragment.style.font leading], maxFontHeight),
                                       fragmentWidth,
                                       maxFontHeight);
      runningXOffset += fragmentWidth;
    }
    // second pass: move the whole line around to get the overall text alignment correct and then actually render
    CGFloat textAlignmentXOffset = 0;
    switch(textAlignment) {
      case UITextAlignmentLeft:;
        textAlignmentXOffset = 0;
        break;
      case UITextAlignmentRight:;
        textAlignmentXOffset = self.lineWidth - runningXOffset;
        break;
      case UITextAlignmentCenter:;
        textAlignmentXOffset = floorf(OffsetToCenterFloatInFloat(runningXOffset, self.lineWidth));
        break;
    }
    for(TLStyledTextFragment *fragment in line) {
      fragment.renderRect = CGRectByAddingXOffset(fragment.renderRect, textAlignmentXOffset);
      [fragment render];
    }
    runningYOffset += maxFontHeight;
  }
}

- (TLStyledTextFragment *)fragmentAtPoint:(CGPoint)pointWithinTextBlock {
  // ick...do an exhaustive search
  for(NSArray *line in self.lines) {
    for(TLStyledTextFragment *fragment in line) {
      if(CGRectContainsPoint(fragment.renderRect, pointWithinTextBlock)) {
        return fragment;
      }
    }
  }  
  return nil;
}

- (NSArray *)siblingFragmentsForFragment:(TLStyledTextFragment *)fragment {
  TLStyledTextFragment *originalFragment = [self originalFragmentForFragment:fragment];
  NSArray *newFragments = [self.newFragmentsForOriginalFragment objectForKey:[NSValue valueWithPointer:originalFragment]];
  return newFragments;
}

- (TLStyledTextFragment *)originalFragmentForFragment:(TLStyledTextFragment *)fragment {
  return [self.originalFragmentForNewFragment objectForKey:[NSValue valueWithPointer:fragment]];
}


- (void)dealloc {
  [lines release];
  lines = nil;
  
  [originalFragmentForNewFragment release];
  originalFragmentForNewFragment = nil;
  
  [newFragmentsForOriginalFragment release];
  newFragmentsForOriginalFragment = nil;
  
  [super dealloc];
}

@end
