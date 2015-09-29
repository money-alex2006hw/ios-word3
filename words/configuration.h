//
//  configuration.h
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//


//  admob
#define     MY_BANNER_UNIT_ID           @"ca-app-pub-1174246192301173/3524246041"
#define     MY_BANNER_UNIT_ID_IPAD      @"ca-app-pub-1174246192301173/3524246041"

//  maximum 9
#define     WORDS_PER_GAME              8

//  remove chars powerup
#define     WORD_TABLE_REMOVE_CHARS     12

//  coins
#ifdef FREE_VERSION
#define     COINS_START_DEFAULT         800
#else
#define     COINS_START_DEFAULT         1000
#endif

#define     COINS_VIDEO_MIN_VIEWS       3
#define     COINS_REWARD_FOR_VIEWS      150
#define     COST_HINT                   50
#define     COST_REMOVE_LETTERS         80
#define     COST_RESOLVE_GAME           300
#define     COINS_REWARD_FOUND_WORD     1
#define     COINS_REWARD_SHARE          150

//  game points
#define     GAME_TOTAL_POINTS               15000
#define     GAME_SESSION_MAX_POINTS         1500.0
#define     GAME_SESSION_MIN_POINTS         100.0
#define     GAME_SESSION_ZERO_POINTS_AT     360.0
#define     GAME_SESSION_TIME1              80.0
#define     GAME_SESSION_TIME1_MINUS_P      700.0

//  star images
#define     STAR_IMAGES_COUNT           5

#define     STORE_BUNDLE_IN_APP_1       @"com.appfresh.swingtest.words.coins1"
#define     STORE_BUNDLE_IN_APP_2       @"com.appfresh.swingtest.words.coins2"
#define     STORE_BUNDLE_IN_APP_3       @"com.appfresh.swingtest.words.coins3"
#define     STORE_BUNDLE_IN_APP_4       @"com.appfresh.swingtest.words.coins4"

#define     STORE_BUNDLE_IN_APP_1_COINS       1000
#define     STORE_BUNDLE_IN_APP_2_COINS       4000
#define     STORE_BUNDLE_IN_APP_3_COINS       8000
#define     STORE_BUNDLE_IN_APP_4_COINS       20000

#define     STORE_BUNDLE_IN_APP_1_TITLE     NSLocalizedString(@"coins1", nil)
#define     STORE_BUNDLE_IN_APP_2_TITLE     NSLocalizedString(@"coins2", nil)
#define     STORE_BUNDLE_IN_APP_3_TITLE     NSLocalizedString(@"coins3", nil)
#define     STORE_BUNDLE_IN_APP_4_TITLE     NSLocalizedString(@"coins4", nil)

#define     STORE_BUNDLE_IN_APP_1_DESCRIPTION     NSLocalizedString(@"coinsDesc1", nil)
#define     STORE_BUNDLE_IN_APP_2_DESCRIPTION     NSLocalizedString(@"coinsDesc2", nil)
#define     STORE_BUNDLE_IN_APP_3_DESCRIPTION     NSLocalizedString(@"coinsDesc3", nil)
#define     STORE_BUNDLE_IN_APP_4_DESCRIPTION     NSLocalizedString(@"coinsDesc4", nil)


//  popup pay coins type
#define     PAY_COINS_POPUP_TYPE_HINT           1
#define     PAY_COINS_POPUP_TYPE_REMOVE_CHARS   2
#define     PAY_COINS_POPUP_TYPE_RESOLVE_GAME   3
#define     PAY_COINS_POPUP_TYPE_SKIP_QUEST     4

//  theme colors
#define     THEME_COLOR_RED             [UIColor colorWithRed:255.0/255 green:143.0/255 blue:143.0/255 alpha:1.0]
#define     THEME_COLOR_GRAY            [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0]
#define     THEME_COLOR_GRAY_BACKGROUND [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]
#define     THEME_COLOR_GRAY_TEXT       [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]
#define     THEME_COLOR_GRAY_LIGHT      [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]
#define     THEME_COLOR_BLUE            [UIColor colorWithRed:19.0/255 green:175.0/255 blue:207.0/255 alpha:1.0]

//  share show reward coins probability
#define     MG_SHARE_SHOW_SHARE_REWARD_PROBABILITY  0.3f

//  Animation interval timer on game footer buttons
#define     TIMER_ANIMATION_FOOTER_BUTTONS      20