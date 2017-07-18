
#import <UIKit/UIKit.h>
#import "ShareSheetCell.h"
@protocol ShareSheetDelegate <NSObject>
@optional
-(void)didSelectIndex:(NSInteger)index;
@end

@interface ShareSheet : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UITableView *view;
    NSArray *listData;
}
-(id)initWithlist:(NSArray *)list height:(CGFloat)height;
- (void)showInView:(UIViewController *)Sview;
@property(nonatomic,assign) id <ShareSheetDelegate> delegate;
@end
