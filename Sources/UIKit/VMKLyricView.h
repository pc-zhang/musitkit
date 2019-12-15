// Copyright © 2016 Venture Media Labs.
//
// This file is part of MusicKit. The full MusicKit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#import "VMKScoreElementContainerView.h"
#import "VMKLyricLayer.h"


@interface VMKLyricView : VMKScoreElementContainerView

- (instancetype)initWithLyricGeometry:(const mxml::LyricGeometry*)lyricGeomerty;

@property(nonatomic) const mxml::LyricGeometry* lyricGeometry;
@property(nonatomic, readonly) VMKLyricLayer* lyricLayer;

@end
