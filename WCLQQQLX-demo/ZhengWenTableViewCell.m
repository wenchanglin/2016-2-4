
#import "ZhengWenTableViewCell.h"


@implementation ZhengWenTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createCell];
    }
    return self;
}
-(void)setModel:(ZhengWenModel *)model
{
    _model = model;
    NSString * url = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],model.ImgUrl];
    NSLog(@"图片:%@",url);
    [_titleImageView sd_setImageWithURL:[NSURL URLWithString:url]];
     _name.text = model.FormulaName;
    //_sucName.text = model.Introduction;
    
}
-(void)createCell
{
    //图像
    _titleImageView  = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, [UIScreen mainScreen].bounds.size.width-30, ([UIScreen mainScreen].bounds.size.width-30)/ 800 * 533)];
    _titleImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_titleImageView];
    _nameView = [[UIView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleImageView.frame)+1,[UIScreen mainScreen].bounds.size.width-30, 35)];
    [self.contentView addSubview:_nameView];
    _nameView.backgroundColor = [UIColor colorWithHexString:@"#282828"];
    //名字
    _name = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_titleImageView.frame)+1,[UIScreen mainScreen].bounds.size.width-30, 35)];
    [self.contentView addSubview:_name];
    _name.font = [UIFont systemFontOfSize:13.0f];
    //_name.textAlignment = NSTextAlignmentCenter;
    _name.textColor = [UIColor colorWithHexString:@"#b4b4b4"];
}
@end
