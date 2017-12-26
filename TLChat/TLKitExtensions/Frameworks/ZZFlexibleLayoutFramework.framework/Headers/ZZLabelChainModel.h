//
//  ZZLabelChainModel.h
//  zhuanzhuan
//
//  Created by 李伯坤 on 2017/10/24.
//  Copyright © 2017年 转转. All rights reserved.
//

#import "ZZBaseViewChainModel.h"

@class ZZLabelChainModel;
@interface ZZLabelChainModel : ZZBaseViewChainModel <ZZLabelChainModel *>

ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ text)(NSString *text);
ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ font)(UIFont *font);
ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ textColor)(UIColor *textColor);
ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ attributedText)(NSAttributedString *attributedText);

ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ textAlignment)(NSTextAlignment textAlignment);
ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ numberOfLines)(NSInteger numberOfLines);
ZZFLEX_CHAIN_PROPERTY ZZLabelChainModel *(^ lineBreakMode)(NSLineBreakMode lineBreakMode);

@end

ZZFLEX_EX_INTERFACE(UILabel, ZZLabelChainModel)
