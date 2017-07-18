

#import <UIKit/UIKit.h>
#import "ZhengWenModel.h"

@interface ZhengWenTableViewCell : UITableViewCell<UIActionSheetDelegate>
@property(nonatomic,strong)ZhengWenModel * model;
@property(nonatomic,strong)UIImageView * titleImageView;
@property(nonatomic,strong)UILabel * name;
@property(nonatomic,strong)UIView * nameView;
//@property(nonatomic,strong)UILabel * sucName;


 @end
