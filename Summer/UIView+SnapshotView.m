#import "UIView+SnapshotView.h"
#import <objc/message.h>

@implementation UIView (SnapshotView)

+ (void)load {
    Method snapshotViewAfterScreenUpdatesMethod =  class_getInstanceMethod(self, @selector(snapshotViewAfterScreenUpdates:));
    Method wwzSnapshotViewAfterScreenUpdatesMethod = class_getInstanceMethod(self, @selector(wwz_snapshotViewAfterScreenUpdates:));
    
    method_exchangeImplementations(snapshotViewAfterScreenUpdatesMethod, wwzSnapshotViewAfterScreenUpdatesMethod);
}

- (UIView *)wwz_snapshotViewAfterScreenUpdates:(BOOL)afterUpdates {
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}]) { // iOS 10
        
        UIGraphicsBeginImageContext(self.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIView *newView = [[UIView alloc] initWithFrame:self.frame];
        newView.layer.contents = (id)image.CGImage;
        
        return newView;
    }else {
        return [self wwz_snapshotViewAfterScreenUpdates:afterUpdates];
    }
}

@end

