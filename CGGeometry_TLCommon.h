//
//  CGGeometry_TLCommon.h
//  TLCommon
//
//  Created by Joshua Bleecher Snyder on 8/31/09.
//

#import <Foundation/Foundation.h>

static inline CGRect CGRectZeroWithSize(CGSize size) {
  return CGRectMake(0.0f, 0.0f, size.width, size.height);
}

static inline CGRect CGRectZeroWithSquareSize(CGFloat size) {
  return CGRectMake(0.0f, 0.0f, size, size);
}

static inline CGRect CGRectZeroWithWidthAndHeight(CGFloat width, CGFloat height) {
  return CGRectMake(0.0f, 0.0f, width, height);
}

static inline CGRect CGRectWithOriginAndSize(CGPoint origin, CGSize size) {
  return CGRectMake(origin.x, origin.y, size.width, size.height);
}

static inline CGRect CGRectWithOriginAndSquareSize(CGPoint origin, CGFloat size) {
  return CGRectMake(origin.x, origin.y, size, size);
}

static inline CGRect CGRectWithXYAndSize(CGFloat xOrigin, CGFloat yOrigin, CGSize size) {
  return CGRectMake(xOrigin, yOrigin, size.width, size.height);
}

static inline CGRect CGRectWithXYAndSquareSize(CGFloat xOrigin, CGFloat yOrigin, CGFloat size) {
  return CGRectMake(xOrigin, yOrigin, size, size);
}

static inline CGRect CGRectWithCenterAndSize(CGPoint center, CGSize size) {
  return CGRectMake(center.x - size.width / 2.0f, center.y - size.height / 2.0f, size.width, size.height);
}

static inline CGRect CGRectWithCenterAndSquareSize(CGPoint center, CGFloat size) {
  return CGRectMake(center.x - size / 2.0f, center.y - size / 2.0f, size, size);
}

static inline CGSize CGSizeMakeSquare(CGFloat widthAndHeight) {
  return CGSizeMake(widthAndHeight, widthAndHeight);
}

static inline CGRect CGRectByAddingXOffset(CGRect originalRect, CGFloat xOffset) {
  return CGRectWithXYAndSize(originalRect.origin.x + xOffset, originalRect.origin.y, originalRect.size);
}

static inline CGRect CGRectByAddingYOffset(CGRect originalRect, CGFloat yOffset) {
  return CGRectWithXYAndSize(originalRect.origin.x, originalRect.origin.y + yOffset, originalRect.size);
}

static inline CGSize CGSizeByAddingHeight(CGSize originalSize, CGFloat extraHeight) {
  return CGSizeMake(originalSize.width, originalSize.height + extraHeight);
}

static inline CGSize CGSizeByAddingWidth(CGSize originalSize, CGFloat extraWidth) {
  return CGSizeMake(originalSize.width + extraWidth, originalSize.height);
}

static inline CGFloat SquaredDistanceBetweenPoints(CGPoint p1, CGPoint p2) {
  CGFloat deltaX = p1.x - p2.x;
  CGFloat deltaY = p1.y - p2.y;
  return (deltaX * deltaX) + (deltaY * deltaY);
}

static inline CGFloat DistanceBetweenPoints(CGPoint p1, CGPoint p2) {
  return sqrt(SquaredDistanceBetweenPoints(p1, p2));
}

static inline CGPoint CenterOfRect(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline double AngleBetweenPoints(CGPoint p, CGPoint q) {
  CGPoint deltaVector = CGPointMake(p.x - q.x, p.y - q.y);
  double angle = atan(deltaVector.y / deltaVector.x) + (deltaVector.x < 0 ? M_PI : 0);
  return angle;
}

static inline CGPoint MidpointBetweenPoints(CGPoint p, CGPoint q) {
  return CGPointMake((p.x + q.x) / 2.0f, (p.y + q.y) / 2.0f);
}

static inline CGPoint PointMinusPoint(CGPoint p, CGPoint q) {
  return CGPointMake(p.x - q.x, p.y - q.y);
}

static inline CGPoint PointPlusPoint(CGPoint p, CGPoint q) {
  return CGPointMake(p.x + q.x, p.y + q.y);
}

static inline CGFloat OffsetToCenterFloatInFloat(CGFloat smallerValue, CGFloat largerValue) {
  return (largerValue - smallerValue) / 2.0f;
}
