// RUN: %clang_cc1 -emit-llvm -fobjc-arc -g -triple x86_64-apple-darwin10 %s -o - | FileCheck %s
// Ensure that the line info is making sense:
// ARC cleanups should be at the closing '}'.
@protocol NSObject
@end

@interface NSObject <NSObject> {}
@end

@protocol NSCopying
@end

@protocol NSCoding
@end

typedef double CGFloat;
struct CGRect {};
typedef struct CGRect CGRect;
typedef CGRect NSRect;
NSRect NSMakeRect(CGFloat x, CGFloat y, CGFloat w, CGFloat h);
@interface NSBezierPath : NSObject <NSCopying, NSCoding>
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius;
@end
@implementation AppDelegate : NSObject {}
- (NSBezierPath *)_createBezierPathWithWidth:(CGFloat)width height:(CGFloat)height radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth
{
  NSRect rect = NSMakeRect(0, 0, width, height);
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
  CGFloat pattern[2];
  // CHECK: define {{.*}}_createBezierPathWithWidth
  // CHECK: load {{.*}} %path, align {{.*}}, !dbg ![[RET:[0-9]+]]
  // CHECK: call void @objc_storeStrong{{.*}} !dbg ![[ARC1:[0-9]+]]
  // CHECK: call {{.*}} @objc_autoreleaseReturnValue{{.*}} !dbg ![[ARC2:[0-9]+]]
  // CHECK: ret {{.*}} !dbg ![[ARC2]]
  // CHECK: ![[RET]] = metadata !{i32 [[@LINE+1]], i32 0, metadata !{{.*}}, null}
  return path;
  // CHECK: ![[ARC1]] = metadata !{i32 [[@LINE+2]], i32 0, metadata !{{.*}}, null}
  // CHECK: ![[ARC2]] = metadata !{i32 [[@LINE+1]], i32 0, metadata !{{.*}}, null}
}
@end
